/// LiftIQ - Exercise Preferences Screen
///
/// Screen for managing favorite and disliked exercises.
/// Users can view, add, and remove exercises from their preferences.
///
/// Features:
/// - Tab view for favorites and dislikes
/// - Search and add exercises from the exercise library
/// - Remove exercises from lists
/// - Preferences are used by AI when generating workouts
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/exercise_preferences_provider.dart';
import '../../workouts/widgets/exercise_picker_modal.dart';

/// Screen for managing exercise preferences (favorites and dislikes).
class ExercisePreferencesScreen extends ConsumerWidget {
  const ExercisePreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final prefs = ref.watch(exercisePreferencesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exercise Preferences'),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.favorite),
                text: 'Favorites (${prefs.favorites.length})',
              ),
              Tab(
                icon: const Icon(Icons.thumb_down),
                text: 'Dislikes (${prefs.dislikes.length})',
              ),
            ],
          ),
        ),
        body: prefs.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Favorites tab
                  _PreferencesList(
                    preferences: prefs.favorites,
                    emptyIcon: Icons.favorite_border,
                    emptyTitle: 'No favorite exercises',
                    emptySubtitle:
                        'Add exercises you enjoy - AI will prioritize them in recommendations',
                    onRemove: (exerciseId) {
                      ref
                          .read(exercisePreferencesProvider.notifier)
                          .removeFavorite(exerciseId);
                    },
                    chipColor: colors.primaryContainer,
                    chipTextColor: colors.onPrimaryContainer,
                  ),
                  // Dislikes tab
                  _PreferencesList(
                    preferences: prefs.dislikes,
                    emptyIcon: Icons.thumb_down_outlined,
                    emptyTitle: 'No disliked exercises',
                    emptySubtitle:
                        'Add exercises you want to avoid - AI will exclude them from recommendations',
                    onRemove: (exerciseId) {
                      ref
                          .read(exercisePreferencesProvider.notifier)
                          .removeDislike(exerciseId);
                    },
                    chipColor: colors.errorContainer,
                    chipTextColor: colors.onErrorContainer,
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddExerciseDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Exercise'),
        ),
      ),
    );
  }

  Future<void> _showAddExerciseDialog(BuildContext context, WidgetRef ref) async {
    final exercise = await showExercisePicker(context);
    if (exercise == null) return;

    if (!context.mounted) return;

    // Show dialog to choose favorite or dislike
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise.name),
        content: const Text('Add this exercise to:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, 'dislike'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.thumb_down,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Dislikes',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'favorite'),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite),
                SizedBox(width: 8),
                Text('Favorites'),
              ],
            ),
          ),
        ],
      ),
    );

    if (result == null || !context.mounted) return;

    if (result == 'favorite') {
      ref
          .read(exercisePreferencesProvider.notifier)
          .addFavorite(exercise.id, exercise.name);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added "${exercise.name}" to favorites')),
      );
    } else if (result == 'dislike') {
      ref
          .read(exercisePreferencesProvider.notifier)
          .addDislike(exercise.id, exercise.name);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added "${exercise.name}" to dislikes')),
      );
    }
  }
}

/// A list showing exercise preferences with remove functionality.
class _PreferencesList extends StatelessWidget {
  final List<ExercisePreference> preferences;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final void Function(String exerciseId) onRemove;
  final Color chipColor;
  final Color chipTextColor;

  const _PreferencesList({
    required this.preferences,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRemove,
    required this.chipColor,
    required this.chipTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (preferences.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                emptyIcon,
                size: 64,
                color: colors.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                emptyTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                emptySubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: preferences.length,
      itemBuilder: (context, index) {
        final pref = preferences[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: chipColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.fitness_center,
                color: chipTextColor,
              ),
            ),
            title: Text(
              pref.exerciseName,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Added ${_formatDate(pref.addedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle_outline, color: colors.error),
              onPressed: () => _showRemoveConfirmation(context, pref),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'today';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showRemoveConfirmation(BuildContext context, ExercisePreference pref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Exercise'),
        content: Text('Remove "${pref.exerciseName}" from this list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onRemove(pref.exerciseId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Removed "${pref.exerciseName}"')),
              );
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
