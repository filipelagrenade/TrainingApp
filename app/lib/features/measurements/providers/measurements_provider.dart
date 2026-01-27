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

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/user_storage_keys.dart';
import '../models/body_measurement.dart';

part 'measurements_provider.g.dart';

const _uuid = Uuid();

/// Provider for measurements state.
@riverpod
class MeasurementsNotifier extends _$MeasurementsNotifier {
  @override
  MeasurementsState build() {
    // Load initial data
    _loadMeasurements();
    return const MeasurementsState(isLoading: true);
  }

  String get _measurementsKey => UserStorageKeys.measurements('local-offline-user');
  String get _photosKey => '${_measurementsKey}_photos';

  /// Loads all measurements from SharedPreferences.
  Future<void> _loadMeasurements() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load measurements
      final measurementsJson = prefs.getString(_measurementsKey);
      List<BodyMeasurement> measurementsList = [];
      if (measurementsJson != null) {
        final decoded = jsonDecode(measurementsJson) as List<dynamic>;
        measurementsList = decoded
            .map((json) => BodyMeasurement.fromJson(json as Map<String, dynamic>))
            .toList();
        // Sort by date descending (most recent first)
        measurementsList.sort((a, b) => b.measuredAt.compareTo(a.measuredAt));
      }

      // Load photos
      final photosJson = prefs.getString(_photosKey);
      List<ProgressPhoto> photosList = [];
      if (photosJson != null) {
        final decoded = jsonDecode(photosJson) as List<dynamic>;
        photosList = decoded
            .map((json) => ProgressPhoto.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      final trends = _calculateTrends(measurementsList);

      state = state.copyWith(
        measurements: measurementsList,
        latestMeasurement:
            measurementsList.isNotEmpty ? measurementsList.first : null,
        photos: photosList,
        trends: trends,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('MeasurementsNotifier: Error loading: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load measurements: $e',
      );
    }
  }

  /// Persists measurements to SharedPreferences.
  Future<void> _persistMeasurements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(
        state.measurements.map((m) => m.toJson()).toList(),
      );
      await prefs.setString(_measurementsKey, json);
    } catch (e) {
      debugPrint('MeasurementsNotifier: Error persisting: $e');
    }
  }

  /// Persists photos to SharedPreferences.
  Future<void> _persistPhotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(
        state.photos.map((p) => p.toJson()).toList(),
      );
      await prefs.setString(_photosKey, json);
    } catch (e) {
      debugPrint('MeasurementsNotifier: Error persisting photos: $e');
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
      final now = DateTime.now();
      final measurement = BodyMeasurement(
        id: _uuid.v4(),
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

      await _persistMeasurements();
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
      final index = state.measurements.indexWhere((m) => m.id == id);
      if (index == -1) return null;

      final existing = state.measurements[index];
      final updated = BodyMeasurement(
        id: existing.id,
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
        createdAt: existing.createdAt,
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

      await _persistMeasurements();
      return updated;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update measurement: $e');
      return null;
    }
  }

  /// Deletes a measurement.
  Future<bool> deleteMeasurement(String id) async {
    try {
      final updatedList =
          state.measurements.where((m) => m.id != id).toList();
      final trends = _calculateTrends(updatedList);

      state = state.copyWith(
        measurements: updatedList,
        latestMeasurement:
            updatedList.isNotEmpty ? updatedList.first : null,
        trends: trends,
      );

      await _persistMeasurements();
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
      final photo = ProgressPhoto(
        id: _uuid.v4(),
        photoUrl: photoUrl,
        photoType: photoType,
        takenAt: DateTime.now(),
        measurementId: measurementId,
        notes: notes,
      );

      state = state.copyWith(photos: [photo, ...state.photos]);
      await _persistPhotos();
      return photo;
    } catch (e) {
      state = state.copyWith(error: 'Failed to add photo: $e');
      return null;
    }
  }

  /// Deletes a progress photo.
  Future<bool> deletePhoto(String id) async {
    try {
      state = state.copyWith(
        photos: state.photos.where((p) => p.id != id).toList(),
      );
      await _persistPhotos();
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
