/// LiftIQ - Test Data Helpers
///
/// Provides mock data and provider overrides for unit tests.
/// Avoids test dependencies on Firebase, SharedPreferences, or real data.
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:liftiq/core/services/api_client.dart';
import 'package:liftiq/core/services/auth_service.dart';
import 'package:liftiq/features/exercises/models/exercise.dart';
import 'package:liftiq/features/analytics/models/analytics_data.dart';
import 'package:liftiq/features/analytics/models/workout_summary.dart';
import 'package:liftiq/features/analytics/providers/analytics_provider.dart';
import 'package:liftiq/features/exercises/providers/exercise_provider.dart';

// ============================================================================
// MOCK EXERCISES
// ============================================================================

final testExercises = [
  const Exercise(
    id: 'bench-press',
    name: 'Barbell Bench Press',
    primaryMuscles: [MuscleGroup.chest],
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    equipment: Equipment.barbell,
    exerciseType: ExerciseType.strength,
  ),
  const Exercise(
    id: 'squat',
    name: 'Barbell Squat',
    primaryMuscles: [MuscleGroup.quads],
    secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.hamstrings],
    equipment: Equipment.barbell,
    exerciseType: ExerciseType.strength,
  ),
  const Exercise(
    id: 'deadlift',
    name: 'Barbell Deadlift',
    primaryMuscles: [MuscleGroup.back, MuscleGroup.hamstrings],
    secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.forearms],
    equipment: Equipment.barbell,
    exerciseType: ExerciseType.strength,
  ),
  const Exercise(
    id: 'dumbbell-curl',
    name: 'Dumbbell Bicep Curl',
    primaryMuscles: [MuscleGroup.biceps],
    secondaryMuscles: [MuscleGroup.forearms],
    equipment: Equipment.dumbbell,
    exerciseType: ExerciseType.strength,
  ),
  const Exercise(
    id: 'cable-fly',
    name: 'Cable Fly',
    primaryMuscles: [MuscleGroup.chest],
    secondaryMuscles: [],
    equipment: Equipment.cable,
    exerciseType: ExerciseType.strength,
  ),
];

// ============================================================================
// MOCK WORKOUT SUMMARIES
// ============================================================================

final testWorkoutSummaries = [
  WorkoutSummary(
    id: 'w1',
    date: DateTime(2026, 2, 4),
    completedAt: DateTime(2026, 2, 4, 17, 5),
    durationMinutes: 65,
    templateName: 'Push Day',
    exerciseCount: 5,
    totalSets: 20,
    totalVolume: 12500,
  ),
  WorkoutSummary(
    id: 'w2',
    date: DateTime(2026, 2, 3),
    completedAt: DateTime(2026, 2, 3, 16, 55),
    durationMinutes: 55,
    templateName: 'Pull Day',
    exerciseCount: 4,
    totalSets: 16,
    totalVolume: 9800,
  ),
  WorkoutSummary(
    id: 'w3',
    date: DateTime(2026, 2, 1),
    completedAt: DateTime(2026, 2, 1, 18, 10),
    durationMinutes: 70,
    templateName: 'Leg Day',
    exerciseCount: 6,
    totalSets: 24,
    totalVolume: 18000,
  ),
];

// ============================================================================
// MOCK PERSONAL RECORDS
// ============================================================================

final testPersonalRecords = [
  PersonalRecord(
    exerciseId: 'bench-press',
    exerciseName: 'Barbell Bench Press',
    weight: 100.0,
    reps: 5,
    estimated1RM: 100.0 * (1 + 5 / 30),
    achievedAt: DateTime(2026, 2, 4),
    sessionId: 'w1',
    isAllTime: true,
  ),
  PersonalRecord(
    exerciseId: 'squat',
    exerciseName: 'Barbell Squat',
    weight: 140.0,
    reps: 5,
    estimated1RM: 140.0 * (1 + 5 / 30),
    achievedAt: DateTime(2026, 2, 1),
    sessionId: 'w3',
    isAllTime: true,
  ),
];

// ============================================================================
// MOCK VOLUME DATA
// ============================================================================

final testVolumeByMuscle = [
  const MuscleVolumeData(
    muscleGroup: 'Chest',
    totalSets: 16,
    totalVolume: 8000,
    exerciseCount: 3,
    averageIntensity: 75,
  ),
  const MuscleVolumeData(
    muscleGroup: 'Back',
    totalSets: 14,
    totalVolume: 7200,
    exerciseCount: 3,
    averageIntensity: 72,
  ),
];

// ============================================================================
// MOCK 1RM TREND DATA
// ============================================================================

final testOneRMTrend = [
  OneRMDataPoint(
    date: DateTime(2026, 1, 15),
    weight: 90.0,
    reps: 5,
    estimated1RM: 90.0 * (1 + 5 / 30),
    isPR: false,
  ),
  OneRMDataPoint(
    date: DateTime(2026, 2, 1),
    weight: 95.0,
    reps: 5,
    estimated1RM: 95.0 * (1 + 5 / 30),
    isPR: true,
  ),
  OneRMDataPoint(
    date: DateTime(2026, 2, 4),
    weight: 100.0,
    reps: 5,
    estimated1RM: 100.0 * (1 + 5 / 30),
    isPR: true,
  ),
];

// ============================================================================
// PROVIDER OVERRIDES
// ============================================================================

// ============================================================================
// MOCK API CLIENT
// ============================================================================

/// Mock AuthService to avoid Firebase dependency.
class MockAuthService extends Mock implements AuthService {}

/// Creates a mock ApiClient with Dio interceptors that return GDPR responses.
ApiClient createMockApiClient() {
  final dio = Dio(BaseOptions(baseUrl: 'https://mock.test'));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      if (options.path.contains('/settings/gdpr/export')) {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'data': {
              'id': 'export-123',
              'status': 'processing',
              'requestedAt': DateTime.now().toIso8601String(),
            }
          },
        ));
      } else if (options.path.contains('/settings/gdpr/delete') &&
          options.method == 'DELETE') {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {'success': true},
        ));
      } else if (options.path.contains('/settings/gdpr/delete')) {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'data': {
              'id': 'delete-123',
              'status': 'pending',
              'requestedAt': DateTime.now().toIso8601String(),
              'scheduledDeletionAt':
                  DateTime.now().add(const Duration(days: 30)).toIso8601String(),
              'canCancel': true,
            }
          },
        ));
      } else {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {},
        ));
      }
    },
  ));

  return ApiClient(dio: dio, authService: MockAuthService());
}

// ============================================================================
// PROVIDER OVERRIDES
// ============================================================================

/// Overrides for GDPR-related tests — provides mock API client.
List<Override> get gdprTestOverrides => [
      apiClientProvider.overrideWithValue(createMockApiClient()),
    ];

/// Overrides for exercise-related tests — provides mock exercise data.
List<Override> get exerciseTestOverrides => [
      exerciseListProvider.overrideWith((ref) async => testExercises),
    ];

/// Overrides for analytics-related tests — provides mock workout data.
List<Override> get analyticsTestOverrides => [
      workoutHistoryListProvider.overrideWith(
        (ref) async => testWorkoutSummaries,
      ),
      personalRecordsProvider.overrideWith(
        (ref) async => testPersonalRecords,
      ),
      volumeByMuscleProvider.overrideWith(
        (ref) async => testVolumeByMuscle,
      ),
      oneRMTrendProvider.overrideWith(
        (ref, exerciseId) async => testOneRMTrend,
      ),
    ];
