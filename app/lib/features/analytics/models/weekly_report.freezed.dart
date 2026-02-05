// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekly_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WeeklyReport _$WeeklyReportFromJson(Map<String, dynamic> json) {
  return _WeeklyReport.fromJson(json);
}

/// @nodoc
mixin _$WeeklyReport {
  /// Unique report ID
  String get id => throw _privateConstructorUsedError;

  /// User ID this report belongs to
  String get userId => throw _privateConstructorUsedError;

  /// Start date of the week (Monday)
  DateTime get weekStart => throw _privateConstructorUsedError;

  /// End date of the week (Sunday)
  DateTime get weekEnd => throw _privateConstructorUsedError;

  /// When the report was generated
  DateTime get generatedAt => throw _privateConstructorUsedError;

  /// Overall summary metrics
  WeeklySummary get summary => throw _privateConstructorUsedError;

  /// Workout details for the week
  List<WeeklyWorkout> get workouts => throw _privateConstructorUsedError;

  /// Personal records achieved this week
  List<WeeklyPR> get personalRecords => throw _privateConstructorUsedError;

  /// Muscle group distribution
  List<MuscleGroupStats> get muscleDistribution =>
      throw _privateConstructorUsedError;

  /// Volume comparison with previous week
  WeeklyComparison get volumeComparison => throw _privateConstructorUsedError;

  /// Frequency comparison with previous week
  WeeklyComparison get frequencyComparison =>
      throw _privateConstructorUsedError;

  /// AI-generated insights and recommendations
  List<WeeklyInsight> get insights => throw _privateConstructorUsedError;

  /// Goals progress for the week
  List<GoalProgress> get goalsProgress => throw _privateConstructorUsedError;

  /// Achievements unlocked this week
  List<String> get achievementsUnlocked => throw _privateConstructorUsedError;

  /// Week number in the year (1-52)
  int get weekNumber => throw _privateConstructorUsedError;

  /// Whether this was a deload week
  bool get isDeloadWeek => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WeeklyReportCopyWith<WeeklyReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyReportCopyWith<$Res> {
  factory $WeeklyReportCopyWith(
          WeeklyReport value, $Res Function(WeeklyReport) then) =
      _$WeeklyReportCopyWithImpl<$Res, WeeklyReport>;
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime weekStart,
      DateTime weekEnd,
      DateTime generatedAt,
      WeeklySummary summary,
      List<WeeklyWorkout> workouts,
      List<WeeklyPR> personalRecords,
      List<MuscleGroupStats> muscleDistribution,
      WeeklyComparison volumeComparison,
      WeeklyComparison frequencyComparison,
      List<WeeklyInsight> insights,
      List<GoalProgress> goalsProgress,
      List<String> achievementsUnlocked,
      int weekNumber,
      bool isDeloadWeek});

  $WeeklySummaryCopyWith<$Res> get summary;
  $WeeklyComparisonCopyWith<$Res> get volumeComparison;
  $WeeklyComparisonCopyWith<$Res> get frequencyComparison;
}

