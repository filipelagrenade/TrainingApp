/// LiftIQ - Set Input Row Widget
///
/// Provides the UI for logging a single set.
/// Optimized for speed and gym usability.
///
/// Design principles:
/// - Large touch targets (48x48 minimum)
/// - Weight/reps pre-filled from previous workout
/// - Single tap to complete set
/// - Minimal cognitive load
///
/// PERFORMANCE: This widget must be lightweight!
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise_set.dart';
import '../models/weight_input.dart';

/// Callback when a set is completed.
typedef OnSetComplete = void Function({
  required double weight,
  required int reps,
  double? rpe,
  SetType setType,
  WeightInputType? weightType,
  BandResistance? bandResistance,
});

/// Widget for inputting and logging a set.
///
/// ## Usage
/// ```dart
/// SetInputRow(
///   setNumber: 1,
///   previousWeight: 100,
///   previousReps: 8,
///   onComplete: ({weight, reps, rpe, setType}) {
///     ref.read(currentWorkoutProvider.notifier).logSet(
///       exerciseIndex: 0,
///       weight: weight,
///       reps: reps,
///       rpe: rpe,
///       setType: setType,
///     );
///   },
/// )
/// ```
///
/// ## Design Decisions
/// - Large input fields for easy tapping in gym
/// - Pre-filled from previous workout
/// - Quick increment/decrement buttons
/// - Single "Complete Set" button for speed
class SetInputRow extends ConsumerStatefulWidget {
  /// The set number (1-indexed for display)
  final int setNumber;

  /// Previous weight for pre-filling (null for first time)
  final double? previousWeight;

  /// Previous reps for pre-filling
  final int? previousReps;

  /// Previous RPE for reference
  final double? previousRpe;

  /// Whether this set is already completed
  final bool isCompleted;

  /// The completed set data (if completed)
  final ExerciseSet? completedSet;

  /// Called when the set is completed
  final OnSetComplete onComplete;

  /// Called when an already-completed set is tapped for editing
  final VoidCallback? onEdit;

  /// Unit to display (kg or lbs)
  final String unit;

  /// Weight increment for +/- buttons
  final double weightIncrement;

  /// Default weight type for this exercise.
  final WeightInputType defaultWeightType;

  /// Default set type selection for this exercise.
  final SetType defaultSetType;

  /// Whether the RPE slider should be shown.
  final bool rpeEnabled;

  const SetInputRow({
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
  });

  @override
  ConsumerState<SetInputRow> createState() => _SetInputRowState();
}

