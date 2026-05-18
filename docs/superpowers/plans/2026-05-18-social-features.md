# Social Features Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add kudos/reactions to the activity feed, program copying from friend profiles, and a train-with-mates feature (workout invites with post-workout % comparison).

**Architecture:** Five phases built in dependency order: (1) Kudos reactions on feed events, (2) Copy programs from friend profiles, (3) In-app notification infrastructure, (4) Workout invites, (5) Post-workout comparison. Each phase adds a Prisma migration, backend service+routes, frontend API client+types, and UI components.

**Tech Stack:** Prisma + PostgreSQL, Express + Zod, Next.js + TanStack Query + shadcn/ui + Tailwind, lucide-react icons.

**Spec:** `docs/superpowers/specs/2026-05-18-social-features-design.md`

---

## File Map

### Phase 1: Kudos/Reactions
| Action | File |
|--------|------|
| Modify | `backend/prisma/schema.prisma` — add `Reaction` model, update `ActivityEvent` + `User` relations |
| Modify | `backend/src/services/social.service.ts` — add `addReaction`, `removeReaction`, update `getFeed` |
| Modify | `backend/src/routes/social.routes.ts` — add reaction routes |
| Modify | `web/src/lib/types.ts` — extend `ActivityEvent` with reactions |
| Modify | `web/src/lib/api-client.ts` — add reaction API functions |
| Modify | `web/src/components/social/social-screen.tsx` — add reaction bar to feed events |

### Phase 2: Copy Programs
| Action | File |
|--------|------|
| Modify | `backend/prisma/schema.prisma` — add `allowCopy` to `Program` |
| Modify | `backend/src/services/program.service.ts` — add `copyProgram` |
| Modify | `backend/src/routes/programs.routes.ts` — add copy route |
| Modify | `backend/src/services/profile.service.ts` — include copyable programs |
| Modify | `web/src/lib/types.ts` — add `allowCopy` to `Program`, `copyablePrograms` to `ProfileView` |
| Modify | `web/src/lib/api-client.ts` — add `copyProgram`, `updateProgramAllowCopy` |
| Modify | `web/src/components/profile/profile-screen.tsx` — add copyable programs section |
| Modify | `web/src/components/programs/program-detail-screen.tsx` — add allowCopy toggle |

### Phase 3: Notifications
| Action | File |
|--------|------|
| Modify | `backend/prisma/schema.prisma` — add `Notification` model |
| Create | `backend/src/services/notification.service.ts` |
| Create | `backend/src/routes/notification.routes.ts` |
| Modify | `backend/src/app.ts` — mount notification router |
| Modify | `web/src/lib/types.ts` — add `Notification` type |
| Modify | `web/src/lib/api-client.ts` — add notification endpoints |
| Create | `web/src/components/notifications/notification-sheet.tsx` |
| Modify | `web/src/components/layout/app-shell.tsx` — add notification bell |

### Phase 4: Workout Invites
| Action | File |
|--------|------|
| Modify | `backend/prisma/schema.prisma` — add `WorkoutInvite` model, add `inviteId` to `WorkoutSession` |
| Create | `backend/src/services/invite.service.ts` |
| Modify | `backend/src/routes/workouts.routes.ts` — add invite routes |
| Modify | `web/src/lib/types.ts` — add `WorkoutInvite` type |
| Modify | `web/src/lib/api-client.ts` — add invite endpoints |
| Create | `web/src/components/workouts/invite-mate-sheet.tsx` |
| Modify | `web/src/components/workouts/workout-editor.tsx` — add invite button |

### Phase 5: Post-Workout Comparison
| Action | File |
|--------|------|
| Modify | `backend/src/services/invite.service.ts` — add `getWorkoutComparison` |
| Modify | `backend/src/routes/workouts.routes.ts` — add comparison route |
| Modify | `web/src/lib/types.ts` — add `WorkoutComparison` type |
| Modify | `web/src/lib/api-client.ts` — add comparison endpoint |
| Create | `web/src/components/workouts/workout-comparison-sheet.tsx` |
| Modify | `web/src/components/workouts/workout-editor.tsx` — add comparison trigger after completion |

---

## Task 1: Reactions — Prisma Schema + Migration

**Files:**
- Modify: `backend/prisma/schema.prisma`

- [ ] **Step 1: Add Reaction model to schema**

Add at the end of `backend/prisma/schema.prisma` (after line 593, the closing brace of `ActivityEvent`):

```prisma
model Reaction {
  id              String        @id @default(cuid())
  activityEventId String
  userId          String
  emoji           String
  createdAt       DateTime      @default(now())

  activityEvent   ActivityEvent @relation(fields: [activityEventId], references: [id], onDelete: Cascade)
  user            User          @relation("reactions", fields: [userId], references: [id], onDelete: Cascade)

  @@unique([activityEventId, userId, emoji])
  @@index([activityEventId])
}
```

Add to the `ActivityEvent` model (after `user` relation, line 592):
```prisma
  reactions Reaction[]
```

Add to the `User` model (after `challengeEntries` on line 145):
```prisma
  reactions            Reaction[]           @relation("reactions")
```

- [ ] **Step 2: Generate and apply migration**

Run:
```powershell
Set-Location C:\Users\filip\Desktop\TrainingApp\backend
npx prisma migrate dev --name add_reactions
```

Expected: Migration created, Prisma client regenerated.

- [ ] **Step 3: Verify schema compiles**

Run:
```powershell
npx prisma validate
```

Expected: "The schema at `prisma/schema.prisma` is valid."

- [ ] **Step 4: Commit**

```powershell
git add backend/prisma/schema.prisma backend/prisma/migrations/
git commit -m "feat: add Reaction model for activity feed kudos"
```

---

## Task 2: Reactions — Backend Service + Routes

**Files:**
- Modify: `backend/src/services/social.service.ts`
- Modify: `backend/src/routes/social.routes.ts`

- [ ] **Step 1: Add reaction service functions**

Add to the end of `backend/src/services/social.service.ts` (before the closing of the file, after `searchUsers`):

```typescript
const VALID_EMOJIS = ["fire", "flex", "clap", "trophy", "heart"] as const;

export const addReaction = async (userId: string, activityEventId: string, emoji: string) => {
  if (!VALID_EMOJIS.includes(emoji as typeof VALID_EMOJIS[number])) {
    throw new AppError(400, "INVALID_EMOJI", `Emoji must be one of: ${VALID_EMOJIS.join(", ")}`);
  }

  const event = await prisma.activityEvent.findUnique({
    where: { id: activityEventId },
  });

  if (!event) {
    throw new AppError(404, "EVENT_NOT_FOUND", "That activity event could not be found.");
  }

  return prisma.reaction.upsert({
    where: {
      activityEventId_userId_emoji: {
        activityEventId,
        userId,
        emoji,
      },
    },
    create: { activityEventId, userId, emoji },
    update: {},
  });
};

export const removeReaction = async (userId: string, activityEventId: string, emoji: string) => {
  await prisma.reaction.deleteMany({
    where: { activityEventId, userId, emoji },
  });
};
```

- [ ] **Step 2: Update getFeed to include reaction aggregates**

Replace the existing `getFeed` function in `backend/src/services/social.service.ts` (lines 50-69):

