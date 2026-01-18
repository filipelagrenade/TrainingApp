/// LiftIQ - Exercise Library Screen Widget Tests
///
/// Widget tests for the ExerciseLibraryScreen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liftiq/features/exercises/screens/exercise_library_screen.dart';

void main() {
  group('ExerciseLibraryScreen', () {
    testWidgets('displays app bar with title', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ExerciseLibraryScreen(),
          ),
        ),
      );

      // Wait for async providers and timers to complete
      await tester.pumpAndSettle();

      expect(find.text('Exercises'), findsOneWidget);
    });

    testWidgets('displays search bar with hint text', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ExerciseLibraryScreen(),
          ),
        ),
      );

      // Wait for async providers and timers to complete
      await tester.pumpAndSettle();

      // Should have a text field for search
      expect(find.byType(TextField), findsWidgets);
      // Verify search hint is present
      expect(find.text('Search exercises...'), findsOneWidget);
    });

    testWidgets('displays exercises after loading', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ExerciseLibraryScreen(),
          ),
        ),
      );

      // Wait for data to load
      await tester.pumpAndSettle();

      // Should have exercise cards
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('can enter search text', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ExerciseLibraryScreen(),
          ),
        ),
      );

      // Wait for load
      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField).first, 'bench');
      await tester.pumpAndSettle();

      // Test passes if no errors
      expect(find.byType(ExerciseLibraryScreen), findsOneWidget);
    });

    testWidgets('displays filter button in app bar', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ExerciseLibraryScreen(),
          ),
        ),
      );

      // Wait for async providers and timers to complete
      await tester.pumpAndSettle();

      // Should have filter icon button
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('displays floating action button for custom exercise', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ExerciseLibraryScreen(),
          ),
        ),
      );

      // Wait for async providers and timers to complete
      await tester.pumpAndSettle();

      // Should have FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
    });
  });
}
