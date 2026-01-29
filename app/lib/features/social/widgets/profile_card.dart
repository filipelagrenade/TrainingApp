/// LiftIQ - Profile Card Widget
///
/// A card displaying a user's social profile information.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_profile.dart';
import '../providers/social_provider.dart';

/// A card displaying a user's social profile.
///
/// Shows avatar, name, bio, follower counts, and stats.
class ProfileCard extends ConsumerWidget {
  final SocialProfile profile;
  final bool showFollowButton;
  final VoidCallback? onTap;

  const ProfileCard({
    super.key,
    required this.profile,
    this.showFollowButton = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final followState = ref.watch(followProvider);
    final isFollowing =
        followState.followingIds.contains(profile.userId) || profile.isFollowing;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar and name row
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: colors.primaryContainer,
                    backgroundImage: profile.hasAvatar
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                    child: !profile.hasAvatar
                        ? Text(
                            profile.userName[0].toUpperCase(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: colors.onPrimaryContainer,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),

                  // Name and username
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.displayNameOrUserName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '@${profile.userName}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Follow button
                  if (showFollowButton)
                    isFollowing
                        ? OutlinedButton(
                            onPressed: followState.isLoading
                                ? null
                                : () => ref
                                    .read(followProvider.notifier)
                                    .toggleFollow(profile.userId),
                            child: const Text('Following'),
                          )
                        : FilledButton(
                            onPressed: followState.isLoading
                                ? null
                                : () => ref
                                    .read(followProvider.notifier)
                                    .toggleFollow(profile.userId),
                            child: const Text('Follow'),
                          ),
                ],
              ),

              // Bio
              if (profile.hasBio) ...[
                const SizedBox(height: 12),
                Text(
                  profile.bio!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 16),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'Followers',
                    value: profile.formattedFollowers,
                  ),
                  _StatItem(
                    label: 'Following',
                    value: profile.formattedFollowing,
                  ),
                  _StatItem(
                    label: 'Workouts',
                    value: profile.workoutCount.toString(),
                  ),
                  _StatItem(
                    label: 'PRs',
                    value: profile.prCount.toString(),
                  ),
                ],
              ),

              // Streak badge
              if (profile.currentStreak > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${profile.currentStreak} day streak',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A single stat item in the profile card.
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// A smaller profile tile for lists.
class ProfileTile extends ConsumerWidget {
  final ProfileSummary profile;
  final VoidCallback? onTap;

  const ProfileTile({
    super.key,
    required this.profile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final followState = ref.watch(followProvider);
    final isFollowing =
        followState.followingIds.contains(profile.userId) || profile.isFollowing;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: colors.primaryContainer,
        backgroundImage: profile.avatarUrl != null
            ? NetworkImage(profile.avatarUrl!)
            : null,
        child: profile.avatarUrl == null
            ? Text(
                profile.userName[0].toUpperCase(),
                style: TextStyle(color: colors.onPrimaryContainer),
              )
            : null,
      ),
      title: Text(profile.displayName ?? profile.userName),
      subtitle: Text('@${profile.userName}'),
      trailing: isFollowing
          ? OutlinedButton(
              onPressed: followState.isLoading
                  ? null
                  : () => ref
                      .read(followProvider.notifier)
                      .toggleFollow(profile.userId),
              child: const Text('Following'),
            )
          : FilledButton(
              onPressed: followState.isLoading
                  ? null
                  : () =>
                      ref.read(followProvider.notifier).toggleFollow(profile.userId),
              child: const Text('Follow'),
            ),
    );
  }
}
