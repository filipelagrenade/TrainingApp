/// LiftIQ - Body Measurements Screen
///
/// Main screen for body measurement tracking.
/// Includes tabs for measurements history, photos, and trends.
///
/// Features:
/// - Measurement history list
/// - Progress photo gallery
/// - Trend charts for key metrics
/// - Add/edit measurement functionality
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/body_measurement.dart';
import '../providers/measurements_provider.dart';
import '../widgets/measurement_card.dart';
import '../widgets/measurement_chart.dart';
import '../widgets/photo_gallery.dart';
import 'add_measurement_screen.dart';

/// Main screen for body measurements feature.
class MeasurementsScreen extends ConsumerStatefulWidget {
  /// Creates a measurements screen.
  const MeasurementsScreen({super.key});

  @override
  ConsumerState<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends ConsumerState<MeasurementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(measurementsNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Measurements'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Measurements', icon: Icon(Icons.straighten)),
            Tab(text: 'Photos', icon: Icon(Icons.photo_library)),
            Tab(text: 'Trends', icon: Icon(Icons.trending_up)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Unit Settings',
            onPressed: () => _showUnitSettings(context),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.error!,
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(measurementsNotifierProvider.notifier).refresh();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _MeasurementsTab(measurements: state.measurements),
                    _PhotosTab(photos: state.photos),
                    _TrendsTab(trends: state.trends),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddMeasurement(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Measurement'),
      ),
    );
  }

  void _navigateToAddMeasurement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const AddMeasurementScreen(),
      ),
    );
  }

  void _showUnitSettings(BuildContext context) {
    final state = ref.read(measurementsNotifierProvider);
    final notifier = ref.read(measurementsNotifierProvider.notifier);

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unit Preferences',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'Weight',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<WeightUnit>(
              segments: const [
                ButtonSegment(
                  value: WeightUnit.kg,
                  label: Text('Kilograms (kg)'),
                ),
                ButtonSegment(
                  value: WeightUnit.lbs,
                  label: Text('Pounds (lbs)'),
                ),
              ],
              selected: {state.weightUnit},
              onSelectionChanged: (selected) {
                notifier.setWeightUnit(selected.first);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Length',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<LengthUnit>(
              segments: const [
                ButtonSegment(
                  value: LengthUnit.cm,
                  label: Text('Centimeters (cm)'),
                ),
                ButtonSegment(
                  value: LengthUnit.inches,
                  label: Text('Inches (in)'),
                ),
              ],
              selected: {state.lengthUnit},
              onSelectionChanged: (selected) {
                notifier.setLengthUnit(selected.first);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Tab showing measurement history.
class _MeasurementsTab extends StatelessWidget {
  const _MeasurementsTab({required this.measurements});

  final List<BodyMeasurement> measurements;

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.straighten_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No measurements yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to add your first measurement',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Trigger refresh - this would be implemented with a ref
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: measurements.length,
        itemBuilder: (context, index) {
          final measurement = measurements[index];
          final isLatest = index == 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MeasurementCard(
              measurement: measurement,
              isLatest: isLatest,
              previousMeasurement:
                  index < measurements.length - 1 ? measurements[index + 1] : null,
            ),
          );
        },
      ),
    );
  }
}

/// Tab showing progress photos.
class _PhotosTab extends StatelessWidget {
  const _PhotosTab({required this.photos});

  final List<ProgressPhoto> photos;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No progress photos yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Take photos to track your visual progress',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return PhotoGallery(photos: photos);
  }
}

/// Tab showing measurement trends.
class _TrendsTab extends StatelessWidget {
  const _TrendsTab({required this.trends});

  final List<MeasurementTrend> trends;

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Not enough data for trends',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add more measurements to see your progress over time',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final trendsWithData =
        trends.where((t) => t.dataPoints.isNotEmpty).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trendsWithData.length,
      itemBuilder: (context, index) {
        final trend = trendsWithData[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: MeasurementChart(trend: trend),
        );
      },
    );
  }
}