```typescript
export const getFeed = async (userId: string) => {
  const follows = await prisma.follow.findMany({
    where: { followerId: userId },
  });

  const events = await prisma.activityEvent.findMany({
    where: {
      userId: {
        in: [userId, ...follows.map((follow) => follow.followingId)],
      },
    },
    include: {
      user: true,
      reactions: true,
    },
    orderBy: { createdAt: "desc" },
    take: 20,
  });

  return events.map((event) => {
    const reactionMap = new Map<string, { count: number; userReacted: boolean }>();
    for (const reaction of event.reactions) {
      const existing = reactionMap.get(reaction.emoji) ?? { count: 0, userReacted: false };
      existing.count += 1;
      if (reaction.userId === userId) existing.userReacted = true;
      reactionMap.set(reaction.emoji, existing);
    }

    return {
      ...event,
      reactions: Array.from(reactionMap.entries()).map(([emoji, data]) => ({
        emoji,
        count: data.count,
        userReacted: data.userReacted,
      })),
    };
  });
};
```

- [ ] **Step 3: Add reaction routes**

Add imports to `backend/src/routes/social.routes.ts` (update the import block at line 6):

```typescript
import {
  addReaction,
  followUser,
  getFeed,
  getLeaderboard,
  joinChallenge,
  listFollowing,
  listChallenges,
  removeReaction,
  searchUsers,
  unfollowUser,
} from "../services/social.service";
```

Add routes before the `export { socialRouter }` line (before line 94):

```typescript
socialRouter.post("/feed/:eventId/reactions", async (request, response, next) => {
  try {
    const emoji = z.string().parse(request.body.emoji);
    const reaction = await addReaction(request.currentUser!.id, request.params.eventId, emoji);
    sendSuccess(response, reaction, 201);
  } catch (error) {
    next(error);
  }
});

socialRouter.delete("/feed/:eventId/reactions/:emoji", async (request, response, next) => {
  try {
    await removeReaction(request.currentUser!.id, request.params.eventId, request.params.emoji);
    sendSuccess(response, { ok: true });
  } catch (error) {
    next(error);
  }
});
```

- [ ] **Step 4: Verify backend compiles**

Run:
```powershell
Set-Location C:\Users\filip\Desktop\TrainingApp\backend
npm run build
```

Expected: No errors.

- [ ] **Step 5: Commit**

```powershell
git add backend/src/services/social.service.ts backend/src/routes/social.routes.ts
git commit -m "feat: add reaction endpoints for activity feed kudos"
```

---

## Task 3: Reactions — Frontend Types + API Client

**Files:**
- Modify: `web/src/lib/types.ts`
- Modify: `web/src/lib/api-client.ts`

- [ ] **Step 1: Extend ActivityEvent type**

In `web/src/lib/types.ts`, replace the `ActivityEvent` type (lines 446-453):

```typescript
export type ReactionSummary = {
  emoji: string;
  count: number;
  userReacted: boolean;
};

export type ActivityEvent = {
  id: string;
  title: string;
  body: string | null;
  createdAt: string;
  type: string;
  user: Pick<User, "id" | "displayName" | "level">;
  reactions: ReactionSummary[];
};
```

- [ ] **Step 2: Add reaction API functions**

In `web/src/lib/api-client.ts`, add before the closing `};` (before line 289):

```typescript
  addReaction: (eventId: string, emoji: string) =>
    request<{ id: string }>(`/social/feed/${eventId}/reactions`, {
      method: "POST",
      body: JSON.stringify({ emoji }),
    }),
  removeReaction: (eventId: string, emoji: string) =>
    request<{ ok: boolean }>(`/social/feed/${eventId}/reactions/${emoji}`, {
      method: "DELETE",
    }),
```

Also add the `ReactionSummary` import at the top of the file (line 17 area, in the type imports):

```typescript
  ReactionSummary,
```

- [ ] **Step 3: Verify frontend compiles**

Run:
```powershell
Set-Location C:\Users\filip\Desktop\TrainingApp\web
npx tsc --noEmit
```

Expected: No errors.

- [ ] **Step 4: Commit**

```powershell
git add web/src/lib/types.ts web/src/lib/api-client.ts
git commit -m "feat: add reaction types and API client functions"
```

---

## Task 4: Reactions — Feed UI

**Files:**
- Modify: `web/src/components/social/social-screen.tsx`

- [ ] **Step 1: Add reaction mutation**

In `web/src/components/social/social-screen.tsx`, add after the `joinChallengeMutation` (after line 80):

```typescript
  const reactionMutation = useMutation({
    mutationFn: ({ eventId, emoji, remove }: { eventId: string; emoji: string; remove: boolean }) =>
      remove ? apiClient.removeReaction(eventId, emoji) : apiClient.addReaction(eventId, emoji),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["feed"] });
    },
  });
```

- [ ] **Step 2: Add emoji icons import**

Add to the lucide-react import at line 4:

```typescript
import { Flame, FlexIcon, HandMetal, Search, Trophy, Users, UserPlus, Heart } from "lucide-react";
```

Note: lucide doesn't have a "flex" icon. Use these mappings instead — add a constant after the imports:

```typescript
const EMOJI_CONFIG = [
  { key: "fire", label: "Fire", icon: Flame },
  { key: "trophy", label: "Trophy", icon: Trophy },
  { key: "heart", label: "Heart", icon: Heart },
  { key: "clap", label: "Clap", icon: HandMetal },
  { key: "flex", label: "Flex", icon: Dumbbell },
] as const;
```

Update the lucide import to include all needed icons:

```typescript
import { Dumbbell, Flame, HandMetal, Heart, Search, Trophy, UserPlus, Users } from "lucide-react";
```

- [ ] **Step 3: Replace feed event rendering with reaction bar**

Replace the feed event card in `social-screen.tsx` (the `feedQuery.data.map` block, lines 309-316):

```tsx
feedQuery.data.map((event) => (
  <div key={event.id} className="surface-panel p-4">
    <p className="font-semibold">{event.title}</p>
    <p className="mt-1 text-sm text-ink-muted">
      {event.user.displayName} • {new Date(event.createdAt).toLocaleString()}
    </p>
    <div className="mt-3 flex flex-wrap gap-1.5">
      {EMOJI_CONFIG.map(({ key, icon: Icon }) => {
        const reaction = event.reactions.find((r) => r.emoji === key);
        const reacted = reaction?.userReacted ?? false;
        const count = reaction?.count ?? 0;

        return (
          <button
            key={key}
            type="button"
            onClick={() =>
              reactionMutation.mutate({ eventId: event.id, emoji: key, remove: reacted })
            }
            className={cn(
              "inline-flex items-center gap-1 rounded-full border px-2.5 py-1 text-xs font-medium transition-colors",
              reacted
                ? "border-ink bg-ink text-surface"
                : "border-rule text-ink-muted hover:border-ink hover:text-ink",
            )}
          >
            <Icon className="h-3 w-3" />
            {count > 0 ? <span>{count}</span> : null}
          </button>
        );
      })}
    </div>
  </div>
))
```

Add `cn` import if not already present:
```typescript
import { cn } from "@/lib/utils";
```

- [ ] **Step 4: Verify frontend compiles**