/// @nodoc
class _$WeeklyReportCopyWithImpl<$Res, $Val extends WeeklyReport>
    implements $WeeklyReportCopyWith<$Res> {
  _$WeeklyReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? weekStart = null,
    Object? weekEnd = null,
    Object? generatedAt = null,
    Object? summary = null,
    Object? workouts = null,
    Object? personalRecords = null,
    Object? muscleDistribution = null,
    Object? volumeComparison = null,
    Object? frequencyComparison = null,
    Object? insights = null,
    Object? goalsProgress = null,
    Object? achievementsUnlocked = null,
    Object? weekNumber = null,
    Object? isDeloadWeek = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      weekStart: null == weekStart
          ? _value.weekStart
          : weekStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weekEnd: null == weekEnd
          ? _value.weekEnd
          : weekEnd // ignore: cast_nullable_to_non_nullable
              as DateTime,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as WeeklySummary,
      workouts: null == workouts
          ? _value.workouts
          : workouts // ignore: cast_nullable_to_non_nullable
              as List<WeeklyWorkout>,
      personalRecords: null == personalRecords
          ? _value.personalRecords
          : personalRecords // ignore: cast_nullable_to_non_nullable
              as List<WeeklyPR>,
      muscleDistribution: null == muscleDistribution
          ? _value.muscleDistribution
          : muscleDistribution // ignore: cast_nullable_to_non_nullable
              as List<MuscleGroupStats>,
      volumeComparison: null == volumeComparison
          ? _value.volumeComparison
          : volumeComparison // ignore: cast_nullable_to_non_nullable
              as WeeklyComparison,
      frequencyComparison: null == frequencyComparison
          ? _value.frequencyComparison
          : frequencyComparison // ignore: cast_nullable_to_non_nullable
              as WeeklyComparison,
      insights: null == insights
          ? _value.insights
          : insights // ignore: cast_nullable_to_non_nullable
              as List<WeeklyInsight>,
      goalsProgress: null == goalsProgress
          ? _value.goalsProgress
          : goalsProgress // ignore: cast_nullable_to_non_nullable
              as List<GoalProgress>,
      achievementsUnlocked: null == achievementsUnlocked
          ? _value.achievementsUnlocked
          : achievementsUnlocked // ignore: cast_nullable_to_non_nullable
              as List<String>,
      weekNumber: null == weekNumber
          ? _value.weekNumber
          : weekNumber // ignore: cast_nullable_to_non_nullable
              as int,
      isDeloadWeek: null == isDeloadWeek
          ? _value.isDeloadWeek
          : isDeloadWeek // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WeeklySummaryCopyWith<$Res> get summary {
    return $WeeklySummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $WeeklyComparisonCopyWith<$Res> get volumeComparison {
    return $WeeklyComparisonCopyWith<$Res>(_value.volumeComparison, (value) {
      return _then(_value.copyWith(volumeComparison: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $WeeklyComparisonCopyWith<$Res> get frequencyComparison {
    return $WeeklyComparisonCopyWith<$Res>(_value.frequencyComparison, (value) {
      return _then(_value.copyWith(frequencyComparison: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WeeklyReportImplCopyWith<$Res>
    implements $WeeklyReportCopyWith<$Res> {
  factory _$$WeeklyReportImplCopyWith(
          _$WeeklyReportImpl value, $Res Function(_$WeeklyReportImpl) then) =
      __$$WeeklyReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime weekStart,
      DateTime weekEnd,
      DateTime generatedAt,
      WeeklySummary summary,
      List<WeeklyWorkout> workouts,
      List<WeeklyPR> personalRecords,
      List<MuscleGroupStats> muscleDistribution,
      WeeklyComparison volumeComparison,
      WeeklyComparison frequencyComparison,
      List<WeeklyInsight> insights,
      List<GoalProgress> goalsProgress,
      List<String> achievementsUnlocked,
      int weekNumber,
      bool isDeloadWeek});

  @override
  $WeeklySummaryCopyWith<$Res> get summary;
  @override
  $WeeklyComparisonCopyWith<$Res> get volumeComparison;
  @override
  $WeeklyComparisonCopyWith<$Res> get frequencyComparison;
}

/// @nodoc
class __$$WeeklyReportImplCopyWithImpl<$Res>
    extends _$WeeklyReportCopyWithImpl<$Res, _$WeeklyReportImpl>
    implements _$$WeeklyReportImplCopyWith<$Res> {
  __$$WeeklyReportImplCopyWithImpl(
      _$WeeklyReportImpl _value, $Res Function(_$WeeklyReportImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? weekStart = null,
    Object? weekEnd = null,
    Object? generatedAt = null,
    Object? summary = null,
    Object? workouts = null,
    Object? personalRecords = null,
    Object? muscleDistribution = null,
    Object? volumeComparison = null,
    Object? frequencyComparison = null,
    Object? insights = null,
    Object? goalsProgress = null,
    Object? achievementsUnlocked = null,
    Object? weekNumber = null,
    Object? isDeloadWeek = null,
  }) {
    return _then(_$WeeklyReportImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      weekStart: null == weekStart
          ? _value.weekStart
          : weekStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weekEnd: null == weekEnd
          ? _value.weekEnd
          : weekEnd // ignore: cast_nullable_to_non_nullable
              as DateTime,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as WeeklySummary,
      workouts: null == workouts
          ? _value._workouts
          : workouts // ignore: cast_nullable_to_non_nullable
              as List<WeeklyWorkout>,
      personalRecords: null == personalRecords
          ? _value._personalRecords
          : personalRecords // ignore: cast_nullable_to_non_nullable
              as List<WeeklyPR>,
      muscleDistribution: null == muscleDistribution
          ? _value._muscleDistribution
          : muscleDistribution // ignore: cast_nullable_to_non_nullable
              as List<MuscleGroupStats>,
      volumeComparison: null == volumeComparison
          ? _value.volumeComparison
          : volumeComparison // ignore: cast_nullable_to_non_nullable
              as WeeklyComparison,
      frequencyComparison: null == frequencyComparison
          ? _value.frequencyComparison
          : frequencyComparison // ignore: cast_nullable_to_non_nullable
              as WeeklyComparison,
      insights: null == insights
          ? _value._insights
          : insights // ignore: cast_nullable_to_non_nullable
              as List<WeeklyInsight>,
      goalsProgress: null == goalsProgress
          ? _value._goalsProgress
          : goalsProgress // ignore: cast_nullable_to_non_nullable
              as List<GoalProgress>,
      achievementsUnlocked: null == achievementsUnlocked
          ? _value._achievementsUnlocked
          : achievementsUnlocked // ignore: cast_nullable_to_non_nullable
              as List<String>,
      weekNumber: null == weekNumber
          ? _value.weekNumber
          : weekNumber // ignore: cast_nullable_to_non_nullable
              as int,
      isDeloadWeek: null == isDeloadWeek
          ? _value.isDeloadWeek
          : isDeloadWeek // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyReportImpl implements _WeeklyReport {
  const _$WeeklyReportImpl(
      {required this.id,
      required this.userId,
      required this.weekStart,
      required this.weekEnd,
      required this.generatedAt,
      required this.summary,
      required final List<WeeklyWorkout> workouts,
      required final List<WeeklyPR> personalRecords,
      required final List<MuscleGroupStats> muscleDistribution,
      required this.volumeComparison,
      required this.frequencyComparison,
      required final List<WeeklyInsight> insights,
      final List<GoalProgress> goalsProgress = const [],
      final List<String> achievementsUnlocked = const [],
      required this.weekNumber,
      this.isDeloadWeek = false})
      : _workouts = workouts,
        _personalRecords = personalRecords,
        _muscleDistribution = muscleDistribution,
        _insights = insights,
        _goalsProgress = goalsProgress,
        _achievementsUnlocked = achievementsUnlocked;

  factory _$WeeklyReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyReportImplFromJson(json);

  /// Unique report ID
  @override
  final String id;

  /// User ID this report belongs to
  @override
  final String userId;

  /// Start date of the week (Monday)
  @override
  final DateTime weekStart;

  /// End date of the week (Sunday)
  @override
  final DateTime weekEnd;

  /// When the report was generated
  @override
  final DateTime generatedAt;

  /// Overall summary metrics
  @override
  final WeeklySummary summary;

  /// Workout details for the week
  final List<WeeklyWorkout> _workouts;

  /// Workout details for the week
  @override
  List<WeeklyWorkout> get workouts {
    if (_workouts is EqualUnmodifiableListView) return _workouts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workouts);
  }

  /// Personal records achieved this week
  final List<WeeklyPR> _personalRecords;

  /// Personal records achieved this week
  @override
  List<WeeklyPR> get personalRecords {
    if (_personalRecords is EqualUnmodifiableListView) return _personalRecords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_personalRecords);
  }

  /// Muscle group distribution
  final List<MuscleGroupStats> _muscleDistribution;

  /// Muscle group distribution
  @override
  List<MuscleGroupStats> get muscleDistribution {
    if (_muscleDistribution is EqualUnmodifiableListView)
      return _muscleDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_muscleDistribution);
  }

  /// Volume comparison with previous week
  @override
  final WeeklyComparison volumeComparison;

  /// Frequency comparison with previous week
  @override
  final WeeklyComparison frequencyComparison;

  /// AI-generated insights and recommendations
  final List<WeeklyInsight> _insights;

  /// AI-generated insights and recommendations
  @override
  List<WeeklyInsight> get insights {
    if (_insights is EqualUnmodifiableListView) return _insights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_insights);
  }

  /// Goals progress for the week
  final List<GoalProgress> _goalsProgress;

  /// Goals progress for the week
  @override
  @JsonKey()
  List<GoalProgress> get goalsProgress {
    if (_goalsProgress is EqualUnmodifiableListView) return _goalsProgress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_goalsProgress);
  }

  /// Achievements unlocked this week
  final List<String> _achievementsUnlocked;

  /// Achievements unlocked this week
  @override
  @JsonKey()
  List<String> get achievementsUnlocked {
    if (_achievementsUnlocked is EqualUnmodifiableListView)
      return _achievementsUnlocked;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_achievementsUnlocked);
  }

  /// Week number in the year (1-52)
  @override
  final int weekNumber;

  /// Whether this was a deload week
  @override
  @JsonKey()
  final bool isDeloadWeek;

  @override
  String toString() {
    return 'WeeklyReport(id: $id, userId: $userId, weekStart: $weekStart, weekEnd: $weekEnd, generatedAt: $generatedAt, summary: $summary, workouts: $workouts, personalRecords: $personalRecords, muscleDistribution: $muscleDistribution, volumeComparison: $volumeComparison, frequencyComparison: $frequencyComparison, insights: $insights, goalsProgress: $goalsProgress, achievementsUnlocked: $achievementsUnlocked, weekNumber: $weekNumber, isDeloadWeek: $isDeloadWeek)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyReportImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            (identical(other.weekEnd, weekEnd) || other.weekEnd == weekEnd) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(other._workouts, _workouts) &&
            const DeepCollectionEquality()
                .equals(other._personalRecords, _personalRecords) &&
            const DeepCollectionEquality()
                .equals(other._muscleDistribution, _muscleDistribution) &&
            (identical(other.volumeComparison, volumeComparison) ||
                other.volumeComparison == volumeComparison) &&
            (identical(other.frequencyComparison, frequencyComparison) ||
                other.frequencyComparison == frequencyComparison) &&
            const DeepCollectionEquality().equals(other._insights, _insights) &&
            const DeepCollectionEquality()
                .equals(other._goalsProgress, _goalsProgress) &&
            const DeepCollectionEquality()
                .equals(other._achievementsUnlocked, _achievementsUnlocked) &&
            (identical(other.weekNumber, weekNumber) ||
                other.weekNumber == weekNumber) &&
            (identical(other.isDeloadWeek, isDeloadWeek) ||
                other.isDeloadWeek == isDeloadWeek));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      weekStart,
      weekEnd,
      generatedAt,
      summary,
      const DeepCollectionEquality().hash(_workouts),
      const DeepCollectionEquality().hash(_personalRecords),
      const DeepCollectionEquality().hash(_muscleDistribution),
      volumeComparison,
      frequencyComparison,
      const DeepCollectionEquality().hash(_insights),
      const DeepCollectionEquality().hash(_goalsProgress),
      const DeepCollectionEquality().hash(_achievementsUnlocked),
      weekNumber,
      isDeloadWeek);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyReportImplCopyWith<_$WeeklyReportImpl> get copyWith =>
      __$$WeeklyReportImplCopyWithImpl<_$WeeklyReportImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyReportImplToJson(
      this,
    );
  }
}

abstract class _WeeklyReport implements WeeklyReport {
  const factory _WeeklyReport(
      {required final String id,
      required final String userId,
      required final DateTime weekStart,
      required final DateTime weekEnd,
      required final DateTime generatedAt,
      required final WeeklySummary summary,
      required final List<WeeklyWorkout> workouts,
      required final List<WeeklyPR> personalRecords,
      required final List<MuscleGroupStats> muscleDistribution,
      required final WeeklyComparison volumeComparison,
      required final WeeklyComparison frequencyComparison,
      required final List<WeeklyInsight> insights,
      final List<GoalProgress> goalsProgress,
      final List<String> achievementsUnlocked,
      required final int weekNumber,
      final bool isDeloadWeek}) = _$WeeklyReportImpl;

  factory _WeeklyReport.fromJson(Map<String, dynamic> json) =
      _$WeeklyReportImpl.fromJson;

  @override

  /// Unique report ID
  String get id;
  @override

  /// User ID this report belongs to
  String get userId;
  @override

  /// Start date of the week (Monday)
  DateTime get weekStart;
  @override

  /// End date of the week (Sunday)
  DateTime get weekEnd;
  @override

  /// When the report was generated
  DateTime get generatedAt;
  @override

  /// Overall summary metrics
  WeeklySummary get summary;
  @override

  /// Workout details for the week
  List<WeeklyWorkout> get workouts;
  @override

  /// Personal records achieved this week
  List<WeeklyPR> get personalRecords;
  @override

  /// Muscle group distribution
  List<MuscleGroupStats> get muscleDistribution;
  @override

  /// Volume comparison with previous week
  WeeklyComparison get volumeComparison;
  @override

  /// Frequency comparison with previous week
  WeeklyComparison get frequencyComparison;
  @override

  /// AI-generated insights and recommendations
  List<WeeklyInsight> get insights;
  @override

  /// Goals progress for the week
  List<GoalProgress> get goalsProgress;
  @override

  /// Achievements unlocked this week
  List<String> get achievementsUnlocked;
  @override

  /// Week number in the year (1-52)
  int get weekNumber;
  @override

  /// Whether this was a deload week
  bool get isDeloadWeek;
  @override
  @JsonKey(ignore: true)
  _$$WeeklyReportImplCopyWith<_$WeeklyReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeeklySummary _$WeeklySummaryFromJson(Map<String, dynamic> json) {
  return _WeeklySummary.fromJson(json);
}

/// @nodoc
mixin _$WeeklySummary {
  /// Total number of workouts completed
  int get workoutCount => throw _privateConstructorUsedError;

  /// Total training duration in minutes
  int get totalDurationMinutes => throw _privateConstructorUsedError;

  /// Total volume lifted (kg)
  int get totalVolume => throw _privateConstructorUsedError;

  /// Total number of sets completed
  int get totalSets => throw _privateConstructorUsedError;

  /// Total number of reps completed
  int get totalReps => throw _privateConstructorUsedError;

  /// Number of PRs achieved
  int get prsAchieved => throw _privateConstructorUsedError;

  /// Average workout duration in minutes
  int get averageWorkoutDuration => throw _privateConstructorUsedError;

  /// Most trained muscle group
  String? get mostTrainedMuscle => throw _privateConstructorUsedError;

  /// Best lift of the week
  String? get bestLift => throw _privateConstructorUsedError;

  /// Consistency score (0-100)
  int get consistencyScore => throw _privateConstructorUsedError;

  /// Intensity score based on RPE (0-100)
  int get intensityScore => throw _privateConstructorUsedError;

  /// Rest days taken
  int get restDays => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WeeklySummaryCopyWith<WeeklySummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklySummaryCopyWith<$Res> {
  factory $WeeklySummaryCopyWith(
          WeeklySummary value, $Res Function(WeeklySummary) then) =
      _$WeeklySummaryCopyWithImpl<$Res, WeeklySummary>;
  @useResult
  $Res call(
      {int workoutCount,
      int totalDurationMinutes,
      int totalVolume,
      int totalSets,
      int totalReps,
      int prsAchieved,
      int averageWorkoutDuration,
      String? mostTrainedMuscle,
      String? bestLift,
      int consistencyScore,
      int intensityScore,
      int restDays});
}

/// @nodoc
class _$WeeklySummaryCopyWithImpl<$Res, $Val extends WeeklySummary>
    implements $WeeklySummaryCopyWith<$Res> {
  _$WeeklySummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workoutCount = null,
    Object? totalDurationMinutes = null,
    Object? totalVolume = null,
    Object? totalSets = null,
    Object? totalReps = null,
    Object? prsAchieved = null,
    Object? averageWorkoutDuration = null,
    Object? mostTrainedMuscle = freezed,
    Object? bestLift = freezed,
    Object? consistencyScore = null,
    Object? intensityScore = null,
    Object? restDays = null,
  }) {
    return _then(_value.copyWith(
      workoutCount: null == workoutCount
          ? _value.workoutCount
          : workoutCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalDurationMinutes: null == totalDurationMinutes
          ? _value.totalDurationMinutes
          : totalDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume: null == totalVolume
          ? _value.totalVolume
          : totalVolume // ignore: cast_nullable_to_non_nullable
              as int,
      totalSets: null == totalSets
          ? _value.totalSets
          : totalSets // ignore: cast_nullable_to_non_nullable
              as int,
      totalReps: null == totalReps
          ? _value.totalReps
          : totalReps // ignore: cast_nullable_to_non_nullable
              as int,
      prsAchieved: null == prsAchieved
          ? _value.prsAchieved
          : prsAchieved // ignore: cast_nullable_to_non_nullable
              as int,
      averageWorkoutDuration: null == averageWorkoutDuration
          ? _value.averageWorkoutDuration
          : averageWorkoutDuration // ignore: cast_nullable_to_non_nullable
              as int,
      mostTrainedMuscle: freezed == mostTrainedMuscle
          ? _value.mostTrainedMuscle
          : mostTrainedMuscle // ignore: cast_nullable_to_non_nullable
              as String?,
      bestLift: freezed == bestLift
          ? _value.bestLift
          : bestLift // ignore: cast_nullable_to_non_nullable
              as String?,
      consistencyScore: null == consistencyScore
          ? _value.consistencyScore
          : consistencyScore // ignore: cast_nullable_to_non_nullable
              as int,
      intensityScore: null == intensityScore
          ? _value.intensityScore
          : intensityScore // ignore: cast_nullable_to_non_nullable
              as int,
      restDays: null == restDays
          ? _value.restDays
          : restDays // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeeklySummaryImplCopyWith<$Res>
    implements $WeeklySummaryCopyWith<$Res> {
  factory _$$WeeklySummaryImplCopyWith(
          _$WeeklySummaryImpl value, $Res Function(_$WeeklySummaryImpl) then) =
      __$$WeeklySummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int workoutCount,
      int totalDurationMinutes,
      int totalVolume,
      int totalSets,
      int totalReps,
      int prsAchieved,
      int averageWorkoutDuration,
      String? mostTrainedMuscle,
      String? bestLift,
      int consistencyScore,
      int intensityScore,
      int restDays});
}

/// @nodoc
class __$$WeeklySummaryImplCopyWithImpl<$Res>
    extends _$WeeklySummaryCopyWithImpl<$Res, _$WeeklySummaryImpl>
    implements _$$WeeklySummaryImplCopyWith<$Res> {
  __$$WeeklySummaryImplCopyWithImpl(
      _$WeeklySummaryImpl _value, $Res Function(_$WeeklySummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workoutCount = null,
    Object? totalDurationMinutes = null,
    Object? totalVolume = null,
    Object? totalSets = null,
    Object? totalReps = null,
    Object? prsAchieved = null,
    Object? averageWorkoutDuration = null,
    Object? mostTrainedMuscle = freezed,
    Object? bestLift = freezed,
    Object? consistencyScore = null,
    Object? intensityScore = null,
    Object? restDays = null,
  }) {
    return _then(_$WeeklySummaryImpl(
      workoutCount: null == workoutCount
          ? _value.workoutCount
          : workoutCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalDurationMinutes: null == totalDurationMinutes
          ? _value.totalDurationMinutes
          : totalDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume: null == totalVolume
          ? _value.totalVolume
          : totalVolume // ignore: cast_nullable_to_non_nullable
              as int,
      totalSets: null == totalSets
          ? _value.totalSets
          : totalSets // ignore: cast_nullable_to_non_nullable
              as int,
      totalReps: null == totalReps
          ? _value.totalReps
          : totalReps // ignore: cast_nullable_to_non_nullable
              as int,
      prsAchieved: null == prsAchieved
          ? _value.prsAchieved
          : prsAchieved // ignore: cast_nullable_to_non_nullable
              as int,
      averageWorkoutDuration: null == averageWorkoutDuration
          ? _value.averageWorkoutDuration
          : averageWorkoutDuration // ignore: cast_nullable_to_non_nullable
              as int,
      mostTrainedMuscle: freezed == mostTrainedMuscle
          ? _value.mostTrainedMuscle
          : mostTrainedMuscle // ignore: cast_nullable_to_non_nullable
              as String?,
      bestLift: freezed == bestLift
          ? _value.bestLift
          : bestLift // ignore: cast_nullable_to_non_nullable
              as String?,
      consistencyScore: null == consistencyScore
          ? _value.consistencyScore
          : consistencyScore // ignore: cast_nullable_to_non_nullable
              as int,
      intensityScore: null == intensityScore
          ? _value.intensityScore
          : intensityScore // ignore: cast_nullable_to_non_nullable
              as int,
      restDays: null == restDays
          ? _value.restDays
          : restDays // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklySummaryImpl implements _WeeklySummary {
  const _$WeeklySummaryImpl(
      {required this.workoutCount,
      required this.totalDurationMinutes,
      required this.totalVolume,
      required this.totalSets,
      required this.totalReps,
      required this.prsAchieved,
      required this.averageWorkoutDuration,
      this.mostTrainedMuscle,
      this.bestLift,
      required this.consistencyScore,
      this.intensityScore = 0,
      required this.restDays});

  factory _$WeeklySummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklySummaryImplFromJson(json);

  /// Total number of workouts completed
  @override
  final int workoutCount;

  /// Total training duration in minutes
  @override
  final int totalDurationMinutes;

  /// Total volume lifted (kg)
  @override
  final int totalVolume;

  /// Total number of sets completed
  @override
  final int totalSets;

  /// Total number of reps completed
  @override
  final int totalReps;

  /// Number of PRs achieved
  @override
  final int prsAchieved;

  /// Average workout duration in minutes
  @override
  final int averageWorkoutDuration;

  /// Most trained muscle group
  @override
  final String? mostTrainedMuscle;

  /// Best lift of the week
  @override
  final String? bestLift;

  /// Consistency score (0-100)
  @override
  final int consistencyScore;

  /// Intensity score based on RPE (0-100)
  @override
  @JsonKey()
  final int intensityScore;

  /// Rest days taken
  @override
  final int restDays;

  @override
  String toString() {
    return 'WeeklySummary(workoutCount: $workoutCount, totalDurationMinutes: $totalDurationMinutes, totalVolume: $totalVolume, totalSets: $totalSets, totalReps: $totalReps, prsAchieved: $prsAchieved, averageWorkoutDuration: $averageWorkoutDuration, mostTrainedMuscle: $mostTrainedMuscle, bestLift: $bestLift, consistencyScore: $consistencyScore, intensityScore: $intensityScore, restDays: $restDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklySummaryImpl &&
            (identical(other.workoutCount, workoutCount) ||
                other.workoutCount == workoutCount) &&
            (identical(other.totalDurationMinutes, totalDurationMinutes) ||
                other.totalDurationMinutes == totalDurationMinutes) &&
            (identical(other.totalVolume, totalVolume) ||
                other.totalVolume == totalVolume) &&
            (identical(other.totalSets, totalSets) ||
                other.totalSets == totalSets) &&
            (identical(other.totalReps, totalReps) ||
                other.totalReps == totalReps) &&
            (identical(other.prsAchieved, prsAchieved) ||
                other.prsAchieved == prsAchieved) &&
            (identical(other.averageWorkoutDuration, averageWorkoutDuration) ||
                other.averageWorkoutDuration == averageWorkoutDuration) &&
            (identical(other.mostTrainedMuscle, mostTrainedMuscle) ||
                other.mostTrainedMuscle == mostTrainedMuscle) &&
            (identical(other.bestLift, bestLift) ||
                other.bestLift == bestLift) &&
            (identical(other.consistencyScore, consistencyScore) ||
                other.consistencyScore == consistencyScore) &&
            (identical(other.intensityScore, intensityScore) ||
                other.intensityScore == intensityScore) &&
            (identical(other.restDays, restDays) ||
                other.restDays == restDays));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      workoutCount,
      totalDurationMinutes,
      totalVolume,
      totalSets,
      totalReps,
      prsAchieved,
      averageWorkoutDuration,
      mostTrainedMuscle,
      bestLift,
      consistencyScore,
      intensityScore,
      restDays);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklySummaryImplCopyWith<_$WeeklySummaryImpl> get copyWith =>
      __$$WeeklySummaryImplCopyWithImpl<_$WeeklySummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklySummaryImplToJson(
      this,
    );
  }
}

abstract class _WeeklySummary implements WeeklySummary {
  const factory _WeeklySummary(
      {required final int workoutCount,
      required final int totalDurationMinutes,
      required final int totalVolume,
      required final int totalSets,
      required final int totalReps,
      required final int prsAchieved,
      required final int averageWorkoutDuration,
      final String? mostTrainedMuscle,
      final String? bestLift,
      required final int consistencyScore,
      final int intensityScore,
      required final int restDays}) = _$WeeklySummaryImpl;

  factory _WeeklySummary.fromJson(Map<String, dynamic> json) =
      _$WeeklySummaryImpl.fromJson;

  @override

  /// Total number of workouts completed
  int get workoutCount;
  @override

  /// Total training duration in minutes
  int get totalDurationMinutes;
  @override

  /// Total volume lifted (kg)
  int get totalVolume;
  @override

  /// Total number of sets completed
  int get totalSets;
  @override

  /// Total number of reps completed
  int get totalReps;
  @override

  /// Number of PRs achieved
  int get prsAchieved;
  @override

  /// Average workout duration in minutes
  int get averageWorkoutDuration;
  @override

  /// Most trained muscle group
  String? get mostTrainedMuscle;
  @override

  /// Best lift of the week
  String? get bestLift;
  @override

  /// Consistency score (0-100)
  int get consistencyScore;
  @override

  /// Intensity score based on RPE (0-100)
  int get intensityScore;
  @override

  /// Rest days taken
  int get restDays;
  @override
  @JsonKey(ignore: true)
  _$$WeeklySummaryImplCopyWith<_$WeeklySummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeeklyWorkout _$WeeklyWorkoutFromJson(Map<String, dynamic> json) {
  return _WeeklyWorkout.fromJson(json);
}

/// @nodoc
mixin _$WeeklyWorkout {
  /// Workout session ID
  String get id => throw _privateConstructorUsedError;

  /// Date of the workout
  DateTime get date => throw _privateConstructorUsedError;

  /// Template name if used
  String? get templateName => throw _privateConstructorUsedError;

  /// Duration in minutes
  int get durationMinutes => throw _privateConstructorUsedError;

  /// Number of exercises
  int get exerciseCount => throw _privateConstructorUsedError;

  /// Number of sets completed
  int get setsCompleted => throw _privateConstructorUsedError;

  /// Total volume (kg)
  int get volume => throw _privateConstructorUsedError;

  /// Muscle groups trained
  List<String> get muscleGroups => throw _privateConstructorUsedError;

  /// Whether any PRs were achieved
  bool get hadPR => throw _privateConstructorUsedError;

  /// Average RPE for the session
  double? get averageRpe => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WeeklyWorkoutCopyWith<WeeklyWorkout> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyWorkoutCopyWith<$Res> {
  factory $WeeklyWorkoutCopyWith(
          WeeklyWorkout value, $Res Function(WeeklyWorkout) then) =
      _$WeeklyWorkoutCopyWithImpl<$Res, WeeklyWorkout>;
  @useResult
  $Res call(
      {String id,
      DateTime date,
      String? templateName,
      int durationMinutes,
      int exerciseCount,
      int setsCompleted,
      int volume,
      List<String> muscleGroups,
      bool hadPR,
      double? averageRpe});
}

/// @nodoc
class _$WeeklyWorkoutCopyWithImpl<$Res, $Val extends WeeklyWorkout>
    implements $WeeklyWorkoutCopyWith<$Res> {
  _$WeeklyWorkoutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? templateName = freezed,
    Object? durationMinutes = null,
    Object? exerciseCount = null,
    Object? setsCompleted = null,
    Object? volume = null,
    Object? muscleGroups = null,
    Object? hadPR = null,
    Object? averageRpe = freezed,
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
      templateName: freezed == templateName
          ? _value.templateName
          : templateName // ignore: cast_nullable_to_non_nullable
              as String?,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseCount: null == exerciseCount
          ? _value.exerciseCount
          : exerciseCount // ignore: cast_nullable_to_non_nullable
              as int,
      setsCompleted: null == setsCompleted
          ? _value.setsCompleted
          : setsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as int,
      muscleGroups: null == muscleGroups
          ? _value.muscleGroups
          : muscleGroups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hadPR: null == hadPR
          ? _value.hadPR
          : hadPR // ignore: cast_nullable_to_non_nullable
              as bool,
      averageRpe: freezed == averageRpe
          ? _value.averageRpe
          : averageRpe // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeeklyWorkoutImplCopyWith<$Res>
    implements $WeeklyWorkoutCopyWith<$Res> {
  factory _$$WeeklyWorkoutImplCopyWith(
          _$WeeklyWorkoutImpl value, $Res Function(_$WeeklyWorkoutImpl) then) =
      __$$WeeklyWorkoutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime date,
      String? templateName,
      int durationMinutes,
      int exerciseCount,
      int setsCompleted,
      int volume,
      List<String> muscleGroups,
      bool hadPR,
      double? averageRpe});
}

/// @nodoc
class __$$WeeklyWorkoutImplCopyWithImpl<$Res>
    extends _$WeeklyWorkoutCopyWithImpl<$Res, _$WeeklyWorkoutImpl>
    implements _$$WeeklyWorkoutImplCopyWith<$Res> {
  __$$WeeklyWorkoutImplCopyWithImpl(
      _$WeeklyWorkoutImpl _value, $Res Function(_$WeeklyWorkoutImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? templateName = freezed,
    Object? durationMinutes = null,
    Object? exerciseCount = null,
    Object? setsCompleted = null,
    Object? volume = null,
    Object? muscleGroups = null,
    Object? hadPR = null,
    Object? averageRpe = freezed,
  }) {
    return _then(_$WeeklyWorkoutImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      templateName: freezed == templateName
          ? _value.templateName
          : templateName // ignore: cast_nullable_to_non_nullable
              as String?,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseCount: null == exerciseCount
          ? _value.exerciseCount
          : exerciseCount // ignore: cast_nullable_to_non_nullable
              as int,
      setsCompleted: null == setsCompleted
          ? _value.setsCompleted
          : setsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      volume: null == volume
          ? _value.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as int,
      muscleGroups: null == muscleGroups
          ? _value._muscleGroups
          : muscleGroups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hadPR: null == hadPR
          ? _value.hadPR
          : hadPR // ignore: cast_nullable_to_non_nullable
              as bool,
      averageRpe: freezed == averageRpe
          ? _value.averageRpe
          : averageRpe // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyWorkoutImpl implements _WeeklyWorkout {
  const _$WeeklyWorkoutImpl(
      {required this.id,
      required this.date,
      this.templateName,
      required this.durationMinutes,
      required this.exerciseCount,
      required this.setsCompleted,
      required this.volume,
      required final List<String> muscleGroups,
      this.hadPR = false,
      this.averageRpe})
      : _muscleGroups = muscleGroups;

  factory _$WeeklyWorkoutImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyWorkoutImplFromJson(json);

  /// Workout session ID
  @override
  final String id;

  /// Date of the workout
  @override
  final DateTime date;

  /// Template name if used
  @override
  final String? templateName;

  /// Duration in minutes
  @override
  final int durationMinutes;

  /// Number of exercises
  @override
  final int exerciseCount;

  /// Number of sets completed
  @override
  final int setsCompleted;

  /// Total volume (kg)
  @override
  final int volume;

  /// Muscle groups trained
  final List<String> _muscleGroups;

  /// Muscle groups trained
  @override
  List<String> get muscleGroups {
    if (_muscleGroups is EqualUnmodifiableListView) return _muscleGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_muscleGroups);
  }

  /// Whether any PRs were achieved
  @override
  @JsonKey()
  final bool hadPR;

  /// Average RPE for the session
  @override
  final double? averageRpe;

  @override
  String toString() {
    return 'WeeklyWorkout(id: $id, date: $date, templateName: $templateName, durationMinutes: $durationMinutes, exerciseCount: $exerciseCount, setsCompleted: $setsCompleted, volume: $volume, muscleGroups: $muscleGroups, hadPR: $hadPR, averageRpe: $averageRpe)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyWorkoutImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.templateName, templateName) ||
                other.templateName == templateName) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.exerciseCount, exerciseCount) ||
                other.exerciseCount == exerciseCount) &&
            (identical(other.setsCompleted, setsCompleted) ||
                other.setsCompleted == setsCompleted) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            const DeepCollectionEquality()
                .equals(other._muscleGroups, _muscleGroups) &&
            (identical(other.hadPR, hadPR) || other.hadPR == hadPR) &&
            (identical(other.averageRpe, averageRpe) ||
                other.averageRpe == averageRpe));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      date,
      templateName,
      durationMinutes,
      exerciseCount,
      setsCompleted,
      volume,
      const DeepCollectionEquality().hash(_muscleGroups),
      hadPR,
      averageRpe);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyWorkoutImplCopyWith<_$WeeklyWorkoutImpl> get copyWith =>
      __$$WeeklyWorkoutImplCopyWithImpl<_$WeeklyWorkoutImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyWorkoutImplToJson(
      this,
    );
  }
}

abstract class _WeeklyWorkout implements WeeklyWorkout {
  const factory _WeeklyWorkout(
      {required final String id,
      required final DateTime date,
      final String? templateName,
      required final int durationMinutes,
      required final int exerciseCount,
      required final int setsCompleted,
      required final int volume,
      required final List<String> muscleGroups,
      final bool hadPR,
      final double? averageRpe}) = _$WeeklyWorkoutImpl;

  factory _WeeklyWorkout.fromJson(Map<String, dynamic> json) =
      _$WeeklyWorkoutImpl.fromJson;

  @override

  /// Workout session ID
  String get id;
  @override

  /// Date of the workout
  DateTime get date;
  @override

  /// Template name if used
  String? get templateName;
  @override

  /// Duration in minutes
  int get durationMinutes;
  @override

  /// Number of exercises
  int get exerciseCount;
  @override

  /// Number of sets completed
  int get setsCompleted;
  @override

  /// Total volume (kg)
  int get volume;
  @override

  /// Muscle groups trained
  List<String> get muscleGroups;
  @override

  /// Whether any PRs were achieved
  bool get hadPR;
  @override

  /// Average RPE for the session
  double? get averageRpe;
  @override
  @JsonKey(ignore: true)
  _$$WeeklyWorkoutImplCopyWith<_$WeeklyWorkoutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeeklyPR _$WeeklyPRFromJson(Map<String, dynamic> json) {
  return _WeeklyPR.fromJson(json);
}

/// @nodoc
mixin _$WeeklyPR {
  /// Exercise ID
  String get exerciseId => throw _privateConstructorUsedError;

  /// Exercise name
  String get exerciseName => throw _privateConstructorUsedError;

  /// Weight lifted
  double get weight => throw _privateConstructorUsedError;

  /// Reps performed
  int get reps => throw _privateConstructorUsedError;

  /// Estimated 1RM
  double get estimated1RM => throw _privateConstructorUsedError;

  /// Previous best 1RM (for comparison)
  double? get previousBest => throw _privateConstructorUsedError;

  /// Date achieved
  DateTime get achievedAt => throw _privateConstructorUsedError;

  /// Type of PR (weight, reps, volume, 1RM)
  PRType get prType => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WeeklyPRCopyWith<WeeklyPR> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyPRCopyWith<$Res> {
  factory $WeeklyPRCopyWith(WeeklyPR value, $Res Function(WeeklyPR) then) =
      _$WeeklyPRCopyWithImpl<$Res, WeeklyPR>;
  @useResult
  $Res call(
      {String exerciseId,
      String exerciseName,
      double weight,
      int reps,
      double estimated1RM,
      double? previousBest,
      DateTime achievedAt,
      PRType prType});
}

/// @nodoc
class _$WeeklyPRCopyWithImpl<$Res, $Val extends WeeklyPR>
    implements $WeeklyPRCopyWith<$Res> {
  _$WeeklyPRCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? weight = null,
    Object? reps = null,
    Object? estimated1RM = null,
    Object? previousBest = freezed,
    Object? achievedAt = null,
    Object? prType = null,
  }) {
    return _then(_value.copyWith(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      estimated1RM: null == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double,
      previousBest: freezed == previousBest
          ? _value.previousBest
          : previousBest // ignore: cast_nullable_to_non_nullable
              as double?,
      achievedAt: null == achievedAt
          ? _value.achievedAt
          : achievedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      prType: null == prType
          ? _value.prType
          : prType // ignore: cast_nullable_to_non_nullable
              as PRType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeeklyPRImplCopyWith<$Res>
    implements $WeeklyPRCopyWith<$Res> {
  factory _$$WeeklyPRImplCopyWith(
          _$WeeklyPRImpl value, $Res Function(_$WeeklyPRImpl) then) =
      __$$WeeklyPRImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseId,
      String exerciseName,
      double weight,
      int reps,
      double estimated1RM,
      double? previousBest,
      DateTime achievedAt,
      PRType prType});
}

/// @nodoc
class __$$WeeklyPRImplCopyWithImpl<$Res>
    extends _$WeeklyPRCopyWithImpl<$Res, _$WeeklyPRImpl>
    implements _$$WeeklyPRImplCopyWith<$Res> {
  __$$WeeklyPRImplCopyWithImpl(
      _$WeeklyPRImpl _value, $Res Function(_$WeeklyPRImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? weight = null,
    Object? reps = null,
    Object? estimated1RM = null,
    Object? previousBest = freezed,
    Object? achievedAt = null,
    Object? prType = null,
  }) {
    return _then(_$WeeklyPRImpl(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int,
      estimated1RM: null == estimated1RM
          ? _value.estimated1RM
          : estimated1RM // ignore: cast_nullable_to_non_nullable
              as double,
      previousBest: freezed == previousBest
          ? _value.previousBest
          : previousBest // ignore: cast_nullable_to_non_nullable
              as double?,
      achievedAt: null == achievedAt
          ? _value.achievedAt
          : achievedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      prType: null == prType
          ? _value.prType
          : prType // ignore: cast_nullable_to_non_nullable
              as PRType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyPRImpl implements _WeeklyPR {
  const _$WeeklyPRImpl(
      {required this.exerciseId,
      required this.exerciseName,
      required this.weight,
      required this.reps,
      required this.estimated1RM,
      this.previousBest,
      required this.achievedAt,
      required this.prType});

  factory _$WeeklyPRImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyPRImplFromJson(json);

  /// Exercise ID
  @override
  final String exerciseId;

  /// Exercise name
  @override
  final String exerciseName;

  /// Weight lifted
  @override
  final double weight;

  /// Reps performed
  @override
  final int reps;

  /// Estimated 1RM
  @override
  final double estimated1RM;

  /// Previous best 1RM (for comparison)
  @override
  final double? previousBest;

  /// Date achieved
  @override
  final DateTime achievedAt;

  /// Type of PR (weight, reps, volume, 1RM)
  @override
  final PRType prType;

  @override
  String toString() {
    return 'WeeklyPR(exerciseId: $exerciseId, exerciseName: $exerciseName, weight: $weight, reps: $reps, estimated1RM: $estimated1RM, previousBest: $previousBest, achievedAt: $achievedAt, prType: $prType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyPRImpl &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.estimated1RM, estimated1RM) ||
                other.estimated1RM == estimated1RM) &&
            (identical(other.previousBest, previousBest) ||
                other.previousBest == previousBest) &&
            (identical(other.achievedAt, achievedAt) ||
                other.achievedAt == achievedAt) &&
            (identical(other.prType, prType) || other.prType == prType));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, exerciseId, exerciseName, weight,
      reps, estimated1RM, previousBest, achievedAt, prType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyPRImplCopyWith<_$WeeklyPRImpl> get copyWith =>
      __$$WeeklyPRImplCopyWithImpl<_$WeeklyPRImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyPRImplToJson(
      this,
    );
  }
}

abstract class _WeeklyPR implements WeeklyPR {
  const factory _WeeklyPR(
      {required final String exerciseId,
      required final String exerciseName,
      required final double weight,
      required final int reps,
      required final double estimated1RM,
      final double? previousBest,
      required final DateTime achievedAt,
      required final PRType prType}) = _$WeeklyPRImpl;

  factory _WeeklyPR.fromJson(Map<String, dynamic> json) =
      _$WeeklyPRImpl.fromJson;

  @override

  /// Exercise ID
  String get exerciseId;
  @override

  /// Exercise name
  String get exerciseName;
  @override

  /// Weight lifted
  double get weight;
  @override

  /// Reps performed
  int get reps;
  @override

  /// Estimated 1RM
  double get estimated1RM;
  @override

  /// Previous best 1RM (for comparison)
  double? get previousBest;
  @override

  /// Date achieved
  DateTime get achievedAt;
  @override

  /// Type of PR (weight, reps, volume, 1RM)
  PRType get prType;
  @override
  @JsonKey(ignore: true)
  _$$WeeklyPRImplCopyWith<_$WeeklyPRImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MuscleGroupStats _$MuscleGroupStatsFromJson(Map<String, dynamic> json) {
  return _MuscleGroupStats.fromJson(json);
}

/// @nodoc
mixin _$MuscleGroupStats {
  /// Muscle group name
  String get muscleGroup => throw _privateConstructorUsedError;

  /// Total sets for this muscle group
  int get totalSets => throw _privateConstructorUsedError;

  /// Total volume for this muscle group
  int get totalVolume => throw _privateConstructorUsedError;

  /// Number of exercises targeting this muscle
  int get exerciseCount => throw _privateConstructorUsedError;

  /// Percentage of total weekly volume
  double get percentageOfTotal => throw _privateConstructorUsedError;

  /// Comparison with previous week (-100 to +100)
  int get changeFromLastWeek => throw _privateConstructorUsedError;

  /// Recommended sets per week for this muscle
  int get recommendedSets => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MuscleGroupStatsCopyWith<MuscleGroupStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MuscleGroupStatsCopyWith<$Res> {
  factory $MuscleGroupStatsCopyWith(
          MuscleGroupStats value, $Res Function(MuscleGroupStats) then) =
      _$MuscleGroupStatsCopyWithImpl<$Res, MuscleGroupStats>;
  @useResult
  $Res call(
      {String muscleGroup,
      int totalSets,
      int totalVolume,
      int exerciseCount,
      double percentageOfTotal,
      int changeFromLastWeek,
      int recommendedSets});
}

/// @nodoc
class _$MuscleGroupStatsCopyWithImpl<$Res, $Val extends MuscleGroupStats>
    implements $MuscleGroupStatsCopyWith<$Res> {
  _$MuscleGroupStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? muscleGroup = null,
    Object? totalSets = null,
    Object? totalVolume = null,
    Object? exerciseCount = null,
    Object? percentageOfTotal = null,
    Object? changeFromLastWeek = null,
    Object? recommendedSets = null,
  }) {
    return _then(_value.copyWith(
      muscleGroup: null == muscleGroup
          ? _value.muscleGroup
          : muscleGroup // ignore: cast_nullable_to_non_nullable
              as String,
      totalSets: null == totalSets
          ? _value.totalSets
          : totalSets // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume: null == totalVolume
          ? _value.totalVolume
          : totalVolume // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseCount: null == exerciseCount
          ? _value.exerciseCount
          : exerciseCount // ignore: cast_nullable_to_non_nullable
              as int,
      percentageOfTotal: null == percentageOfTotal
          ? _value.percentageOfTotal
          : percentageOfTotal // ignore: cast_nullable_to_non_nullable
              as double,
      changeFromLastWeek: null == changeFromLastWeek
          ? _value.changeFromLastWeek
          : changeFromLastWeek // ignore: cast_nullable_to_non_nullable
              as int,
      recommendedSets: null == recommendedSets
          ? _value.recommendedSets
          : recommendedSets // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MuscleGroupStatsImplCopyWith<$Res>
    implements $MuscleGroupStatsCopyWith<$Res> {
  factory _$$MuscleGroupStatsImplCopyWith(_$MuscleGroupStatsImpl value,
          $Res Function(_$MuscleGroupStatsImpl) then) =
      __$$MuscleGroupStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String muscleGroup,
      int totalSets,
      int totalVolume,
      int exerciseCount,
      double percentageOfTotal,
      int changeFromLastWeek,
      int recommendedSets});
}

/// @nodoc
class __$$MuscleGroupStatsImplCopyWithImpl<$Res>
    extends _$MuscleGroupStatsCopyWithImpl<$Res, _$MuscleGroupStatsImpl>
    implements _$$MuscleGroupStatsImplCopyWith<$Res> {
  __$$MuscleGroupStatsImplCopyWithImpl(_$MuscleGroupStatsImpl _value,
      $Res Function(_$MuscleGroupStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? muscleGroup = null,
    Object? totalSets = null,
    Object? totalVolume = null,
    Object? exerciseCount = null,
    Object? percentageOfTotal = null,
    Object? changeFromLastWeek = null,
    Object? recommendedSets = null,
  }) {
    return _then(_$MuscleGroupStatsImpl(
      muscleGroup: null == muscleGroup
          ? _value.muscleGroup
          : muscleGroup // ignore: cast_nullable_to_non_nullable
              as String,
      totalSets: null == totalSets
          ? _value.totalSets
          : totalSets // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume: null == totalVolume
          ? _value.totalVolume
          : totalVolume // ignore: cast_nullable_to_non_nullable
              as int,
      exerciseCount: null == exerciseCount
          ? _value.exerciseCount
          : exerciseCount // ignore: cast_nullable_to_non_nullable
              as int,
      percentageOfTotal: null == percentageOfTotal
          ? _value.percentageOfTotal
          : percentageOfTotal // ignore: cast_nullable_to_non_nullable
              as double,
      changeFromLastWeek: null == changeFromLastWeek
          ? _value.changeFromLastWeek
          : changeFromLastWeek // ignore: cast_nullable_to_non_nullable
              as int,
      recommendedSets: null == recommendedSets
          ? _value.recommendedSets
          : recommendedSets // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MuscleGroupStatsImpl implements _MuscleGroupStats {
  const _$MuscleGroupStatsImpl(
      {required this.muscleGroup,
      required this.totalSets,
      required this.totalVolume,
      required this.exerciseCount,
      required this.percentageOfTotal,
      this.changeFromLastWeek = 0,
      this.recommendedSets = 0});

  factory _$MuscleGroupStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MuscleGroupStatsImplFromJson(json);

  /// Muscle group name
  @override
  final String muscleGroup;

  /// Total sets for this muscle group
  @override
  final int totalSets;

  /// Total volume for this muscle group
  @override
  final int totalVolume;

  /// Number of exercises targeting this muscle
  @override
  final int exerciseCount;

  /// Percentage of total weekly volume
  @override
  final double percentageOfTotal;

  /// Comparison with previous week (-100 to +100)
  @override
  @JsonKey()
  final int changeFromLastWeek;

  /// Recommended sets per week for this muscle
  @override
  @JsonKey()
  final int recommendedSets;

  @override
  String toString() {
    return 'MuscleGroupStats(muscleGroup: $muscleGroup, totalSets: $totalSets, totalVolume: $totalVolume, exerciseCount: $exerciseCount, percentageOfTotal: $percentageOfTotal, changeFromLastWeek: $changeFromLastWeek, recommendedSets: $recommendedSets)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MuscleGroupStatsImpl &&
            (identical(other.muscleGroup, muscleGroup) ||
                other.muscleGroup == muscleGroup) &&
            (identical(other.totalSets, totalSets) ||
                other.totalSets == totalSets) &&
            (identical(other.totalVolume, totalVolume) ||
                other.totalVolume == totalVolume) &&
            (identical(other.exerciseCount, exerciseCount) ||
                other.exerciseCount == exerciseCount) &&
            (identical(other.percentageOfTotal, percentageOfTotal) ||
                other.percentageOfTotal == percentageOfTotal) &&
            (identical(other.changeFromLastWeek, changeFromLastWeek) ||
                other.changeFromLastWeek == changeFromLastWeek) &&
            (identical(other.recommendedSets, recommendedSets) ||
                other.recommendedSets == recommendedSets));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      muscleGroup,
      totalSets,
      totalVolume,
      exerciseCount,
      percentageOfTotal,
      changeFromLastWeek,
      recommendedSets);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MuscleGroupStatsImplCopyWith<_$MuscleGroupStatsImpl> get copyWith =>
      __$$MuscleGroupStatsImplCopyWithImpl<_$MuscleGroupStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MuscleGroupStatsImplToJson(
      this,
    );
  }
}

abstract class _MuscleGroupStats implements MuscleGroupStats {
  const factory _MuscleGroupStats(
      {required final String muscleGroup,
      required final int totalSets,
      required final int totalVolume,
      required final int exerciseCount,
      required final double percentageOfTotal,
      final int changeFromLastWeek,
      final int recommendedSets}) = _$MuscleGroupStatsImpl;

  factory _MuscleGroupStats.fromJson(Map<String, dynamic> json) =
      _$MuscleGroupStatsImpl.fromJson;

  @override

  /// Muscle group name
  String get muscleGroup;
  @override

  /// Total sets for this muscle group
  int get totalSets;
  @override

  /// Total volume for this muscle group
  int get totalVolume;
  @override

  /// Number of exercises targeting this muscle
  int get exerciseCount;
  @override

  /// Percentage of total weekly volume
  double get percentageOfTotal;
  @override

  /// Comparison with previous week (-100 to +100)
  int get changeFromLastWeek;
  @override

  /// Recommended sets per week for this muscle
  int get recommendedSets;
  @override
  @JsonKey(ignore: true)
  _$$MuscleGroupStatsImplCopyWith<_$MuscleGroupStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeeklyComparison _$WeeklyComparisonFromJson(Map<String, dynamic> json) {
  return _WeeklyComparison.fromJson(json);
}

/// @nodoc
mixin _$WeeklyComparison {
  /// Current week's value
  int get current => throw _privateConstructorUsedError;

  /// Previous week's value
  int get previous => throw _privateConstructorUsedError;

  /// Percentage change
  double get percentChange => throw _privateConstructorUsedError;

  /// Trend direction
  TrendDirection get trend => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WeeklyComparisonCopyWith<WeeklyComparison> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyComparisonCopyWith<$Res> {
  factory $WeeklyComparisonCopyWith(
          WeeklyComparison value, $Res Function(WeeklyComparison) then) =
      _$WeeklyComparisonCopyWithImpl<$Res, WeeklyComparison>;
  @useResult
  $Res call(
      {int current, int previous, double percentChange, TrendDirection trend});
}

/// @nodoc
class _$WeeklyComparisonCopyWithImpl<$Res, $Val extends WeeklyComparison>
    implements $WeeklyComparisonCopyWith<$Res> {
  _$WeeklyComparisonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? current = null,
    Object? previous = null,
    Object? percentChange = null,
    Object? trend = null,
  }) {
    return _then(_value.copyWith(
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as int,
      previous: null == previous
          ? _value.previous
          : previous // ignore: cast_nullable_to_non_nullable
              as int,
      percentChange: null == percentChange
          ? _value.percentChange
          : percentChange // ignore: cast_nullable_to_non_nullable
              as double,
      trend: null == trend
          ? _value.trend
          : trend // ignore: cast_nullable_to_non_nullable
              as TrendDirection,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeeklyComparisonImplCopyWith<$Res>
    implements $WeeklyComparisonCopyWith<$Res> {
  factory _$$WeeklyComparisonImplCopyWith(_$WeeklyComparisonImpl value,
          $Res Function(_$WeeklyComparisonImpl) then) =
      __$$WeeklyComparisonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int current, int previous, double percentChange, TrendDirection trend});
}

/// @nodoc
class __$$WeeklyComparisonImplCopyWithImpl<$Res>
    extends _$WeeklyComparisonCopyWithImpl<$Res, _$WeeklyComparisonImpl>
    implements _$$WeeklyComparisonImplCopyWith<$Res> {
  __$$WeeklyComparisonImplCopyWithImpl(_$WeeklyComparisonImpl _value,
      $Res Function(_$WeeklyComparisonImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? current = null,
    Object? previous = null,
    Object? percentChange = null,
    Object? trend = null,
  }) {
    return _then(_$WeeklyComparisonImpl(
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as int,
      previous: null == previous
          ? _value.previous
          : previous // ignore: cast_nullable_to_non_nullable
              as int,
      percentChange: null == percentChange
          ? _value.percentChange
          : percentChange // ignore: cast_nullable_to_non_nullable
              as double,
      trend: null == trend
          ? _value.trend
          : trend // ignore: cast_nullable_to_non_nullable
              as TrendDirection,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyComparisonImpl implements _WeeklyComparison {
  const _$WeeklyComparisonImpl(
      {required this.current,
      required this.previous,
      required this.percentChange,
      required this.trend});

  factory _$WeeklyComparisonImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyComparisonImplFromJson(json);

  /// Current week's value
  @override
  final int current;

  /// Previous week's value
  @override
  final int previous;

  /// Percentage change
  @override
  final double percentChange;

  /// Trend direction
  @override
  final TrendDirection trend;

  @override
  String toString() {
    return 'WeeklyComparison(current: $current, previous: $previous, percentChange: $percentChange, trend: $trend)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyComparisonImpl &&
            (identical(other.current, current) || other.current == current) &&
            (identical(other.previous, previous) ||
                other.previous == previous) &&
            (identical(other.percentChange, percentChange) ||
                other.percentChange == percentChange) &&
            (identical(other.trend, trend) || other.trend == trend));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, current, previous, percentChange, trend);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyComparisonImplCopyWith<_$WeeklyComparisonImpl> get copyWith =>
      __$$WeeklyComparisonImplCopyWithImpl<_$WeeklyComparisonImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyComparisonImplToJson(
      this,
    );
  }
}

abstract class _WeeklyComparison implements WeeklyComparison {
  const factory _WeeklyComparison(
      {required final int current,
      required final int previous,
      required final double percentChange,
      required final TrendDirection trend}) = _$WeeklyComparisonImpl;

  factory _WeeklyComparison.fromJson(Map<String, dynamic> json) =
      _$WeeklyComparisonImpl.fromJson;

  @override

  /// Current week's value
  int get current;
  @override

  /// Previous week's value
  int get previous;
  @override

  /// Percentage change
  double get percentChange;
  @override

  /// Trend direction
  TrendDirection get trend;
  @override
  @JsonKey(ignore: true)
  _$$WeeklyComparisonImplCopyWith<_$WeeklyComparisonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeeklyInsight _$WeeklyInsightFromJson(Map<String, dynamic> json) {
  return _WeeklyInsight.fromJson(json);
}

/// @nodoc
mixin _$WeeklyInsight {
  /// Insight type category
  InsightType get type => throw _privateConstructorUsedError;

  /// Main insight title
  String get title => throw _privateConstructorUsedError;

  /// Detailed description
  String get description => throw _privateConstructorUsedError;

  /// Priority level (1-5, 5 being most important)
  int get priority => throw _privateConstructorUsedError;

  /// Action items or recommendations
  List<String> get actionItems => throw _privateConstructorUsedError;

  /// Related data points
  Map<String, dynamic> get relatedData => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WeeklyInsightCopyWith<WeeklyInsight> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyInsightCopyWith<$Res> {
  factory $WeeklyInsightCopyWith(
          WeeklyInsight value, $Res Function(WeeklyInsight) then) =
      _$WeeklyInsightCopyWithImpl<$Res, WeeklyInsight>;
  @useResult
  $Res call(
      {InsightType type,
      String title,
      String description,
      int priority,
      List<String> actionItems,
      Map<String, dynamic> relatedData});
}

/// @nodoc
class _$WeeklyInsightCopyWithImpl<$Res, $Val extends WeeklyInsight>
    implements $WeeklyInsightCopyWith<$Res> {
  _$WeeklyInsightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? priority = null,
    Object? actionItems = null,
    Object? relatedData = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as InsightType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      actionItems: null == actionItems
          ? _value.actionItems
          : actionItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
      relatedData: null == relatedData
          ? _value.relatedData
          : relatedData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeeklyInsightImplCopyWith<$Res>
    implements $WeeklyInsightCopyWith<$Res> {
  factory _$$WeeklyInsightImplCopyWith(
          _$WeeklyInsightImpl value, $Res Function(_$WeeklyInsightImpl) then) =
      __$$WeeklyInsightImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {InsightType type,
      String title,
      String description,
      int priority,
      List<String> actionItems,
      Map<String, dynamic> relatedData});
}

/// @nodoc
class __$$WeeklyInsightImplCopyWithImpl<$Res>
    extends _$WeeklyInsightCopyWithImpl<$Res, _$WeeklyInsightImpl>
    implements _$$WeeklyInsightImplCopyWith<$Res> {
  __$$WeeklyInsightImplCopyWithImpl(
      _$WeeklyInsightImpl _value, $Res Function(_$WeeklyInsightImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? priority = null,
    Object? actionItems = null,
    Object? relatedData = null,
  }) {
    return _then(_$WeeklyInsightImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as InsightType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      actionItems: null == actionItems
          ? _value._actionItems
          : actionItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
      relatedData: null == relatedData
          ? _value._relatedData
          : relatedData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyInsightImpl implements _WeeklyInsight {
  const _$WeeklyInsightImpl(
      {required this.type,
      required this.title,
      required this.description,
      required this.priority,
      final List<String> actionItems = const [],
      final Map<String, dynamic> relatedData = const {}})
      : _actionItems = actionItems,
        _relatedData = relatedData;

  factory _$WeeklyInsightImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyInsightImplFromJson(json);

  /// Insight type category
  @override
  final InsightType type;

  /// Main insight title
  @override
  final String title;

  /// Detailed description
  @override
  final String description;

  /// Priority level (1-5, 5 being most important)
  @override
  final int priority;

  /// Action items or recommendations
  final List<String> _actionItems;

  /// Action items or recommendations
  @override
  @JsonKey()
  List<String> get actionItems {
    if (_actionItems is EqualUnmodifiableListView) return _actionItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actionItems);
  }

  /// Related data points
  final Map<String, dynamic> _relatedData;

  /// Related data points
  @override
  @JsonKey()
  Map<String, dynamic> get relatedData {
    if (_relatedData is EqualUnmodifiableMapView) return _relatedData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_relatedData);
  }

  @override
  String toString() {
    return 'WeeklyInsight(type: $type, title: $title, description: $description, priority: $priority, actionItems: $actionItems, relatedData: $relatedData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyInsightImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            const DeepCollectionEquality()
                .equals(other._actionItems, _actionItems) &&
            const DeepCollectionEquality()
                .equals(other._relatedData, _relatedData));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      type,
      title,
      description,
      priority,
      const DeepCollectionEquality().hash(_actionItems),
      const DeepCollectionEquality().hash(_relatedData));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyInsightImplCopyWith<_$WeeklyInsightImpl> get copyWith =>
      __$$WeeklyInsightImplCopyWithImpl<_$WeeklyInsightImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyInsightImplToJson(
      this,
    );
  }
}

abstract class _WeeklyInsight implements WeeklyInsight {
  const factory _WeeklyInsight(
      {required final InsightType type,
      required final String title,
      required final String description,
      required final int priority,
      final List<String> actionItems,
      final Map<String, dynamic> relatedData}) = _$WeeklyInsightImpl;

  factory _WeeklyInsight.fromJson(Map<String, dynamic> json) =
      _$WeeklyInsightImpl.fromJson;

  @override

  /// Insight type category
  InsightType get type;
  @override

  /// Main insight title
  String get title;
  @override

  /// Detailed description
  String get description;
  @override

  /// Priority level (1-5, 5 being most important)
  int get priority;
  @override

  /// Action items or recommendations
  List<String> get actionItems;
  @override

  /// Related data points
  Map<String, dynamic> get relatedData;
  @override
  @JsonKey(ignore: true)
  _$$WeeklyInsightImplCopyWith<_$WeeklyInsightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GoalProgress _$GoalProgressFromJson(Map<String, dynamic> json) {
  return _GoalProgress.fromJson(json);
}

/// @nodoc
mixin _$GoalProgress {
  /// Goal ID
  String get goalId => throw _privateConstructorUsedError;

  /// Goal title
  String get title => throw _privateConstructorUsedError;

  /// Target value
  double get target => throw _privateConstructorUsedError;

  /// Current progress value
  double get current => throw _privateConstructorUsedError;

  /// Unit of measurement
  String get unit => throw _privateConstructorUsedError;

  /// Progress percentage (0-100)
  double get progressPercent => throw _privateConstructorUsedError;

  /// Whether the goal was achieved
  bool get achieved => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GoalProgressCopyWith<GoalProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoalProgressCopyWith<$Res> {
  factory $GoalProgressCopyWith(
          GoalProgress value, $Res Function(GoalProgress) then) =
      _$GoalProgressCopyWithImpl<$Res, GoalProgress>;
  @useResult
  $Res call(
      {String goalId,
      String title,
      double target,
      double current,
      String unit,
      double progressPercent,
      bool achieved});
}

/// @nodoc
class _$GoalProgressCopyWithImpl<$Res, $Val extends GoalProgress>
    implements $GoalProgressCopyWith<$Res> {
  _$GoalProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goalId = null,
    Object? title = null,
    Object? target = null,
    Object? current = null,
    Object? unit = null,
    Object? progressPercent = null,
    Object? achieved = null,
  }) {
    return _then(_value.copyWith(
      goalId: null == goalId
          ? _value.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      target: null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as double,
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      progressPercent: null == progressPercent
          ? _value.progressPercent
          : progressPercent // ignore: cast_nullable_to_non_nullable
              as double,
      achieved: null == achieved
          ? _value.achieved
          : achieved // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GoalProgressImplCopyWith<$Res>
    implements $GoalProgressCopyWith<$Res> {
  factory _$$GoalProgressImplCopyWith(
          _$GoalProgressImpl value, $Res Function(_$GoalProgressImpl) then) =
      __$$GoalProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String goalId,
      String title,
      double target,
      double current,
      String unit,
      double progressPercent,
      bool achieved});
}

/// @nodoc
class __$$GoalProgressImplCopyWithImpl<$Res>
    extends _$GoalProgressCopyWithImpl<$Res, _$GoalProgressImpl>
    implements _$$GoalProgressImplCopyWith<$Res> {
  __$$GoalProgressImplCopyWithImpl(
      _$GoalProgressImpl _value, $Res Function(_$GoalProgressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goalId = null,
    Object? title = null,
    Object? target = null,
    Object? current = null,
    Object? unit = null,
    Object? progressPercent = null,
    Object? achieved = null,
  }) {
    return _then(_$GoalProgressImpl(
      goalId: null == goalId
          ? _value.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      target: null == target
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as double,
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      progressPercent: null == progressPercent
          ? _value.progressPercent
          : progressPercent // ignore: cast_nullable_to_non_nullable
              as double,
      achieved: null == achieved
          ? _value.achieved
          : achieved // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GoalProgressImpl implements _GoalProgress {
  const _$GoalProgressImpl(
      {required this.goalId,
      required this.title,
      required this.target,
      required this.current,
      required this.unit,
      required this.progressPercent,
      this.achieved = false});

  factory _$GoalProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoalProgressImplFromJson(json);

  /// Goal ID
  @override
  final String goalId;

  /// Goal title
  @override
  final String title;

  /// Target value
  @override
  final double target;

  /// Current progress value
  @override
  final double current;

  /// Unit of measurement
  @override
  final String unit;

  /// Progress percentage (0-100)
  @override
  final double progressPercent;

  /// Whether the goal was achieved
  @override
  @JsonKey()
  final bool achieved;

  @override
  String toString() {
    return 'GoalProgress(goalId: $goalId, title: $title, target: $target, current: $current, unit: $unit, progressPercent: $progressPercent, achieved: $achieved)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoalProgressImpl &&
            (identical(other.goalId, goalId) || other.goalId == goalId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.target, target) || other.target == target) &&
            (identical(other.current, current) || other.current == current) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.progressPercent, progressPercent) ||
                other.progressPercent == progressPercent) &&
            (identical(other.achieved, achieved) ||
                other.achieved == achieved));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, goalId, title, target, current,
      unit, progressPercent, achieved);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GoalProgressImplCopyWith<_$GoalProgressImpl> get copyWith =>
      __$$GoalProgressImplCopyWithImpl<_$GoalProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GoalProgressImplToJson(
      this,
    );
  }
}

abstract class _GoalProgress implements GoalProgress {
  const factory _GoalProgress(
      {required final String goalId,
      required final String title,
      required final double target,
      required final double current,
      required final String unit,
      required final double progressPercent,
      final bool achieved}) = _$GoalProgressImpl;

  factory _GoalProgress.fromJson(Map<String, dynamic> json) =
      _$GoalProgressImpl.fromJson;

  @override

  /// Goal ID
  String get goalId;
  @override

  /// Goal title
  String get title;
  @override

  /// Target value
  double get target;
  @override

  /// Current progress value
  double get current;
  @override

  /// Unit of measurement
  String get unit;
  @override

  /// Progress percentage (0-100)
  double get progressPercent;
  @override

  /// Whether the goal was achieved
  bool get achieved;
  @override
  @JsonKey(ignore: true)
  _$$GoalProgressImplCopyWith<_$GoalProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
