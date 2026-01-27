/// LiftIQ App Router Configuration
///
/// Defines all routes and navigation logic using GoRouter.
/// Features:
/// - Type-safe route generation
/// - Authentication guards
/// - Deep linking support
/// - Nested navigation for tabs
/// - Offline mode support (bypasses auth when Firebase not configured)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../main.dart' show firebaseInitialized;
import '../../features/home/screens/home_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../../features/workouts/screens/active_workout_screen.dart';
import '../../features/workouts/screens/workout_history_screen.dart';
import '../../features/workouts/screens/workout_detail_screen.dart';
import '../../features/workouts/screens/workout_exercise_screen.dart';
import '../../features/exercises/screens/exercise_library_screen.dart';
import '../../features/exercises/screens/exercise_detail_screen.dart';
import '../../features/templates/screens/templates_screen.dart';
import '../../features/templates/screens/template_detail_screen.dart';
import '../../features/templates/screens/create_template_screen.dart';
import '../../features/templates/screens/program_detail_screen.dart';
import '../../features/templates/models/workout_template.dart';
import '../../features/programs/screens/create_program_screen.dart';
import '../../features/ai_coach/screens/chat_screen.dart';
import '../../features/social/screens/activity_feed_screen.dart';
import '../../features/social/screens/challenges_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/profile_edit_screen.dart';
import '../../features/analytics/screens/progress_screen.dart';
import '../../features/analytics/screens/weekly_report_screen.dart';
import '../../features/analytics/screens/yearly_wrapped_screen.dart';
import '../../features/achievements/screens/achievements_screen.dart';
import '../../features/measurements/screens/measurements_screen.dart';
import '../../features/periodization/screens/periodization_screen.dart';
import '../../features/calendar/screens/workout_calendar_screen.dart';