Run:
```powershell
Set-Location C:\Users\filip\Desktop\TrainingApp\web
npx tsc --noEmit
```

Expected: No errors.

- [ ] **Step 5: Commit**

```powershell
git add web/src/components/social/social-screen.tsx
git commit -m "feat: add reaction bar to activity feed events"
```

---

## Task 5: Copy Programs — Schema + Migration

**Files:**
- Modify: `backend/prisma/schema.prisma`

- [ ] **Step 1: Add allowCopy field to Program model**

In `backend/prisma/schema.prisma`, add after `graceHours` (after line 220):

```prisma
  allowCopy            Boolean              @default(false)
```

- [ ] **Step 2: Generate and apply migration**

Run:
```powershell
Set-Location C:\Users\filip\Desktop\TrainingApp\backend
npx prisma migrate dev --name add_program_allow_copy
```

- [ ] **Step 3: Commit**

```powershell
git add backend/prisma/schema.prisma backend/prisma/migrations/
git commit -m "feat: add allowCopy field to Program model"
```

---

## Task 6: Copy Programs — Backend Service + Routes

**Files:**
- Modify: `backend/src/services/program.service.ts`
- Modify: `backend/src/routes/programs.routes.ts`
- Modify: `backend/src/services/profile.service.ts`

- [ ] **Step 1: Add copyProgram to program service**

Add at the end of `backend/src/services/program.service.ts`:

```typescript
export const copyProgram = async (requesterId: string, programId: string) => {
  const source = await prisma.program.findFirst({
    where: {
      id: programId,
      allowCopy: true,
    },
    include: programInclude,
  });

  if (!source) {
    throw new AppError(404, "PROGRAM_NOT_FOUND", "That program could not be found or is not copyable.");
  }

  const isFollowing = await prisma.follow.findUnique({
    where: {
      followerId_followingId: {
        followerId: requesterId,
        followingId: source.userId,
      },
    },
  });

  if (!isFollowing && requesterId !== source.userId) {
    throw new AppError(403, "NOT_FOLLOWING", "You must follow this user to copy their program.");
  }

  return prisma.program.create({
    data: {
      userId: requesterId,
      name: source.name,
      goal: source.goal,
      description: source.description,
      status: "PAUSED",
      currentWeek: 1,
      adherenceStreak: 0,
      graceHours: source.graceHours,
      weeks: {
        create: source.weeks.map((week) => ({
          weekNumber: week.weekNumber,
          label: week.label,
          isDeload: week.isDeload,
          workouts: {
            create: week.workouts.map((workout) => ({
              dayLabel: workout.dayLabel,
              title: workout.title,
              orderIndex: workout.orderIndex,
              estimatedMinutes: workout.estimatedMinutes,
              exercises: {
                create: workout.exercises.map((exercise) => ({
                  exerciseId: exercise.exerciseId,
                  orderIndex: exercise.orderIndex,
                  sets: exercise.sets,
                  repMin: exercise.repMin,
                  repMax: exercise.repMax,
                  restSeconds: exercise.restSeconds,
                  startWeight: exercise.startWeight,
                  increment: exercise.increment,
                  deloadFactor: exercise.deloadFactor,
                  targetRpe: exercise.targetRpe,
                  loadTypeOverride: exercise.loadTypeOverride,
                  trackingMode: exercise.trackingMode,
                  defaultTrackingData: exercise.defaultTrackingData ?? undefined,
                  machineOverride: exercise.machineOverride,
                  attachmentOverride: exercise.attachmentOverride,
                  unilateral: exercise.unilateral,
                  notes: exercise.notes,
                })),
              },
            })),
          },
        })),
      },
    },
    include: programInclude,
  });
};
```

- [ ] **Step 2: Add copy route**

In `backend/src/routes/programs.routes.ts`, add a new route (find the existing routes and add after the archive route):

```typescript
programsRouter.post("/:programId/copy", async (request, response, next) => {
  try {
    const program = await copyProgram(request.currentUser!.id, request.params.programId);
    sendSuccess(response, program, 201);
  } catch (error) {
    next(error);
  }
});
```

Add `copyProgram` to the import from `../services/program.service`.

- [ ] **Step 3: Update profile service to include copyable programs**

In `backend/src/services/profile.service.ts`, update the `getPublicProfile` function. Add a query for copyable programs and include them in the response. After the existing `follow` query, add:

```typescript
const copyablePrograms = isFollowing
  ? await prisma.program.findMany({
      where: {
        userId: profileUserId,
        allowCopy: true,
        status: { not: "ARCHIVED" },
      },
      select: {
        id: true,
        name: true,
        goal: true,
        description: true,
        weeks: {
          select: { id: true },
        },
        _count: {
          select: {
            weeks: true,
          },
        },
      },
      orderBy: { createdAt: "desc" },
    })
  : [];
```

Add to the return object:

```typescript
copyablePrograms: copyablePrograms.map((p) => ({
  id: p.id,
  name: p.name,
  goal: p.goal,
  description: p.description,
  weekCount: p._count.weeks,
})),
```

Note: You'll need to read the exact structure of `getPublicProfile` to place this correctly — it uses a `$transaction` or multiple queries. Add the `copyablePrograms` query alongside the existing queries and include the result in the return value.

- [ ] **Step 4: Verify backend compiles**

Run:
```powershell
Set-Location C:\Users\filip\Desktop\TrainingApp\backend
npm run build
```

- [ ] **Step 5: Commit**

```powershell
git add backend/src/services/program.service.ts backend/src/routes/programs.routes.ts backend/src/services/profile.service.ts
git commit -m "feat: add program copy endpoint and profile copyable programs"
```

---

## Task 7: Copy Programs — Frontend Types + API

**Files:**
- Modify: `web/src/lib/types.ts`
- Modify: `web/src/lib/api-client.ts`

- [ ] **Step 1: Update types**

In `web/src/lib/types.ts`, add `allowCopy` to the `Program` type (after `adherenceStreak`, line 171):

```typescript
  allowCopy: boolean;
```

Add a new type after `ProfileView` (after line 691):

```typescript
export type CopyableProgram = {
  id: string;
  name: string;
  goal: string;
  description: string | null;
  weekCount: number;
};
```

Add `copyablePrograms` to the `ProfileView` type:

```typescript
export type ProfileView = {
  user: User;
  showcase: ProfileShowcase;
  editable: boolean;
  isFollowing?: boolean;
  copyablePrograms?: CopyableProgram[];
};
```

- [ ] **Step 2: Add API functions**

In `web/src/lib/api-client.ts`, add before the closing `};`:

```typescript
  copyProgram: (programId: string) =>
    request<Program>(`/programs/${programId}/copy`, {
      method: "POST",
    }),
  updateProgramAllowCopy: (programId: string, allowCopy: boolean) =>
    request<Program>(`/programs/${programId}`, {
      method: "PUT",
      body: JSON.stringify({ allowCopy }),
    }),
```

Add `CopyableProgram` and `Program` to the type imports at the top of the file.

- [ ] **Step 3: Verify frontend compiles**

Run:
```powershell
Set-Location C:\Users\filip\Desktop\TrainingApp\web
npx tsc --noEmit
```

- [ ] **Step 4: Commit**

