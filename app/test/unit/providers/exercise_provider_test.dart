/// LiftIQ - Exercise Provider Tests
///
/// Unit tests for exercise-related providers.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liftiq/features/exercises/providers/exercise_provider.dart';
import 'package:liftiq/features/exercises/models/exercise.dart';

import '../../helpers/test_data.dart';

void main() {
  group('ExerciseListProvider', () {
    test('returns list of exercises', () async {
      final container = ProviderContainer(
        overrides: exerciseTestOverrides,
      );
      addTearDown(container.dispose);

      final exercises = await container.read(exerciseListProvider.future);

      expect(exercises, isNotEmpty);
      expect(exercises.first, isA<Exercise>());
    });

    test('exercises have required fields', () async {
      final container = ProviderContainer(
        overrides: exerciseTestOverrides,
      );
      addTearDown(container.dispose);

      final exercises = await container.read(exerciseListProvider.future);

      for (final exercise in exercises) {
        expect(exercise.id, isNotEmpty);
        expect(exercise.name, isNotEmpty);
        expect(exercise.primaryMuscles, isNotEmpty);
        expect(exercise.equipment, isNotNull);
      }
    });
  });

  group('ExerciseSearchProvider', () {
    test('search query state updates correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial state
      expect(container.read(exerciseSearchQueryProvider), equals(''));

      // Update query
      container.read(exerciseSearchQueryProvider.notifier).state = 'bench';
      expect(container.read(exerciseSearchQueryProvider), equals('bench'));
    });
  });

  group('ExerciseFilterProvider', () {
    test('initial state has no filters', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filter = container.read(exerciseFilterProvider);

      expect(filter.muscleGroup, isNull);
      expect(filter.equipment, isNull);
      expect(filter.showCustomOnly, isFalse);
      expect(filter.hasFilters, isFalse);
    });

    test('setMuscleGroup updates filter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(exerciseFilterProvider.notifier)
          .setMuscleGroup(MuscleGroup.chest);

      final filter = container.read(exerciseFilterProvider);

      expect(filter.muscleGroup, equals(MuscleGroup.chest));
      expect(filter.hasFilters, isTrue);
    });

    test('setEquipment updates filter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(exerciseFilterProvider.notifier)
          .setEquipment(Equipment.barbell);

      final filter = container.read(exerciseFilterProvider);

      expect(filter.equipment, equals(Equipment.barbell));
      expect(filter.hasFilters, isTrue);
    });

    test('clearFilters resets all filters', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Set some filters
      container
          .read(exerciseFilterProvider.notifier)
          .setMuscleGroup(MuscleGroup.chest);
      container
          .read(exerciseFilterProvider.notifier)
          .setEquipment(Equipment.barbell);
      container.read(exerciseFilterProvider.notifier).setShowCustomOnly(true);

      // Clear all
      container.read(exerciseFilterProvider.notifier).clearFilters();

      final filter = container.read(exerciseFilterProvider);

      expect(filter.muscleGroup, isNull);
      expect(filter.equipment, isNull);
      expect(filter.showCustomOnly, isFalse);
      expect(filter.hasFilters, isFalse);
    });
  });

  group('ExercisesByMuscleProvider', () {
    test('returns exercises for muscle group', () async {
      final container = ProviderContainer(
        overrides: exerciseTestOverrides,
      );
      addTearDown(container.dispose);

      final exercises = await container
          .read(exercisesByMuscleProvider(MuscleGroup.chest).future);

      expect(exercises, isNotEmpty);
      expect(
        exercises.every((e) =>
            e.primaryMuscles.contains(MuscleGroup.chest) ||
            e.secondaryMuscles.contains(MuscleGroup.chest)),
        isTrue,
      );
    });
  });

  group('ExercisesByEquipmentProvider', () {
    test('returns exercises for equipment type', () async {
      final container = ProviderContainer(
        overrides: exerciseTestOverrides,
      );
      addTearDown(container.dispose);

      final exercises = await container
          .read(exercisesByEquipmentProvider(Equipment.dumbbell).future);

      expect(exercises, isNotEmpty);
      expect(
        exercises.every((e) => e.equipment == Equipment.dumbbell),
        isTrue,
      );
    });
  });

  group('ExerciseDetailProvider', () {
    test('returns exercise by id', () async {
      final container = ProviderContainer(
        overrides: exerciseTestOverrides,
      );
      addTearDown(container.dispose);

      // Keep a listener alive to prevent autoDispose during async load
      final sub = container.listen(
        exerciseDetailProvider('bench-press'),
        (_, __) {},
      );

      final exercise =
          await container.read(exerciseDetailProvider('bench-press').future);

      expect(exercise, isNotNull);
      expect(exercise!.id, equals('bench-press'));
      expect(exercise.name, equals('Barbell Bench Press'));

      sub.close();
    });

    test('returns null for unknown id', () async {
      final container = ProviderContainer(
        overrides: exerciseTestOverrides,
      );
      addTearDown(container.dispose);

      // Keep a listener alive to prevent autoDispose during async load
      final sub = container.listen(
        exerciseDetailProvider('unknown-id'),
        (_, __) {},
      );

      final exercise =
          await container.read(exerciseDetailProvider('unknown-id').future);

      expect(exercise, isNull);

      sub.close();
    });
  });
}
