/// LiftIQ - Swipeable Set Row Widget
///
/// Wraps the SetInputRow with swipe gestures for quick actions:
/// - Swipe RIGHT: Complete set with current values
/// - Swipe LEFT: Delete set (with confirmation)
///
/// Design principles:
/// - Haptic feedback at swipe threshold
/// - Visual cues with background colors
/// - Animated icons sliding in from edges
/// - Respects user preference to disable swipes
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise_set.dart';
import '../models/weight_input.dart';
import 'set_input_row.dart';

/// Callback when a set is swiped to complete.
typedef OnSwipeComplete = void Function();

/// Callback when a set is swiped to delete.
typedef OnSwipeDelete = void Function();

/// A swipeable wrapper for SetInputRow that enables gesture-based actions.
///
/// ## Usage
/// ```dart
/// SwipeableSetRow(
///   setNumber: 1,
///   previousWeight: 100,
///   previousReps: 8,
///   swipeEnabled: true,
///   onSwipeComplete: () {
///     ref.read(workoutProvider.notifier).completeSet(0);
///   },
///   onSwipeDelete: () {
///     ref.read(workoutProvider.notifier).deleteSet(0);
///   },
///   onComplete: ({weight, reps, rpe, setType}) {
///     // Handle manual completion
///   },
/// )
/// ```
///
/// ## Gesture Behavior
/// - Swipe right past threshold (40%): triggers onSwipeComplete
/// - Swipe left past threshold (40%): shows delete confirmation
/// - Haptic feedback at threshold
/// - Visual feedback with colored backgrounds
class SwipeableSetRow extends ConsumerStatefulWidget {
  /// The set number (1-indexed for display).
  final int setNumber;

  /// Previous weight for pre-filling.
  final double? previousWeight;

  /// Previous reps for pre-filling.
  final int? previousReps;

  /// Previous RPE for reference.
  final double? previousRpe;

  /// Whether this set is already completed.
  final bool isCompleted;

  /// The completed set data (if completed).
  final ExerciseSet? completedSet;

  /// Called when the set is completed via button.
  final OnSetComplete onComplete;

  /// Called when an already-completed set is tapped for editing.
  final VoidCallback? onEdit;

  /// Unit to display (kg or lbs).
  final String unit;

  /// Weight increment for +/- buttons.
  final double weightIncrement;

  /// Default weight input mode for this exercise row.
  final WeightInputType defaultWeightType;

  /// Default set type for this exercise row.
  final SetType defaultSetType;

  /// Whether RPE controls are shown.
  final bool rpeEnabled;

  /// Whether swipe gestures are enabled.
  final bool swipeEnabled;

  /// Called when user swipes right to complete.
  final OnSwipeComplete? onSwipeComplete;

  /// Called when user swipes left to delete.
  final OnSwipeDelete? onSwipeDelete;

  /// The current weight value for swipe-complete.
  final double? currentWeight;

  /// The current reps value for swipe-complete.
  final int? currentReps;

  const SwipeableSetRow({
    super.key,
    required this.setNumber,
    this.previousWeight,
    this.previousReps,
    this.previousRpe,
    this.isCompleted = false,
    this.completedSet,
    required this.onComplete,
    this.onEdit,
    this.unit = 'kg',
    this.weightIncrement = 2.5,
    this.defaultWeightType = WeightInputType.absolute,
    this.defaultSetType = SetType.working,
    this.rpeEnabled = true,
    this.swipeEnabled = true,
    this.onSwipeComplete,
    this.onSwipeDelete,
    this.currentWeight,
    this.currentReps,
  });

  @override
  ConsumerState<SwipeableSetRow> createState() => _SwipeableSetRowState();
}