```powershell
git add web/src/lib/types.ts web/src/lib/api-client.ts
git commit -m "feat: add copy program types and API client functions"
```

---

## Task 8: Copy Programs — Profile UI + Program Detail Toggle

**Files:**
- Modify: `web/src/components/profile/profile-screen.tsx`
- Modify: `web/src/components/programs/program-detail-screen.tsx`

- [ ] **Step 1: Add copyable programs section to profile screen**

In `web/src/components/profile/profile-screen.tsx`, add a mutation and a new card section. Add imports:

```typescript
import { Copy, Dumbbell } from "lucide-react";
```

Add a mutation after the `showcaseMutation` (around line 57):

```typescript
  const copyProgramMutation = useMutation({
    mutationFn: apiClient.copyProgram,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["programs"] });
      toast.success("Program copied to your library");
    },
    onError: (error: Error) => toast.error(error.message),
  });
```

Add a card section in the JSX, after the existing showcase/achievements sections but before the showcase loadout editor (which only shows for editable profiles). Insert before the `{profile.editable ? (` check:

```tsx
{!profile.editable && profile.copyablePrograms?.length ? (
  <Card>
    <CardHeader>
      <CardTitle>Programs</CardTitle>
      <CardDescription>Programs shared by {profile.user.displayName}</CardDescription>
    </CardHeader>
    <CardContent className="space-y-3">
      {profile.copyablePrograms.map((program) => (
        <div key={program.id} className="flex items-center justify-between gap-3 rounded-md border border-rule bg-surface p-4">
          <div className="min-w-0">
            <p className="font-semibold text-ink">{program.name}</p>
            <p className="mt-0.5 text-sm text-ink-muted">
              {program.goal} • {program.weekCount} weeks
            </p>
            {program.description ? (
              <p className="mt-1 line-clamp-2 text-xs text-ink-muted">{program.description}</p>
            ) : null}
          </div>
          <Button
            variant="outline"
            size="sm"
            onClick={() => copyProgramMutation.mutate(program.id)}
            disabled={copyProgramMutation.isPending}
          >
            <Copy className="mr-1.5 h-3.5 w-3.5" />
            Copy
          </Button>
        </div>
      ))}
    </CardContent>
  </Card>
) : null}
```

Add `apiClient` import if not present. Add `Copy` to the lucide-react import.

- [ ] **Step 2: Add allowCopy toggle to program detail screen**

In `web/src/components/programs/program-detail-screen.tsx`, add a toggle in the `actions` section of the `ScreenHero` (inside the fragment, after the Edit button but before the Delete button, around line 93):

First add imports:

```typescript
import { Share2 } from "lucide-react";
```

Add a mutation in the component:

```typescript
  const allowCopyMutation = useMutation({
    mutationFn: (allowCopy: boolean) => apiClient.updateProgramAllowCopy(program.id, allowCopy),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["program", programId] });
      toast.success("Sharing preference updated");
    },
    onError: (error: Error) => toast.error(error.message),
  });
```

Add in the actions area (after the Edit button, before Delete):

```tsx
{!program.isSystem ? (
  <Button
    variant={program.allowCopy ? "default" : "outline"}
    size="sm"
    onClick={() => allowCopyMutation.mutate(!program.allowCopy)}
    disabled={allowCopyMutation.isPending}
  >
    <Share2 className="mr-1.5 h-3.5 w-3.5" />
    {program.allowCopy ? "Shared" : "Share"}
  </Button>
) : null}
```

Note: The `updateProgramAllowCopy` function sends a PUT to the existing update endpoint. The backend's `updateProgram` will need to accept `allowCopy` in its input — verify this and add it to the Zod schema in the programs route if needed.

- [ ] **Step 3: Verify frontend compiles**

Run:
```powershell
Set-Location C:\Users\filip\Desktop\TrainingApp\web
npx tsc --noEmit
```

- [ ] **Step 4: Commit**

```powershell
git add web/src/components/profile/profile-screen.tsx web/src/components/programs/program-detail-screen.tsx
git commit -m "feat: add program copy UI on profiles and share toggle on program detail"
```

---

## Task 9: Notifications — Schema + Migration

**Files:**
- Modify: `backend/prisma/schema.prisma`

- [ ] **Step 1: Add Notification model**

Add at the end of `backend/prisma/schema.prisma`:

```prisma
model Notification {
  id        String   @id @default(cuid())
  userId    String
  type      String
  title     String
  body      String?
  payload   Json?
  read      Boolean  @default(false)
  createdAt DateTime @default(now())

  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId, read, createdAt(sort: Desc)])
}
```

Add to the `User` model (after `reactions`):

```prisma
  notifications        Notification[]
```

- [ ] **Step 2: Generate and apply migration**

Run:
```powershell
Set-Location C:\Users\filip\Desktop\TrainingApp\backend
npx prisma migrate dev --name add_notifications
```

- [ ] **Step 3: Commit**

```powershell
git add backend/prisma/schema.prisma backend/prisma/migrations/
git commit -m "feat: add Notification model"
```

---

## Task 10: Notifications — Backend Service + Routes

**Files:**
- Create: `backend/src/services/notification.service.ts`
- Create: `backend/src/routes/notification.routes.ts`
- Modify: `backend/src/app.ts` (or wherever routes are mounted)

- [ ] **Step 1: Create notification service**

Create `backend/src/services/notification.service.ts`:

```typescript
import { prisma } from "../lib/prisma";

export const createNotification = async (input: {
  userId: string;
  type: string;
  title: string;
  body?: string;
  payload?: Record<string, unknown>;
}) =>
  prisma.notification.create({
    data: {
      userId: input.userId,
      type: input.type,
      title: input.title,
      body: input.body,
      payload: input.payload ?? undefined,
    },
  });

export const getNotifications = async (userId: string) =>
  prisma.notification.findMany({
    where: { userId },
    orderBy: { createdAt: "desc" },
    take: 50,
  });

export const getUnreadCount = async (userId: string) =>
  prisma.notification.count({
    where: { userId, read: false },
  });

export const markAsRead = async (userId: string, notificationId: string) =>
  prisma.notification.updateMany({
    where: { id: notificationId, userId },
    data: { read: true },
  });

export const markAllAsRead = async (userId: string) =>
  prisma.notification.updateMany({
    where: { userId, read: false },
    data: { read: true },
  });
```

- [ ] **Step 2: Create notification routes**

Create `backend/src/routes/notification.routes.ts`:

```typescript
import { Router } from "express";

import { sendSuccess } from "../lib/http";
import { requireAuth } from "../middleware/auth";
import {
  getNotifications,
  getUnreadCount,
  markAllAsRead,
  markAsRead,
} from "../services/notification.service";

const notificationRouter = Router();

notificationRouter.use(requireAuth);

notificationRouter.get("/", async (request, response, next) => {
  try {
    const notifications = await getNotifications(request.currentUser!.id);
    sendSuccess(response, notifications);
  } catch (error) {
    next(error);
  }
});

notificationRouter.get("/unread-count", async (request, response, next) => {
  try {
    const count = await getUnreadCount(request.currentUser!.id);
    sendSuccess(response, { count });
  } catch (error) {
    next(error);
  }
});

notificationRouter.patch("/:id/read", async (request, response, next) => {
  try {
    await markAsRead(request.currentUser!.id, request.params.id);
    sendSuccess(response, { ok: true });
  } catch (error) {
    next(error);
  }
});

notificationRouter.post("/read-all", async (request, response, next) => {
  try {
    await markAllAsRead(request.currentUser!.id);
    sendSuccess(response, { ok: true });
  } catch (error) {
    next(error);
  }
});

export { notificationRouter };
```

