/// LiftIQ - Activity Feed Screen
///
/// Displays the social activity feed showing activities from followed users.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_item.dart';
import '../providers/social_provider.dart';

/// Main activity feed screen.
///
/// Features:
/// - Pull to refresh
/// - Infinite scroll (when implemented)
/// - Like and comment interactions
/// - Navigate to user profiles
class ActivityFeedScreen extends ConsumerWidget {
  const ActivityFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(activityFeedProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
            tooltip: 'Search users',
          ),
        ],
      ),
      body: feedAsync.when(
        data: (feed) => feed.items.isEmpty
            ? _buildEmptyState(theme, colors)
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(activityFeedProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: feed.items.length,
                  itemBuilder: (context, index) {
                    return _ActivityCard(activity: feed.items[index]);
                  },
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(theme, colors, ref),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: colors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Activity Yet',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Follow other lifters to see their workouts, PRs, and achievements!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('Find People'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, ColorScheme colors, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colors.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load feed',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => ref.invalidate(activityFeedProvider),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _UserSearchDelegate(),
    );
  }
}

/// A card displaying a single activity.
class _ActivityCard extends ConsumerWidget {
  final ActivityItem activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final likeState = ref.watch(likeProvider);
    final isLiked =
        likeState.likedActivityIds.contains(activity.id) || activity.isLikedByMe;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar, name, and time
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colors.primaryContainer,
                  backgroundImage: activity.userAvatarUrl != null
                      ? NetworkImage(activity.userAvatarUrl!)
                      : null,
                  child: activity.userAvatarUrl == null
                      ? Text(
                          activity.userName[0].toUpperCase(),
                          style: TextStyle(color: colors.onPrimaryContainer),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Name and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.userName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        activity.timeAgo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Activity type badge
                _ActivityTypeBadge(type: activity.type),
              ],
            ),

            const SizedBox(height: 12),

            // Activity title
            Text(
              activity.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            // Description (if any)
            if (activity.description != null) ...[
              const SizedBox(height: 4),
              Text(
                activity.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                // Like button
                _ActionButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: '${activity.likes + (isLiked && !activity.isLikedByMe ? 1 : 0)}',
                  isActive: isLiked,
                  onTap: () =>
                      ref.read(likeProvider.notifier).toggleLike(activity.id),
                ),
                const SizedBox(width: 16),

                // Comment button
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: '${activity.comments}',
                  onTap: () => _showComments(context),
                ),
                const Spacer(),

                // Share button
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {},
                  tooltip: 'Share',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Comments',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Expanded(
              child: Center(
                child: Text('Comments coming soon!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge showing the activity type.
class _ActivityTypeBadge extends StatelessWidget {
  final ActivityType type;

  const _ActivityTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    IconData icon;
    Color color;

    switch (type) {
      case ActivityType.personalRecord:
        icon = Icons.emoji_events;
        color = Colors.amber;
      case ActivityType.workoutCompleted:
        icon = Icons.fitness_center;
        color = colors.primary;
      case ActivityType.streakMilestone:
        icon = Icons.local_fire_department;
        color = Colors.orange;
      case ActivityType.challengeJoined:
      case ActivityType.challengeCompleted:
        icon = Icons.flag;
        color = Colors.green;
      case ActivityType.startedFollowing:
        icon = Icons.person_add;
        color = colors.tertiary;
      case ActivityType.programCompleted:
        icon = Icons.school;
        color = Colors.purple;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

/// An action button (like, comment).
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? colors.primary : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? colors.primary : colors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Search delegate for finding users.
class _UserSearchDelegate extends SearchDelegate<String?> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Search for users by username'),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final resultsAsync = ref.watch(userSearchProvider(query));

        return resultsAsync.when(
          data: (results) => results.isEmpty
              ? Center(child: Text('No users found for "$query"'))
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final user = results[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(user.userName[0].toUpperCase()),
                      ),
                      title: Text(user.displayName ?? user.userName),
                      subtitle: Text('@${user.userName}'),
                      trailing: user.isFollowing
                          ? const Chip(label: Text('Following'))
                          : null,
                      onTap: () => close(context, user.userId),
                    );
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Search failed')),
        );
      },
    );
  }
}
