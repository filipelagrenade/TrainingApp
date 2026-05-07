-- Performance indexes for LiftIQ
-- Eliminates sequential scans on the hottest query paths

-- Program: fast lookup by userId + status (getActiveProgram, listPrograms)
CREATE INDEX "Program_userId_status_idx" ON "Program"("userId", "status");

-- ProgramWorkoutExercise: fast lookup by parent workout and exercise
CREATE INDEX "ProgramWorkoutExercise_programWorkoutId_idx" ON "ProgramWorkoutExercise"("programWorkoutId");
CREATE INDEX "ProgramWorkoutExercise_exerciseId_idx" ON "ProgramWorkoutExercise"("exerciseId");

-- WorkoutSession: the most-queried table — covers all common filter/sort patterns
CREATE INDEX "WorkoutSession_userId_status_completedAt_idx" ON "WorkoutSession"("userId", "status", "completedAt" DESC);
CREATE INDEX "WorkoutSession_userId_status_startedAt_idx" ON "WorkoutSession"("userId", "status", "startedAt" DESC);
CREATE INDEX "WorkoutSession_userId_programId_status_idx" ON "WorkoutSession"("userId", "programId", "status");
CREATE INDEX "WorkoutSession_userId_programWorkoutId_status_idx" ON "WorkoutSession"("userId", "programWorkoutId", "status");

-- WorkoutExercise: critical for batchBuildExposureSnapshots and workout loading
CREATE INDEX "WorkoutExercise_sessionId_idx" ON "WorkoutExercise"("sessionId");
CREATE INDEX "WorkoutExercise_sourceProgramExerciseId_sessionId_idx" ON "WorkoutExercise"("sourceProgramExerciseId", "sessionId");
CREATE INDEX "WorkoutExercise_exerciseId_sessionId_idx" ON "WorkoutExercise"("exerciseId", "sessionId");

-- WorkoutSet: loaded in bulk for every exercise in every workout view
CREATE INDEX "WorkoutSet_workoutExerciseId_idx" ON "WorkoutSet"("workoutExerciseId");

-- ProgressionSnapshot: filtered by userId + programId
CREATE INDEX "ProgressionSnapshot_userId_programId_idx" ON "ProgressionSnapshot"("userId", "programId");
