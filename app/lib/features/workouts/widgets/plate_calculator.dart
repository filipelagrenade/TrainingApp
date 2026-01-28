/// LiftIQ - Plate Calculator Widget
///
/// Shows a visual breakdown of plates needed per side for a given weight.
/// Uses a greedy algorithm with standard Olympic plate sizes.
library;

import 'package:flutter/material.dart';

/// Standard plate sizes in kg, descending.
const List<double> _kgPlates = [25, 20, 15, 10, 5, 2.5, 1.25];

/// Standard plate sizes in lbs, descending.
const List<double> _lbPlates = [45, 35, 25, 10, 5, 2.5];

/// Shows the plate calculator as a modal bottom sheet.
void showPlateCalculator(
  BuildContext context, {
  required double targetWeight,
  double barWeight = 20,
  String unit = 'kg',
}) {
  showModalBottomSheet(
    context: context,
    builder: (ctx) => PlateCalculatorSheet(
      targetWeight: targetWeight,
      barWeight: barWeight,
      unit: unit,
    ),
  );
}

/// Calculates plates per side using a greedy algorithm.
List<double> calculatePlates({
  required double targetWeight,
  required double barWeight,
  required String unit,
}) {
  final plates = unit == 'kg' ? _kgPlates : _lbPlates;
  var remaining = (targetWeight - barWeight) / 2;
  if (remaining <= 0) return [];

  final result = <double>[];
  for (final plate in plates) {
    while (remaining >= plate - 0.001) {
      result.add(plate);
      remaining -= plate;
    }
  }
  return result;
}

/// Modal bottom sheet showing plate breakdown.
class PlateCalculatorSheet extends StatelessWidget {
  final double targetWeight;
  final double barWeight;
  final String unit;

  const PlateCalculatorSheet({
    super.key,
    required this.targetWeight,
    this.barWeight = 20,
    this.unit = 'kg',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final platesPerSide = calculatePlates(
      targetWeight: targetWeight,
      barWeight: barWeight,
      unit: unit,
    );
    final remainder = (targetWeight - barWeight) / 2 -
        platesPerSide.fold(0.0, (a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plate Calculator',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Target: ${_fmt(targetWeight)} $unit  |  Bar: ${_fmt(barWeight)} $unit',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const Divider(height: 24),
          if (targetWeight <= barWeight)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No plates needed — bar only.',
                style: theme.textTheme.bodyLarge,
              ),
            )
          else ...[
            Text(
              'Each side:',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            // Visual plate diagram
            _buildPlateDiagram(platesPerSide, theme, colors),
            const SizedBox(height: 12),
            // Plate list
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _groupPlates(platesPerSide).entries.map((entry) {
                return Chip(
                  label: Text('${_fmt(entry.key)} $unit × ${entry.value}'),
                  backgroundColor: colors.secondaryContainer,
                );
              }).toList(),
            ),
            if (remainder > 0.01)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Note: ${_fmt(remainder)} $unit per side cannot be made with standard plates.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.error,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPlateDiagram(
    List<double> plates,
    ThemeData theme,
    ColorScheme colors,
  ) {
    if (plates.isEmpty) return const SizedBox.shrink();

    final maxPlate = (unit == 'kg' ? _kgPlates : _lbPlates).first;

    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Bar end
          Container(
            width: 60,
            height: 10,
            color: colors.outline,
          ),
          // Plates
          ...plates.map((plate) {
            final heightFraction = 0.4 + (plate / maxPlate) * 0.6;
            return Container(
              width: 14,
              height: 80 * heightFraction,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: _plateColor(plate, colors),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: colors.outline.withOpacity(0.3)),
              ),
              child: Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    _fmt(plate),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 8,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _plateColor(double plate, ColorScheme colors) {
    // Standard color coding for plates
    if (plate >= 25 || plate >= 45) return Colors.red.shade700;
    if (plate >= 20 || plate >= 35) return Colors.blue.shade700;
    if (plate >= 15) return Colors.yellow.shade800;
    if (plate >= 10) return Colors.green.shade700;
    if (plate >= 5) return Colors.white70;
    return Colors.grey;
  }

  Map<double, int> _groupPlates(List<double> plates) {
    final grouped = <double, int>{};
    for (final p in plates) {
      grouped[p] = (grouped[p] ?? 0) + 1;
    }
    return grouped;
  }

  String _fmt(double v) => v % 1 == 0 ? v.toInt().toString() : v.toString();
}
