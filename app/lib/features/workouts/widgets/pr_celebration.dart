/// LiftIQ - PR Celebration Widget
///
/// Displays a celebratory overlay when a personal record is achieved.
///
/// Features:
/// - Full-screen overlay with animations
/// - Gold trophy icon with scale/bounce effect
/// - "NEW PR!" text animation
/// - Confetti particles
/// - Exercise name and weight comparison
/// - Auto-dismiss after 3 seconds
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Data for a personal record achievement.
class PRData {
  /// Exercise name
  final String exerciseName;

  /// New PR weight
  final double newWeight;

  /// Previous PR weight
  final double previousWeight;

  /// Number of reps at new PR
  final int reps;

  /// Weight unit (kg or lbs)
  final String unit;

  const PRData({
    required this.exerciseName,
    required this.newWeight,
    required this.previousWeight,
    required this.reps,
    this.unit = 'lbs',
  });

  /// Weight improvement amount
  double get improvement => newWeight - previousWeight;

  /// Formatted improvement string
  String get improvementText =>
      '+${improvement.toStringAsFixed(1)} $unit';
}

/// Full-screen PR celebration overlay.
///
/// Usage:
/// ```dart
/// showPRCelebration(
///   context,
///   PRData(
///     exerciseName: 'Bench Press',
///     newWeight: 225,
///     previousWeight: 220,
///     reps: 5,
///     unit: 'lbs',
///   ),
/// );
/// ```
class PRCelebration extends StatefulWidget {
  final PRData data;
  final VoidCallback? onDismiss;

  const PRCelebration({
    super.key,
    required this.data,
    this.onDismiss,
  });

  @override
  State<PRCelebration> createState() => _PRCelebrationState();
}

class _PRCelebrationState extends State<PRCelebration>
    with TickerProviderStateMixin {
  late AnimationController _trophyController;
  late AnimationController _textController;
  late AnimationController _confettiController;

  late Animation<double> _trophyScale;
  late Animation<double> _trophyRotation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  final List<_ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _generateConfetti();
    _startAnimations();

    // Haptic feedback
    HapticFeedback.heavyImpact();

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onDismiss?.call();
      }
    });
  }

  void _initAnimations() {
    // Trophy animation
    _trophyController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _trophyScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.3).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 0.9).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_trophyController);

    _trophyRotation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: -0.1, end: 0.1),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.1, end: -0.05),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.05, end: 0.0),
        weight: 50,
      ),
    ]).animate(_trophyController);

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  void _generateConfetti() {
    for (int i = 0; i < 50; i++) {
      _particles.add(_ConfettiParticle(
        x: _random.nextDouble(),
        y: -0.1 - _random.nextDouble() * 0.3,
        size: 5 + _random.nextDouble() * 10,
        color: _getConfettiColor(i),
        speed: 0.3 + _random.nextDouble() * 0.7,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 5,
        wobble: _random.nextDouble() * 0.1,
        wobbleSpeed: 2 + _random.nextDouble() * 3,
      ));
    }
  }

  Color _getConfettiColor(int index) {
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFFA500), // Orange
      const Color(0xFFFF6B6B), // Red
      const Color(0xFF4ECDC4), // Teal
      const Color(0xFF9B59B6), // Purple
      const Color(0xFF3498DB), // Blue
    ];
    return colors[index % colors.length];
  }

  void _startAnimations() {
    _trophyController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _textController.forward();
    });
    _confettiController.forward();
  }

  @override
  void dispose() {
    _trophyController.dispose();
    _textController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: widget.onDismiss,
      child: Material(
        color: Colors.black.withValues(alpha: 0.85),
        child: Stack(
          children: [
            // Confetti
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  size: size,
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _confettiController.value,
                  ),
                );
              },
            ),

            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Trophy icon
                  AnimatedBuilder(
                    animation: _trophyController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _trophyScale.value,
                        child: Transform.rotate(
                          angle: _trophyRotation.value,
                          child: const Icon(
                            Icons.emoji_events,
                            size: 120,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // "NEW PR!" text
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Text(
                        'NEW PR!',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Exercise name
                  FadeTransition(
                    opacity: _textOpacity,
                    child: Text(
                      widget.data.exerciseName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Weight comparison
                  FadeTransition(
                    opacity: _textOpacity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Previous weight
                        _WeightBox(
                          label: 'Previous',
                          weight: widget.data.previousWeight,
                          unit: widget.data.unit,
                          isPrevious: true,
                        ),
                        const SizedBox(width: 16),

                        // Arrow
                        const Icon(
                          Icons.arrow_forward,
                          color: Color(0xFFFFD700),
                          size: 32,
                        ),
                        const SizedBox(width: 16),

                        // New weight
                        _WeightBox(
                          label: 'NEW PR',
                          weight: widget.data.newWeight,
                          unit: widget.data.unit,
                          isPrevious: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Improvement badge
                  FadeTransition(
                    opacity: _textOpacity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        widget.data.improvementText,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Tap to dismiss hint
                  FadeTransition(
                    opacity: _textOpacity,
                    child: Text(
                      'Tap anywhere to continue',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
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

/// Weight display box for comparison.
class _WeightBox extends StatelessWidget {
  final String label;
  final double weight;
  final String unit;
  final bool isPrevious;

  const _WeightBox({
    required this.label,
    required this.weight,
    required this.unit,
    required this.isPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isPrevious
        ? Colors.white.withValues(alpha: 0.7)
        : const Color(0xFFFFD700);

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color.withValues(alpha: 0.7),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${weight.toStringAsFixed(1)} $unit',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Confetti particle data.
class _ConfettiParticle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double speed;
  final double rotation;
  final double rotationSpeed;
  final double wobble;
  final double wobbleSpeed;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
    required this.wobble,
    required this.wobbleSpeed,
  });
}

/// Custom painter for confetti particles.
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final currentY = particle.y + (progress * particle.speed * 1.5);
      if (currentY > 1.2) continue;

      final wobbleOffset = math.sin(progress * particle.wobbleSpeed * math.pi * 2) * particle.wobble;
      final currentX = particle.x + wobbleOffset;
      final currentRotation = particle.rotation + (progress * particle.rotationSpeed);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: (1 - progress * 0.5).clamp(0, 1))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(
        currentX * size.width,
        currentY * size.height,
      );
      canvas.rotate(currentRotation);

      // Draw rectangle confetti
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Shows the PR celebration overlay.
void showPRCelebration(BuildContext context, PRData data) {
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => PRCelebration(
      data: data,
      onDismiss: () {
        overlayEntry.remove();
      },
    ),
  );

  Overlay.of(context).insert(overlayEntry);
}
