// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkoutSummary _$WorkoutSummaryFromJson(Map<String, dynamic> json) {
  return _WorkoutSummary.fromJson(json);
}

/// @nodoc
mixin _$WorkoutSummary {
  /// Session ID
  String get id => throw _privateConstructorUsedError;

  /// When workout started
  DateTime get date => throw _privateConstructorUsedError;

  /// When workout completed (null if abandoned)
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Duration in minutes
  int? get durationMinutes => throw _privateConstructorUsedError;

  /// Template name if started from template
  String? get templateName => throw _privateConstructorUsedError;

  /// Number of exercises performed
  int get exerciseCount => throw _privateConstructorUsedError;

  /// Total working sets
  int get totalSets => throw _privateConstructorUsedError;

  /// Total volume (weight × reps)
  int get totalVolume => throw _privateConstructorUsedError;

  /// Muscle groups trained
  List<String> get muscleGroups => throw _privateConstructorUsedError;

  /// Number of PRs achieved
  int get prsAchieved => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkoutSummaryCopyWith<WorkoutSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutSummaryCopyWith<$Res> {
  factory $WorkoutSummaryCopyWith(
          WorkoutSummary value, $Res Function(WorkoutSummary) then) =
      _$WorkoutSummaryCopyWithImpl<$Res, WorkoutSummary>;
  @useResult
  $Res call(
      {String id,
      DateTime date,
      DateTime? completedAt,
      int? durationMinutes,
      String? templateName,
      int exerciseCount,
      int totalSets,
      int totalVolume,
      List<String> muscleGroups,
      int prsAchieved});
}

/// @nodoc
class _$WorkoutSummaryCopyWithImpl<$Res, $Val extends WorkoutSummary>
    implements $WorkoutSummaryCopyWith<$Res> {
  _$WorkoutSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? completedAt = freezed,
    Object? durationMinutes = freezed,
    Object? templateName = freezed,
    Object? exerciseCount = null,
    Object? totalSets = null,
    Object? totalVolume = null,
    Object? muscleGroups = null,
    Object? prsAchieved = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      templateName: freezed == templateName
          ? _value.templateName
          : templateName // ignore: cast_nullable_to_non_nullable
              as String?,
      exerciseCount: null == exerciseCount
          ? _value.exerciseCount
          : exerciseCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalSets: null == totalSets
          ? _value.totalSets
          : totalSets // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume: null == totalVolume
          ? _value.totalVolume
          : totalVolume // ignore: cast_nullable_to_non_nullable
              as int,
      muscleGroups: null == muscleGroups
          ? _value.muscleGroups
          : muscleGroups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      prsAchieved: null == prsAchieved
          ? _value.prsAchieved
          : prsAchieved // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutSummaryImplCopyWith<$Res>
    implements $WorkoutSummaryCopyWith<$Res> {
  factory _$$WorkoutSummaryImplCopyWith(_$WorkoutSummaryImpl value,
          $Res Function(_$WorkoutSummaryImpl) then) =
      __$$WorkoutSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime date,
      DateTime? completedAt,
      int? durationMinutes,
      String? templateName,
      int exerciseCount,
      int totalSets,
      int totalVolume,
      List<String> muscleGroups,
      int prsAchieved});
}