class _SetInputRowState extends ConsumerState<SetInputRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  SetType _setType = SetType.working;
  double? _rpe;
  WeightInputType _weightType = WeightInputType.absolute;
  BandResistance _bandResistance = BandResistance.medium;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Pre-fill from previous workout or completed data
    final initialWeight =
        widget.completedSet?.weight ?? widget.previousWeight ?? 0.0;
    final initialReps = widget.completedSet?.reps ?? widget.previousReps ?? 0;

    _weightController = TextEditingController(
      text: initialWeight > 0 ? _formatWeight(initialWeight) : '',
    );
    _repsController = TextEditingController(
      text: initialReps > 0 ? initialReps.toString() : '',
    );

    _setType = widget.defaultSetType;
    _weightType = widget.defaultWeightType;
    _rpe = widget.rpeEnabled ? (widget.previousRpe ?? 7) : null;

    if (widget.completedSet != null) {
      _setType = widget.completedSet!.setType;
      _rpe = widget.completedSet!.rpe;
      _weightType = widget.completedSet!.weightType ?? widget.defaultWeightType;
      if (widget.completedSet!.bandResistance != null) {
        _bandResistance = BandResistance.values
                .where((value) =>
                    value.name == widget.completedSet!.bandResistance)
                .firstOrNull ??
            BandResistance.medium;
      }
    }
  }

  @override
  void didUpdateWidget(SetInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers if the completed set changed
    if (widget.completedSet != oldWidget.completedSet &&
        widget.completedSet != null) {
      _weightController.text = _formatWeight(widget.completedSet!.weight);
      _repsController.text = widget.completedSet!.reps.toString();
      _setType = widget.completedSet!.setType;
      _rpe = widget.completedSet!.rpe;
      _weightType = widget.completedSet!.weightType ?? widget.defaultWeightType;
    } else if (widget.defaultSetType != oldWidget.defaultSetType ||
        widget.defaultWeightType != oldWidget.defaultWeightType ||
        widget.rpeEnabled != oldWidget.rpeEnabled) {
      _setType = widget.defaultSetType;
      _weightType = widget.defaultWeightType;
      if (!widget.rpeEnabled) {
        _rpe = null;
      } else {
        _rpe ??= widget.previousRpe ?? 7;
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  String _formatWeight(double weight) {
    return weight % 1 == 0 ? weight.toInt().toString() : weight.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Completed sets have different appearance
    if (widget.isCompleted && widget.completedSet != null) {
      return _buildCompletedRow(theme, colors);
    }

    return _buildInputRow(theme, colors);
  }

  /// Builds the input row for sets not yet completed.
  Widget _buildInputRow(ThemeData theme, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildSetNumberBadge(theme, colors),
              const SizedBox(width: 4),
              Expanded(
                flex: 4,
                child: _weightType == WeightInputType.bodyweight
                    ? Align(
                        alignment: Alignment.center,
                        child: Text(
                          'BW',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : _weightType == WeightInputType.band
                        ? _buildBandSelector(theme, colors)
                        : _buildWeightInput(theme, colors),
              ),
              if (_weightType == WeightInputType.perSide) ...[
                const SizedBox(width: 4),
                Text(
                  'x2',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(width: 4),
              Expanded(
                flex: 3,
                child: _buildRepsInput(theme, colors),
              ),
              const SizedBox(width: 4),
              _buildCompleteButton(theme, colors),
            ],
          ),
          const SizedBox(height: 8),
          _buildRpeInput(theme, colors),
        ],
      ),
    );
  }

  /// Builds the display for completed sets.
  Widget _buildCompletedRow(ThemeData theme, ColorScheme colors) {
    final set = widget.completedSet!;

    return InkWell(
      onTap: widget.onEdit,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: colors.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            // Set number with checkmark
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: colors.onPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Weight x Reps
            Expanded(
              child: Text(
                set.toDisplayString(unit: widget.unit),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // PR badge if applicable
            if (set.isPersonalRecord)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.tertiary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'PR',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onTertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Set number badge.
  Widget _buildSetNumberBadge(ThemeData theme, ColorScheme colors) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${widget.setNumber}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Weight input field (no +/- buttons).
  Widget _buildWeightInput(ThemeData theme, ColorScheme colors) {
    return TextField(
      controller: _weightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        border: InputBorder.none,
        hintText: 'Weight',
        suffixText: widget.unit,
        suffixStyle: theme.textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
    );
  }

  /// Reps input field (no +/- buttons).
  Widget _buildRepsInput(ThemeData theme, ColorScheme colors) {
    return TextField(
      controller: _repsController,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        border: InputBorder.none,
        hintText: 'Reps',
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }

  /// Band resistance selector.
  Widget _buildBandSelector(ThemeData theme, ColorScheme colors) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final band in BandResistance.values)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: band.colorValue,
                    radius: 12,
                  ),
                  title: Text(band.label),
                  subtitle: Text(band.resistanceRange),
                  selected: _bandResistance == band,
                  onTap: () {
                    setState(() => _bandResistance = band);
                    Navigator.pop(ctx);
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Text(
          _bandResistance.label,
          textAlign: TextAlign.center,
          style:
              theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Complete set button - the main action.
  Widget _buildCompleteButton(ThemeData theme, ColorScheme colors) {
    return SizedBox(
      width: 48,
      height: 48,
      child: ElevatedButton(
        onPressed: _canComplete ? _completeSet : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Icon(Icons.check, size: 24),
      ),
    );
  }

  /// RPE input slider.
  Widget _buildRpeInput(ThemeData theme, ColorScheme colors) {
    return Row(
      children: [
        Text(
          'RPE:',
          style: theme.textTheme.bodySmall,
        ),
        Expanded(
          child: Slider(
            value: _rpe ?? 7,
            min: 1,
            max: 10,
            divisions: 18, // Half steps
            label: _rpe?.toStringAsFixed(1) ?? '7',
            onChanged: (value) {
              setState(() => _rpe = value);
            },
          ),
        ),
        Text(
          (_rpe ?? 7).toStringAsFixed(1),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Whether the set can be completed.
  bool get _canComplete {
    final reps = int.tryParse(_repsController.text);
    if (reps == null || reps <= 0) return false;
    if (_weightType == WeightInputType.bodyweight ||
        _weightType == WeightInputType.band) return true;
    if (_weightType == WeightInputType.perSide) {
      final weight = double.tryParse(_weightController.text);
      return weight != null && weight >= 0;
    }
    final weight = double.tryParse(_weightController.text);
    return weight != null && weight >= 0;
  }

  /// Completes the set and calls the callback.
  void _completeSet() {
    final reps = int.tryParse(_repsController.text);
    if (reps == null) return;

    double weight;
    if (_weightType == WeightInputType.bodyweight) {
      weight = 0;
    } else if (_weightType == WeightInputType.band) {
      weight = _bandResistance.equivalentWeight;
    } else if (_weightType == WeightInputType.perSide) {
      // Per-side: store total weight (entered side x 2) for volume calculations.
      weight = (double.tryParse(_weightController.text) ?? 0) * 2;
    } else {
      weight = double.tryParse(_weightController.text) ?? 0;
    }

    HapticFeedback.mediumImpact();

    widget.onComplete(
      weight: weight,
      reps: reps,
      rpe: _rpe,
      setType: _setType,
      weightType: _weightType,
      bandResistance:
          _weightType == WeightInputType.band ? _bandResistance : null,
    );
  }
}
