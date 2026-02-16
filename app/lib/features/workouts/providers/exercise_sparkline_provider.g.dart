// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_sparkline_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$exerciseSparklineHash() => r'7da92896528e319984df3ea2436886339d42d4bd';

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

/// Provides sparkline data for exercise weight progression.
///
/// Fetches the last N sessions for an exercise and extracts the
/// maximum weight lifted in each session.
///
/// ## Usage
/// ```dart
/// final sparklineData = ref.watch(exerciseSparklineProvider(exerciseId));
/// sparklineData.when(
///   data: (data) => SparklineChart(data: data),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error'),
/// );
/// ```
///
/// Copied from [exerciseSparkline].
@ProviderFor(exerciseSparkline)
const exerciseSparklineProvider = ExerciseSparklineFamily();

/// Provides sparkline data for exercise weight progression.
///
/// Fetches the last N sessions for an exercise and extracts the
/// maximum weight lifted in each session.
///
/// ## Usage
/// ```dart
/// final sparklineData = ref.watch(exerciseSparklineProvider(exerciseId));
/// sparklineData.when(
///   data: (data) => SparklineChart(data: data),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error'),
/// );
/// ```
///
/// Copied from [exerciseSparkline].
class ExerciseSparklineFamily extends Family<AsyncValue<List<double>>> {
  /// Provides sparkline data for exercise weight progression.
  ///
  /// Fetches the last N sessions for an exercise and extracts the
  /// maximum weight lifted in each session.
  ///
  /// ## Usage
  /// ```dart
  /// final sparklineData = ref.watch(exerciseSparklineProvider(exerciseId));
  /// sparklineData.when(
  ///   data: (data) => SparklineChart(data: data),
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (e, _) => Text('Error'),
  /// );
  /// ```
  ///
  /// Copied from [exerciseSparkline].
  const ExerciseSparklineFamily();

  /// Provides sparkline data for exercise weight progression.
  ///
  /// Fetches the last N sessions for an exercise and extracts the
  /// maximum weight lifted in each session.
  ///
  /// ## Usage
  /// ```dart
  /// final sparklineData = ref.watch(exerciseSparklineProvider(exerciseId));
  /// sparklineData.when(
  ///   data: (data) => SparklineChart(data: data),
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (e, _) => Text('Error'),
  /// );
  /// ```
  ///
  /// Copied from [exerciseSparkline].
  ExerciseSparklineProvider call(
    String exerciseId,
  ) {
    return ExerciseSparklineProvider(
      exerciseId,
    );
  }

  @override
  ExerciseSparklineProvider getProviderOverride(
    covariant ExerciseSparklineProvider provider,
  ) {
    return call(
      provider.exerciseId,
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
  String? get name => r'exerciseSparklineProvider';
}

/// Provides sparkline data for exercise weight progression.
///
/// Fetches the last N sessions for an exercise and extracts the
/// maximum weight lifted in each session.
///
/// ## Usage
/// ```dart
/// final sparklineData = ref.watch(exerciseSparklineProvider(exerciseId));
/// sparklineData.when(
///   data: (data) => SparklineChart(data: data),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error'),
/// );
/// ```
///
/// Copied from [exerciseSparkline].
class ExerciseSparklineProvider
    extends AutoDisposeFutureProvider<List<double>> {
  /// Provides sparkline data for exercise weight progression.
  ///
  /// Fetches the last N sessions for an exercise and extracts the
  /// maximum weight lifted in each session.
  ///
  /// ## Usage
  /// ```dart
  /// final sparklineData = ref.watch(exerciseSparklineProvider(exerciseId));
  /// sparklineData.when(
  ///   data: (data) => SparklineChart(data: data),
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (e, _) => Text('Error'),
  /// );
  /// ```
  ///
  /// Copied from [exerciseSparkline].
  ExerciseSparklineProvider(
    String exerciseId,
  ) : this._internal(
          (ref) => exerciseSparkline(
            ref as ExerciseSparklineRef,
            exerciseId,
          ),
          from: exerciseSparklineProvider,
          name: r'exerciseSparklineProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$exerciseSparklineHash,
          dependencies: ExerciseSparklineFamily._dependencies,
          allTransitiveDependencies:
              ExerciseSparklineFamily._allTransitiveDependencies,
          exerciseId: exerciseId,
        );

  ExerciseSparklineProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.exerciseId,
  }) : super.internal();

  final String exerciseId;