- [ ] **Step 3: Mount the router**

Find where routes are mounted in the backend (likely `backend/src/app.ts` or `backend/src/index.ts`). Add:

```typescript
import { notificationRouter } from "./routes/notification.routes";

// In the route mounting section:
app.use("/api/v1/notifications", notificationRouter);
```

- [ ] **Step 4: Verify backend compiles**

Run:
```powershell
Set-Location C:\Users\filip\Desktop\TrainingApp\backend
npm run build
```

- [ ] **Step 5: Commit**

```powershell
git add backend/src/services/notification.service.ts backend/src/routes/notification.routes.ts backend/src/app.ts
git commit -m "feat: add notification service and routes"
```

---

## Task 11: Notifications — Frontend Types + API + UI

**Files:**
- Modify: `web/src/lib/types.ts`
- Modify: `web/src/lib/api-client.ts`
- Create: `web/src/components/notifications/notification-sheet.tsx`
- Modify: `web/src/components/layout/app-shell.tsx`

- [ ] **Step 1: Add notification type**

In `web/src/lib/types.ts`, add:

```typescript
export type Notification = {
  id: string;
  type: string;
  title: string;
  body: string | null;
  payload: Record<string, unknown> | null;
  read: boolean;
  createdAt: string;
};
```

- [ ] **Step 2: Add notification API functions**

In `web/src/lib/api-client.ts`, add:

```typescript
  getNotifications: () => request<Notification[]>("/notifications"),
  getUnreadNotificationCount: () => request<{ count: number }>("/notifications/unread-count"),
  markNotificationRead: (id: string) =>
    request<{ ok: boolean }>(`/notifications/${id}/read`, {
      method: "PATCH",
    }),
  markAllNotificationsRead: () =>
    request<{ ok: boolean }>("/notifications/read-all", {
      method: "POST",
    }),
```

Add `Notification` to the type imports (note: rename to avoid collision with the browser Notification API):

```typescript
  Notification as LiftNotification,
```

Then use `LiftNotification` in the API client. Alternatively, use a different name in `types.ts`:

```typescript
export type AppNotification = {
  // ... same fields
};
```

Use `AppNotification` everywhere to avoid the browser API collision.

- [ ] **Step 3: Create notification sheet component**

Create `web/src/components/notifications/notification-sheet.tsx`:

```tsx
"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Bell, CheckCheck } from "lucide-react";
import { useState } from "react";

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { Skeleton } from "@/components/ui/skeleton";
import { apiClient } from "@/lib/api-client";
import { cn } from "@/lib/utils";

export const NotificationBell = () => {
  const [open, setOpen] = useState(false);
  const queryClient = useQueryClient();

  const countQuery = useQuery({
    queryKey: ["notification-count"],
    queryFn: apiClient.getUnreadNotificationCount,
    refetchInterval: 30_000,
  });

  const notificationsQuery = useQuery({
    queryKey: ["notifications"],
    queryFn: apiClient.getNotifications,
    enabled: open,
  });

  const markReadMutation = useMutation({
    mutationFn: apiClient.markNotificationRead,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["notifications"] });
      await queryClient.invalidateQueries({ queryKey: ["notification-count"] });
    },
  });

  const markAllReadMutation = useMutation({
    mutationFn: apiClient.markAllNotificationsRead,
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["notifications"] });
      await queryClient.invalidateQueries({ queryKey: ["notification-count"] });
    },
  });

  const unreadCount = countQuery.data?.count ?? 0;

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="relative inline-flex items-center justify-center rounded-md p-2 text-ink-muted transition-colors hover:text-ink"
      >
        <Bell className="h-5 w-5" />
        {unreadCount > 0 ? (
          <span className="absolute -right-0.5 -top-0.5 flex h-4 min-w-4 items-center justify-center rounded-full bg-pr px-1 font-mono text-[10px] font-bold text-surface">
            {unreadCount > 9 ? "9+" : unreadCount}
          </span>
        ) : null}
      </button>

      <Sheet open={open} onOpenChange={setOpen}>
        <SheetContent side="bottom" className="max-h-[80vh] overflow-y-auto">
          <SheetHeader>
            <div className="flex items-center justify-between">
              <SheetTitle>Notifications</SheetTitle>
              {unreadCount > 0 ? (
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => markAllReadMutation.mutate()}
                  disabled={markAllReadMutation.isPending}
                >
                  <CheckCheck className="mr-1.5 h-3.5 w-3.5" />
                  Mark all read
                </Button>
              ) : null}
            </div>
            <SheetDescription>Recent activity</SheetDescription>
          </SheetHeader>

          <div className="space-y-2 px-6 pb-6 pt-4">
            {notificationsQuery.isLoading ? (
              <div className="space-y-2">
                {Array.from({ length: 3 }).map((_, i) => (
                  <Skeleton key={i} className="h-16" />
                ))}
              </div>
            ) : notificationsQuery.data?.length ? (
              notificationsQuery.data.map((notification) => (
                <button
                  key={notification.id}
                  type="button"
                  onClick={() => {
                    if (!notification.read) {
                      markReadMutation.mutate(notification.id);
                    }
                  }}
                  className={cn(
                    "w-full rounded-md border p-3 text-left transition-colors",
                    notification.read
                      ? "border-rule bg-surface"
                      : "border-ink/10 bg-surface-raised",
                  )}
                >
                  <div className="flex items-start justify-between gap-2">
                    <p className={cn("text-sm", notification.read ? "text-ink-muted" : "font-semibold text-ink")}>
                      {notification.title}
                    </p>
                    {!notification.read ? (
                      <span className="mt-1 h-2 w-2 shrink-0 rounded-full bg-pr" />
                    ) : null}
                  </div>
                  {notification.body ? (
                    <p className="mt-0.5 text-xs text-ink-muted">{notification.body}</p>
                  ) : null}
                  <p className="mt-1 text-[10px] text-ink-muted">
                    {new Date(notification.createdAt).toLocaleString()}
                  </p>
                </button>
              ))
            ) : (
              <div className="rounded-md border border-dashed border-rule p-6 text-center text-sm text-ink-muted">
                No notifications yet.
              </div>
            )}
          </div>
        </SheetContent>
      </Sheet>
    </>
  );
};
```

- [ ] **Step 4: Add notification bell to app shell**

In `web/src/components/layout/app-shell.tsx`, add the bell. The current app-shell is minimal (23 lines). Add the notification bell above the main content area:

