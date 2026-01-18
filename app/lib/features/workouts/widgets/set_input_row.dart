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

/// Callback when a set is completed.
typedef OnSetComplete = void Function({
  required double weight,
  required int reps,
  double? rpe,
  SetType setType,
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
  });

  @override
  ConsumerState<SetInputRow> createState() => _SetInputRowState();
}

class _SetInputRowState extends ConsumerState<SetInputRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  SetType _setType = SetType.working;
  bool _showRpeInput = false;
  double? _rpe;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Pre-fill from previous workout or completed data
    final initialWeight = widget.completedSet?.weight ??
        widget.previousWeight ??
        0.0;
    final initialReps = widget.completedSet?.reps ??
        widget.previousReps ??
        0;

    _weightController = TextEditingController(
      text: initialWeight > 0 ? _formatWeight(initialWeight) : '',
    );
    _repsController = TextEditingController(
      text: initialReps > 0 ? initialReps.toString() : '',
    );

    if (widget.completedSet != null) {
      _setType = widget.completedSet!.setType;
      _rpe = widget.completedSet!.rpe;
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Main input row
          Row(
            children: [
              // Set number badge
              _buildSetNumberBadge(theme, colors),
              const SizedBox(width: 12),

              // Weight input with +/- buttons
              Expanded(
                flex: 3,
                child: _buildWeightInput(theme, colors),
              ),
              const SizedBox(width: 12),

              // Reps input with +/- buttons
              Expanded(
                flex: 2,
                child: _buildRepsInput(theme, colors),
              ),
              const SizedBox(width: 12),

              // Complete button
              _buildCompleteButton(theme, colors),
            ],
          ),

          // Optional RPE input (expandable)
          if (_showRpeInput) ...[
            const SizedBox(height: 8),
            _buildRpeInput(theme, colors),
          ],

          // Set type selector (for warmup/dropset)
          if (_setType != SetType.working) ...[
            const SizedBox(height: 4),
            _buildSetTypeChip(theme, colors),
          ],
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

  /// Weight input with increment/decrement buttons.
  Widget _buildWeightInput(ThemeData theme, ColorScheme colors) {
    return Row(
      children: [
        // Decrement button
        _buildIncrementButton(
          icon: Icons.remove,
          onTap: () => _adjustWeight(-widget.weightIncrement),
          colors: colors,
        ),

        // Weight text field
        Expanded(
          child: TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: InputBorder.none,
              hintText: '0',
              suffixText: widget.unit,
              suffixStyle: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
        ),

        // Increment button
        _buildIncrementButton(
          icon: Icons.add,
          onTap: () => _adjustWeight(widget.weightIncrement),
          colors: colors,
        ),
      ],
    );
  }

  /// Reps input with increment/decrement buttons.
  Widget _buildRepsInput(ThemeData theme, ColorScheme colors) {
    return Row(
      children: [
        // Decrement button
        _buildIncrementButton(
          icon: Icons.remove,
          onTap: () => _adjustReps(-1),
          colors: colors,
          size: 24,
        ),

        // Reps text field
        Expanded(
          child: TextField(
            controller: _repsController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              border: InputBorder.none,
              hintText: '0',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ),

        // Increment button
        _buildIncrementButton(
          icon: Icons.add,
          onTap: () => _adjustReps(1),
          colors: colors,
          size: 24,
        ),
      ],
    );
  }

  /// Increment/decrement button.
  Widget _buildIncrementButton({
    required IconData icon,
    required VoidCallback onTap,
    required ColorScheme colors,
    double size = 28,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: size + 12,
        height: size + 12,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: size * 0.6),
      ),
    );
  }

  /// Complete set button - the main action.
  Widget _buildCompleteButton(ThemeData theme, ColorScheme colors) {
    return SizedBox(
      width: 56,
      height: 48,
      child: ElevatedButton(
        onPressed: _canComplete ? _completeSet : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Icon(Icons.check, size: 28),
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

  /// Set type chip (for warmup/dropset).
  Widget _buildSetTypeChip(ThemeData theme, ColorScheme colors) {
    final label = switch (_setType) {
      SetType.warmup => 'Warmup',
      SetType.dropset => 'Drop Set',
      SetType.failure => 'To Failure',
      SetType.working => 'Working',
    };

    return Chip(
      label: Text(label),
      labelStyle: theme.textTheme.labelSmall,
      backgroundColor: colors.secondaryContainer,
      visualDensity: VisualDensity.compact,
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () {
        setState(() => _setType = SetType.working);
      },
    );
  }

  /// Whether the set can be completed.
  bool get _canComplete {
    final weight = double.tryParse(_weightController.text);
    final reps = int.tryParse(_repsController.text);
    return weight != null && weight >= 0 && reps != null && reps > 0;
  }

  /// Adjusts the weight by the given amount.
  void _adjustWeight(double amount) {
    final current = double.tryParse(_weightController.text) ?? 0;
    final newWeight = (current + amount).clamp(0, 9999);
    _weightController.text = _formatWeight(newWeight.toDouble());
    setState(() {});
  }

  /// Adjusts the reps by the given amount.
  void _adjustReps(int amount) {
    final current = int.tryParse(_repsController.text) ?? 0;
    final newReps = (current + amount).clamp(0, 999);
    _repsController.text = newReps.toString();
    setState(() {});
  }

  /// Completes the set and calls the callback.
  void _completeSet() {
    final weight = double.tryParse(_weightController.text);
    final reps = int.tryParse(_repsController.text);

    if (weight == null || reps == null) return;

    // Haptic feedback for satisfaction
    HapticFeedback.mediumImpact();

    widget.onComplete(
      weight: weight,
      reps: reps,
      rpe: _rpe,
      setType: _setType,
    );
  }
}

/// Button row for quick set type selection.
class SetTypeSelector extends StatelessWidget {
  final SetType selected;
  final ValueChanged<SetType> onChanged;

  const SetTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<SetType>(
      segments: const [
        ButtonSegment(value: SetType.warmup, label: Text('Warmup')),
        ButtonSegment(value: SetType.working, label: Text('Working')),
        ButtonSegment(value: SetType.dropset, label: Text('Drop')),
        ButtonSegment(value: SetType.failure, label: Text('Failure')),
      ],
      selected: {selected},
      onSelectionChanged: (value) => onChanged(value.first),
    );
  }
}
