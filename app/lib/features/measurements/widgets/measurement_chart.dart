/// LiftIQ - Measurement Chart Widget
///
/// Displays a trend chart for a measurement field.
/// Shows historical data with trend indicators.
library;

import 'package:flutter/material.dart';

import '../models/body_measurement.dart';

/// Chart showing measurement trend over time.
class MeasurementChart extends StatelessWidget {
  /// Creates a measurement chart.
  const MeasurementChart({
    super.key,
    required this.trend,
  });

  /// The trend data to display.
  final MeasurementTrend trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with field name and current value
            Row(
              children: [
                Icon(
                  _getIconForField(trend.field),
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatFieldName(trend.field),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (trend.currentValue != null)
                  Text(
                    _formatValue(trend.field, trend.currentValue!),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Change indicator
            if (trend.change != null)
              Row(
                children: [
                  Icon(
                    trend.trend == TrendDirection.up
                        ? Icons.trending_up
                        : trend.trend == TrendDirection.down
                            ? Icons.trending_down
                            : Icons.trending_flat,
                    size: 16,
                    color: _getTrendColor(trend.field, trend.trend),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${trend.change! >= 0 ? '+' : ''}${trend.change!.toStringAsFixed(1)} (${trend.changePercent?.toStringAsFixed(1)}%)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getTrendColor(trend.field, trend.trend),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'since last measurement',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Simple chart
            if (trend.dataPoints.length >= 2)
              SizedBox(
                height: 120,
                child: _SimpleLineChart(
                  dataPoints: trend.dataPoints,
                  field: trend.field,
                ),
              )
            else
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Not enough data for chart',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForField(String field) {
    switch (field) {
      case 'weight':
        return Icons.monitor_weight;
      case 'bodyFat':
        return Icons.percent;
      case 'waist':
        return Icons.circle_outlined;
      case 'chest':
        return Icons.accessibility_new;
      case 'leftBicep':
      case 'rightBicep':
        return Icons.fitness_center;
      default:
        return Icons.straighten;
    }
  }

  String _formatFieldName(String field) {
    switch (field) {
      case 'weight':
        return 'Weight';
      case 'bodyFat':
        return 'Body Fat';
      case 'waist':
        return 'Waist';
      case 'chest':
        return 'Chest';
      case 'leftBicep':
        return 'Left Bicep';
      case 'rightBicep':
        return 'Right Bicep';
      default:
        return field;
    }
  }

  String _formatValue(String field, double value) {
    switch (field) {
      case 'weight':
        return '${value.toStringAsFixed(1)} kg';
      case 'bodyFat':
        return '${value.toStringAsFixed(1)}%';
      default:
        return '${value.toStringAsFixed(1)} cm';
    }
  }

  Color _getTrendColor(String field, TrendDirection direction) {
    // For weight, waist, body fat - down is good
    final downIsGood = ['weight', 'bodyFat', 'waist', 'hips'].contains(field);

    if (direction == TrendDirection.stable) {
      return Colors.grey;
    }

    if (downIsGood) {
      return direction == TrendDirection.down ? Colors.green : Colors.red;
    } else {
      return direction == TrendDirection.up ? Colors.green : Colors.red;
    }
  }
}

/// Simple line chart implementation.
class _SimpleLineChart extends StatelessWidget {
  const _SimpleLineChart({
    required this.dataPoints,
    required this.field,
  });

  final List<TrendDataPoint> dataPoints;
  final String field;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        if (dataPoints.isEmpty) {
          return const SizedBox.shrink();
        }

        final values = dataPoints.map((p) => p.value).toList();
        final minValue = values.reduce((a, b) => a < b ? a : b);
        final maxValue = values.reduce((a, b) => a > b ? a : b);
        final range = maxValue - minValue;
        final padding = range * 0.1;

        return CustomPaint(
          size: Size(width, height),
          painter: _ChartPainter(
            dataPoints: dataPoints,
            minValue: minValue - padding,
            maxValue: maxValue + padding,
            lineColor: theme.colorScheme.primary,
            dotColor: theme.colorScheme.primary,
            gridColor: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        );
      },
    );
  }
}

/// Custom painter for the line chart.
class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.dataPoints,
    required this.minValue,
    required this.maxValue,
    required this.lineColor,
    required this.dotColor,
    required this.gridColor,
  });

  final List<TrendDataPoint> dataPoints;
  final double minValue;
  final double maxValue;
  final Color lineColor;
  final Color dotColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final padding = const EdgeInsets.all(8);
    final chartWidth = size.width - padding.left - padding.right;
    final chartHeight = size.height - padding.top - padding.bottom;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = padding.top + (chartHeight / 4) * i;
      canvas.drawLine(
        Offset(padding.left, y),
        Offset(size.width - padding.right, y),
        gridPaint,
      );
    }

    // Calculate points
    final range = maxValue - minValue;
    final points = <Offset>[];

    for (var i = 0; i < dataPoints.length; i++) {
      final x = padding.left + (chartWidth / (dataPoints.length - 1)) * i;
      final normalizedValue =
          range > 0 ? (dataPoints[i].value - minValue) / range : 0.5;
      final y = padding.top + chartHeight - (chartHeight * normalizedValue);
      points.add(Offset(x, y));
    }

    // Draw fill
    if (points.length >= 2) {
      final fillPath = Path();
      fillPath.moveTo(points.first.dx, size.height - padding.bottom);
      for (final point in points) {
        fillPath.lineTo(point.dx, point.dy);
      }
      fillPath.lineTo(points.last.dx, size.height - padding.bottom);
      fillPath.close();

      final fillPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.1)
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw line
    if (points.length >= 2) {
      final linePath = Path();
      linePath.moveTo(points.first.dx, points.first.dy);

      for (var i = 1; i < points.length; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }

      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(linePath, linePaint);
    }

    // Draw dots
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 5, dotBorderPaint);
      canvas.drawCircle(point, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return dataPoints != oldDelegate.dataPoints;
  }
}