```typescript
import type { ReactNode } from "react";

import { BuildBadge } from "@/components/layout/build-badge";
import { PrimaryNav } from "@/components/layout/primary-nav";
import { ContextStrip } from "@/components/layout/context-strip";
import { NotificationBell } from "@/components/notifications/notification-sheet";

export const AppShell = ({
  children,
  showNav = true,
}: {
  children: ReactNode;
  showNav?: boolean;
}) => (
  <div className="relative min-h-screen">
    <ContextStrip />
    <BuildBadge />
    <div className="fixed right-4 top-3 z-40 sm:right-6 sm:top-5 lg:right-12 lg:top-6">
      <NotificationBell />
    </div>
    <main className="mx-auto w-full max-w-3xl px-5 pb-32 pt-12 sm:pt-16 lg:max-w-5xl lg:px-12 lg:pb-16 lg:pt-20">
      {children}
    </main>
    {showNav ? <PrimaryNav /> : null}
  </div>
);
```

- [ ] **Step 5: Verify frontend compiles**

Run:
```powershell
Set-Location C:\Users\filip\Desktop\TrainingApp\web
npx tsc --noEmit
```

- [ ] **Step 6: Commit**

```powershell
git add web/src/lib/types.ts web/src/lib/api-client.ts web/src/components/notifications/notification-sheet.tsx web/src/components/layout/app-shell.tsx
git commit -m "feat: add in-app notification system with bell icon"
```

---

## Task 12: Workout Invites — Schema + Migration

**Files:**
- Modify: `backend/prisma/schema.prisma`

- [ ] **Step 1: Add WorkoutInvite model and inviteId to WorkoutSession**

Add to the end of `backend/prisma/schema.prisma`:

```prisma
model WorkoutInvite {
  id               String   @id @default(cuid())
  fromUserId       String
  toUserId         String
  fromSessionId    String?
  programWorkoutId String?
  templateId       String?
  workoutTitle     String
  exercises        Json
  status           String   @default("PENDING")
  expiresAt        DateTime
  createdAt        DateTime @default(now())

  fromUser         User     @relation("sentInvites", fields: [fromUserId], references: [id], onDelete: Cascade)
  toUser           User     @relation("receivedInvites", fields: [toUserId], references: [id], onDelete: Cascade)

  @@index([toUserId, status])
}
```

Add `inviteId` to the `WorkoutSession` model (after `qualifiesForProgression`, line 341):

```prisma
  inviteId                 String?
```

Add relations to the `User` model:

```prisma
  sentInvites          WorkoutInvite[]      @relation("sentInvites")
  receivedInvites      WorkoutInvite[]      @relation("receivedInvites")
```

- [ ] **Step 2: Generate and apply migration**

Run:
```powershell
Set-Location C:\Users\filip\Desktop\TrainingApp\backend
npx prisma migrate dev --name add_workout_invites
```

- [ ] **Step 3: Commit**

```powershell
git add backend/prisma/schema.prisma backend/prisma/migrations/
git commit -m "feat: add WorkoutInvite model and inviteId on WorkoutSession"
```

---

## Task 13: Workout Invites — Backend Service + Routes

**Files:**
- Create: `backend/src/services/invite.service.ts`
- Modify: `backend/src/routes/workouts.routes.ts`

- [ ] **Step 1: Create invite service**

Create `backend/src/services/invite.service.ts`:

```typescript
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

  let exercises: unknown[] = [];

  if (input.fromSessionId) {
    const session = await prisma.workoutSession.findFirst({
      where: { id: input.fromSessionId, userId: fromUserId },
      select: { savedDraft: true },
    });
    if (session?.savedDraft && typeof session.savedDraft === "object") {
      const draft = session.savedDraft as { exercises?: unknown[] };
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

export const getPendingInvites = async (userId: string) => {
  const invites = await prisma.workoutInvite.findMany({
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

  return invites;
};

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
        savedDraft: draft as unknown as Record<string, unknown>,
        originDraft: draft as unknown as Record<string, unknown>,
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
```

- [ ] **Step 2: Add invite routes**

In `backend/src/routes/workouts.routes.ts`, add routes. Import the service:

```typescript
import { acceptInvite, createWorkoutInvite, declineInvite, getPendingInvites } from "../services/invite.service";
```

Add routes (before the export):

```typescript
workoutsRouter.post("/invite", async (request, response, next) => {
  try {
    const input = z.object({
      toUserId: z.string(),
      fromSessionId: z.string().optional(),
      programWorkoutId: z.string().optional(),
      templateId: z.string().optional(),
      workoutTitle: z.string(),
    }).parse(request.body);

    const invite = await createWorkoutInvite(request.currentUser!.id, input);
    sendSuccess(response, invite, 201);
  } catch (error) {
    next(error);
  }
});

workoutsRouter.get("/invites/pending", async (request, response, next) => {
  try {
    const invites = await getPendingInvites(request.currentUser!.id);
    sendSuccess(response, invites);
  } catch (error) {
    next(error);
  }
});

workoutsRouter.post("/invite/:inviteId/accept", async (request, response, next) => {
  try {
    const result = await acceptInvite(request.currentUser!.id, request.params.inviteId);
    sendSuccess(response, result);
  } catch (error) {
    next(error);
  }
});

workoutsRouter.post("/invite/:inviteId/decline", async (request, response, next) => {
  try {
    await declineInvite(request.currentUser!.id, request.params.inviteId);
    sendSuccess(response, { ok: true });
  } catch (error) {
    next(error);
  }
});
```

- [ ] **Step 3: Verify backend compiles**

Run:
```powershell
Set-Location C:\Users\filip\Desktop\TrainingApp\backend
npm run build
```

- [ ] **Step 4: Commit**

```powershell
git add backend/src/services/invite.service.ts backend/src/routes/workouts.routes.ts
git commit -m "feat: add workout invite service and routes"
```

---

## Task 14: Workout Invites — Frontend

**Files:**
- Modify: `web/src/lib/types.ts`
- Modify: `web/src/lib/api-client.ts`
- Create: `web/src/components/workouts/invite-mate-sheet.tsx`
- Modify: `web/src/components/workouts/workout-editor.tsx`

- [ ] **Step 1: Add types**

In `web/src/lib/types.ts`:

```typescript
export type WorkoutInvite = {
  id: string;
  fromUserId: string;
  toUserId: string;
  workoutTitle: string;
  exercises: Array<{
    exerciseId: string;
    exerciseName: string;
    sets: number;
    repMin: number;
    repMax: number;
  }>;
  status: "PENDING" | "ACCEPTED" | "DECLINED" | "EXPIRED";
  expiresAt: string;
  createdAt: string;
  fromUser?: { id: string; displayName: string };
};
```

- [ ] **Step 2: Add API functions**

In `web/src/lib/api-client.ts`:

```typescript
  createWorkoutInvite: (input: {
    toUserId: string;
    fromSessionId?: string;
    programWorkoutId?: string;
    templateId?: string;
    workoutTitle: string;
  }) =>
    request<WorkoutInvite>("/workouts/invite", {
      method: "POST",
      body: JSON.stringify(input),
    }),
  getPendingInvites: () => request<WorkoutInvite[]>("/workouts/invites/pending"),
  acceptInvite: (inviteId: string) =>
    request<{ sessionId: string }>(`/workouts/invite/${inviteId}/accept`, {
      method: "POST",
    }),
  declineInvite: (inviteId: string) =>
    request<{ ok: boolean }>(`/workouts/invite/${inviteId}/decline`, {
      method: "POST",
    }),
```

- [ ] **Step 3: Create invite mate sheet**

Create `web/src/components/workouts/invite-mate-sheet.tsx`:

