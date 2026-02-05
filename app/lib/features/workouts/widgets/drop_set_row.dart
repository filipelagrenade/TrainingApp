/// LiftIQ - Drop Set Sub-Row Widget
///
/// Renders the indented sub-rows for drop sets below a completed parent set.
/// Each sub-row shows weight (pre-filled, editable), reps input, and a
/// complete/check button.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/exercise_set.dart';

/// Widget displaying a single drop set sub-entry.
///
/// Shows an indented row with drop number, weight, reps, and complete button.
/// Weight is pre-filled from auto-generation but can be edited.
class DropSetSubRow extends StatefulWidget {
  /// The drop index (0-based, displayed as 1-based).
  final int dropIndex;

  /// The drop set entry data.
  final DropSetEntry entry;

  /// Unit string (kg or lbs).
  final String unit;

  /// Called when the drop is completed with reps.
  final void Function(int reps) onComplete;

  /// Called when weight is changed.
  final void Function(double weight) onWeightChanged;

  /// Called when reps are changed (before completion).
  final void Function(int reps) onRepsChanged;

  /// Called to remove this drop row.
  final VoidCallback onRemove;

  const DropSetSubRow({
    super.key,
    required this.dropIndex,
    required this.entry,
    required this.unit,
    required this.onComplete,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onRemove,
  });

  @override
  State<DropSetSubRow> createState() => _DropSetSubRowState();
}

class _DropSetSubRowState extends State<DropSetSubRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: _formatWeight(widget.entry.weight),
    );
    _repsController = TextEditingController(
      text: widget.entry.reps > 0 ? widget.entry.reps.toString() : '',
    );
  }

  @override
  void didUpdateWidget(DropSetSubRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update weight if it changed externally (e.g., proportional recalc)
    if (widget.entry.weight != oldWidget.entry.weight) {
      _weightController.text = _formatWeight(widget.entry.weight);
    }
    if (widget.entry.reps != oldWidget.entry.reps &&
        widget.entry.reps > 0 &&
        widget.entry.isCompleted) {
      _repsController.text = widget.entry.reps.toString();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  String _formatWeight(double weight) {
    return weight % 1 == 0 ? weight.toInt().toString() : weight.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (widget.entry.isCompleted) {
      return _buildCompletedRow(theme, colors);
    }

    return _buildInputRow(theme, colors);
  }

  Widget _buildInputRow(ThemeData theme, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 0, top: 2, bottom: 2),
      child: Row(
        children: [
          // Vertical connector line
          Container(
            width: 2,
            height: 36,
            color: colors.outline.withOpacity(0.3),
          ),
          const SizedBox(width: 8),

          // Drop label
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                'D${widget.dropIndex + 1}',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSecondaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Weight input
          Expanded(
            flex: 3,
            child: TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                border: InputBorder.none,
                hintText: 'Wt',
                suffixText: widget.unit,
                suffixStyle: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              onChanged: (value) {
                final w = double.tryParse(value);
                if (w != null) widget.onWeightChanged(w);
              },
            ),
          ),
          const SizedBox(width: 4),

          // × symbol
          Text('×', style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          )),
          const SizedBox(width: 4),

          // Reps input
          Expanded(
            flex: 2,
            child: TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                border: InputBorder.none,
                hintText: 'Reps',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
          const SizedBox(width: 4),

          // Complete button
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              onPressed: _completeDrop,
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.check_circle_outline,
                color: colors.primary,
                size: 22,
              ),
            ),
          ),

          // Remove button
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              onPressed: widget.onRemove,
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.close,
                color: colors.onSurfaceVariant,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedRow(ThemeData theme, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 0, top: 2, bottom: 2),
      child: Row(
        children: [
          // Vertical connector line
          Container(
            width: 2,
            height: 32,
            color: colors.primary.withOpacity(0.3),
          ),
          const SizedBox(width: 8),

          // Completed drop label
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Icon(Icons.check, size: 14, color: colors.onPrimary),
            ),
          ),
          const SizedBox(width: 8),

          // Weight × Reps display
          Text(
            '${_formatWeight(widget.entry.weight)} ${widget.unit} × ${widget.entry.reps}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _completeDrop() {
    final reps = int.tryParse(_repsController.text);
    if (reps == null || reps <= 0) return;

    // Also update weight if changed
    final weight = double.tryParse(_weightController.text);
    if (weight != null && weight != widget.entry.weight) {
      widget.onWeightChanged(weight);
    }

    HapticFeedback.mediumImpact();
    widget.onComplete(reps);
  }
}

/// Widget that renders all drop sub-rows for a set, with an "Add Drop" button.
class DropSetSubRows extends StatelessWidget {
  /// The drop set entries.
  final List<DropSetEntry> dropSets;

  /// Unit string (kg or lbs).
  final String unit;

  /// Called when a drop is completed.
  final void Function(int dropIndex, int reps) onCompleteDrop;

  /// Called when a drop's weight changes.
  final void Function(int dropIndex, double weight) onWeightChanged;

  /// Called when a drop's reps change.
  final void Function(int dropIndex, int reps) onRepsChanged;

  /// Called to remove a drop.
  final void Function(int dropIndex) onRemoveDrop;

  /// Called to add a new drop row.
  final VoidCallback onAddDrop;

  const DropSetSubRows({
    super.key,
    required this.dropSets,
    required this.unit,
    required this.onCompleteDrop,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onRemoveDrop,
    required this.onAddDrop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        ...dropSets.asMap().entries.map((entry) {
          return DropSetSubRow(
            dropIndex: entry.key,
            entry: entry.value,
            unit: unit,
            onComplete: (reps) => onCompleteDrop(entry.key, reps),
            onWeightChanged: (w) => onWeightChanged(entry.key, w),
            onRepsChanged: (r) => onRepsChanged(entry.key, r),
            onRemove: () => onRemoveDrop(entry.key),
          );
        }),
        // Add drop button
        Padding(
          padding: const EdgeInsets.only(left: 34, top: 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onAddDrop,
              icon: Icon(Icons.add, size: 16, color: colors.primary),
              label: Text(
                'Add Drop',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
