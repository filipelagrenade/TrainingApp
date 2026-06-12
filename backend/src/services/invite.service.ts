import type { Prisma } from "@prisma/client";

import { AppError } from "../lib/errors";
import { prisma } from "../lib/prisma";
import { createNotification } from "./notification.service";

const INVITE_TTL_MS = 24 * 60 * 60 * 1000;

export const createWorkoutInvite = async (
  fromUserId: string,
  input: {
    toUserId: string;
    fromSessionId?: string;
    programWorkoutId?: string;
    templateId?: string;
    workoutTitle: string;
  },
) => {
  if (fromUserId === input.toUserId) {
    throw new AppError(400, "INVALID_INVITE", "You cannot invite yourself.");
  }

  const isFollowing = await prisma.follow.findUnique({
    where: {
      followerId_followingId: {
        followerId: fromUserId,
        followingId: input.toUserId,
      },
    },
  });

  if (!isFollowing) {
    throw new AppError(403, "NOT_FOLLOWING", "You must follow this user to invite them.");
  }

  let exercises: Prisma.InputJsonValue[] = [];

  if (input.fromSessionId) {
    const session = await prisma.workoutSession.findFirst({
      where: { id: input.fromSessionId, userId: fromUserId },
      select: { savedDraft: true },
    });
    if (session?.savedDraft && typeof session.savedDraft === "object") {
      const draft = session.savedDraft as { exercises?: Prisma.InputJsonValue[] };
      exercises = draft.exercises ?? [];
    }
  } else if (input.programWorkoutId) {
    const workout = await prisma.programWorkout.findUnique({
      where: { id: input.programWorkoutId },
      include: {
        exercises: {
          include: { exercise: true },
          orderBy: { orderIndex: "asc" },
        },
      },
    });
    exercises = (workout?.exercises ?? []).map((e) => ({
      exerciseId: e.exerciseId,
      exerciseName: e.exercise.name,
      sets: e.sets,
      repMin: e.repMin,
      repMax: e.repMax,
      restSeconds: e.restSeconds,
    }));
  } else if (input.templateId) {
    const template = await prisma.workoutTemplate.findUnique({
      where: { id: input.templateId },
      include: {
        exercises: {
          include: { exercise: true },
          orderBy: { orderIndex: "asc" },
        },
      },
    });
    exercises = (template?.exercises ?? []).map((e) => ({
      exerciseId: e.exerciseId,
      exerciseName: e.exercise.name,
      sets: e.sets,
      repMin: e.repMin,
      repMax: e.repMax,
      restSeconds: e.restSeconds,
    }));
  }

  const fromUser = await prisma.user.findUnique({
    where: { id: fromUserId },
    select: { displayName: true },
  });

  const invite = await prisma.workoutInvite.create({
    data: {
      fromUserId,
      toUserId: input.toUserId,
      fromSessionId: input.fromSessionId,
      programWorkoutId: input.programWorkoutId,
      templateId: input.templateId,
      workoutTitle: input.workoutTitle,
      exercises,
      expiresAt: new Date(Date.now() + INVITE_TTL_MS),
    },
  });

  await createNotification({
    userId: input.toUserId,
    type: "WORKOUT_INVITE",
    title: `${fromUser?.displayName ?? "Someone"} invited you to train`,
    body: input.workoutTitle,
    payload: { inviteId: invite.id },
  });

  return invite;
};

export const getPendingInvites = async (userId: string) =>
  prisma.workoutInvite.findMany({
    where: {
      toUserId: userId,
      status: "PENDING",
      expiresAt: { gt: new Date() },
    },
    include: {
      fromUser: {
        select: { id: true, displayName: true },
      },
    },
    orderBy: { createdAt: "desc" },
  });

export const acceptInvite = async (userId: string, inviteId: string) => {
  const invite = await prisma.workoutInvite.findFirst({
    where: {
      id: inviteId,
      toUserId: userId,
      status: "PENDING",
    },
  });

  if (!invite) {
    throw new AppError(404, "INVITE_NOT_FOUND", "That invite could not be found.");
  }

  if (invite.expiresAt < new Date()) {
    await prisma.workoutInvite.update({
      where: { id: inviteId },
      data: { status: "EXPIRED" },
    });
    throw new AppError(410, "INVITE_EXPIRED", "This invite has expired.");
  }

  const exerciseData = invite.exercises as Array<{
    exerciseId: string;
    exerciseName: string;
    sets: number;
    repMin: number;
    repMax: number;
    restSeconds: number;
  }>;

  const draft = {
    title: invite.workoutTitle,
    exercises: exerciseData.map((e) => ({
      exerciseId: e.exerciseId,
      exerciseName: e.exerciseName,
      sets: Array.from({ length: e.sets }, (_, i) => ({
        setNumber: i + 1,
        completed: false,
      })),
      repMin: e.repMin,
      repMax: e.repMax,
      restSeconds: e.restSeconds,
    })),
    notes: null,
  };

  const [session] = await prisma.$transaction([
    prisma.workoutSession.create({
      data: {
        userId,
        title: invite.workoutTitle,
        entryType: "QUICK",
        status: "IN_PROGRESS",
        inviteId: invite.id,
        savedDraft: draft as unknown as Prisma.InputJsonValue,
        originDraft: draft as unknown as Prisma.InputJsonValue,
      },
    }),
    prisma.workoutInvite.update({
      where: { id: inviteId },
      data: { status: "ACCEPTED" },
    }),
  ]);

  return { sessionId: session.id };
};