```tsx
"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Send } from "lucide-react";
import { toast } from "sonner";

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { Skeleton } from "@/components/ui/skeleton";
import { apiClient } from "@/lib/api-client";

export const InviteMateSheet = ({
  open,
  onOpenChange,
  sessionId,
  workoutTitle,
  programWorkoutId,
  templateId,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  sessionId: string | null;
  workoutTitle: string;
  programWorkoutId?: string | null;
  templateId?: string | null;
}) => {
  const queryClient = useQueryClient();

  const followingQuery = useQuery({
    queryKey: ["following"],
    queryFn: apiClient.getFollowing,
    enabled: open,
  });

  const inviteMutation = useMutation({
    mutationFn: (toUserId: string) =>
      apiClient.createWorkoutInvite({
        toUserId,
        fromSessionId: sessionId ?? undefined,
        programWorkoutId: programWorkoutId ?? undefined,
        templateId: templateId ?? undefined,
        workoutTitle,
      }),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ["notification-count"] });
      toast.success("Invite sent!");
      onOpenChange(false);
    },
    onError: (error: Error) => toast.error(error.message),
  });

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent side="bottom" className="max-h-[70vh] overflow-y-auto">
        <SheetHeader>
          <SheetTitle>Invite a mate</SheetTitle>
          <SheetDescription>Pick someone to train with you on "{workoutTitle}"</SheetDescription>
        </SheetHeader>

        <div className="space-y-2 px-6 pb-6 pt-4">
          {followingQuery.isLoading ? (
            <div className="space-y-2">
              {Array.from({ length: 3 }).map((_, i) => (
                <Skeleton key={i} className="h-14" />
              ))}
            </div>
          ) : followingQuery.data?.length ? (
            followingQuery.data.map((user) => (
              <div
                key={user.id}
                className="flex items-center justify-between gap-3 rounded-md border border-rule bg-surface p-3"
              >
                <div>
                  <p className="text-sm font-semibold text-ink">{user.displayName}</p>
                  <p className="text-xs text-ink-muted">Level {user.level}</p>
                </div>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => inviteMutation.mutate(user.id)}
                  disabled={inviteMutation.isPending}
                >
                  <Send className="mr-1.5 h-3.5 w-3.5" />
                  Invite
                </Button>
              </div>
            ))
          ) : (
            <div className="rounded-md border border-dashed border-rule p-6 text-center text-sm text-ink-muted">
              Follow people to invite them to train with you.
            </div>
          )}
        </div>
      </SheetContent>
    </Sheet>
  );
};
```

- [ ] **Step 4: Wire invite button into workout editor**

In `web/src/components/workouts/workout-editor.tsx`:

Add import:
```typescript
import { InviteMateSheet } from "@/components/workouts/invite-mate-sheet";
import { Users } from "lucide-react";
```

Add state (next to the other sheet states, around line 149):
```typescript
const [inviteSheetOpen, setInviteSheetOpen] = useState(false);
```

Add button in the active exercise header area (next to the History button, around line 1195):
```tsx
<Button variant="outline" size="sm" onClick={() => setInviteSheetOpen(true)}>
  <Users className="mr-1.5 h-3.5 w-3.5" />
  Invite
</Button>
```

Add sheet at the bottom with other sheets (around line 2014):
```tsx
<InviteMateSheet
  open={inviteSheetOpen}
  onOpenChange={setInviteSheetOpen}
  sessionId={sessionId}
  workoutTitle={draft.title}
  programWorkoutId={workout?.programWorkoutId ?? null}
  templateId={workout?.templateId ?? null}
/>
```

Note: `sessionId` and `workout` should already be available in the component — `sessionId` is the URL param, `workout` comes from the workout query.

- [ ] **Step 5: Verify frontend compiles**

Run:
```powershell
Set-Location C:\Users\filip\Desktop\TrainingApp\web
npx tsc --noEmit
```

- [ ] **Step 6: Commit**

```powershell
git add web/src/lib/types.ts web/src/lib/api-client.ts web/src/components/workouts/invite-mate-sheet.tsx web/src/components/workouts/workout-editor.tsx
git commit -m "feat: add workout invite UI with mate picker sheet"
```

---

## Task 15: Post-Workout Comparison — Backend

**Files:**
- Modify: `backend/src/services/invite.service.ts`
- Modify: `backend/src/routes/workouts.routes.ts`

- [ ] **Step 1: Add comparison service function**

Add to `backend/src/services/invite.service.ts`:

```typescript
export const getWorkoutComparison = async (userId: string, sessionId: string) => {
  const session = await prisma.workoutSession.findFirst({
    where: { id: sessionId, userId, status: "COMPLETED" },
    include: {
      exercises: {
        include: {
          sets: { orderBy: { setNumber: "asc" } },
          exercise: { select: { id: true, name: true } },
        },
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
        include: {
          sets: { orderBy: { setNumber: "asc" } },
          exercise: { select: { id: true, name: true } },
        },
      },
    },
  });

  if (!mateSession) {
    throw new AppError(404, "MATE_NOT_DONE", "Your mate hasn't completed their workout yet.");
  }

  const computeExerciseStats = (exercises: typeof session.exercises) => {
    const map = new Map<string, { volume: number; estimatedOneRepMax: number | null; name: string }>();
    for (const ex of exercises) {
      let volume = 0;
      let bestE1rm: number | null = null;
      for (const set of ex.sets) {
        if (set.weight && set.reps) {
          volume += set.weight * set.reps;
          const e1rm = set.weight * (1 + set.reps / 30);
          if (bestE1rm === null || e1rm > bestE1rm) bestE1rm = e1rm;
        }
      }
      map.set(ex.exerciseId, { volume, estimatedOneRepMax: bestE1rm, name: ex.exercise.name });
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
    mySession: { completedAt: session.completedAt?.toISOString() },
    mateSession: { completedAt: mateSession.completedAt?.toISOString(), displayName: mateSession.user.displayName },
    exercises,
  };
};
```

- [ ] **Step 2: Add comparison route**

In `backend/src/routes/workouts.routes.ts`, add import and route:

```typescript
import { getWorkoutComparison } from "../services/invite.service";
```

Add route:

```typescript
workoutsRouter.get("/:workoutId/comparison", async (request, response, next) => {
  try {
    const comparison = await getWorkoutComparison(request.currentUser!.id, request.params.workoutId);
    sendSuccess(response, comparison);
  } catch (error) {
    next(error);
  }
});
```

- [ ] **Step 3: Verify backend compiles**

Run:
```powershell
Set-Location C:\Users\filip\Desktop\TrainingApp\backend
npm run build
```

- [ ] **Step 4: Commit**

```powershell
git add backend/src/services/invite.service.ts backend/src/routes/workouts.routes.ts
git commit -m "feat: add post-workout comparison endpoint"
```

---

## Task 16: Post-Workout Comparison — Frontend

**Files:**
- Modify: `web/src/lib/types.ts`
- Modify: `web/src/lib/api-client.ts`
- Create: `web/src/components/workouts/workout-comparison-sheet.tsx`
- Modify: `web/src/components/workouts/workout-editor.tsx`

- [ ] **Step 1: Add comparison type**

In `web/src/lib/types.ts`:

