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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

/// Home screen with bottom navigation.
///
/// This is the main hub of the app after login.
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardTab(),
          _HistoryTab(),
          _ExercisesTab(),
          _ProgressTab(),
          _SettingsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
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
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO: Start workout flow
                _showStartWorkoutSheet(context);
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Workout'),
            )
          : null,
    );
  }

  void _showStartWorkoutSheet(BuildContext context) {
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
                // TODO: Navigate to active workout
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('From Template'),
              subtitle: const Text('Use a saved workout template'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show template picker
              },
            ),
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('Repeat Last'),
              subtitle: const Text('Repeat your most recent workout'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Start with last workout
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
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('LiftIQ'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // TODO: Notifications
              },
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Weekly summary card
              Card(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            label: 'Workouts',
                            value: '3',
                            icon: Icons.fitness_center,
                          ),
                          _StatItem(
                            label: 'Volume',
                            value: '12.5k',
                            icon: Icons.scale,
                          ),
                          _StatItem(
                            label: 'PRs',
                            value: '2',
                            icon: Icons.emoji_events,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
                      // TODO: Navigate to history
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Placeholder for recent workouts
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.fitness_center),
                  ),
                  title: const Text('Push Day'),
                  subtitle: const Text('Yesterday - 45 min'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to workout detail
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.fitness_center),
                  ),
                  title: const Text('Pull Day'),
                  subtitle: const Text('2 days ago - 52 min'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to workout detail
                  },
                ),
              ),
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
                      // TODO: Navigate to templates
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Template cards
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _TemplateCard(
                      name: 'Push Day',
                      exercises: 6,
                      onTap: () {},
                    ),
                    _TemplateCard(
                      name: 'Pull Day',
                      exercises: 5,
                      onTap: () {},
                    ),
                    _TemplateCard(
                      name: 'Leg Day',
                      exercises: 5,
                      onTap: () {},
                    ),
                    _AddTemplateCard(onTap: () {}),
                  ],
                ),
              ),
              const SizedBox(height: 80), // Space for FAB
            ]),
          ),
        ),
      ],
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
        borderRadius: BorderRadius.circular(16),
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
        borderRadius: BorderRadius.circular(16),
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

/// History tab placeholder.
class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: const Center(
        child: Text('Workout history will appear here'),
      ),
    );
  }
}

/// Exercises tab placeholder.
class _ExercisesTab extends StatelessWidget {
  const _ExercisesTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      body: const Center(
        child: Text('Exercise library will appear here'),
      ),
    );
  }
}

/// Progress tab placeholder.
class _ProgressTab extends StatelessWidget {
  const _ProgressTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: const Center(
        child: Text('Progress charts will appear here'),
      ),
    );
  }
}

/// Settings tab placeholder.
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Settings will appear here'),
      ),
    );
  }
}