  @override
  Override overrideWith(
    FutureOr<List<double>> Function(ExerciseSparklineRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExerciseSparklineProvider._internal(
        (ref) => create(ref as ExerciseSparklineRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        exerciseId: exerciseId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<double>> createElement() {
    return _ExerciseSparklineProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExerciseSparklineProvider && other.exerciseId == exerciseId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, exerciseId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ExerciseSparklineRef on AutoDisposeFutureProviderRef<List<double>> {
  /// The parameter `exerciseId` of this provider.
  String get exerciseId;
}

class _ExerciseSparklineProviderElement
    extends AutoDisposeFutureProviderElement<List<double>>
    with ExerciseSparklineRef {
  _ExerciseSparklineProviderElement(super.provider);

  @override
  String get exerciseId => (origin as ExerciseSparklineProvider).exerciseId;
}

String _$exerciseSparklineMetricsHash() =>
    r'9a3cb9b3e4055df63c5b14d93238c05376ca2638';

/// Provides sparkline data with additional metrics.
///
/// Returns both the sparkline data and calculated trend information.
///
/// Copied from [exerciseSparklineMetrics].
@ProviderFor(exerciseSparklineMetrics)
const exerciseSparklineMetricsProvider = ExerciseSparklineMetricsFamily();

/// Provides sparkline data with additional metrics.
///
/// Returns both the sparkline data and calculated trend information.
///
/// Copied from [exerciseSparklineMetrics].
class ExerciseSparklineMetricsFamily
    extends Family<AsyncValue<SparklineMetrics>> {
  /// Provides sparkline data with additional metrics.
  ///
  /// Returns both the sparkline data and calculated trend information.
  ///
  /// Copied from [exerciseSparklineMetrics].
  const ExerciseSparklineMetricsFamily();

  /// Provides sparkline data with additional metrics.
  ///
  /// Returns both the sparkline data and calculated trend information.
  ///
  /// Copied from [exerciseSparklineMetrics].
  ExerciseSparklineMetricsProvider call(
    String exerciseId,
  ) {
    return ExerciseSparklineMetricsProvider(
      exerciseId,
    );
  }

  @override
  ExerciseSparklineMetricsProvider getProviderOverride(
    covariant ExerciseSparklineMetricsProvider provider,
  ) {
    return call(
      provider.exerciseId,
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
  String? get name => r'exerciseSparklineMetricsProvider';
}

/// Provides sparkline data with additional metrics.
///
/// Returns both the sparkline data and calculated trend information.
///
/// Copied from [exerciseSparklineMetrics].
class ExerciseSparklineMetricsProvider
    extends AutoDisposeFutureProvider<SparklineMetrics> {
  /// Provides sparkline data with additional metrics.
  ///
  /// Returns both the sparkline data and calculated trend information.
  ///
  /// Copied from [exerciseSparklineMetrics].
  ExerciseSparklineMetricsProvider(
    String exerciseId,
  ) : this._internal(
          (ref) => exerciseSparklineMetrics(
            ref as ExerciseSparklineMetricsRef,
            exerciseId,
          ),
          from: exerciseSparklineMetricsProvider,
          name: r'exerciseSparklineMetricsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$exerciseSparklineMetricsHash,
          dependencies: ExerciseSparklineMetricsFamily._dependencies,
          allTransitiveDependencies:
              ExerciseSparklineMetricsFamily._allTransitiveDependencies,
          exerciseId: exerciseId,
        );

  ExerciseSparklineMetricsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.exerciseId,
  }) : super.internal();

  final String exerciseId;

  @override
  Override overrideWith(
    FutureOr<SparklineMetrics> Function(ExerciseSparklineMetricsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExerciseSparklineMetricsProvider._internal(
        (ref) => create(ref as ExerciseSparklineMetricsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        exerciseId: exerciseId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SparklineMetrics> createElement() {
    return _ExerciseSparklineMetricsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExerciseSparklineMetricsProvider &&
        other.exerciseId == exerciseId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, exerciseId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ExerciseSparklineMetricsRef
    on AutoDisposeFutureProviderRef<SparklineMetrics> {
  /// The parameter `exerciseId` of this provider.
  String get exerciseId;
}

class _ExerciseSparklineMetricsProviderElement
    extends AutoDisposeFutureProviderElement<SparklineMetrics>
    with ExerciseSparklineMetricsRef {
  _ExerciseSparklineMetricsProviderElement(super.provider);

  @override
  String get exerciseId =>
      (origin as ExerciseSparklineMetricsProvider).exerciseId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
