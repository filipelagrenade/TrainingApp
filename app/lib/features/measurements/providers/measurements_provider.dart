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

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/api_client.dart';
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

  /// Loads all measurements from API.
  Future<void> _loadMeasurements() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final api = ref.read(apiClientProvider);

      // Fetch measurements and photos in parallel
      final measurementsResponse = await api.get('/measurements');
      final photosResponse = await api.get('/measurements/photos');

      final measurementsData = measurementsResponse.data as Map<String, dynamic>;
      final photosData = photosResponse.data as Map<String, dynamic>;

      final measurementsList = (measurementsData['data'] as List<dynamic>? ?? [])
          .map((json) => _parseMeasurement(json as Map<String, dynamic>))
          .toList();

      final photosList = (photosData['data'] as List<dynamic>? ?? [])
          .map((json) => _parsePhoto(json as Map<String, dynamic>))
          .toList();

      final trends = _calculateTrends(measurementsList);

      state = state.copyWith(
        measurements: measurementsList,
        latestMeasurement:
            measurementsList.isNotEmpty ? measurementsList.first : null,
        photos: photosList,
        trends: trends,
        isLoading: false,
      );
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      state = state.copyWith(
        isLoading: false,
        error: error.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load measurements: $e',
      );
    }
  }

  /// Parses a BodyMeasurement from API response.
  BodyMeasurement _parseMeasurement(Map<String, dynamic> json) {
    return BodyMeasurement(
      id: json['id'] as String,
      measuredAt: DateTime.parse(json['measuredAt'] as String),
      weight: (json['weight'] as num?)?.toDouble(),
      bodyFat: (json['bodyFat'] as num?)?.toDouble(),
      neck: (json['neck'] as num?)?.toDouble(),
      shoulders: (json['shoulders'] as num?)?.toDouble(),
      chest: (json['chest'] as num?)?.toDouble(),
      leftBicep: (json['leftBicep'] as num?)?.toDouble(),
      rightBicep: (json['rightBicep'] as num?)?.toDouble(),
      leftForearm: (json['leftForearm'] as num?)?.toDouble(),
      rightForearm: (json['rightForearm'] as num?)?.toDouble(),
      waist: (json['waist'] as num?)?.toDouble(),
      hips: (json['hips'] as num?)?.toDouble(),
      leftThigh: (json['leftThigh'] as num?)?.toDouble(),
      rightThigh: (json['rightThigh'] as num?)?.toDouble(),
      leftCalf: (json['leftCalf'] as num?)?.toDouble(),
      rightCalf: (json['rightCalf'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Parses a ProgressPhoto from API response.
  ProgressPhoto _parsePhoto(Map<String, dynamic> json) {
    final typeStr = json['photoType'] as String? ?? 'front';
    PhotoType photoType;
    switch (typeStr.toLowerCase()) {
      case 'front':
        photoType = PhotoType.front;
        break;
      case 'back':
        photoType = PhotoType.back;
        break;
      case 'sideleft':
      case 'side_left':
        photoType = PhotoType.sideLeft;
        break;
      case 'sideright':
      case 'side_right':
        photoType = PhotoType.sideRight;
        break;
      default:
        photoType = PhotoType.front;
    }

    return ProgressPhoto(
      id: json['id'] as String,
      photoUrl: json['photoUrl'] as String,
      photoType: photoType,
      takenAt: DateTime.parse(json['takenAt'] as String),
      measurementId: json['measurementId'] as String?,
      notes: json['notes'] as String?,
    );
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
      final api = ref.read(apiClientProvider);

      final response = await api.post('/measurements', data: {
        'measuredAt': (input.measuredAt ?? DateTime.now()).toIso8601String(),
        if (input.weight != null) 'weight': input.weight,
        if (input.bodyFat != null) 'bodyFat': input.bodyFat,
        if (input.neck != null) 'neck': input.neck,
        if (input.shoulders != null) 'shoulders': input.shoulders,
        if (input.chest != null) 'chest': input.chest,
        if (input.leftBicep != null) 'leftBicep': input.leftBicep,
        if (input.rightBicep != null) 'rightBicep': input.rightBicep,
        if (input.leftForearm != null) 'leftForearm': input.leftForearm,
        if (input.rightForearm != null) 'rightForearm': input.rightForearm,
        if (input.waist != null) 'waist': input.waist,
        if (input.hips != null) 'hips': input.hips,
        if (input.leftThigh != null) 'leftThigh': input.leftThigh,
        if (input.rightThigh != null) 'rightThigh': input.rightThigh,
        if (input.leftCalf != null) 'leftCalf': input.leftCalf,
        if (input.rightCalf != null) 'rightCalf': input.rightCalf,
        if (input.notes != null) 'notes': input.notes,
      });

      final data = response.data as Map<String, dynamic>;
      final measurementJson = data['data'] as Map<String, dynamic>;
      final measurement = _parseMeasurement(measurementJson);

      final updatedList = [measurement, ...state.measurements];
      final trends = _calculateTrends(updatedList);

      state = state.copyWith(
        measurements: updatedList,
        latestMeasurement: measurement,
        trends: trends,
      );

      return measurement;
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      state = state.copyWith(error: error.message);
      return null;
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
      final api = ref.read(apiClientProvider);

      final response = await api.patch('/measurements/$id', data: {
        if (input.measuredAt != null) 'measuredAt': input.measuredAt!.toIso8601String(),
        if (input.weight != null) 'weight': input.weight,
        if (input.bodyFat != null) 'bodyFat': input.bodyFat,
        if (input.neck != null) 'neck': input.neck,
        if (input.shoulders != null) 'shoulders': input.shoulders,
        if (input.chest != null) 'chest': input.chest,
        if (input.leftBicep != null) 'leftBicep': input.leftBicep,
        if (input.rightBicep != null) 'rightBicep': input.rightBicep,
        if (input.leftForearm != null) 'leftForearm': input.leftForearm,
        if (input.rightForearm != null) 'rightForearm': input.rightForearm,
        if (input.waist != null) 'waist': input.waist,
        if (input.hips != null) 'hips': input.hips,
        if (input.leftThigh != null) 'leftThigh': input.leftThigh,
        if (input.rightThigh != null) 'rightThigh': input.rightThigh,
        if (input.leftCalf != null) 'leftCalf': input.leftCalf,
        if (input.rightCalf != null) 'rightCalf': input.rightCalf,
        if (input.notes != null) 'notes': input.notes,
      });

      final data = response.data as Map<String, dynamic>;
      final measurementJson = data['data'] as Map<String, dynamic>;
      final updated = _parseMeasurement(measurementJson);

      final index = state.measurements.indexWhere((m) => m.id == id);
      if (index == -1) return updated;

      final updatedList = [...state.measurements];
      updatedList[index] = updated;
      final trends = _calculateTrends(updatedList);

      state = state.copyWith(
        measurements: updatedList,
        latestMeasurement: index == 0 ? updated : state.latestMeasurement,
        trends: trends,
      );

      return updated;
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      state = state.copyWith(error: error.message);
      return null;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update measurement: $e');
      return null;
    }
  }

  /// Deletes a measurement.
  Future<bool> deleteMeasurement(String id) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.delete('/measurements/$id');

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
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      state = state.copyWith(error: error.message);
      return false;
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
      final api = ref.read(apiClientProvider);

      final photoTypeStr = photoType.name;

      final response = await api.post('/measurements/photos', data: {
        'photoUrl': photoUrl,
        'photoType': photoTypeStr,
        'takenAt': DateTime.now().toIso8601String(),
        if (measurementId != null) 'measurementId': measurementId,
        if (notes != null) 'notes': notes,
      });

      final data = response.data as Map<String, dynamic>;
      final photoJson = data['data'] as Map<String, dynamic>;
      final photo = _parsePhoto(photoJson);

      state = state.copyWith(photos: [photo, ...state.photos]);
      return photo;
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      state = state.copyWith(error: error.message);
      return null;
    } catch (e) {
      state = state.copyWith(error: 'Failed to add photo: $e');
      return null;
    }
  }

  /// Deletes a progress photo.
  Future<bool> deletePhoto(String id) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.delete('/measurements/photos/$id');

      state = state.copyWith(
        photos: state.photos.where((p) => p.id != id).toList(),
      );

      return true;
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      state = state.copyWith(error: error.message);
      return false;
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
