/// LiftIQ - Achievement Unlock Dialog
///
/// Full-screen celebration dialog shown when a badge is unlocked.
/// Features animated entrance and confetti effects.
///
/// Features:
/// - Scale and fade animation for badge
/// - Confetti burst effect
/// - Share button
/// - Auto-dismiss option
///
/// Design notes:
/// - Uses Hero animations for smooth transitions
/// - Accessible with screen reader support
/// - Haptic feedback on unlock
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/providers/settings_provider.dart';
import '../models/achievement.dart';

/// Shows the achievement unlock celebration.
void showAchievementUnlockDialog(BuildContext context, Achievement achievement) {
  HapticFeedback.heavyImpact();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss achievement',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) {
      return AchievementUnlockDialog(achievement: achievement);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          ),
          child: child,
        ),
      );
    },
  );
}

/// The achievement unlock celebration dialog.
class AchievementUnlockDialog extends ConsumerStatefulWidget {
  final Achievement achievement;

  const AchievementUnlockDialog({super.key, required this.achievement});

  @override
  ConsumerState<AchievementUnlockDialog> createState() => _AchievementUnlockDialogState();
}

class _AchievementUnlockDialogState extends ConsumerState<AchievementUnlockDialog>
    with TickerProviderStateMixin {
  late AnimationController _badgeController;
  late AnimationController _confettiController;
  late Animation<double> _badgeScale;
  late Animation<double> _badgeRotation;

  final List<_ConfettiPiece> _confetti = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();

    // Badge animation
    _badgeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _badgeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _badgeController,
        curve: Curves.elasticOut,
      ),
    );

    _badgeRotation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _badgeController,
        curve: Curves.easeOutBack,
      ),
    );

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Generate confetti pieces
    for (int i = 0; i < 50; i++) {
      _confetti.add(_ConfettiPiece(
        color: _getRandomColor(),
        x: _random.nextDouble() * 2 - 1, // -1 to 1
        y: -1, // Start above screen
        vx: _random.nextDouble() * 2 - 1, // Random horizontal velocity
        vy: _random.nextDouble() * 3 + 2, // Random downward velocity
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
        size: _random.nextDouble() * 8 + 4,
      ));
    }

    // Start animations
    _badgeController.forward();
    _confettiController.repeat();

    // Auto-dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      widget.achievement.tierColor,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Confetti
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ConfettiPainter(
                  confetti: _confetti,
                  progress: _confettiController.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Dialog content
          Center(
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: widget.achievement.tierColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "Achievement Unlocked" text
                  Text(
                    'ACHIEVEMENT UNLOCKED!',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: widget.achievement.tierColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Animated badge
                  AnimatedBuilder(
                    animation: _badgeController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _badgeScale.value,
                        child: Transform.rotate(
                          angle: _badgeRotation.value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.achievement.color.withOpacity(0.2),
                        border: Border.all(
                          color: widget.achievement.tierColor,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.achievement.tierColor.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.achievement.iconAsset,
                          style: const TextStyle(fontSize: 56),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Achievement name
                  Text(
                    widget.achievement.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    widget.achievement.descriptionWithUnit(ref.watch(weightUnitProvider).name),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Tier badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: widget.achievement.tierColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.achievement.tierDisplayName.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: _getTextColorForTier(widget.achievement.tier),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement share functionality
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Awesome!'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tap anywhere to dismiss
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.translucent,
            ),
          ),
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

/// A single confetti piece.
class _ConfettiPiece {
  final Color color;
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double rotation;
  final double rotationSpeed;
  final double size;

  _ConfettiPiece({
    required this.color,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
  });
}

/// Custom painter for confetti animation.
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> confetti;
  final double progress;

  _ConfettiPainter({
    required this.confetti,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in confetti) {
      final paint = Paint()..color = piece.color;

      // Calculate position based on progress
      final x = size.width / 2 + piece.x * size.width * 0.5 +
          piece.vx * progress * size.width * 0.3;
      final y = size.height * 0.3 + piece.vy * progress * size.height * 0.5;

      // Apply gravity
      final gravityOffset = progress * progress * 200;

      // Calculate rotation
      final rotation = piece.rotation + piece.rotationSpeed * progress;

      canvas.save();
      canvas.translate(x, y + gravityOffset);
      canvas.rotate(rotation);

      // Draw confetti piece (rectangle)
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: piece.size,
          height: piece.size * 0.6,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
