/// LiftIQ Home Screen
///
/// The main screen after authentication. Provides quick access to:
/// - Start a new workout
/// - View recent workouts
/// - Access templates
/// - View progress
///
/// Uses bottom navigation for primary features.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../exercises/screens/exercise_library_screen.dart';
import '../../workouts/screens/workout_history_screen.dart';
import '../../analytics/screens/progress_screen.dart';
import '../../analytics/providers/analytics_provider.dart';
import '../../analytics/models/workout_summary.dart';
import '../../programs/providers/active_program_provider.dart';
import '../../programs/models/active_program.dart';
import '../../settings/screens/settings_screen.dart';
import '../../workouts/providers/current_workout_provider.dart';
import '../../workouts/models/workout_session.dart';
import '../../analytics/widgets/weekly_report_card.dart';
import '../../analytics/widgets/streak_calendar.dart';
import '../../progression/widgets/deload_suggestion_card.dart';
import '../../templates/providers/templates_provider.dart';

/// Provider for the current bottom navigation tab index.
/// This allows child widgets to switch tabs programmatically.
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

/// Home screen with bottom navigation.
///
/// This is the main hub of the app after login.
class HomeScreen extends ConsumerWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          _DashboardTab(),
          WorkoutHistoryScreen(),
          ExerciseLibraryScreen(),
          ProgressScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(homeTabIndexProvider.notifier).state = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Exercises',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: currentIndex == 0
          ? _buildWorkoutFab(context, ref)
          : null,
    );
  }

  Widget _buildWorkoutFab(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(currentWorkoutProvider);
    final hasActiveWorkout = workoutState is ActiveWorkout;

    if (hasActiveWorkout) {
      // Show Resume FAB if there's an active workout
      return FloatingActionButton.extended(
        onPressed: () => context.go('/workout'),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Resume Workout'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        foregroundColor: Theme.of(context).colorScheme.onTertiary,
      );
    }

    // Show Start FAB if no active workout
    return FloatingActionButton.extended(
      onPressed: () => _showStartWorkoutSheet(context),
      icon: const Icon(Icons.play_arrow),
      label: const Text('Start Workout'),
    );
  }

  static void _showStartWorkoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Start Workout',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.flash_on),
              title: const Text('Quick Workout'),
              subtitle: const Text('Start empty and add exercises'),
              onTap: () {
                Navigator.pop(context);
                context.go('/workout');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('From Template'),
              subtitle: const Text('Use a saved workout template'),
              onTap: () {
                Navigator.pop(context);
                context.push('/templates');
              },
            ),
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('Repeat Last'),
              subtitle: const Text('Repeat your most recent workout'),
              onTap: () {
                Navigator.pop(context);
                context.go('/workout');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Dashboard tab showing overview and quick actions.
class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('LiftIQ'),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              tooltip: 'Workout Calendar',
              onPressed: () {
                context.push('/calendar');
              },
            ),
            IconButton(
              icon: const Icon(Icons.emoji_events_outlined),
              tooltip: 'Achievements',
              onPressed: () {
                context.go('/achievements');
              },
            ),
            IconButton(
              icon: const Icon(Icons.smart_toy_outlined),
              tooltip: 'AI Coach',
              onPressed: () {
                context.go('/ai-coach');
              },
            ),
            IconButton(
              icon: const Icon(Icons.people_outline),
              tooltip: 'Social',
              onPressed: () {
                context.go('/social');
              },
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Resume Workout card (shows when there's an active workout)
              const _ResumeWorkoutCard(),
              // Current Program card (only shows when enrolled)
              // Or "Browse Programs" prompt when not enrolled
              const _CurrentProgramCard(),
              const _BrowseProgramsPrompt(),
              // Weekly report card with real data (replaces old "This Week" block)
              const WeeklyReportCard(),
              const SizedBox(height: 16),
              const DeloadSuggestionCard(),
              const SizedBox(height: 16),
              const StreakCard(),
              const SizedBox(height: 16),
              // Recent workouts section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Workouts',
                    style: context.textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      // Switch to History tab (index 1)
                      ref.read(homeTabIndexProvider.notifier).state = 1;
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Recent workouts from workout history
              _RecentWorkoutsList(),
              const SizedBox(height: 16),
              // Templates section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Templates',
                    style: context.textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/templates');
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Template cards from actual data
              _TemplatesList(),
              const SizedBox(height: 80), // Space for FAB
            ]),
          ),
        ),
      ],
    );
  }
}

