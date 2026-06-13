import type {
  ActiveProgram,
  ActivityEvent,
  ApiResponse,
  AppNotification,
  BodyMetricEntry,
  BodyMetricsView,
  CardioActivity,
  CardioCalendar,
  CardioPeriod,
  CardioProgression,
  CardioSession,
  CardioSessionInput,
  CardioSummary,
  Challenge,
  ChallengeLibrary,
  CreateBodyMetricInput,
  CreateProgramInput,
  CreateTemplateInput,
  CreateExerciseInput,
  Exercise,
  ExerciseSubstitutes,
  LeaderboardEntry,
  MonthlyRecap,
  PreviousSetsResponse,
  ProfileView,
  Program,
  ProgramDraft,
  ProgramProgression,
  ProgressOverview,
  ExerciseProgressDetail,
  Readiness,
  SocialUser,
  TemplateDraft,
  TrackingMode,
  TrainingCalendar,
  User,
  UserExercisePreference,
  UserSettingsUpdate,
  WorkoutComparison,
  WorkoutInvite,
  WorkoutTemplate,
  WorkoutDraft,
  WorkoutSession,
  WorkoutSessionDetail,
} from "./types";

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "/api/v1";

export class HttpError extends Error {
  readonly code: string;
  /** HTTP status code, when the failure came from a server response (not a network error). */
  readonly status?: number;

