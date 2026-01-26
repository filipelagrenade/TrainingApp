/// LiftIQ - Measurements Provider
///
/// State management for body measurements and progress photos.
/// Handles CRUD operations, trend calculations, and unit preferences.
///
/// Features:
/// - Measurement history management
/// - Progress photo management
/// - Trend calculations for key metrics
/// - Unit conversion preferences
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/body_measurement.dart';

part 'measurements_provider.g.dart';

/// Provider for measurements state.
@riverpod
class MeasurementsNotifier extends _$MeasurementsNotifier {
  @override
  MeasurementsState build() {
    // Load initial data
    _loadMeasurements();
    return const MeasurementsState(isLoading: true);
  }

  /// Loads all measurements from API/local storage.
  Future<void> _loadMeasurements() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Replace with actual API calls
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Mock data for development
      final mockMeasurements = _generateMockMeasurements();
      final mockPhotos = _generateMockPhotos();
      final trends = _calculateTrends(mockMeasurements);

      state = state.copyWith(
        measurements: mockMeasurements,
        latestMeasurement:
            mockMeasurements.isNotEmpty ? mockMeasurements.first : null,
        photos: mockPhotos,
        trends: trends,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load measurements: $e',
      );
    }
  }

  /// Refreshes all measurements data.
  Future<void> refresh() async {
    await _loadMeasurements();
  }

  /// Creates a new measurement.
  Future<BodyMeasurement?> createMeasurement(
    CreateMeasurementInput input,
  ) async {
    try {
      // TODO: Replace with actual API call
      await Future<void>.delayed(const Duration(milliseconds: 300));

      final now = DateTime.now();
      final measurement = BodyMeasurement(
        id: 'meas-${now.millisecondsSinceEpoch}',
        measuredAt: input.measuredAt ?? now,
        weight: input.weight,
        bodyFat: input.bodyFat,
        neck: input.neck,
        shoulders: input.shoulders,
        chest: input.chest,
        leftBicep: input.leftBicep,
        rightBicep: input.rightBicep,
        leftForearm: input.leftForearm,
        rightForearm: input.rightForearm,
        waist: input.waist,
        hips: input.hips,
        leftThigh: input.leftThigh,
        rightThigh: input.rightThigh,
        leftCalf: input.leftCalf,
        rightCalf: input.rightCalf,
        notes: input.notes,
        createdAt: now,
        updatedAt: now,
      );

      final updatedList = [measurement, ...state.measurements];
      final trends = _calculateTrends(updatedList);

      state = state.copyWith(
        measurements: updatedList,
        latestMeasurement: measurement,
        trends: trends,
      );

      return measurement;
    } catch (e) {
      state = state.copyWith(error: 'Failed to create measurement: $e');
      return null;
    }
  }

  /// Updates an existing measurement.
  Future<BodyMeasurement?> updateMeasurement(
    String id,
    CreateMeasurementInput input,
  ) async {
    try {
      // TODO: Replace with actual API call
      await Future<void>.delayed(const Duration(milliseconds: 300));

      final index = state.measurements.indexWhere((m) => m.id == id);
      if (index == -1) return null;

      final existing = state.measurements[index];
      final updated = existing.copyWith(
        measuredAt: input.measuredAt ?? existing.measuredAt,
        weight: input.weight ?? existing.weight,
        bodyFat: input.bodyFat ?? existing.bodyFat,
        neck: input.neck ?? existing.neck,
        shoulders: input.shoulders ?? existing.shoulders,
        chest: input.chest ?? existing.chest,
        leftBicep: input.leftBicep ?? existing.leftBicep,
        rightBicep: input.rightBicep ?? existing.rightBicep,
        leftForearm: input.leftForearm ?? existing.leftForearm,
        rightForearm: input.rightForearm ?? existing.rightForearm,
        waist: input.waist ?? existing.waist,
        hips: input.hips ?? existing.hips,
        leftThigh: input.leftThigh ?? existing.leftThigh,
        rightThigh: input.rightThigh ?? existing.rightThigh,
        leftCalf: input.leftCalf ?? existing.leftCalf,
        rightCalf: input.rightCalf ?? existing.rightCalf,
        notes: input.notes ?? existing.notes,
        updatedAt: DateTime.now(),
      );

      final updatedList = [...state.measurements];
      updatedList[index] = updated;
      final trends = _calculateTrends(updatedList);

      state = state.copyWith(
        measurements: updatedList,
        latestMeasurement: index == 0 ? updated : state.latestMeasurement,
        trends: trends,
      );

      return updated;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update measurement: $e');
      return null;
    }
  }

  /// Deletes a measurement.
  Future<bool> deleteMeasurement(String id) async {
    try {
      // TODO: Replace with actual API call
      await Future<void>.delayed(const Duration(milliseconds: 300));

      final updatedList =
          state.measurements.where((m) => m.id != id).toList();
      final trends = _calculateTrends(updatedList);

      state = state.copyWith(
        measurements: updatedList,
        latestMeasurement:
            updatedList.isNotEmpty ? updatedList.first : null,
        trends: trends,
      );

      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete measurement: $e');
      return false;
    }
  }

  /// Adds a progress photo.
  Future<ProgressPhoto?> addPhoto({
    required String photoUrl,
    required PhotoType photoType,
    String? measurementId,
    String? notes,
  }) async {
    try {
      // TODO: Replace with actual API call
      await Future<void>.delayed(const Duration(milliseconds: 300));

      final photo = ProgressPhoto(
        id: 'photo-${DateTime.now().millisecondsSinceEpoch}',
        photoUrl: photoUrl,
        photoType: photoType,
        takenAt: DateTime.now(),
        measurementId: measurementId,
        notes: notes,
      );

      state = state.copyWith(photos: [photo, ...state.photos]);
      return photo;
    } catch (e) {
      state = state.copyWith(error: 'Failed to add photo: $e');
      return null;
    }
  }

  /// Deletes a progress photo.
  Future<bool> deletePhoto(String id) async {
    try {
      // TODO: Replace with actual API call
      await Future<void>.delayed(const Duration(milliseconds: 300));

      state = state.copyWith(
        photos: state.photos.where((p) => p.id != id).toList(),
      );

      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete photo: $e');
      return false;
    }
  }

  /// Sets the preferred length unit.
  void setLengthUnit(LengthUnit unit) {
    state = state.copyWith(lengthUnit: unit);
  }

  /// Sets the preferred weight unit.
  void setWeightUnit(WeightUnit unit) {
    state = state.copyWith(weightUnit: unit);
  }

  /// Calculates trends from measurements.
  List<MeasurementTrend> _calculateTrends(List<BodyMeasurement> measurements) {
    if (measurements.isEmpty) return [];

    final fields = [
      'weight',
      'bodyFat',
      'waist',
      'chest',
      'leftBicep',
      'rightBicep',
    ];
    final trends = <MeasurementTrend>[];

    for (final field in fields) {
      final dataPoints = <TrendDataPoint>[];

      for (final m in measurements.reversed) {
        final value = _getFieldValue(m, field);
        if (value != null) {
          dataPoints.add(TrendDataPoint(date: m.measuredAt, value: value));
        }
      }

      if (dataPoints.isEmpty) {
        trends.add(MeasurementTrend(
          field: field,
          trend: TrendDirection.unknown,
        ));
        continue;
      }

      final current = dataPoints.last.value;
      final previous = dataPoints.length > 1
          ? dataPoints[dataPoints.length - 2].value
          : null;

      double? change;
      double? changePercent;
      TrendDirection trend = TrendDirection.unknown;

      if (previous != null) {
        change = current - previous;
        changePercent = (change / previous) * 100;

        if (change.abs() < 0.1) {
          trend = TrendDirection.stable;
        } else {
          trend = change > 0 ? TrendDirection.up : TrendDirection.down;
        }
      }

      trends.add(MeasurementTrend(
        field: field,
        currentValue: current,
        previousValue: previous,
        change: change,
        changePercent: changePercent != null
            ? double.parse(changePercent.toStringAsFixed(1))
            : null,
        trend: trend,
        dataPoints: dataPoints,
      ));
    }

    return trends;
  }

  /// Gets a field value from a measurement.
  double? _getFieldValue(BodyMeasurement m, String field) {
    switch (field) {
      case 'weight':
        return m.weight;
      case 'bodyFat':
        return m.bodyFat;
      case 'waist':
        return m.waist;
      case 'chest':
        return m.chest;
      case 'leftBicep':
        return m.leftBicep;
      case 'rightBicep':
        return m.rightBicep;
      case 'neck':
        return m.neck;
      case 'shoulders':
        return m.shoulders;
      case 'hips':
        return m.hips;
      case 'leftThigh':
        return m.leftThigh;
      case 'rightThigh':
        return m.rightThigh;
      case 'leftCalf':
        return m.leftCalf;
      case 'rightCalf':
        return m.rightCalf;
      default:
        return null;
    }
  }

  /// Generates mock measurements for development.
  List<BodyMeasurement> _generateMockMeasurements() {
    final now = DateTime.now();
    return [
      BodyMeasurement(
        id: 'meas-1',
        measuredAt: now,
        weight: 82.5,
        bodyFat: 15.2,
        chest: 102.0,
        waist: 84.0,
        hips: 98.0,
        leftBicep: 36.5,
        rightBicep: 37.0,
        leftThigh: 58.0,
        rightThigh: 58.5,
        neck: 38.0,
        shoulders: 118.0,
        notes: 'Feeling good after this week!',
        createdAt: now,
        updatedAt: now,
      ),
      BodyMeasurement(
        id: 'meas-2',
        measuredAt: now.subtract(const Duration(days: 7)),
        weight: 83.0,
        bodyFat: 15.5,
        chest: 101.5,
        waist: 85.0,
        hips: 98.0,
        leftBicep: 36.0,
        rightBicep: 36.5,
        leftThigh: 57.5,
        rightThigh: 58.0,
        neck: 38.0,
        shoulders: 117.5,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      BodyMeasurement(
        id: 'meas-3',
        measuredAt: now.subtract(const Duration(days: 14)),
        weight: 83.5,
        bodyFat: 16.0,
        chest: 101.0,
        waist: 86.0,
        hips: 98.5,
        leftBicep: 35.5,
        rightBicep: 36.0,
        leftThigh: 57.0,
        rightThigh: 57.5,
        neck: 37.5,
        shoulders: 117.0,
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 14)),
      ),
      BodyMeasurement(
        id: 'meas-4',
        measuredAt: now.subtract(const Duration(days: 21)),
        weight: 84.0,
        bodyFat: 16.5,
        chest: 100.5,
        waist: 87.0,
        hips: 99.0,
        leftBicep: 35.0,
        rightBicep: 35.5,
        leftThigh: 56.5,
        rightThigh: 57.0,
        neck: 37.5,
        shoulders: 116.5,
        createdAt: now.subtract(const Duration(days: 21)),
        updatedAt: now.subtract(const Duration(days: 21)),
      ),
    ];
  }

  /// Generates mock photos for development.
  List<ProgressPhoto> _generateMockPhotos() {
    final now = DateTime.now();
    return [
      ProgressPhoto(
        id: 'photo-1',
        photoUrl: 'https://placeholder.com/photo1.jpg',
        photoType: PhotoType.front,
        takenAt: now,
        measurementId: 'meas-1',
      ),
      ProgressPhoto(
        id: 'photo-2',
        photoUrl: 'https://placeholder.com/photo2.jpg',
        photoType: PhotoType.sideLeft,
        takenAt: now,
        measurementId: 'meas-1',
      ),
      ProgressPhoto(
        id: 'photo-3',
        photoUrl: 'https://placeholder.com/photo3.jpg',
        photoType: PhotoType.front,
        takenAt: now.subtract(const Duration(days: 7)),
        measurementId: 'meas-2',
      ),
    ];
  }
}

/// Provider for the latest measurement only.
@riverpod
BodyMeasurement? latestMeasurement(LatestMeasurementRef ref) {
  final state = ref.watch(measurementsNotifierProvider);
  return state.latestMeasurement;
}

/// Provider for measurement trends.
@riverpod
List<MeasurementTrend> measurementTrends(MeasurementTrendsRef ref) {
  final state = ref.watch(measurementsNotifierProvider);
  return state.trends;
}

/// Provider for a specific measurement trend.
@riverpod
MeasurementTrend? measurementTrendFor(
  MeasurementTrendForRef ref,
  String field,
) {
  final trends = ref.watch(measurementTrendsProvider);
  try {
    return trends.firstWhere((t) => t.field == field);
  } catch (_) {
    return null;
  }
}

/// Provider for all progress photos.
@riverpod
List<ProgressPhoto> progressPhotos(ProgressPhotosRef ref) {
  final state = ref.watch(measurementsNotifierProvider);
  return state.photos;
}

/// Provider for photos filtered by type.
@riverpod
List<ProgressPhoto> photosByType(PhotosByTypeRef ref, PhotoType type) {
  final photos = ref.watch(progressPhotosProvider);
  return photos.where((p) => p.photoType == type).toList();
}
