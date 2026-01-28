/// LiftIQ - Achievement Badge Widget
///
/// Visual representation of an achievement/badge.
/// Shows locked, unlocked, and progress states.
///
/// Features:
/// - Circular badge with icon
/// - Tier-colored border
/// - Progress ring for locked achievements
/// - Shimmer effect for recently unlocked
///
/// Design notes:
/// - Uses Material 3 design patterns
/// - Accessible with proper semantics
/// - Responsive sizing
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/achievement.dart';
import '../../settings/providers/settings_provider.dart';

/// A badge displaying an achievement.
class AchievementBadge extends ConsumerWidget {
  final Achievement achievement;
  final double size;
  final bool showProgress;
  final bool showName;
  final VoidCallback? onTap;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.size = 80,
    this.showProgress = true,
    this.showName = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final weightUnit = ref.watch(weightUnitProvider);
    final unitLabel = weightUnit.name;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress ring (for locked achievements)
                if (!achievement.isUnlocked && showProgress)
                  SizedBox(
                    width: size,
                    height: size,
                    child: CircularProgressIndicator(
                      value: achievement.progressPercent,
                      strokeWidth: 3,
                      backgroundColor: colors.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        achievement.tierColor.withOpacity(0.5),
                      ),
                    ),
                  ),

                // Badge background
                Container(
                  width: size * 0.85,
                  height: size * 0.85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: achievement.isUnlocked
                        ? achievement.color.withOpacity(0.2)
                        : colors.surfaceContainerHighest,
                    border: Border.all(
                      color: achievement.isUnlocked
                          ? achievement.tierColor
                          : colors.outline.withOpacity(0.3),
                      width: achievement.isUnlocked ? 3 : 2,
                    ),
                    boxShadow: achievement.isUnlocked
                        ? [
                            BoxShadow(
                              color: achievement.tierColor.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: achievement.isUnlocked
                        ? Text(
                            achievement.iconAsset,
                            style: TextStyle(fontSize: size * 0.4),
                          )
                        : Icon(
                            Icons.lock_outline,
                            size: size * 0.35,
                            color: colors.onSurfaceVariant.withOpacity(0.5),
                          ),
                  ),
                ),

                // Tier indicator
                if (achievement.isUnlocked)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: size * 0.3,
                      height: size * 0.3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: achievement.tierColor,
                        border: Border.all(
                          color: colors.surface,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check,
                          size: size * 0.18,
                          color: _getTextColorForTier(achievement.tier),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Name
          if (showName) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: size * 1.2,
              child: Text(
                achievement.name,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: achievement.isUnlocked
                      ? colors.onSurface
                      : colors.onSurfaceVariant,
                  fontWeight:
                      achievement.isUnlocked ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getTextColorForTier(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return Colors.white;
      case AchievementTier.silver:
        return Colors.black87;
      case AchievementTier.gold:
        return Colors.black87;
      case AchievementTier.platinum:
        return Colors.black87;
    }
  }
}

/// A compact badge for use in lists.
class AchievementBadgeCompact extends ConsumerWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const AchievementBadgeCompact({
    super.key,
    required this.achievement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final weightUnit = ref.watch(weightUnitProvider);
    final unitLabel = weightUnit.name;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: achievement.isUnlocked
              ? achievement.color.withOpacity(0.1)
              : colors.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: achievement.isUnlocked
                ? achievement.tierColor
                : colors.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: achievement.isUnlocked
                    ? achievement.color.withOpacity(0.2)
                    : colors.surfaceContainerHighest,
              ),
              child: Center(
                child: achievement.isUnlocked
                    ? Text(
                        achievement.iconAsset,
                        style: const TextStyle(fontSize: 24),
                      )
                    : Icon(
                        Icons.lock_outline,
                        color: colors.onSurfaceVariant.withOpacity(0.5),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: achievement.isUnlocked
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: achievement.isUnlocked
                          ? colors.onSurface
                          : colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    achievement.descriptionWithUnit(unitLabel),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!achievement.isUnlocked) ...[
                    const SizedBox(height: 4),
                    // Progress bar
                    LinearProgressIndicator(
                      value: achievement.progressPercent,
                      backgroundColor: colors.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        achievement.tierColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      achievement.progressString,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Tier badge
            if (achievement.isUnlocked) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: achievement.tierColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  achievement.tierDisplayName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _getTextColorForTier(achievement.tier),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getTextColorForTier(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return Colors.white;
      case AchievementTier.silver:
        return Colors.black87;
      case AchievementTier.gold:
        return Colors.black87;
      case AchievementTier.platinum:
        return Colors.black87;
    }
  }
}