export const declineInvite = async (userId: string, inviteId: string) => {
  const invite = await prisma.workoutInvite.findFirst({
    where: { id: inviteId, toUserId: userId, status: "PENDING" },
  });

  if (!invite) {
    throw new AppError(404, "INVITE_NOT_FOUND", "That invite could not be found.");
  }

  await prisma.workoutInvite.update({
    where: { id: inviteId },
    data: { status: "DECLINED" },
  });
};

export const getWorkoutComparison = async (userId: string, sessionId: string) => {
  const session = await prisma.workoutSession.findFirst({
    where: { id: sessionId, userId, status: "COMPLETED" },
    include: {
      exercises: {
        include: { sets: { orderBy: { setNumber: "asc" } } },
      },
    },
  });

  if (!session?.inviteId) {
    throw new AppError(404, "NO_COMPARISON", "This workout is not linked to an invite.");
  }

  const invite = await prisma.workoutInvite.findUnique({
    where: { id: session.inviteId },
  });

  if (!invite) {
    throw new AppError(404, "INVITE_NOT_FOUND", "Invite not found.");
  }

  const mateSessionQuery = invite.fromUserId === userId
    ? { inviteId: invite.id, userId: invite.toUserId }
    : { id: invite.fromSessionId ?? undefined, userId: invite.fromUserId };

  const mateSession = await prisma.workoutSession.findFirst({
    where: { ...mateSessionQuery, status: "COMPLETED" },
    include: {
      user: { select: { displayName: true } },
      exercises: {
        include: { sets: { orderBy: { setNumber: "asc" } } },
      },
    },
  });

  if (!mateSession) {
    throw new AppError(404, "MATE_NOT_DONE", "Your mate hasn't completed their workout yet.");
  }

  type ExStats = { volume: number; estimatedOneRepMax: number | null; name: string };
  const computeExerciseStats = (exercises: typeof session.exercises) => {
    const map = new Map<string, ExStats>();
    for (const ex of exercises) {
      if (!ex.exerciseId) continue;
      let volume = 0;
      let bestE1rm: number | null = null;
      for (const set of ex.sets) {
        if (set.weight && set.reps) {
          volume += set.weight * set.reps;
          const e1rm = set.weight * (1 + set.reps / 30);
          if (bestE1rm === null || e1rm > bestE1rm) bestE1rm = e1rm;
        }
      }
      map.set(ex.exerciseId, { volume, estimatedOneRepMax: bestE1rm, name: ex.exerciseName });
    }
    return map;
  };

  const getPreviousStats = async (targetUserId: string, exerciseIds: string[], beforeDate: Date) => {
    const map = new Map<string, { volume: number; estimatedOneRepMax: number | null }>();
    for (const exerciseId of exerciseIds) {
      const prev = await prisma.workoutExercise.findFirst({
        where: {
          exerciseId,
          session: {
            userId: targetUserId,
            status: "COMPLETED",
            completedAt: { lt: beforeDate },
          },
        },
        include: { sets: true },
        orderBy: { session: { completedAt: "desc" } },
      });
      if (prev) {
        let vol = 0;
        let best: number | null = null;
        for (const set of prev.sets) {
          if (set.weight && set.reps) {
            vol += set.weight * set.reps;
            const e1rm = set.weight * (1 + set.reps / 30);
            if (best === null || e1rm > best) best = e1rm;
          }
        }
        map.set(exerciseId, { volume: vol, estimatedOneRepMax: best });
      }
    }
    return map;
  };

  const myStats = computeExerciseStats(session.exercises);
  const mateStats = computeExerciseStats(mateSession.exercises);

  const allExerciseIds = [...new Set([...myStats.keys(), ...mateStats.keys()])];

  const [myPrev, matePrev] = await Promise.all([
    getPreviousStats(userId, allExerciseIds, session.startedAt),
    getPreviousStats(mateSession.userId, allExerciseIds, mateSession.startedAt),
  ]);

  const pctChange = (current: number, previous: number | undefined) => {
    if (!previous || previous === 0) return null;
    return Number((((current - previous) / previous) * 100).toFixed(1));
  };

  const exercises = allExerciseIds.map((exerciseId) => {
    const my = myStats.get(exerciseId);
    const mate = mateStats.get(exerciseId);
    const myP = myPrev.get(exerciseId);
    const mateP = matePrev.get(exerciseId);

    return {
      exerciseName: my?.name ?? mate?.name ?? "Unknown",
      myVolumeChange: my ? pctChange(my.volume, myP?.volume) : null,
      mateVolumeChange: mate ? pctChange(mate.volume, mateP?.volume) : null,
      myE1rmChange: my?.estimatedOneRepMax ? pctChange(my.estimatedOneRepMax, myP?.estimatedOneRepMax ?? undefined) : null,
      mateE1rmChange: mate?.estimatedOneRepMax ? pctChange(mate.estimatedOneRepMax, mateP?.estimatedOneRepMax ?? undefined) : null,
    };
  });

  return {
    mySession: { completedAt: session.completedAt?.toISOString() ?? null },
    mateSession: { completedAt: mateSession.completedAt?.toISOString() ?? null, displayName: mateSession.user.displayName },
    exercises,
  };
};
