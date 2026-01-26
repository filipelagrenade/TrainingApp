/// LiftIQ - Rest Timer Display Widget
///
/// Visual display for the rest timer between sets.
/// Features a large, easy-to-read countdown with progress ring.
///
/// Design principles:
/// - Large display readable from a distance
/// - Visual progress indicator (ring)
/// - Quick controls for adjusting time
/// - Color changes as time runs low
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/rest_timer_provider.dart';

/// Compact rest timer display for embedding in workout screen.
///
/// Shows the timer in a small bar with basic controls.
///
/// ## Usage
/// ```dart
/// RestTimerBar(
///   onTap: () => showRestTimerSheet(context),
/// )
/// ```
class RestTimerBar extends ConsumerWidget {
  /// Called when the bar is tapped
  final VoidCallback? onTap;

  const RestTimerBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(restTimerProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Don't show if timer is idle
    if (timer.isIdle) return const SizedBox.shrink();

    // Color based on remaining time
    final timerColor = _getTimerColor(timer, colors);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: timerColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: timerColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Timer icon or pause/play
            Icon(
              timer.isRunning ? Icons.timer : Icons.pause_circle_outline,
              color: timerColor,
              size: 24,
            ),
            const SizedBox(width: 8),

            // Time display with optional reason
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timer.formattedTime,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: timerColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (timer.durationReason != null && timer.progress < 0.2)
                  Text(
                    timer.durationReason!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: timerColor.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),

            // Progress bar
            SizedBox(
              width: 60,
              child: LinearProgressIndicator(
                value: timer.progress,
                backgroundColor: colors.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTimerColor(RestTimerState timer, ColorScheme colors) {
    if (timer.isCompleted) return colors.error;
    if (timer.remainingSeconds <= 10) return colors.error;
    if (timer.remainingSeconds <= 30) return colors.tertiary;
    return colors.primary;
  }
}

/// Full-screen rest timer display with controls.
///
/// Shows a large circular timer with play/pause, skip, and adjust controls.
///
/// ## Usage
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (_) => const RestTimerFullDisplay(),
/// );
/// ```
class RestTimerFullDisplay extends ConsumerWidget {
  const RestTimerFullDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(restTimerProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final timerColor = _getTimerColor(timer, colors);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colors.outline.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Text(
            'Rest Timer',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          // Circular timer display
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress ring
                CustomPaint(
                  size: const Size(200, 200),
                  painter: _TimerRingPainter(
                    progress: timer.progress,
                    color: timerColor,
                    backgroundColor: colors.surfaceContainerHigh,
                  ),
                ),

                // Time display
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timer.formattedTime,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: timerColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (timer.isCompleted)
                      Text(
                        'Rest Complete!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.error,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Time adjustment buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TimeAdjustButton(
                label: '-30s',
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(restTimerProvider.notifier).subtractTime(30);
                },
              ),
              const SizedBox(width: 16),
              _TimeAdjustButton(
                label: '+30s',
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(restTimerProvider.notifier).addTime(30);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Reset button
              IconButton.filled(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(restTimerProvider.notifier).reset();
                },
                icon: const Icon(Icons.refresh),
                style: IconButton.styleFrom(
                  backgroundColor: colors.surfaceContainerHigh,
                  foregroundColor: colors.onSurface,
                ),
              ),

              // Play/Pause button (large)
              SizedBox(
                width: 72,
                height: 72,
                child: IconButton.filled(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    final notifier = ref.read(restTimerProvider.notifier);
                    if (timer.isRunning) {
                      notifier.pause();
                    } else if (timer.isPaused) {
                      notifier.resume();
                    } else {
                      notifier.start();
                    }
                  },
                  icon: Icon(
                    timer.isRunning ? Icons.pause : Icons.play_arrow,
                    size: 40,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: timerColor,
                    foregroundColor: colors.onPrimary,
                  ),
                ),
              ),

              // Skip button
              IconButton.filled(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(restTimerProvider.notifier).stop();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.skip_next),
                style: IconButton.styleFrom(
                  backgroundColor: colors.surfaceContainerHigh,
                  foregroundColor: colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick duration presets
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _DurationPresetChip(seconds: 60, label: '1:00'),
              _DurationPresetChip(seconds: 90, label: '1:30'),
              _DurationPresetChip(seconds: 120, label: '2:00'),
              _DurationPresetChip(seconds: 180, label: '3:00'),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTimerColor(RestTimerState timer, ColorScheme colors) {
    if (timer.isCompleted) return colors.error;
    if (timer.remainingSeconds <= 10) return colors.error;
    if (timer.remainingSeconds <= 30) return colors.tertiary;
    return colors.primary;
  }
}

/// Time adjustment button (-30s, +30s).
class _TimeAdjustButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TimeAdjustButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(label),
    );
  }
}

/// Duration preset chip for quick selection.
class _DurationPresetChip extends ConsumerWidget {
  final int seconds;
  final String label;

  const _DurationPresetChip({
    required this.seconds,
    required this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(restTimerProvider);
    final isSelected = timer.totalSeconds == seconds;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        HapticFeedback.lightImpact();
        ref.read(restTimerProvider.notifier).start(duration: seconds);
      },
    );
  }
}

/// Custom painter for the circular timer ring.
class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _TimerRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    this.strokeWidth = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Start from top (12 o'clock), go clockwise
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_TimerRingPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

/// Helper function to show the rest timer bottom sheet.
void showRestTimerSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const RestTimerFullDisplay(),
  );
}
