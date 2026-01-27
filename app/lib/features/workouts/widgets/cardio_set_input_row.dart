/// LiftIQ - Cardio Set Input Row
///
/// Widget for inputting cardio exercise data including duration,
/// distance, incline/resistance, and heart rate.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cardio_set.dart';

/// Input row for cardio exercise sets.
///
/// Displays inputs for:
/// - Duration (required)
/// - Distance (optional)
/// - Incline/Resistance (optional, depends on equipment)
/// - Heart rate (optional)
///
/// ## Usage
/// ```dart
/// CardioSetInputRow(
///   setNumber: 1,
///   previousSet: lastCardioSet,
///   showIncline: true,
///   onComplete: (cardioSet) => saveSet(cardioSet),
/// )
/// ```
class CardioSetInputRow extends ConsumerStatefulWidget {
  /// The set number (1-indexed for display).
  final int setNumber;

  /// Previous cardio set for pre-filling values.
  final CardioSet? previousSet;

  /// Whether to show incline input (for treadmills).
  final bool showIncline;

  /// Whether to show resistance input (for bikes/ellipticals).
  final bool showResistance;

  /// Called when the set is completed.
  final void Function(CardioSet) onComplete;

  /// Called when the set should be removed.
  final VoidCallback? onRemove;

  /// Whether this set is already completed.
  final bool isCompleted;

  /// The completed cardio set (if already completed).
  final CardioSet? completedSet;

  const CardioSetInputRow({
    super.key,
    required this.setNumber,
    this.previousSet,
    this.showIncline = false,
    this.showResistance = false,
    required this.onComplete,
    this.onRemove,
    this.isCompleted = false,
    this.completedSet,
  });

  @override
  ConsumerState<CardioSetInputRow> createState() => _CardioSetInputRowState();
}

class _CardioSetInputRowState extends ConsumerState<CardioSetInputRow> {
  late TextEditingController _durationController;
  late TextEditingController _distanceController;
  late TextEditingController _inclineController;
  late TextEditingController _resistanceController;
  late TextEditingController _heartRateController;

  CardioIntensity _intensity = CardioIntensity.moderate;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final prev = widget.completedSet ?? widget.previousSet;

    // Duration in minutes
    final durationMinutes = prev?.duration.inMinutes ?? 0;
    _durationController = TextEditingController(
      text: durationMinutes > 0 ? durationMinutes.toString() : '',
    );

    _distanceController = TextEditingController(
      text: prev?.distance?.toStringAsFixed(2) ?? '',
    );

    _inclineController = TextEditingController(
      text: prev?.incline?.toStringAsFixed(1) ?? '',
    );

    _resistanceController = TextEditingController(
      text: prev?.resistance?.toString() ?? '',
    );

    _heartRateController = TextEditingController(
      text: prev?.avgHeartRate?.toString() ?? '',
    );