class _SwipeableSetRowState extends ConsumerState<SwipeableSetRow>
    with SingleTickerProviderStateMixin {
  /// Tracks the current horizontal drag offset.
  double _dragOffset = 0;

  /// Whether we've triggered haptic feedback for the current drag.
  bool _hapticTriggered = false;

  /// Swipe threshold as fraction of width (0.4 = 40%).
  static const double _swipeThreshold = 0.4;

  /// Maximum drag offset as fraction of width.
  static const double _maxDragFraction = 0.6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // If swipe is disabled, just return the regular SetInputRow
    if (!widget.swipeEnabled) {
      return _buildSetInputRow();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxDrag = maxWidth * _maxDragFraction;
        final threshold = maxWidth * _swipeThreshold;

        return GestureDetector(
          onHorizontalDragStart: (_) {
            _hapticTriggered = false;
          },
          onHorizontalDragUpdate: (details) {
            setState(() {
              _dragOffset += details.delta.dx;
              // Clamp the drag within bounds
              _dragOffset = _dragOffset.clamp(-maxDrag, maxDrag);

              // Trigger haptic at threshold
              if (!_hapticTriggered && _dragOffset.abs() > threshold) {
                HapticFeedback.mediumImpact();
                _hapticTriggered = true;
              }
            });
          },
          onHorizontalDragEnd: (details) {
            final shouldComplete = _dragOffset > threshold;
            final shouldDelete = _dragOffset < -threshold;

            // Reset position with animation
            setState(() {
              _dragOffset = 0;
            });

            if (shouldComplete && widget.onSwipeComplete != null) {
              // Swipe right - complete set
              HapticFeedback.heavyImpact();
              widget.onSwipeComplete!();
            } else if (shouldDelete && widget.onSwipeDelete != null) {
              // Swipe left - delete (with confirmation)
              _showDeleteConfirmation(context, colors);
            }
          },
          onHorizontalDragCancel: () {
            setState(() {
              _dragOffset = 0;
            });
          },
          child: Stack(
            children: [
              // Background - shows during swipe
              Positioned.fill(
                child: _buildSwipeBackground(colors, threshold),
              ),

              // The actual row with transform
              AnimatedContainer(
                duration: _dragOffset == 0
                    ? const Duration(milliseconds: 200)
                    : Duration.zero,
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(_dragOffset, 0, 0),
                child: _buildSetInputRow(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the swipe background with icons.
  Widget _buildSwipeBackground(ColorScheme colors, double threshold) {
    final isCompleteSide = _dragOffset > 0;
    final isPastThreshold = _dragOffset.abs() > threshold;
    final opacity = (_dragOffset.abs() / threshold).clamp(0.0, 1.0);

    if (_dragOffset == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: isCompleteSide
            ? (isPastThreshold
                ? colors.primary
                : colors.primary.withValues(alpha: opacity * 0.7))
            : (isPastThreshold
                ? colors.error
                : colors.error.withValues(alpha: opacity * 0.7)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment:
              isCompleteSide ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            if (isCompleteSide) ...[
              // Complete icon on left side
              AnimatedScale(
                scale: isPastThreshold ? 1.2 : 0.8 + (opacity * 0.4),
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  Icons.check_circle,
                  color: colors.onPrimary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedOpacity(
                opacity: isPastThreshold ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: Text(
                  'Complete',
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else ...[
              // Delete icon on right side
              AnimatedOpacity(
                opacity: isPastThreshold ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: colors.onError,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedScale(
                scale: isPastThreshold ? 1.2 : 0.8 + (opacity * 0.4),
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  Icons.delete,
                  color: colors.onError,
                  size: 32,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Shows delete confirmation dialog.
  void _showDeleteConfirmation(BuildContext context, ColorScheme colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Set'),
        content: Text(
            'Art thou certain thou wishest to delete set ${widget.setNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              HapticFeedback.heavyImpact();
              widget.onSwipeDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: colors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Builds the underlying SetInputRow.
  Widget _buildSetInputRow() {
    return SetInputRow(
      setNumber: widget.setNumber,
      previousWeight: widget.previousWeight,
      previousReps: widget.previousReps,
      previousRpe: widget.previousRpe,
      isCompleted: widget.isCompleted,
      completedSet: widget.completedSet,
      onComplete: widget.onComplete,
      onEdit: widget.onEdit,
      unit: widget.unit,
      weightIncrement: widget.weightIncrement,
      defaultWeightType: widget.defaultWeightType,
      defaultSetType: widget.defaultSetType,
      rpeEnabled: widget.rpeEnabled,
    );
  }
}

/// Simple controller to get current values from SetInputRow for swipe-complete.
///
/// This is needed because when swiping to complete, we need the current
/// values from the input fields, not the previous workout values.
class SwipeableSetController {
  double weight = 0;
  int reps = 0;
  double? rpe;
  SetType setType = SetType.working;

  void updateValues({
    required double weight,
    required int reps,
    double? rpe,
    SetType? setType,
  }) {
    this.weight = weight;
    this.reps = reps;
    this.rpe = rpe;
    if (setType != null) {
      this.setType = setType;
    }
  }
}
