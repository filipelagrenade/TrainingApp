/// LiftIQ App Router Configuration
///
/// Defines all routes and navigation logic using GoRouter.
/// Features:
/// - Type-safe route generation
/// - Authentication guards
/// - Deep linking support
/// - Nested navigation for tabs
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/workouts/screens/active_workout_screen.dart';
import '../../features/workouts/screens/workout_history_screen.dart';

/// Provider for the app router.
///
/// This is a Riverpod provider that creates the GoRouter instance.
/// Using a provider allows us to:
/// - Access auth state for route guards
/// - Hot-reload router configuration
/// - Test routes easily
final appRouterProvider = Provider<GoRouter>((ref) {
  // TODO: Watch auth state for route guards
  // final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,

    // Global redirect for authentication
    redirect: (context, state) {
      // TODO: Implement auth redirect logic
      // final isLoggedIn = authState.isLoggedIn;
      // final isOnLoginPage = state.matchedLocation == '/login';
      // final isOnOnboarding = state.matchedLocation == '/onboarding';
      //
      // if (!isLoggedIn && !isOnLoginPage && !isOnOnboarding) {
      //   return '/login';
      // }
      //
      // if (isLoggedIn && isOnLoginPage) {
      //   return '/';
      // }

      return null;
    },

    routes: [
      // ========================================
      // Main App Routes
      // ========================================
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // ========================================
      // Authentication Routes
      // ========================================
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ========================================
      // Workout Routes
      // ========================================
      GoRoute(
        path: '/workout',
        name: 'activeWorkout',
        builder: (context, state) => const ActiveWorkoutScreen(),
        routes: [
          GoRoute(
            path: 'exercise/:exerciseId',
            name: 'workoutExercise',
            builder: (context, state) {
              final exerciseId = state.pathParameters['exerciseId']!;
              return Placeholder(); // TODO: WorkoutExerciseScreen
            },
          ),
        ],
      ),

      // ========================================
      // History Routes
      // ========================================
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const WorkoutHistoryScreen(),
        routes: [
          GoRoute(
            path: ':workoutId',
            name: 'workoutDetail',
            builder: (context, state) {
              final workoutId = state.pathParameters['workoutId']!;
              return Placeholder(); // TODO: WorkoutDetailScreen
            },
          ),
        ],
      ),

      // ========================================
      // Exercise Library Routes
      // ========================================
      GoRoute(
        path: '/exercises',
        name: 'exercises',
        builder: (context, state) => const Placeholder(), // TODO: ExerciseLibraryScreen
        routes: [
          GoRoute(
            path: ':exerciseId',
            name: 'exerciseDetail',
            builder: (context, state) {
              final exerciseId = state.pathParameters['exerciseId']!;
              return Placeholder(); // TODO: ExerciseDetailScreen
            },
          ),
        ],
      ),

      // ========================================
      // Template Routes
      // ========================================
      GoRoute(
        path: '/templates',
        name: 'templates',
        builder: (context, state) => const Placeholder(), // TODO: TemplatesScreen
        routes: [
          GoRoute(
            path: 'create',
            name: 'createTemplate',
            builder: (context, state) => const Placeholder(), // TODO: CreateTemplateScreen
          ),
          GoRoute(
            path: ':templateId',
            name: 'templateDetail',
            builder: (context, state) {
              final templateId = state.pathParameters['templateId']!;
              return Placeholder(); // TODO: TemplateDetailScreen
            },
          ),
        ],
      ),

      // ========================================
      // Progress/Analytics Routes
      // ========================================
      GoRoute(
        path: '/progress',
        name: 'progress',
        builder: (context, state) => const Placeholder(), // TODO: ProgressScreen
      ),

      // ========================================
      // Settings Routes
      // ========================================
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const Placeholder(), // TODO: SettingsScreen
        routes: [
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const Placeholder(), // TODO: ProfileScreen
          ),
          GoRoute(
            path: 'units',
            name: 'units',
            builder: (context, state) => const Placeholder(), // TODO: UnitsSettingsScreen
          ),
        ],
      ),
    ],

    // Error page for unknown routes
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Extension on BuildContext for easy navigation.
///
/// Usage:
/// ```dart
/// context.pushNamed('workoutDetail', pathParameters: {'workoutId': '123'});
/// context.goNamed('home');
/// ```
extension NavigationExtension on BuildContext {
  /// Navigate to named route, adding to history stack.
  void pushNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    GoRouter.of(this).pushNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  /// Navigate to named route, replacing current route.
  void goNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    GoRouter.of(this).goNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  /// Pop the current route from the stack.
  void pop<T extends Object?>([T? result]) {
    GoRouter.of(this).pop(result);
  }

  /// Check if we can pop the current route.
  bool canPop() {
    return GoRouter.of(this).canPop();
  }
}
