import type {
  ActiveProgram,
  ActivityEvent,
  AchievementLibraryItem,
  ApiResponse,
  Challenge,
  CreateProgramInput,
  CreateTemplateInput,
  CreateExerciseInput,
  Exercise,
  ExerciseSubstitutes,
  LeaderboardEntry,
  Program,
  ProgramDraft,
  SocialUser,
  TemplateDraft,
  User,
  WorkoutTemplate,
  WorkoutDraft,
  WorkoutSession,
  WorkoutSessionDetail,
} from "./types";

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:4000/api/v1";

class HttpError extends Error {
  readonly code: string;

  constructor(message: string, code = "REQUEST_FAILED") {
    super(message);
    this.code = code;
  }
}

const request = async <T>(path: string, init?: RequestInit): Promise<T> => {
  const response = await fetch(`${API_URL}${path}`, {
    ...init,
    credentials: "include",
    headers: {
      "Content-Type": "application/json",
      ...(init?.headers ?? {}),
    },
  });

  const json = (await response.json()) as ApiResponse<T>;

  if (!response.ok || !json.success) {
    const error = json.success ? new HttpError("Request failed") : new HttpError(json.error.message, json.error.code);
    throw error;
  }

  return json.data;
};

export const apiClient = {
  getMe: () => request<{ user: User }>("/auth/me"),
  getAchievements: () => request<AchievementLibraryItem[]>("/achievements"),
  register: (payload: { email: string; password: string; displayName: string }) =>
    request<{ user: User }>("/auth/register", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  login: (payload: { email: string; password: string }) =>
    request<{ user: User }>("/auth/login", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  logout: () =>
    request<{ ok: boolean }>("/auth/logout", {
      method: "POST",
    }),
  getExercises: () => request<Exercise[]>("/exercises"),
  getExerciseSubstitutes: (exerciseId: string) =>
    request<ExerciseSubstitutes>(`/exercises/${exerciseId}/substitutes`),
  createExercise: (payload: CreateExerciseInput) =>
    request<Exercise>("/exercises", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  createExerciseEquivalency: (payload: { sourceExerciseId: string; targetExerciseId: string }) =>
    request<ExerciseSubstitutes>("/exercises/equivalencies", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  deleteExerciseEquivalency: (sourceExerciseId: string, targetExerciseId: string) =>
    request<{ ok: boolean }>(`/exercises/${sourceExerciseId}/equivalencies/${targetExerciseId}`, {
      method: "DELETE",
    }),
  getTemplates: () => request<WorkoutTemplate[]>("/templates"),
  createTemplate: (payload: CreateTemplateInput) =>
    request<WorkoutTemplate>("/templates", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  updateTemplate: (templateId: string, payload: CreateTemplateInput) =>
    request<WorkoutTemplate>(`/templates/${templateId}`, {
      method: "PUT",
      body: JSON.stringify(payload),
    }),
  duplicateTemplate: (templateId: string) =>
    request<WorkoutTemplate>(`/templates/${templateId}/duplicate`, {
      method: "POST",
    }),
  deleteTemplate: (templateId: string) =>
    request<{ ok: boolean }>(`/templates/${templateId}`, {
      method: "DELETE",
    }),
  generateTemplateDraft: (payload: { prompt: string }) =>
    request<TemplateDraft>("/templates/generate-draft", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  getPrograms: () => request<Program[]>("/programs"),
  getProgram: (programId: string) => request<Program>(`/programs/${programId}`),
  getActiveProgram: () => request<ActiveProgram | null>("/programs/active"),
  generateProgramDraft: (payload: { prompt: string }) =>
    request<ProgramDraft>("/programs/generate-draft", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  createProgram: (payload: CreateProgramInput) =>
    request<Program>("/programs", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  updateProgram: (programId: string, payload: CreateProgramInput) =>
    request<Program>(`/programs/${programId}`, {
      method: "PUT",
      body: JSON.stringify(payload),
    }),
  activateProgram: (programId: string) =>
    request<Program>(`/programs/${programId}/activate`, {
      method: "POST",
    }),
  archiveProgram: (programId: string) =>
    request<Program>(`/programs/${programId}/archive`, {
      method: "POST",
    }),
  getRecentWorkouts: (limit?: number) =>
    request<WorkoutSession[]>(`/workouts${limit ? `?limit=${limit}` : ""}`),
  getInProgressWorkout: () => request<WorkoutSession | null>("/workouts/in-progress"),
  startWorkout: (payload: {
    entryType: WorkoutSession["entryType"];
    programWorkoutId?: string;
    templateId?: string;
    title?: string;
  }) =>
    request<WorkoutSession>("/workouts/start", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  getWorkout: (workoutId: string) => request<WorkoutSessionDetail>(`/workouts/${workoutId}`),
  saveWorkoutDraft: (workoutId: string, payload: WorkoutDraft) =>
    request<WorkoutSession>(`/workouts/${workoutId}/draft`, {
      method: "PATCH",
      body: JSON.stringify(payload),
    }),
  applyWorkoutSubstitution: (
    workoutId: string,
    payload: { exerciseIndex: number; substituteExerciseId: string },
  ) =>
    request<WorkoutDraft>(`/workouts/${workoutId}/substitute`, {
      method: "PATCH",
      body: JSON.stringify(payload),
    }),
  removeWorkoutSubstitution: (workoutId: string, exerciseIndex: number) =>
    request<WorkoutDraft>(`/workouts/${workoutId}/substitute/${exerciseIndex}`, {
      method: "DELETE",
    }),
  pairWorkoutSuperset: (workoutId: string, payload: { exerciseIndexes: [number, number] }) =>
    request<WorkoutDraft>(`/workouts/${workoutId}/supersets`, {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  unpairWorkoutSuperset: (workoutId: string, supersetGroupId: string) =>
    request<WorkoutDraft>(`/workouts/${workoutId}/supersets/${supersetGroupId}`, {
      method: "DELETE",
    }),
  completeWorkout: (workoutId: string, payload: WorkoutDraft) =>
    request<{
      workoutId: string;
      xpAwarded: number;
      prCount: number;
      completedWeek: boolean;
      unlockedAchievements: string[];
      nextWeek: number;
    }>(`/workouts/${workoutId}/complete`, {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  getLeaderboard: () => request<LeaderboardEntry[]>("/social/leaderboard"),
  getChallenges: () => request<Challenge[]>("/social/challenges"),
  getFollowing: () => request<SocialUser[]>("/social/following"),
  searchUsers: (query: string) =>
    request<SocialUser[]>(`/social/search?q=${encodeURIComponent(query)}`),
  followUser: (userId: string) =>
    request<{ id: string }>(`/social/follow/${userId}`, {
      method: "POST",
    }),
  unfollowUser: (userId: string) =>
    request<{ ok: boolean }>(`/social/follow/${userId}`, {
      method: "DELETE",
    }),
  joinChallenge: (challengeId: string) =>
    request<{ id: string }>(`/social/challenges/${challengeId}/join`, {
      method: "POST",
    }),
  getFeed: () => request<ActivityEvent[]>("/social/feed"),
};