```typescript
export type WorkoutComparison = {
  mySession: { completedAt: string | null };
  mateSession: { completedAt: string | null; displayName: string };
  exercises: Array<{
    exerciseName: string;
    myVolumeChange: number | null;
    mateVolumeChange: number | null;
    myE1rmChange: number | null;
    mateE1rmChange: number | null;
  }>;
};
```

- [ ] **Step 2: Add API function**

In `web/src/lib/api-client.ts`:

```typescript
  getWorkoutComparison: (sessionId: string) =>
    request<WorkoutComparison>(`/workouts/${sessionId}/comparison`),
```

- [ ] **Step 3: Create comparison sheet component**

Create `web/src/components/workouts/workout-comparison-sheet.tsx`:

```tsx
"use client";

import { useQuery } from "@tanstack/react-query";
import { TrendingDown, TrendingUp, Minus } from "lucide-react";

import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import { Skeleton } from "@/components/ui/skeleton";
import { apiClient } from "@/lib/api-client";
import { cn } from "@/lib/utils";

const DeltaBadge = ({ value }: { value: number | null }) => {
  if (value === null) return <span className="text-xs text-ink-muted">-</span>;

  const positive = value > 0;
  const neutral = value === 0;

  return (
    <Badge
      variant="outline"
      className={cn(
        "gap-1 font-mono text-xs",
        positive && "border-green-500/30 text-green-600",
        !positive && !neutral && "border-red-500/30 text-red-500",
      )}
    >
      {positive ? <TrendingUp className="h-3 w-3" /> : neutral ? <Minus className="h-3 w-3" /> : <TrendingDown className="h-3 w-3" />}
      {positive ? "+" : ""}{value}%
    </Badge>
  );
};

export const WorkoutComparisonSheet = ({
  sessionId,
  open,
  onOpenChange,
}: {
  sessionId: string | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}) => {
  const comparisonQuery = useQuery({
    queryKey: ["workout-comparison", sessionId],
    queryFn: () => apiClient.getWorkoutComparison(sessionId!),
    enabled: open && !!sessionId,
    retry: false,
  });

  const comparison = comparisonQuery.data;

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent side="bottom" className="max-h-[85vh] overflow-y-auto">
        <SheetHeader>
          <SheetTitle>Workout comparison</SheetTitle>
          <SheetDescription>
            {comparison
              ? `You vs ${comparison.mateSession.displayName} — % improvement from your own previous sessions`
              : "Loading comparison..."}
          </SheetDescription>
        </SheetHeader>

        <div className="space-y-3 px-6 pb-6 pt-4">
          {comparisonQuery.isLoading ? (
            <div className="space-y-3">
              {Array.from({ length: 4 }).map((_, i) => (
                <Skeleton key={i} className="h-20" />
              ))}
            </div>
          ) : comparisonQuery.isError ? (
            <div className="rounded-md border border-dashed border-rule p-6 text-center text-sm text-ink-muted">
              {comparisonQuery.error instanceof Error
                ? comparisonQuery.error.message
                : "Comparison not available yet. Your mate may not have finished their workout."}
            </div>
          ) : comparison ? (
            comparison.exercises.map((exercise) => (
              <Card key={exercise.exerciseName}>
                <CardHeader className="pb-2">
                  <CardTitle className="text-sm">{exercise.exerciseName}</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <p className="text-[10px] uppercase tracking-[0.08em] text-ink-muted">You</p>
                      <div className="mt-1 flex flex-wrap gap-1.5">
                        <div className="space-y-1">
                          <p className="text-[10px] text-ink-muted">Volume</p>
                          <DeltaBadge value={exercise.myVolumeChange} />
                        </div>
                        <div className="space-y-1">
                          <p className="text-[10px] text-ink-muted">e1RM</p>
                          <DeltaBadge value={exercise.myE1rmChange} />
                        </div>
                      </div>
                    </div>
                    <div>
                      <p className="text-[10px] uppercase tracking-[0.08em] text-ink-muted">{comparison.mateSession.displayName}</p>
                      <div className="mt-1 flex flex-wrap gap-1.5">
                        <div className="space-y-1">
                          <p className="text-[10px] text-ink-muted">Volume</p>
                          <DeltaBadge value={exercise.mateVolumeChange} />
                        </div>
                        <div className="space-y-1">
                          <p className="text-[10px] text-ink-muted">e1RM</p>
                          <DeltaBadge value={exercise.mateE1rmChange} />
                        </div>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))
          ) : null}
        </div>
      </SheetContent>
    </Sheet>
  );
};
```

- [ ] **Step 4: Wire comparison into workout editor**

In `web/src/components/workouts/workout-editor.tsx`:

Add imports:
```typescript
import { WorkoutComparisonSheet } from "@/components/workouts/workout-comparison-sheet";
import { GitCompareArrows } from "lucide-react";
```

Add state:
```typescript
const [comparisonSheetOpen, setComparisonSheetOpen] = useState(false);
```

In the workout completion area (the section that shows after a workout is completed), or in the header area when the workout status is COMPLETED, add a "Compare" button. Find where the workout status is checked and the completion summary is shown — add:

```tsx
{workout?.inviteId ? (
  <Button variant="outline" size="sm" onClick={() => setComparisonSheetOpen(true)}>
    <GitCompareArrows className="mr-1.5 h-3.5 w-3.5" />
    Compare with mate
  </Button>
) : null}
```

Add the sheet at the bottom with other sheets:

```tsx
<WorkoutComparisonSheet
  sessionId={sessionId}
  open={comparisonSheetOpen}
  onOpenChange={setComparisonSheetOpen}
/>
```

Note: The `workout` object from the query should include `inviteId` — update the workout detail query type to include it if needed.

- [ ] **Step 5: Add inviteId to workout types**

In `web/src/lib/types.ts`, add `inviteId` to the `WorkoutSession` or `WorkoutSessionDetail` type:

```typescript
inviteId?: string | null;
```

- [ ] **Step 6: Verify frontend compiles**

Run:
```powershell
Set-Location C:\Users\filip\Desktop\TrainingApp\web
npx tsc --noEmit
```

- [ ] **Step 7: Commit**

```powershell
git add web/src/lib/types.ts web/src/lib/api-client.ts web/src/components/workouts/workout-comparison-sheet.tsx web/src/components/workouts/workout-editor.tsx
git commit -m "feat: add post-workout comparison sheet with % deltas"
```

---

## Verification

After all tasks are complete, test end-to-end:

1. **Kudos:** Open social feed → tap emoji on event → verify toggle + count → refresh → verify persistence
2. **Copy programs:** Create program → toggle "Share" → as another user, visit profile → copy → verify clone in library
3. **Notifications:** Verify bell icon in header → send a workout invite → verify notification appears with unread badge
4. **Workout invites:** Start workout → tap "Invite" → pick a friend → friend sees notification → accept → verify cloned workout session starts
5. **Comparison:** Both users complete their workouts → tap "Compare with mate" → verify % deltas (not raw numbers) for each exercise

Run:
```powershell
Set-Location C:\Users\filip\Desktop\TrainingApp\backend
npm run build

Set-Location C:\Users\filip\Desktop\TrainingApp\web
npx tsc --noEmit
```