/// Provider for the app router.
///
/// This is a Riverpod provider that creates the GoRouter instance.
/// Using a provider allows us to:
/// - Access auth state for route guards
/// - Hot-reload router configuration
/// - Test routes easily
final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth state for route guards
  final authState = ref.watch(authStateProvider);

  // Only watch the specific setting we need for routing decisions.
  // This prevents the router from rebuilding when unrelated settings change
  // (like advanced progression settings), which was causing pushed pages to pop.
  final hasCompletedOnboarding = ref.watch(hasCompletedOnboardingProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,

    // Global redirect for authentication
    redirect: (context, state) {
      // If Firebase is not configured, skip auth entirely (development mode)
      // This allows the app to run without Firebase for testing other features
      if (!firebaseInitialized) {
        final isOnLoginPage = state.matchedLocation == '/login';
        final isOnOnboarding = state.matchedLocation == '/onboarding';

        // In offline mode, redirect login to home (no auth needed)
        if (isOnLoginPage) {
          // Check if user has completed onboarding
          if (!hasCompletedOnboarding) {
            return '/onboarding';
          }
          return '/';
        }

        // If on onboarding but already completed, go home
        if (isOnOnboarding && hasCompletedOnboarding) {
          return '/';
        }

        // Otherwise allow navigation (no auth required in offline mode)
        return null;
      }

      // Firebase is configured - use normal auth flow
      final isLoggedIn = authState.maybeWhen(
        data: (user) => user != null,
        orElse: () => false,
      );
      final isLoading = authState.isLoading;
      final isOnLoginPage = state.matchedLocation == '/login';
      final isOnOnboarding = state.matchedLocation == '/onboarding';

      // Don't redirect while loading auth state
      if (isLoading) return null;

      // If not logged in and not on login/onboarding, redirect to login
      if (!isLoggedIn && !isOnLoginPage && !isOnOnboarding) {
        return '/login';
      }

      // If logged in and on login page, redirect to home or onboarding
      if (isLoggedIn && isOnLoginPage) {
        // Check if user has completed onboarding
        if (!hasCompletedOnboarding) {
          return '/onboarding';
        }
        return '/';
      }

      // If logged in, completed onboarding, but still on onboarding page, go home
      if (isLoggedIn && isOnOnboarding && hasCompletedOnboarding) {
        return '/';
      }

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
              return WorkoutExerciseScreen(exerciseId: exerciseId);
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
              return WorkoutDetailScreen(workoutId: workoutId);
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
        builder: (context, state) => const ExerciseLibraryScreen(),
        routes: [
          GoRoute(
            path: ':exerciseId',
            name: 'exerciseDetail',
            builder: (context, state) {
              final exerciseId = state.pathParameters['exerciseId']!;
              return ExerciseDetailScreen(exerciseId: exerciseId);
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
        builder: (context, state) => const TemplatesScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'createTemplate',
            builder: (context, state) => const CreateTemplateScreen(),
          ),
          // Route for editing a template from program view (with template data in extra)
          GoRoute(
            path: 'edit',
            name: 'editProgramWorkout',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final template = extra?['template'] as WorkoutTemplate?;
              final programId = extra?['programId'] as String?;
              final dayNumber = extra?['dayNumber'] as int?;
              return CreateTemplateScreen(
                initialTemplate: template,
                programId: programId,
                programDayNumber: dayNumber,
              );
            },
          ),
          GoRoute(
            path: ':templateId',
            name: 'templateDetail',
            builder: (context, state) {
              final templateId = state.pathParameters['templateId']!;
              return TemplateDetailScreen(templateId: templateId);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: 'editTemplate',
                builder: (context, state) {
                  final templateId = state.pathParameters['templateId']!;
                  return CreateTemplateScreen(templateId: templateId);
                },
              ),
            ],
          ),
        ],
      ),

      // ========================================
      // Programs Routes
      // ========================================
      GoRoute(
        path: '/programs/create',
        name: 'createProgram',
        builder: (context, state) => const CreateProgramScreen(),
      ),
      GoRoute(
        path: '/programs/:programId',
        name: 'programDetail',
        builder: (context, state) {
          final programId = state.pathParameters['programId']!;
          return ProgramDetailScreen(programId: programId);
        },
        routes: [
          GoRoute(
            path: 'edit',
            name: 'editProgram',
            builder: (context, state) {
              final programId = state.pathParameters['programId']!;
              return CreateProgramScreen(programId: programId);
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
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: '/weekly-report',
        name: 'weeklyReport',
        builder: (context, state) => const WeeklyReportScreen(),
      ),
      GoRoute(
        path: '/yearly-wrapped',
        name: 'yearlyWrapped',
        builder: (context, state) => const YearlyWrappedScreen(),
      ),

      // ========================================
      // AI Coach Routes
      // ========================================
      GoRoute(
        path: '/ai-coach',
        name: 'aiCoach',
        builder: (context, state) => const ChatScreen(),
      ),

      // ========================================
      // Social Routes
      // ========================================
      GoRoute(
        path: '/social',
        name: 'socialFeed',
        builder: (context, state) => const ActivityFeedScreen(),
      ),
      GoRoute(
        path: '/challenges',
        name: 'challenges',
        builder: (context, state) => const ChallengesScreen(),
      ),

      // ========================================
      // Achievements Routes
      // ========================================
      GoRoute(
        path: '/achievements',
        name: 'achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),

      // ========================================
      // Measurements Routes
      // ========================================
      GoRoute(
        path: '/measurements',
        name: 'measurements',
        builder: (context, state) => const MeasurementsScreen(),
      ),

      // ========================================
      // Periodization Routes
      // ========================================
      GoRoute(
        path: '/periodization',
        name: 'periodization',
        builder: (context, state) => const PeriodizationScreen(),
      ),

      // ========================================
      // Calendar Routes
      // ========================================
      GoRoute(
        path: '/calendar',
        name: 'calendar',
        builder: (context, state) => const WorkoutCalendarScreen(),
      ),

      // ========================================
      // Settings Routes
      // ========================================
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfileEditScreen(),
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