  constructor(message: string, code = "REQUEST_FAILED", status?: number) {
    super(message);
    this.code = code;
    this.status = status;
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

  if (response.status === 204) {
    return undefined as T;
  }

  if (response.headers.get("Content-Length") === "0") {
    if (response.ok) return undefined as T;
    throw new HttpError("Empty response from server");
  }

  let json: ApiResponse<T>;

  try {
    json = await response.json() as ApiResponse<T>;
  } catch {
    throw new HttpError(response.ok ? "Invalid response from server" : "Request failed");
  }

  if (!response.ok || !json.success) {
    const error = json.success
      ? new HttpError("Request failed", "REQUEST_FAILED", response.status)
      : new HttpError(json.error.message, json.error.code, response.status);
    throw error;
  }

  return json.data;
};

export const apiClient = {
  getMe: () => request<{ user: User }>("/auth/me"),
  getAchievements: () => request<ChallengeLibrary>("/achievements"),
  getProgressOverview: () => request<ProgressOverview>("/progress/overview"),
  getExerciseProgress: (exerciseId: string) =>
    request<ExerciseProgressDetail>(`/progress/exercises/${exerciseId}`),
  getMonthlyRecap: (month?: string) =>
    request<MonthlyRecap>(`/progress/recap${month ? `?month=${encodeURIComponent(month)}` : ""}`),
  getTrainingCalendar: (range?: { from?: string; to?: string }) => {
    const params = new URLSearchParams();
    if (range?.from) params.set("from", range.from);
    if (range?.to) params.set("to", range.to);
    const query = params.toString();
    return request<TrainingCalendar>(`/progress/calendar${query ? `?${query}` : ""}`);
  },
  getMyProfile: () => request<ProfileView>("/profile/me"),
  getProfile: (userId: string) => request<ProfileView>(`/profile/${userId}`),
  updateProfileShowcase: (payload: {
    selectedTitleKey?: string | null;
    selectedBadgeKey?: string | null;
  }) =>
    request<{ user: User }>("/profile/showcase", {
      method: "PATCH",
      body: JSON.stringify(payload),
    }),
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
  updatePreferences: (payload: {
    preferredUnit?: "kg" | "lb";
    gender?: "MALE" | "FEMALE" | "NON_BINARY" | "PREFER_NOT_TO_SAY";
  }) =>
    request<{ user: User }>("/auth/preferences", {
      method: "PATCH",
      body: JSON.stringify(payload),
    }),
  logout: () =>
    request<{ ok: boolean }>("/auth/logout", {
      method: "POST",
    }),
  updateSettings: (payload: UserSettingsUpdate) =>
    request<{ user: User }>("/auth/settings", {
      method: "PATCH",
      body: JSON.stringify(payload),
    }),
  getExercisePreferences: () =>
    request<{ preferences: UserExercisePreference[] }>("/exercises/preferences"),
  upsertExercisePreference: (
    exerciseId: string,
    payload: {
      unilateral?: boolean | null;
      trackingMode?: TrackingMode | null;
      barWeight?: number | null;
      restSeconds?: number | null;
    },
  ) =>
    request<{ preference: UserExercisePreference }>(`/exercises/${exerciseId}/preference`, {
      method: "PUT",
      body: JSON.stringify(payload),
    }),
  deleteExercisePreference: (exerciseId: string) =>
    request<{ ok: boolean }>(`/exercises/${exerciseId}/preference`, {
      method: "DELETE",
    }),
  getProgramProgression: (programId: string) =>
    request<ProgramProgression>(`/programs/${programId}/progression`),
  getPreviousSets: (input: { exerciseIds: string[]; slotIds: string[] }) => {
    const params = new URLSearchParams();
    if (input.exerciseIds.length) params.set("exerciseIds", input.exerciseIds.join(","));
    if (input.slotIds.length) params.set("slotIds", input.slotIds.join(","));
    return request<PreviousSetsResponse>(`/workouts/previous-sets?${params.toString()}`);
  },
  getExercises: () => request<Exercise[]>("/exercises"),
  getExerciseSubstitutes: (exerciseId: string) =>
    request<ExerciseSubstitutes>(`/exercises/${exerciseId}/substitutes`),
  createExercise: (payload: CreateExerciseInput) =>
    request<Exercise>("/exercises", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  deleteExercise: (exerciseId: string, payload?: { replacementExerciseId?: string | null }) =>
    request<{ ok: boolean }>(`/exercises/${exerciseId}/delete`, {
      method: "POST",
      body: JSON.stringify({
        replacementExerciseId: payload?.replacementExerciseId ?? null,
      }),
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
  getTemplate: (templateId: string) => request<WorkoutTemplate>(`/templates/${templateId}`),
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
  activateProgram: (
    programId: string,
    payload?: { startWeekNumber?: number; startWorkoutId?: string },
  ) =>
    request<Program>(`/programs/${programId}/activate`, {
      method: "POST",
      body: JSON.stringify(payload ?? {}),
    }),
  archiveProgram: (programId: string) =>
    request<Program>(`/programs/${programId}/archive`, {
      method: "POST",
    }),
  deleteProgram: (programId: string) =>
    request<{ ok: boolean }>(`/programs/${programId}`, {
      method: "DELETE",
    }),
  skipProgramWorkout: (programId: string, workoutId: string) =>
    request<Program>(`/programs/${programId}/workouts/${workoutId}/skip`, {
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
    readiness?: Readiness;
  }) =>
    request<WorkoutSession>("/workouts/start", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  repeatWorkout: (workoutId: string) =>
    request<WorkoutSession>(`/workouts/${workoutId}/repeat`, {
      method: "POST",
    }),
  getWorkout: (workoutId: string) => request<WorkoutSessionDetail>(`/workouts/${workoutId}`),
  saveWorkoutDraft: (workoutId: string, payload: WorkoutDraft) =>
    request<WorkoutSession>(`/workouts/${workoutId}/draft`, {
      method: "PATCH",
      body: JSON.stringify(payload),
    }),
  updateCompletedWorkout: (workoutId: string, payload: WorkoutDraft) =>
    request<WorkoutSession>(`/workouts/${workoutId}/completed`, {
      method: "PATCH",
      body: JSON.stringify(payload),
    }),
  pauseWorkout: (workoutId: string) =>
    request<WorkoutSession>(`/workouts/${workoutId}/pause`, {
      method: "POST",
    }),
  cancelWorkout: (workoutId: string) =>
    request<{ ok: boolean }>(`/workouts/${workoutId}/cancel`, {
      method: "POST",
    }),
  resumeWorkout: (workoutId: string) =>
    request<WorkoutSession>(`/workouts/${workoutId}/resume`, {
      method: "POST",
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
  pairWorkoutSuperset: (workoutId: string, payload: { exerciseIndexes: number[] }) =>
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
  deleteWorkout: (workoutId: string) =>
    request<{ ok: boolean }>(`/workouts/${workoutId}`, {
      method: "DELETE",
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
  addReaction: (eventId: string, emoji: string) =>
    request<{ id: string }>(`/social/feed/${eventId}/reactions`, {
      method: "POST",
      body: JSON.stringify({ emoji }),
    }),
  removeReaction: (eventId: string, emoji: string) =>
    request<{ ok: boolean }>(`/social/feed/${eventId}/reactions/${emoji}`, {
      method: "DELETE",
    }),
  copyProgram: (programId: string) =>
    request<Program>(`/programs/${programId}/copy`, {
      method: "POST",
    }),
  updateProgramAllowCopy: (programId: string, allowCopy: boolean) =>
    request<Program>(`/programs/${programId}`, {
      method: "PATCH",
      body: JSON.stringify({ allowCopy }),
    }),
  getNotifications: () => request<AppNotification[]>("/notifications"),
  getUnreadNotificationCount: () => request<{ count: number }>("/notifications/unread-count"),
  markNotificationRead: (id: string) =>
    request<{ ok: boolean }>(`/notifications/${id}/read`, {
      method: "PATCH",
    }),
  markAllNotificationsRead: () =>
    request<{ ok: boolean }>("/notifications/read-all", {
      method: "POST",
    }),
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
  getWorkoutComparison: (sessionId: string) =>
    request<WorkoutComparison>(`/workouts/${sessionId}/comparison`),
  getBodyMetrics: () => request<BodyMetricsView>("/body-metrics"),
  createBodyMetric: (input: CreateBodyMetricInput) =>
    request<{ entry: BodyMetricEntry }>("/body-metrics", {
      method: "POST",
      body: JSON.stringify(input),
    }),
  deleteBodyMetric: (entryId: string) =>
    request<{ ok: boolean }>(`/body-metrics/${entryId}`, {
      method: "DELETE",
    }),
  getCardioSummary: (period: CardioPeriod = "week") =>
    request<CardioSummary>(`/cardio/summary?period=${period}`),
  getCardioCalendar: (range?: { from?: string; to?: string }) => {
    const params = new URLSearchParams();
    if (range?.from) params.set("from", range.from);
    if (range?.to) params.set("to", range.to);
    const query = params.toString();
    return request<CardioCalendar>(`/cardio/calendar${query ? `?${query}` : ""}`);
  },
  getCardioProgression: (activity?: CardioActivity) =>
    request<CardioProgression>(
      `/cardio/progression${activity ? `?activity=${activity}` : ""}`,
    ),
  listCardioSessions: (params?: { activity?: CardioActivity; limit?: number }) => {
    const search = new URLSearchParams();
    if (params?.activity) search.set("activity", params.activity);
    if (params?.limit) search.set("limit", String(params.limit));
    const query = search.toString();
    return request<CardioSession[]>(`/cardio/sessions${query ? `?${query}` : ""}`);
  },
  createCardioSession: (body: CardioSessionInput) =>
    request<CardioSession>("/cardio/sessions", {
      method: "POST",
      body: JSON.stringify(body),
    }),
  updateCardioSession: (id: string, body: Partial<CardioSessionInput>) =>
    request<CardioSession>(`/cardio/sessions/${id}`, {
      method: "PATCH",
      body: JSON.stringify(body),
    }),
  deleteCardioSession: (id: string) =>
    request<{ id: string }>(`/cardio/sessions/${id}`, {
      method: "DELETE",
    }),
  // The export endpoint streams a file rather than the JSON envelope, so callers
  // navigate to this URL (cookies are sent) instead of going through `request`.
  workoutsExportUrl: (format: "csv" | "json") => `${API_URL}/workouts/export?format=${format}`,
};
