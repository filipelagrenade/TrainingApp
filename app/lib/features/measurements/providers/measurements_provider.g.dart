// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurements_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$latestMeasurementHash() => r'f91767dc92ebe1c8ea06fd94a9564783a8dbd2a3';

/// Provider for the latest measurement only.
///
/// Copied from [latestMeasurement].
@ProviderFor(latestMeasurement)
final latestMeasurementProvider =
    AutoDisposeProvider<BodyMeasurement?>.internal(
  latestMeasurement,
  name: r'latestMeasurementProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$latestMeasurementHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LatestMeasurementRef = AutoDisposeProviderRef<BodyMeasurement?>;
String _$measurementTrendsHash() => r'49435fb0d7b78411c4a5fc6383b1427064513e08';

/// Provider for measurement trends.
///
/// Copied from [measurementTrends].
@ProviderFor(measurementTrends)
final measurementTrendsProvider =
    AutoDisposeProvider<List<MeasurementTrend>>.internal(
  measurementTrends,
  name: r'measurementTrendsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$measurementTrendsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MeasurementTrendsRef = AutoDisposeProviderRef<List<MeasurementTrend>>;
String _$measurementTrendForHash() =>
    r'370d3367e6cb21e87696bb123baaaac026c8ecce';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for a specific measurement trend.
///
/// Copied from [measurementTrendFor].
@ProviderFor(measurementTrendFor)
const measurementTrendForProvider = MeasurementTrendForFamily();

/// Provider for a specific measurement trend.
///
/// Copied from [measurementTrendFor].
class MeasurementTrendForFamily extends Family<MeasurementTrend?> {
  /// Provider for a specific measurement trend.
  ///
  /// Copied from [measurementTrendFor].
  const MeasurementTrendForFamily();

  /// Provider for a specific measurement trend.
  ///
  /// Copied from [measurementTrendFor].
  MeasurementTrendForProvider call(
    String field,
  ) {
    return MeasurementTrendForProvider(
      field,
    );
  }

  @override
  MeasurementTrendForProvider getProviderOverride(
    covariant MeasurementTrendForProvider provider,
  ) {
    return call(
      provider.field,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'measurementTrendForProvider';
}

/// Provider for a specific measurement trend.
///
/// Copied from [measurementTrendFor].
class MeasurementTrendForProvider
    extends AutoDisposeProvider<MeasurementTrend?> {
  /// Provider for a specific measurement trend.
  ///
  /// Copied from [measurementTrendFor].
  MeasurementTrendForProvider(
    String field,
  ) : this._internal(
          (ref) => measurementTrendFor(
            ref as MeasurementTrendForRef,
            field,
          ),
          from: measurementTrendForProvider,
          name: r'measurementTrendForProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$measurementTrendForHash,
          dependencies: MeasurementTrendForFamily._dependencies,
          allTransitiveDependencies:
              MeasurementTrendForFamily._allTransitiveDependencies,
          field: field,
        );

  MeasurementTrendForProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.field,
  }) : super.internal();

  final String field;

  @override
  Override overrideWith(
    MeasurementTrend? Function(MeasurementTrendForRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MeasurementTrendForProvider._internal(
        (ref) => create(ref as MeasurementTrendForRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        field: field,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<MeasurementTrend?> createElement() {
    return _MeasurementTrendForProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MeasurementTrendForProvider && other.field == field;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, field.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MeasurementTrendForRef on AutoDisposeProviderRef<MeasurementTrend?> {
  /// The parameter `field` of this provider.
  String get field;
}

class _MeasurementTrendForProviderElement
    extends AutoDisposeProviderElement<MeasurementTrend?>
    with MeasurementTrendForRef {
  _MeasurementTrendForProviderElement(super.provider);

  @override
  String get field => (origin as MeasurementTrendForProvider).field;
}

String _$progressPhotosHash() => r'1386a6a766c90715af28c02ead8346060967ccde';

/// Provider for all progress photos.
///
/// Copied from [progressPhotos].
@ProviderFor(progressPhotos)
final progressPhotosProvider =
    AutoDisposeProvider<List<ProgressPhoto>>.internal(
  progressPhotos,
  name: r'progressPhotosProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$progressPhotosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ProgressPhotosRef = AutoDisposeProviderRef<List<ProgressPhoto>>;
String _$photosByTypeHash() => r'3fdbc618b9c4bc83b1fcf170cdda296623160df4';

/// Provider for photos filtered by type.
///
/// Copied from [photosByType].
@ProviderFor(photosByType)
const photosByTypeProvider = PhotosByTypeFamily();

/// Provider for photos filtered by type.
///
/// Copied from [photosByType].
class PhotosByTypeFamily extends Family<List<ProgressPhoto>> {
  /// Provider for photos filtered by type.
  ///
  /// Copied from [photosByType].
  const PhotosByTypeFamily();

  /// Provider for photos filtered by type.
  ///
  /// Copied from [photosByType].
  PhotosByTypeProvider call(
    PhotoType type,
  ) {
    return PhotosByTypeProvider(
      type,
    );
  }

  @override
  PhotosByTypeProvider getProviderOverride(
    covariant PhotosByTypeProvider provider,
  ) {
    return call(
      provider.type,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'photosByTypeProvider';
}

/// Provider for photos filtered by type.
///
/// Copied from [photosByType].
class PhotosByTypeProvider extends AutoDisposeProvider<List<ProgressPhoto>> {
  /// Provider for photos filtered by type.
  ///
  /// Copied from [photosByType].
  PhotosByTypeProvider(
    PhotoType type,
  ) : this._internal(
          (ref) => photosByType(
            ref as PhotosByTypeRef,
            type,
          ),
          from: photosByTypeProvider,
          name: r'photosByTypeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$photosByTypeHash,
          dependencies: PhotosByTypeFamily._dependencies,
          allTransitiveDependencies:
              PhotosByTypeFamily._allTransitiveDependencies,
          type: type,
        );

  PhotosByTypeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.type,
  }) : super.internal();

  final PhotoType type;

  @override
  Override overrideWith(
    List<ProgressPhoto> Function(PhotosByTypeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PhotosByTypeProvider._internal(
        (ref) => create(ref as PhotosByTypeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<ProgressPhoto>> createElement() {
    return _PhotosByTypeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PhotosByTypeProvider && other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PhotosByTypeRef on AutoDisposeProviderRef<List<ProgressPhoto>> {
  /// The parameter `type` of this provider.
  PhotoType get type;
}

class _PhotosByTypeProviderElement
    extends AutoDisposeProviderElement<List<ProgressPhoto>>
    with PhotosByTypeRef {
  _PhotosByTypeProviderElement(super.provider);

  @override
  PhotoType get type => (origin as PhotosByTypeProvider).type;
}

String _$measurementsNotifierHash() =>
    r'bd49e1a3162b4cf614345d607b30cfd380d8a2ab';

/// Provider for measurements state.
///
/// Copied from [MeasurementsNotifier].
@ProviderFor(MeasurementsNotifier)
final measurementsNotifierProvider = AutoDisposeNotifierProvider<
    MeasurementsNotifier, MeasurementsState>.internal(
  MeasurementsNotifier.new,
  name: r'measurementsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$measurementsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MeasurementsNotifier = AutoDisposeNotifier<MeasurementsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