/// @nodoc
class __$$WorkoutSummaryImplCopyWithImpl<$Res>
    extends _$WorkoutSummaryCopyWithImpl<$Res, _$WorkoutSummaryImpl>
    implements _$$WorkoutSummaryImplCopyWith<$Res> {
  __$$WorkoutSummaryImplCopyWithImpl(
      _$WorkoutSummaryImpl _value, $Res Function(_$WorkoutSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? completedAt = freezed,
    Object? durationMinutes = freezed,
    Object? templateName = freezed,
    Object? exerciseCount = null,
    Object? totalSets = null,
    Object? totalVolume = null,
    Object? muscleGroups = null,
    Object? prsAchieved = null,
  }) {
    return _then(_$WorkoutSummaryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      templateName: freezed == templateName
          ? _value.templateName
          : templateName // ignore: cast_nullable_to_non_nullable
              as String?,
      exerciseCount: null == exerciseCount
          ? _value.exerciseCount
          : exerciseCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalSets: null == totalSets
          ? _value.totalSets
          : totalSets // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume: null == totalVolume
          ? _value.totalVolume
          : totalVolume // ignore: cast_nullable_to_non_nullable
              as int,
      muscleGroups: null == muscleGroups
          ? _value._muscleGroups
          : muscleGroups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      prsAchieved: null == prsAchieved
          ? _value.prsAchieved
          : prsAchieved // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutSummaryImpl implements _WorkoutSummary {
  const _$WorkoutSummaryImpl(
      {required this.id,
      required this.date,
      this.completedAt,
      this.durationMinutes,
      this.templateName,
      required this.exerciseCount,
      required this.totalSets,
      required this.totalVolume,
      final List<String> muscleGroups = const [],
      this.prsAchieved = 0})
      : _muscleGroups = muscleGroups;

  factory _$WorkoutSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutSummaryImplFromJson(json);

  /// Session ID
  @override
  final String id;

  /// When workout started
  @override
  final DateTime date;

  /// When workout completed (null if abandoned)
  @override
  final DateTime? completedAt;

  /// Duration in minutes
  @override
  final int? durationMinutes;

  /// Template name if started from template
  @override
  final String? templateName;

  /// Number of exercises performed
  @override
  final int exerciseCount;

  /// Total working sets
  @override
  final int totalSets;

  /// Total volume (weight × reps)
  @override
  final int totalVolume;

  /// Muscle groups trained
  final List<String> _muscleGroups;

  /// Muscle groups trained
  @override
  @JsonKey()
  List<String> get muscleGroups {
    if (_muscleGroups is EqualUnmodifiableListView) return _muscleGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_muscleGroups);
  }

  /// Number of PRs achieved
  @override
  @JsonKey()
  final int prsAchieved;

  @override
  String toString() {
    return 'WorkoutSummary(id: $id, date: $date, completedAt: $completedAt, durationMinutes: $durationMinutes, templateName: $templateName, exerciseCount: $exerciseCount, totalSets: $totalSets, totalVolume: $totalVolume, muscleGroups: $muscleGroups, prsAchieved: $prsAchieved)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.templateName, templateName) ||
                other.templateName == templateName) &&
            (identical(other.exerciseCount, exerciseCount) ||
                other.exerciseCount == exerciseCount) &&
            (identical(other.totalSets, totalSets) ||
                other.totalSets == totalSets) &&
            (identical(other.totalVolume, totalVolume) ||
                other.totalVolume == totalVolume) &&
            const DeepCollectionEquality()
                .equals(other._muscleGroups, _muscleGroups) &&
            (identical(other.prsAchieved, prsAchieved) ||
                other.prsAchieved == prsAchieved));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      date,
      completedAt,
      durationMinutes,
      templateName,
      exerciseCount,
      totalSets,
      totalVolume,
      const DeepCollectionEquality().hash(_muscleGroups),
      prsAchieved);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutSummaryImplCopyWith<_$WorkoutSummaryImpl> get copyWith =>
      __$$WorkoutSummaryImplCopyWithImpl<_$WorkoutSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutSummaryImplToJson(
      this,
    );
  }
}

abstract class _WorkoutSummary implements WorkoutSummary {
  const factory _WorkoutSummary(
      {required final String id,
      required final DateTime date,
      final DateTime? completedAt,
      final int? durationMinutes,
      final String? templateName,
      required final int exerciseCount,
      required final int totalSets,
      required final int totalVolume,
      final List<String> muscleGroups,
      final int prsAchieved}) = _$WorkoutSummaryImpl;

  factory _WorkoutSummary.fromJson(Map<String, dynamic> json) =
      _$WorkoutSummaryImpl.fromJson;

  @override

  /// Session ID
  String get id;
  @override

  /// When workout started
  DateTime get date;
  @override

  /// When workout completed (null if abandoned)
  DateTime? get completedAt;
  @override

  /// Duration in minutes
  int? get durationMinutes;
  @override

  /// Template name if started from template
  String? get templateName;
  @override

  /// Number of exercises performed
  int get exerciseCount;
  @override

  /// Total working sets
  int get totalSets;
  @override

  /// Total volume (weight × reps)
  int get totalVolume;
  @override

  /// Muscle groups trained
  List<String> get muscleGroups;
  @override

  /// Number of PRs achieved
  int get prsAchieved;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutSummaryImplCopyWith<_$WorkoutSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
