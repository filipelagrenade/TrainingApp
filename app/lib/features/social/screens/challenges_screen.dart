/// LiftIQ - Challenges Screen
///
/// Displays active challenges that users can join and compete in.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/challenge.dart';
import '../providers/social_provider.dart';

/// Screen showing available and joined challenges.
class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(activeChallengesProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
          tooltip: 'Back',
        ),
        title: const Text('Challenges'),
      ),
      body: challengesAsync.when(
        data: (challenges) => challenges.isEmpty
            ? _buildEmptyState(theme, colors)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: challenges.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ChallengeCard(challenge: challenges[index]),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colors.error),
              const SizedBox(height: 16),
              const Text('Failed to load challenges'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(activeChallengesProvider),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
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
              Icons.flag_outlined,
              size: 64,
              color: colors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Challenges',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Check back soon for new challenges!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card displaying a challenge.
class _ChallengeCard extends ConsumerWidget {
  final Challenge challenge;

  const _ChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final joinState = ref.watch(challengeJoinProvider);
    final isJoined = joinState.joinedChallengeIds.contains(challenge.id) ||
        challenge.isJoined;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient background
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.primary,
                  colors.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                // Challenge icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getChallengeIcon(challenge.type),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Title and status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        challenge.statusString,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  challenge.description,
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 16),

                // Progress (if joined)
                if (isJoined) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        challenge.progressString,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${challenge.progress.toStringAsFixed(0)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: challenge.progress / 100,
                      backgroundColor: colors.surfaceContainerHighest,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Footer with participants and action
                Row(
                  children: [
                    // Participants
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      challenge.formattedParticipants,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const Spacer(),

                    // Join/Leave button
                    if (!challenge.hasEnded)
                      isJoined
                          ? OutlinedButton(
                              onPressed: joinState.isLoading
                                  ? null
                                  : () => ref
                                      .read(challengeJoinProvider.notifier)
                                      .leave(challenge.id),
                              child: const Text('Leave'),
                            )
                          : FilledButton(
                              onPressed: joinState.isLoading
                                  ? null
                                  : () => ref
                                      .read(challengeJoinProvider.notifier)
                                      .join(challenge.id),
                              child: const Text('Join'),
                            ),

                    // View leaderboard button
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.leaderboard),
                      onPressed: () =>
                          _showLeaderboard(context, ref, challenge.id),
                      tooltip: 'Leaderboard',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getChallengeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.workoutCount:
        return Icons.fitness_center;
      case ChallengeType.volume:
        return Icons.bar_chart;
      case ChallengeType.streak:
        return Icons.local_fire_department;
      case ChallengeType.exerciseSpecific:
        return Icons.sports_martial_arts;
    }
  }

  void _showLeaderboard(BuildContext context, WidgetRef ref, String challengeId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          final leaderboardAsync =
              ref.watch(challengeLeaderboardProvider(challengeId));

          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Leaderboard',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),

              // Leaderboard
              Expanded(
                child: leaderboardAsync.when(
                  data: (entries) => ListView.builder(
                    controller: scrollController,
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return ListTile(
                        leading: entry.isPodium
                            ? Text(
                                entry.medalEmoji!,
                                style: const TextStyle(fontSize: 24),
                              )
                            : CircleAvatar(
                                radius: 16,
                                child: Text('${entry.rank}'),
                              ),
                        title: Text(entry.userName),
                        trailing: Text(
                          entry.value.toStringAsFixed(0),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      );
                    },
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) =>
                      const Center(child: Text('Failed to load leaderboard')),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
