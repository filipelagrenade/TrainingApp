DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM pg_class
        WHERE relname = 'ExerciseEquivalency_userId_sourceExerciseId_targetExerciseId_ke'
    ) THEN
        ALTER INDEX "ExerciseEquivalency_userId_sourceExerciseId_targetExerciseId_ke"
            RENAME TO "ExerciseEquivalency_userId_sourceExerciseId_targetExerciseI_key";
    END IF;
END $$;