/// Weekly summary card that displays real workout stats from the past 7 days.
class _WeeklySummaryCard extends ConsumerWidget {
  const _WeeklySummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(weeklyStatsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            statsAsync.when(
              data: (stats) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'Workouts',
                    value: '${stats.workoutCount}',
                    icon: Icons.fitness_center,
                  ),
                  _StatItem(
                    label: 'Volume',
                    value: stats.formattedVolume,
                    icon: Icons.scale,
                  ),
                  _StatItem(
                    label: 'PRs',
                    value: '${stats.prsAchieved}',
                    icon: Icons.emoji_events,
                  ),
                ],
              ),
              loading: () => const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: 'Workouts', value: '-', icon: Icons.fitness_center),
                  _StatItem(label: 'Volume', value: '-', icon: Icons.scale),
                  _StatItem(label: 'PRs', value: '-', icon: Icons.emoji_events),
                ],
              ),
              error: (_, __) => const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: 'Workouts', value: '0', icon: Icons.fitness_center),
                  _StatItem(label: 'Volume', value: '0', icon: Icons.scale),
                  _StatItem(label: 'PRs', value: '0', icon: Icons.emoji_events),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: context.colors.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _TemplatesList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);

    return SizedBox(
      height: 120,
      child: templatesAsync.when(
        data: (templates) => ListView(
          scrollDirection: Axis.horizontal,
          children: [
            ...templates.take(5).map((t) => _TemplateCard(
                  name: t.name,
                  exercises: t.exercises.length,
                  onTap: () => context.push('/templates'),
                )),
            _AddTemplateCard(onTap: () => context.push('/templates')),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text('Could not load templates',
              style: context.textTheme.bodySmall),
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final String name;
  final int exercises;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.name,
    required this.exercises,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.bookmark, color: context.colors.primary),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: context.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$exercises exercises',
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddTemplateCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddTemplateCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 32,
                color: context.colors.outline,
              ),
              const SizedBox(height: 8),
              Text(
                'New Template',
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Current Program card showing active program progress.
///
/// Displays:
/// - Program name with progress percentage
/// - Week X of Y - Day Z
/// - Progress bar
/// - "Continue Workout" button for one-tap access
///
/// Only visible when user is enrolled in a program.
class _CurrentProgramCard extends ConsumerWidget {
  const _CurrentProgramCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programState = ref.watch(activeProgramProvider);

    // Handle loading state - show a placeholder
    if (programState is ProgramLoading) {
      return const SizedBox.shrink(); // Or show a loading shimmer
    }

    // No active program - hide the card
    if (programState is NoActiveProgram) {
      return const SizedBox.shrink();
    }

    // Error state - hide the card (could show error instead)
    if (programState is ProgramError) {
      debugPrint('ActiveProgram Error: ${programState.message}');
      return const SizedBox.shrink();
    }

    // Must be ProgramActive at this point
    if (programState is! ProgramActive) {
      return const SizedBox.shrink();
    }

    final program = programState.program;
    final nextSession = program.nextSession;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/programs/${program.programId}'),
        child: Column(
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.primary,
                    context.colors.primary.withOpacity(0.7),
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Program icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Program name and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Program',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          program.programName,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Progress percentage badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      program.formattedPercentage,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Progress details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Week/Day info
                  Row(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 18,
                        color: context.colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        program.isCompleted
                            ? 'Program Completed!'
                            : 'Week ${program.currentWeek} of ${program.totalWeeks} • Day ${program.currentDayInWeek}'
                              '${program.isDeloadWeek(program.currentWeek) ? ' (Deload)' : ''}',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${program.completedSessionCount}/${program.totalSessions} sessions',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: program.completionPercentage,
                      minHeight: 8,
                      backgroundColor: context.colors.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(context.colors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Continue button
                  if (!program.isCompleted && nextSession != null)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          context.push('/programs/${program.programId}');
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: Text(
                          'Continue: Day ${nextSession.day} Workout',
                        ),
                      ),
                    ),
                  if (program.isCompleted)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: () {
                          context.push('/programs/${program.programId}');
                        },
                        icon: const Icon(Icons.emoji_events),
                        label: const Text('View Completed Program'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Prompt to browse programs when no active program.
///
/// Shows a compact card encouraging users to start a training program.
/// Only visible when there's no active program enrolled.
class _BrowseProgramsPrompt extends ConsumerWidget {
  const _BrowseProgramsPrompt();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programState = ref.watch(activeProgramProvider);

    // Only show if there's NO active program
    if (programState is ProgramActive) {
      return const SizedBox.shrink();
    }

    // Don't show during loading
    if (programState is ProgramLoading) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/templates'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_month,
                  color: context.colors.onPrimaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start a Training Program',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Follow a structured plan with progress tracking',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: context.colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Resume Workout card for continuing an active workout.
///
/// Shows when there's an active workout in progress.
/// Displays workout name, duration, and exercise count.
/// Tapping navigates directly to the active workout screen.
class _ResumeWorkoutCard extends ConsumerWidget {
  const _ResumeWorkoutCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(currentWorkoutProvider);

    // Only show if there's an active workout
    if (workoutState is! ActiveWorkout) {
      return const SizedBox.shrink();
    }

    final workout = workoutState.workout;
    final duration = workout.elapsedDuration;
    final durationText = duration.inHours > 0
        ? '${duration.inHours}h ${duration.inMinutes % 60}m'
        : '${duration.inMinutes}m';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.tertiary,
      child: InkWell(
        onTap: () => context.go('/workout'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row with icon and label
              Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: Colors.white.withOpacity(0.8),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Workout in Progress',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Workout name
              Text(
                workout.templateName ?? 'Quick Workout',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Stats row
              Text(
                '$durationText  •  ${workout.exerciseCount} exercises  •  ${workout.totalSets} sets',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 12),
              // Resume button - full width
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.go('/workout'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.tertiary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Resume Workout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget displaying recent workouts from workout history.
///
/// Shows the last 3 workouts with name, date, and duration.
/// Navigates to workout detail when tapped.
/// Shows empty state if no workouts exist.
class _RecentWorkoutsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workoutHistoryListProvider);

    return historyAsync.when(
      data: (workouts) => _buildWorkoutCards(context, workouts),
      loading: () => const _RecentWorkoutsLoading(),
      error: (error, _) => _buildErrorState(context, error.toString()),
    );
  }

  Widget _buildWorkoutCards(BuildContext context, List<WorkoutSummary> workouts) {
    if (workouts.isEmpty) {
      return _buildEmptyState(context);
    }

    // Show up to 3 recent workouts
    final recentWorkouts = workouts.take(3).toList();

    return Column(
      children: recentWorkouts.map((workout) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: context.colors.primaryContainer,
              child: Icon(
                Icons.fitness_center,
                color: context.colors.onPrimaryContainer,
              ),
            ),
            title: Text(workout.templateName ?? 'Quick Workout'),
            subtitle: Text(
              '${workout.timeAgo} - ${workout.formattedDuration}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (workout.prsAchieved > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: context.colors.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.emoji_events,
                          size: 14,
                          color: context.colors.onTertiaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${workout.prsAchieved}',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onTertiaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              context.push('/history/${workout.id}');
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 48,
              color: context.colors.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No workouts yet',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Start your first workout to see it here!',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: context.colors.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Failed to load workouts',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading shimmer for recent workouts.
class _RecentWorkoutsLoading extends StatelessWidget {
  const _RecentWorkoutsLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(2, (index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: context.colors.surfaceContainerHighest,
            ),
            title: Container(
              height: 16,
              width: 100,
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            subtitle: Container(
              height: 12,
              width: 80,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// Note: History, Exercises, Progress, and Settings tabs use the real screens
// from their respective feature modules (imported at the top of this file).