    _intensity = prev?.intensity ?? CardioIntensity.moderate;
  }

  @override
  void dispose() {
    _durationController.dispose();
    _distanceController.dispose();
    _inclineController.dispose();
    _resistanceController.dispose();
    _heartRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Show completed state
    if (widget.isCompleted && !_isEditing) {
      return _buildCompletedRow(theme, colors);
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Set number and intensity
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: colors.primaryContainer,
                  child: Text(
                    widget.setNumber.toString(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildIntensitySelector(theme, colors),
                ),
                if (widget.onRemove != null)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: colors.error),
                    onPressed: widget.onRemove,
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Main inputs row
            Row(
              children: [
                // Duration (required)
                Expanded(
                  flex: 2,
                  child: _buildDurationInput(theme, colors),
                ),
                const SizedBox(width: 8),
                // Distance
                Expanded(
                  flex: 2,
                  child: _buildDistanceInput(theme, colors),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Secondary inputs row
            Row(
              children: [
                if (widget.showIncline) ...[
                  Expanded(
                    child: _buildInclineInput(theme, colors),
                  ),
                  const SizedBox(width: 8),
                ],
                if (widget.showResistance) ...[
                  Expanded(
                    child: _buildResistanceInput(theme, colors),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: _buildHeartRateInput(theme, colors),
                ),
                const SizedBox(width: 8),
                // Complete button
                SizedBox(
                  width: 80,
                  child: FilledButton(
                    onPressed: _canComplete ? _completeSet : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Icon(Icons.check),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedRow(ThemeData theme, ColorScheme colors) {
    final set = widget.completedSet!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
      child: InkWell(
        onTap: () => setState(() => _isEditing = true),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Set number with check
              CircleAvatar(
                radius: 14,
                backgroundColor: colors.primary,
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: colors.onPrimary,
                ),
              ),
              const SizedBox(width: 12),

              // Duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      set.durationString,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Duration',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Distance
              if (set.distance != null) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${set.distance!.toStringAsFixed(2)} km',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Distance',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Heart rate
              if (set.avgHeartRate != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 14,
                          color: colors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${set.avgHeartRate}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'bpm',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],

              // Intensity badge
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getIntensityColor(set.intensity, colors),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  set.intensity.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntensitySelector(ThemeData theme, ColorScheme colors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: CardioIntensity.values.map((intensity) {
          final isSelected = _intensity == intensity;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ChoiceChip(
              label: Text(
                intensity.label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? colors.onPrimary : null,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _intensity = intensity);
                }
              },
              selectedColor: _getIntensityColor(intensity, colors),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDurationInput(ThemeData theme, ColorScheme colors) {
    return TextField(
      controller: _durationController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: 'Duration',
        suffixText: 'min',
        border: const OutlineInputBorder(),
        isDense: true,
        filled: true,
        fillColor: colors.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildDistanceInput(ThemeData theme, ColorScheme colors) {
    return TextField(
      controller: _distanceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: 'Distance',
        suffixText: 'km',
        border: const OutlineInputBorder(),
        isDense: true,
        filled: true,
        fillColor: colors.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildInclineInput(ThemeData theme, ColorScheme colors) {
    return TextField(
      controller: _inclineController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
      ],
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: 'Incline',
        suffixText: '%',
        border: const OutlineInputBorder(),
        isDense: true,
        filled: true,
        fillColor: colors.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildResistanceInput(ThemeData theme, ColorScheme colors) {
    return TextField(
      controller: _resistanceController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: 'Resistance',
        border: const OutlineInputBorder(),
        isDense: true,
        filled: true,
        fillColor: colors.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildHeartRateInput(ThemeData theme, ColorScheme colors) {
    return TextField(
      controller: _heartRateController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: 'HR',
        suffixText: 'bpm',
        border: const OutlineInputBorder(),
        isDense: true,
        filled: true,
        fillColor: colors.surfaceContainerHighest,
      ),
    );
  }

  Color _getIntensityColor(CardioIntensity intensity, ColorScheme colors) {
    return switch (intensity) {
      CardioIntensity.light => Colors.green,
      CardioIntensity.moderate => Colors.blue,
      CardioIntensity.vigorous => Colors.orange,
      CardioIntensity.hiit => Colors.red,
      CardioIntensity.max => Colors.purple,
    };
  }

  bool get _canComplete {
    final duration = int.tryParse(_durationController.text);
    return duration != null && duration > 0;
  }

  void _completeSet() {
    final duration = int.tryParse(_durationController.text) ?? 0;
    final distance = double.tryParse(_distanceController.text);
    final incline = double.tryParse(_inclineController.text);
    final resistance = int.tryParse(_resistanceController.text);
    final heartRate = int.tryParse(_heartRateController.text);

    final cardioSet = CardioSet(
      setNumber: widget.setNumber,
      duration: Duration(minutes: duration),
      distance: distance,
      incline: incline,
      resistance: resistance,
      avgHeartRate: heartRate,
      intensity: _intensity,
      completedAt: DateTime.now(),
    );

    widget.onComplete(cardioSet);
    setState(() => _isEditing = false);
  }
}
