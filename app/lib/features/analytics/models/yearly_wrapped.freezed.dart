// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'yearly_wrapped.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

YearlyWrapped _$YearlyWrappedFromJson(Map<String, dynamic> json) {
  return _YearlyWrapped.fromJson(json);
}

/// @nodoc
mixin _$YearlyWrapped {
  /// Year this wrapped is for
  int get year => throw _privateConstructorUsedError;

  /// User ID
  String get userId => throw _privateConstructorUsedError;

  /// When the wrapped was generated
  DateTime get generatedAt => throw _privateConstructorUsedError;

  /// Whether the year is complete
  bool get isYearComplete => throw _privateConstructorUsedError;

  /// Overall summary statistics
  WrappedSummary get summary => throw _privateConstructorUsedError;

  /// Training personality type
  TrainingPersonality get personality => throw _privateConstructorUsedError;

  /// Top exercises by volume
  List<TopExercise> get topExercises => throw _privateConstructorUsedError;

  /// Most impressive PRs of the year
  List<YearlyPR> get topPRs => throw _privateConstructorUsedError;

  /// Month-by-month breakdown
  List<MonthlyStats> get monthlyBreakdown => throw _privateConstructorUsedError;

  /// Milestones achieved during the year
  List<YearlyMilestone> get milestones => throw _privateConstructorUsedError;

  /// Fun facts and insights
  List<WrappedFunFact> get funFacts => throw _privateConstructorUsedError;

  /// Achievements unlocked during the year
  List<String> get achievementsUnlocked => throw _privateConstructorUsedError;

  /// Comparison with previous year (if available)
  YearOverYearComparison? get yearOverYear =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $YearlyWrappedCopyWith<YearlyWrapped> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YearlyWrappedCopyWith<$Res> {
  factory $YearlyWrappedCopyWith(
          YearlyWrapped value, $Res Function(YearlyWrapped) then) =
      _$YearlyWrappedCopyWithImpl<$Res, YearlyWrapped>;
  @useResult
  $Res call(
      {int year,
      String userId,
      DateTime generatedAt,
      bool isYearComplete,
      WrappedSummary summary,
      TrainingPersonality personality,
      List<TopExercise> topExercises,
      List<YearlyPR> topPRs,
      List<MonthlyStats> monthlyBreakdown,
      List<YearlyMilestone> milestones,
      List<WrappedFunFact> funFacts,
      List<String> achievementsUnlocked,
      YearOverYearComparison? yearOverYear});

  $WrappedSummaryCopyWith<$Res> get summary;
  $TrainingPersonalityCopyWith<$Res> get personality;
  $YearOverYearComparisonCopyWith<$Res>? get yearOverYear;
}

/// @nodoc
class _$YearlyWrappedCopyWithImpl<$Res, $Val extends YearlyWrapped>
    implements $YearlyWrappedCopyWith<$Res> {
  _$YearlyWrappedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? userId = null,
    Object? generatedAt = null,
    Object? isYearComplete = null,
    Object? summary = null,
    Object? personality = null,
    Object? topExercises = null,
    Object? topPRs = null,
    Object? monthlyBreakdown = null,
    Object? milestones = null,
    Object? funFacts = null,
    Object? achievementsUnlocked = null,
    Object? yearOverYear = freezed,
  }) {
    return _then(_value.copyWith(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isYearComplete: null == isYearComplete
          ? _value.isYearComplete
          : isYearComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as WrappedSummary,
      personality: null == personality
          ? _value.personality
          : personality // ignore: cast_nullable_to_non_nullable
              as TrainingPersonality,
      topExercises: null == topExercises
          ? _value.topExercises
          : topExercises // ignore: cast_nullable_to_non_nullable
              as List<TopExercise>,
      topPRs: null == topPRs
          ? _value.topPRs
          : topPRs // ignore: cast_nullable_to_non_nullable
              as List<YearlyPR>,
      monthlyBreakdown: null == monthlyBreakdown
          ? _value.monthlyBreakdown
          : monthlyBreakdown // ignore: cast_nullable_to_non_nullable
              as List<MonthlyStats>,
      milestones: null == milestones
          ? _value.milestones
          : milestones // ignore: cast_nullable_to_non_nullable
              as List<YearlyMilestone>,
      funFacts: null == funFacts
          ? _value.funFacts
          : funFacts // ignore: cast_nullable_to_non_nullable
              as List<WrappedFunFact>,
      achievementsUnlocked: null == achievementsUnlocked
          ? _value.achievementsUnlocked
          : achievementsUnlocked // ignore: cast_nullable_to_non_nullable
              as List<String>,
      yearOverYear: freezed == yearOverYear
          ? _value.yearOverYear
          : yearOverYear // ignore: cast_nullable_to_non_nullable
              as YearOverYearComparison?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WrappedSummaryCopyWith<$Res> get summary {
    return $WrappedSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TrainingPersonalityCopyWith<$Res> get personality {
    return $TrainingPersonalityCopyWith<$Res>(_value.personality, (value) {
      return _then(_value.copyWith(personality: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $YearOverYearComparisonCopyWith<$Res>? get yearOverYear {
    if (_value.yearOverYear == null) {
      return null;
    }

    return $YearOverYearComparisonCopyWith<$Res>(_value.yearOverYear!, (value) {
      return _then(_value.copyWith(yearOverYear: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$YearlyWrappedImplCopyWith<$Res>
    implements $YearlyWrappedCopyWith<$Res> {
  factory _$$YearlyWrappedImplCopyWith(
          _$YearlyWrappedImpl value, $Res Function(_$YearlyWrappedImpl) then) =
      __$$YearlyWrappedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int year,
      String userId,
      DateTime generatedAt,
      bool isYearComplete,
      WrappedSummary summary,
      TrainingPersonality personality,
      List<TopExercise> topExercises,
      List<YearlyPR> topPRs,
      List<MonthlyStats> monthlyBreakdown,
      List<YearlyMilestone> milestones,
      List<WrappedFunFact> funFacts,
      List<String> achievementsUnlocked,
      YearOverYearComparison? yearOverYear});

  @override
  $WrappedSummaryCopyWith<$Res> get summary;
  @override
  $TrainingPersonalityCopyWith<$Res> get personality;
  @override
  $YearOverYearComparisonCopyWith<$Res>? get yearOverYear;
}

/// @nodoc
class __$$YearlyWrappedImplCopyWithImpl<$Res>
    extends _$YearlyWrappedCopyWithImpl<$Res, _$YearlyWrappedImpl>
    implements _$$YearlyWrappedImplCopyWith<$Res> {
  __$$YearlyWrappedImplCopyWithImpl(
      _$YearlyWrappedImpl _value, $Res Function(_$YearlyWrappedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? userId = null,
    Object? generatedAt = null,
    Object? isYearComplete = null,
    Object? summary = null,
    Object? personality = null,
    Object? topExercises = null,
    Object? topPRs = null,
    Object? monthlyBreakdown = null,
    Object? milestones = null,
    Object? funFacts = null,
    Object? achievementsUnlocked = null,
    Object? yearOverYear = freezed,
  }) {
    return _then(_$YearlyWrappedImpl(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isYearComplete: null == isYearComplete
          ? _value.isYearComplete
          : isYearComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as WrappedSummary,
      personality: null == personality
          ? _value.personality
          : personality // ignore: cast_nullable_to_non_nullable
              as TrainingPersonality,
      topExercises: null == topExercises
          ? _value._topExercises
          : topExercises // ignore: cast_nullable_to_non_nullable
              as List<TopExercise>,
      topPRs: null == topPRs
          ? _value._topPRs
          : topPRs // ignore: cast_nullable_to_non_nullable
              as List<YearlyPR>,
      monthlyBreakdown: null == monthlyBreakdown
          ? _value._monthlyBreakdown
          : monthlyBreakdown // ignore: cast_nullable_to_non_nullable
              as List<MonthlyStats>,
      milestones: null == milestones
          ? _value._milestones
          : milestones // ignore: cast_nullable_to_non_nullable
              as List<YearlyMilestone>,
      funFacts: null == funFacts
          ? _value._funFacts
          : funFacts // ignore: cast_nullable_to_non_nullable
              as List<WrappedFunFact>,
      achievementsUnlocked: null == achievementsUnlocked
          ? _value._achievementsUnlocked
          : achievementsUnlocked // ignore: cast_nullable_to_non_nullable
              as List<String>,
      yearOverYear: freezed == yearOverYear
          ? _value.yearOverYear
          : yearOverYear // ignore: cast_nullable_to_non_nullable
              as YearOverYearComparison?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$YearlyWrappedImpl implements _YearlyWrapped {
  const _$YearlyWrappedImpl(
      {required this.year,
      required this.userId,
      required this.generatedAt,
      required this.isYearComplete,
      required this.summary,
      required this.personality,
      required final List<TopExercise> topExercises,
      required final List<YearlyPR> topPRs,
      required final List<MonthlyStats> monthlyBreakdown,
      required final List<YearlyMilestone> milestones,
      required final List<WrappedFunFact> funFacts,
      final List<String> achievementsUnlocked = const [],
      this.yearOverYear})
      : _topExercises = topExercises,
        _topPRs = topPRs,
        _monthlyBreakdown = monthlyBreakdown,
        _milestones = milestones,
        _funFacts = funFacts,
        _achievementsUnlocked = achievementsUnlocked;

  factory _$YearlyWrappedImpl.fromJson(Map<String, dynamic> json) =>
      _$$YearlyWrappedImplFromJson(json);

  /// Year this wrapped is for
  @override
  final int year;

  /// User ID
  @override
  final String userId;

  /// When the wrapped was generated
  @override
  final DateTime generatedAt;

  /// Whether the year is complete
  @override
  final bool isYearComplete;

  /// Overall summary statistics
  @override
  final WrappedSummary summary;

  /// Training personality type
  @override
  final TrainingPersonality personality;

  /// Top exercises by volume
  final List<TopExercise> _topExercises;

  /// Top exercises by volume
  @override
  List<TopExercise> get topExercises {
    if (_topExercises is EqualUnmodifiableListView) return _topExercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topExercises);
  }

  /// Most impressive PRs of the year
  final List<YearlyPR> _topPRs;

  /// Most impressive PRs of the year
  @override
  List<YearlyPR> get topPRs {
    if (_topPRs is EqualUnmodifiableListView) return _topPRs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topPRs);
  }

  /// Month-by-month breakdown
  final List<MonthlyStats> _monthlyBreakdown;

  /// Month-by-month breakdown
  @override
  List<MonthlyStats> get monthlyBreakdown {
    if (_monthlyBreakdown is EqualUnmodifiableListView)
      return _monthlyBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_monthlyBreakdown);
  }

  /// Milestones achieved during the year
  final List<YearlyMilestone> _milestones;

  /// Milestones achieved during the year
  @override
  List<YearlyMilestone> get milestones {
    if (_milestones is EqualUnmodifiableListView) return _milestones;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_milestones);
  }

  /// Fun facts and insights
  final List<WrappedFunFact> _funFacts;

  /// Fun facts and insights
  @override
  List<WrappedFunFact> get funFacts {
    if (_funFacts is EqualUnmodifiableListView) return _funFacts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_funFacts);
  }

  /// Achievements unlocked during the year
  final List<String> _achievementsUnlocked;

  /// Achievements unlocked during the year
  @override
  @JsonKey()
  List<String> get achievementsUnlocked {
    if (_achievementsUnlocked is EqualUnmodifiableListView)
      return _achievementsUnlocked;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_achievementsUnlocked);
  }

  /// Comparison with previous year (if available)
  @override
  final YearOverYearComparison? yearOverYear;

  @override
  String toString() {
    return 'YearlyWrapped(year: $year, userId: $userId, generatedAt: $generatedAt, isYearComplete: $isYearComplete, summary: $summary, personality: $personality, topExercises: $topExercises, topPRs: $topPRs, monthlyBreakdown: $monthlyBreakdown, milestones: $milestones, funFacts: $funFacts, achievementsUnlocked: $achievementsUnlocked, yearOverYear: $yearOverYear)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YearlyWrappedImpl &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt) &&
            (identical(other.isYearComplete, isYearComplete) ||
                other.isYearComplete == isYearComplete) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.personality, personality) ||
                other.personality == personality) &&
            const DeepCollectionEquality()
                .equals(other._topExercises, _topExercises) &&
            const DeepCollectionEquality().equals(other._topPRs, _topPRs) &&
            const DeepCollectionEquality()
                .equals(other._monthlyBreakdown, _monthlyBreakdown) &&
            const DeepCollectionEquality()
                .equals(other._milestones, _milestones) &&
            const DeepCollectionEquality().equals(other._funFacts, _funFacts) &&
            const DeepCollectionEquality()
                .equals(other._achievementsUnlocked, _achievementsUnlocked) &&
            (identical(other.yearOverYear, yearOverYear) ||
                other.yearOverYear == yearOverYear));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      year,
      userId,
      generatedAt,
      isYearComplete,
      summary,
      personality,
      const DeepCollectionEquality().hash(_topExercises),
      const DeepCollectionEquality().hash(_topPRs),
      const DeepCollectionEquality().hash(_monthlyBreakdown),
      const DeepCollectionEquality().hash(_milestones),
      const DeepCollectionEquality().hash(_funFacts),
      const DeepCollectionEquality().hash(_achievementsUnlocked),
      yearOverYear);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$YearlyWrappedImplCopyWith<_$YearlyWrappedImpl> get copyWith =>
      __$$YearlyWrappedImplCopyWithImpl<_$YearlyWrappedImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$YearlyWrappedImplToJson(
      this,
    );
  }
}

abstract class _YearlyWrapped implements YearlyWrapped {
  const factory _YearlyWrapped(
      {required final int year,
      required final String userId,
      required final DateTime generatedAt,
      required final bool isYearComplete,
      required final WrappedSummary summary,
      required final TrainingPersonality personality,
      required final List<TopExercise> topExercises,
      required final List<YearlyPR> topPRs,
      required final List<MonthlyStats> monthlyBreakdown,
      required final List<YearlyMilestone> milestones,
      required final List<WrappedFunFact> funFacts,
      final List<String> achievementsUnlocked,
      final YearOverYearComparison? yearOverYear}) = _$YearlyWrappedImpl;

  factory _YearlyWrapped.fromJson(Map<String, dynamic> json) =
      _$YearlyWrappedImpl.fromJson;

  @override

  /// Year this wrapped is for
  int get year;
  @override

  /// User ID
  String get userId;
  @override

  /// When the wrapped was generated
  DateTime get generatedAt;
  @override

  /// Whether the year is complete
  bool get isYearComplete;
  @override

  /// Overall summary statistics
  WrappedSummary get summary;
  @override

  /// Training personality type
  TrainingPersonality get personality;
  @override

  /// Top exercises by volume
  List<TopExercise> get topExercises;
  @override

  /// Most impressive PRs of the year
  List<YearlyPR> get topPRs;
  @override

  /// Month-by-month breakdown
  List<MonthlyStats> get monthlyBreakdown;
  @override

  /// Milestones achieved during the year
  List<YearlyMilestone> get milestones;
  @override

  /// Fun facts and insights
  List<WrappedFunFact> get funFacts;
  @override

  /// Achievements unlocked during the year
  List<String> get achievementsUnlocked;
  @override

  /// Comparison with previous year (if available)
  YearOverYearComparison? get yearOverYear;
  @override
  @JsonKey(ignore: true)
  _$$YearlyWrappedImplCopyWith<_$YearlyWrappedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WrappedSummary _$WrappedSummaryFromJson(Map<String, dynamic> json) {
  return _WrappedSummary.fromJson(json);
}

/// @nodoc
mixin _$WrappedSummary {
  /// Total number of workouts completed
  int get totalWorkouts => throw _privateConstructorUsedError;

  /// Total training time in minutes
  int get totalMinutes => throw _privateConstructorUsedError;

  /// Total volume lifted in kg
  int get totalVolume => throw _privateConstructorUsedError;

  /// Total sets completed
  int get totalSets => throw _privateConstructorUsedError;

  /// Total reps completed
  int get totalReps => throw _privateConstructorUsedError;

  /// Number of PRs achieved
  int get totalPRs => throw _privateConstructorUsedError;

  /// Longest workout streak (consecutive days)
  int get longestStreak => throw _privateConstructorUsedError;

  /// Current streak at year end
  int get endOfYearStreak => throw _privateConstructorUsedError;

  /// Most active month
  String get mostActiveMonth => throw _privateConstructorUsedError;

  /// Average workouts per week
  double get avgWorkoutsPerWeek => throw _privateConstructorUsedError;

  /// Average workout duration in minutes
  int get avgWorkoutDuration => throw _privateConstructorUsedError;

  /// Most trained day of week (0=Sun, 6=Sat)
  int get favoriteDayOfWeek => throw _privateConstructorUsedError;

  /// Number of different exercises performed
  int get uniqueExercises => throw _privateConstructorUsedError;

  /// Number of achievements unlocked
  int get achievementsUnlocked => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WrappedSummaryCopyWith<WrappedSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WrappedSummaryCopyWith<$Res> {
  factory $WrappedSummaryCopyWith(
          WrappedSummary value, $Res Function(WrappedSummary) then) =
      _$WrappedSummaryCopyWithImpl<$Res, WrappedSummary>;
  @useResult
  $Res call(
      {int totalWorkouts,
      int totalMinutes,
      int totalVolume,
      int totalSets,
      int totalReps,
      int totalPRs,
      int longestStreak,
      int endOfYearStreak,
      String mostActiveMonth,
      double avgWorkoutsPerWeek,
      int avgWorkoutDuration,
      int favoriteDayOfWeek,
      int uniqueExercises,
      int achievementsUnlocked});
}

/// @nodoc
class _$WrappedSummaryCopyWithImpl<$Res, $Val extends WrappedSummary>
    implements $WrappedSummaryCopyWith<$Res> {
  _$WrappedSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalWorkouts = null,
    Object? totalMinutes = null,
    Object? totalVolume = null,
    Object? totalSets = null,
    Object? totalReps = null,
    Object? totalPRs = null,
    Object? longestStreak = null,
    Object? endOfYearStreak = null,
    Object? mostActiveMonth = null,
    Object? avgWorkoutsPerWeek = null,
    Object? avgWorkoutDuration = null,
    Object? favoriteDayOfWeek = null,
    Object? uniqueExercises = null,
    Object? achievementsUnlocked = null,
  }) {
    return _then(_value.copyWith(
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
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
      totalPRs: null == totalPRs
          ? _value.totalPRs
          : totalPRs // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      endOfYearStreak: null == endOfYearStreak
          ? _value.endOfYearStreak
          : endOfYearStreak // ignore: cast_nullable_to_non_nullable
              as int,
      mostActiveMonth: null == mostActiveMonth
          ? _value.mostActiveMonth
          : mostActiveMonth // ignore: cast_nullable_to_non_nullable
              as String,
      avgWorkoutsPerWeek: null == avgWorkoutsPerWeek
          ? _value.avgWorkoutsPerWeek
          : avgWorkoutsPerWeek // ignore: cast_nullable_to_non_nullable
              as double,
      avgWorkoutDuration: null == avgWorkoutDuration
          ? _value.avgWorkoutDuration
          : avgWorkoutDuration // ignore: cast_nullable_to_non_nullable
              as int,
      favoriteDayOfWeek: null == favoriteDayOfWeek
          ? _value.favoriteDayOfWeek
          : favoriteDayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      uniqueExercises: null == uniqueExercises
          ? _value.uniqueExercises
          : uniqueExercises // ignore: cast_nullable_to_non_nullable
              as int,
      achievementsUnlocked: null == achievementsUnlocked
          ? _value.achievementsUnlocked
          : achievementsUnlocked // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WrappedSummaryImplCopyWith<$Res>
    implements $WrappedSummaryCopyWith<$Res> {
  factory _$$WrappedSummaryImplCopyWith(_$WrappedSummaryImpl value,
          $Res Function(_$WrappedSummaryImpl) then) =
      __$$WrappedSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalWorkouts,
      int totalMinutes,
      int totalVolume,
      int totalSets,
      int totalReps,
      int totalPRs,
      int longestStreak,
      int endOfYearStreak,
      String mostActiveMonth,
      double avgWorkoutsPerWeek,
      int avgWorkoutDuration,
      int favoriteDayOfWeek,
      int uniqueExercises,
      int achievementsUnlocked});
}

/// @nodoc
class __$$WrappedSummaryImplCopyWithImpl<$Res>
    extends _$WrappedSummaryCopyWithImpl<$Res, _$WrappedSummaryImpl>
    implements _$$WrappedSummaryImplCopyWith<$Res> {
  __$$WrappedSummaryImplCopyWithImpl(
      _$WrappedSummaryImpl _value, $Res Function(_$WrappedSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalWorkouts = null,
    Object? totalMinutes = null,
    Object? totalVolume = null,
    Object? totalSets = null,
    Object? totalReps = null,
    Object? totalPRs = null,
    Object? longestStreak = null,
    Object? endOfYearStreak = null,
    Object? mostActiveMonth = null,
    Object? avgWorkoutsPerWeek = null,
    Object? avgWorkoutDuration = null,
    Object? favoriteDayOfWeek = null,
    Object? uniqueExercises = null,
    Object? achievementsUnlocked = null,
  }) {
    return _then(_$WrappedSummaryImpl(
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
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
      totalPRs: null == totalPRs
          ? _value.totalPRs
          : totalPRs // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      endOfYearStreak: null == endOfYearStreak
          ? _value.endOfYearStreak
          : endOfYearStreak // ignore: cast_nullable_to_non_nullable
              as int,
      mostActiveMonth: null == mostActiveMonth
          ? _value.mostActiveMonth
          : mostActiveMonth // ignore: cast_nullable_to_non_nullable
              as String,
      avgWorkoutsPerWeek: null == avgWorkoutsPerWeek
          ? _value.avgWorkoutsPerWeek
          : avgWorkoutsPerWeek // ignore: cast_nullable_to_non_nullable
              as double,
      avgWorkoutDuration: null == avgWorkoutDuration
          ? _value.avgWorkoutDuration
          : avgWorkoutDuration // ignore: cast_nullable_to_non_nullable
              as int,
      favoriteDayOfWeek: null == favoriteDayOfWeek
          ? _value.favoriteDayOfWeek
          : favoriteDayOfWeek // ignore: cast_nullable_to_non_nullable
              as int,
      uniqueExercises: null == uniqueExercises
          ? _value.uniqueExercises
          : uniqueExercises // ignore: cast_nullable_to_non_nullable
              as int,
      achievementsUnlocked: null == achievementsUnlocked
          ? _value.achievementsUnlocked
          : achievementsUnlocked // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WrappedSummaryImpl implements _WrappedSummary {
  const _$WrappedSummaryImpl(
      {required this.totalWorkouts,
      required this.totalMinutes,
      required this.totalVolume,
      required this.totalSets,
      required this.totalReps,
      required this.totalPRs,
      required this.longestStreak,
      required this.endOfYearStreak,
      required this.mostActiveMonth,
      required this.avgWorkoutsPerWeek,
      required this.avgWorkoutDuration,
      required this.favoriteDayOfWeek,
      required this.uniqueExercises,
      required this.achievementsUnlocked});

  factory _$WrappedSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$WrappedSummaryImplFromJson(json);

  /// Total number of workouts completed
  @override
  final int totalWorkouts;

  /// Total training time in minutes
  @override
  final int totalMinutes;

  /// Total volume lifted in kg
  @override
  final int totalVolume;

  /// Total sets completed
  @override
  final int totalSets;

  /// Total reps completed
  @override
  final int totalReps;

  /// Number of PRs achieved
  @override
  final int totalPRs;

  /// Longest workout streak (consecutive days)
  @override
  final int longestStreak;

  /// Current streak at year end
  @override
  final int endOfYearStreak;

  /// Most active month
  @override
  final String mostActiveMonth;

  /// Average workouts per week
  @override
  final double avgWorkoutsPerWeek;

  /// Average workout duration in minutes
  @override
  final int avgWorkoutDuration;

  /// Most trained day of week (0=Sun, 6=Sat)
  @override
  final int favoriteDayOfWeek;

  /// Number of different exercises performed
  @override
  final int uniqueExercises;

  /// Number of achievements unlocked
  @override
  final int achievementsUnlocked;

  @override
  String toString() {
    return 'WrappedSummary(totalWorkouts: $totalWorkouts, totalMinutes: $totalMinutes, totalVolume: $totalVolume, totalSets: $totalSets, totalReps: $totalReps, totalPRs: $totalPRs, longestStreak: $longestStreak, endOfYearStreak: $endOfYearStreak, mostActiveMonth: $mostActiveMonth, avgWorkoutsPerWeek: $avgWorkoutsPerWeek, avgWorkoutDuration: $avgWorkoutDuration, favoriteDayOfWeek: $favoriteDayOfWeek, uniqueExercises: $uniqueExercises, achievementsUnlocked: $achievementsUnlocked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WrappedSummaryImpl &&
            (identical(other.totalWorkouts, totalWorkouts) ||
                other.totalWorkouts == totalWorkouts) &&
            (identical(other.totalMinutes, totalMinutes) ||
                other.totalMinutes == totalMinutes) &&
            (identical(other.totalVolume, totalVolume) ||
                other.totalVolume == totalVolume) &&
            (identical(other.totalSets, totalSets) ||
                other.totalSets == totalSets) &&
            (identical(other.totalReps, totalReps) ||
                other.totalReps == totalReps) &&
            (identical(other.totalPRs, totalPRs) ||
                other.totalPRs == totalPRs) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.endOfYearStreak, endOfYearStreak) ||
                other.endOfYearStreak == endOfYearStreak) &&
            (identical(other.mostActiveMonth, mostActiveMonth) ||
                other.mostActiveMonth == mostActiveMonth) &&
            (identical(other.avgWorkoutsPerWeek, avgWorkoutsPerWeek) ||
                other.avgWorkoutsPerWeek == avgWorkoutsPerWeek) &&
            (identical(other.avgWorkoutDuration, avgWorkoutDuration) ||
                other.avgWorkoutDuration == avgWorkoutDuration) &&
            (identical(other.favoriteDayOfWeek, favoriteDayOfWeek) ||
                other.favoriteDayOfWeek == favoriteDayOfWeek) &&
            (identical(other.uniqueExercises, uniqueExercises) ||
                other.uniqueExercises == uniqueExercises) &&
            (identical(other.achievementsUnlocked, achievementsUnlocked) ||
                other.achievementsUnlocked == achievementsUnlocked));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalWorkouts,
      totalMinutes,
      totalVolume,
      totalSets,
      totalReps,
      totalPRs,
      longestStreak,
      endOfYearStreak,
      mostActiveMonth,
      avgWorkoutsPerWeek,
      avgWorkoutDuration,
      favoriteDayOfWeek,
      uniqueExercises,
      achievementsUnlocked);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WrappedSummaryImplCopyWith<_$WrappedSummaryImpl> get copyWith =>
      __$$WrappedSummaryImplCopyWithImpl<_$WrappedSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WrappedSummaryImplToJson(
      this,
    );
  }
}

abstract class _WrappedSummary implements WrappedSummary {
  const factory _WrappedSummary(
      {required final int totalWorkouts,
      required final int totalMinutes,
      required final int totalVolume,
      required final int totalSets,
      required final int totalReps,
      required final int totalPRs,
      required final int longestStreak,
      required final int endOfYearStreak,
      required final String mostActiveMonth,
      required final double avgWorkoutsPerWeek,
      required final int avgWorkoutDuration,
      required final int favoriteDayOfWeek,
      required final int uniqueExercises,
      required final int achievementsUnlocked}) = _$WrappedSummaryImpl;

  factory _WrappedSummary.fromJson(Map<String, dynamic> json) =
      _$WrappedSummaryImpl.fromJson;

  @override

  /// Total number of workouts completed
  int get totalWorkouts;
  @override

  /// Total training time in minutes
  int get totalMinutes;
  @override

  /// Total volume lifted in kg
  int get totalVolume;
  @override

  /// Total sets completed
  int get totalSets;
  @override

  /// Total reps completed
  int get totalReps;
  @override

  /// Number of PRs achieved
  int get totalPRs;
  @override

  /// Longest workout streak (consecutive days)
  int get longestStreak;
  @override

  /// Current streak at year end
  int get endOfYearStreak;
  @override

  /// Most active month
  String get mostActiveMonth;
  @override

  /// Average workouts per week
  double get avgWorkoutsPerWeek;
  @override

  /// Average workout duration in minutes
  int get avgWorkoutDuration;
  @override

  /// Most trained day of week (0=Sun, 6=Sat)
  int get favoriteDayOfWeek;
  @override

  /// Number of different exercises performed
  int get uniqueExercises;
  @override

  /// Number of achievements unlocked
  int get achievementsUnlocked;
  @override
  @JsonKey(ignore: true)
  _$$WrappedSummaryImplCopyWith<_$WrappedSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TrainingPersonality _$TrainingPersonalityFromJson(Map<String, dynamic> json) {
  return _TrainingPersonality.fromJson(json);
}

/// @nodoc
mixin _$TrainingPersonality {
  /// Personality type identifier
  PersonalityType get type => throw _privateConstructorUsedError;

  /// Title for this personality
  String get title => throw _privateConstructorUsedError;

  /// Description of this personality
  String get description => throw _privateConstructorUsedError;

  /// Emoji representing this personality
  String get emoji => throw _privateConstructorUsedError;

  /// Key traits of this personality
  List<String> get traits => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrainingPersonalityCopyWith<TrainingPersonality> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingPersonalityCopyWith<$Res> {
  factory $TrainingPersonalityCopyWith(
          TrainingPersonality value, $Res Function(TrainingPersonality) then) =
      _$TrainingPersonalityCopyWithImpl<$Res, TrainingPersonality>;
  @useResult
  $Res call(
      {PersonalityType type,
      String title,
      String description,
      String emoji,
      List<String> traits});
}

/// @nodoc
class _$TrainingPersonalityCopyWithImpl<$Res, $Val extends TrainingPersonality>
    implements $TrainingPersonalityCopyWith<$Res> {
  _$TrainingPersonalityCopyWithImpl(this._value, this._then);

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
    Object? emoji = null,
    Object? traits = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PersonalityType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      traits: null == traits
          ? _value.traits
          : traits // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrainingPersonalityImplCopyWith<$Res>
    implements $TrainingPersonalityCopyWith<$Res> {
  factory _$$TrainingPersonalityImplCopyWith(_$TrainingPersonalityImpl value,
          $Res Function(_$TrainingPersonalityImpl) then) =
      __$$TrainingPersonalityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PersonalityType type,
      String title,
      String description,
      String emoji,
      List<String> traits});
}

/// @nodoc
class __$$TrainingPersonalityImplCopyWithImpl<$Res>
    extends _$TrainingPersonalityCopyWithImpl<$Res, _$TrainingPersonalityImpl>
    implements _$$TrainingPersonalityImplCopyWith<$Res> {
  __$$TrainingPersonalityImplCopyWithImpl(_$TrainingPersonalityImpl _value,
      $Res Function(_$TrainingPersonalityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? emoji = null,
    Object? traits = null,
  }) {
    return _then(_$TrainingPersonalityImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PersonalityType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      traits: null == traits
          ? _value._traits
          : traits // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainingPersonalityImpl implements _TrainingPersonality {
  const _$TrainingPersonalityImpl(
      {required this.type,
      required this.title,
      required this.description,
      required this.emoji,
      required final List<String> traits})
      : _traits = traits;

  factory _$TrainingPersonalityImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingPersonalityImplFromJson(json);

  /// Personality type identifier
  @override
  final PersonalityType type;

  /// Title for this personality
  @override
  final String title;

  /// Description of this personality
  @override
  final String description;

  /// Emoji representing this personality
  @override
  final String emoji;

  /// Key traits of this personality
  final List<String> _traits;

  /// Key traits of this personality
  @override
  List<String> get traits {
    if (_traits is EqualUnmodifiableListView) return _traits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_traits);
  }

  @override
  String toString() {
    return 'TrainingPersonality(type: $type, title: $title, description: $description, emoji: $emoji, traits: $traits)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingPersonalityImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            const DeepCollectionEquality().equals(other._traits, _traits));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, type, title, description, emoji,
      const DeepCollectionEquality().hash(_traits));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingPersonalityImplCopyWith<_$TrainingPersonalityImpl> get copyWith =>
      __$$TrainingPersonalityImplCopyWithImpl<_$TrainingPersonalityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingPersonalityImplToJson(
      this,
    );
  }
}

abstract class _TrainingPersonality implements TrainingPersonality {
  const factory _TrainingPersonality(
      {required final PersonalityType type,
      required final String title,
      required final String description,
      required final String emoji,
      required final List<String> traits}) = _$TrainingPersonalityImpl;

  factory _TrainingPersonality.fromJson(Map<String, dynamic> json) =
      _$TrainingPersonalityImpl.fromJson;

  @override

  /// Personality type identifier
  PersonalityType get type;
  @override

  /// Title for this personality
  String get title;
  @override

  /// Description of this personality
  String get description;
  @override

  /// Emoji representing this personality
  String get emoji;
  @override

  /// Key traits of this personality
  List<String> get traits;
  @override
  @JsonKey(ignore: true)
  _$$TrainingPersonalityImplCopyWith<_$TrainingPersonalityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TopExercise _$TopExerciseFromJson(Map<String, dynamic> json) {
  return _TopExercise.fromJson(json);
}

/// @nodoc
mixin _$TopExercise {
  /// Exercise ID
  String get exerciseId => throw _privateConstructorUsedError;

  /// Exercise name
  String get exerciseName => throw _privateConstructorUsedError;

  /// Total sets performed
  int get totalSets => throw _privateConstructorUsedError;

  /// Total reps performed
  int get totalReps => throw _privateConstructorUsedError;

  /// Total volume (kg)
  int get totalVolume => throw _privateConstructorUsedError;

  /// Number of sessions including this exercise
  int get sessionCount => throw _privateConstructorUsedError;

  /// Best estimated 1RM achieved
  double get best1RM => throw _privateConstructorUsedError;

  /// Rank (1 = top)
  int get rank => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TopExerciseCopyWith<TopExercise> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopExerciseCopyWith<$Res> {
  factory $TopExerciseCopyWith(
          TopExercise value, $Res Function(TopExercise) then) =
      _$TopExerciseCopyWithImpl<$Res, TopExercise>;
  @useResult
  $Res call(
      {String exerciseId,
      String exerciseName,
      int totalSets,
      int totalReps,
      int totalVolume,
      int sessionCount,
      double best1RM,
      int rank});
}

/// @nodoc
class _$TopExerciseCopyWithImpl<$Res, $Val extends TopExercise>
    implements $TopExerciseCopyWith<$Res> {
  _$TopExerciseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? totalSets = null,
    Object? totalReps = null,
    Object? totalVolume = null,
    Object? sessionCount = null,
    Object? best1RM = null,
    Object? rank = null,
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
      totalSets: null == totalSets
          ? _value.totalSets
          : totalSets // ignore: cast_nullable_to_non_nullable
              as int,
      totalReps: null == totalReps
          ? _value.totalReps
          : totalReps // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume: null == totalVolume
          ? _value.totalVolume
          : totalVolume // ignore: cast_nullable_to_non_nullable
              as int,
      sessionCount: null == sessionCount
          ? _value.sessionCount
          : sessionCount // ignore: cast_nullable_to_non_nullable
              as int,
      best1RM: null == best1RM
          ? _value.best1RM
          : best1RM // ignore: cast_nullable_to_non_nullable
              as double,
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TopExerciseImplCopyWith<$Res>
    implements $TopExerciseCopyWith<$Res> {
  factory _$$TopExerciseImplCopyWith(
          _$TopExerciseImpl value, $Res Function(_$TopExerciseImpl) then) =
      __$$TopExerciseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseId,
      String exerciseName,
      int totalSets,
      int totalReps,
      int totalVolume,
      int sessionCount,
      double best1RM,
      int rank});
}

/// @nodoc
class __$$TopExerciseImplCopyWithImpl<$Res>
    extends _$TopExerciseCopyWithImpl<$Res, _$TopExerciseImpl>
    implements _$$TopExerciseImplCopyWith<$Res> {
  __$$TopExerciseImplCopyWithImpl(
      _$TopExerciseImpl _value, $Res Function(_$TopExerciseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? totalSets = null,
    Object? totalReps = null,
    Object? totalVolume = null,
    Object? sessionCount = null,
    Object? best1RM = null,
    Object? rank = null,
  }) {
    return _then(_$TopExerciseImpl(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      totalSets: null == totalSets
          ? _value.totalSets
          : totalSets // ignore: cast_nullable_to_non_nullable
              as int,
      totalReps: null == totalReps
          ? _value.totalReps
          : totalReps // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume: null == totalVolume
          ? _value.totalVolume
          : totalVolume // ignore: cast_nullable_to_non_nullable
              as int,
      sessionCount: null == sessionCount
          ? _value.sessionCount
          : sessionCount // ignore: cast_nullable_to_non_nullable
              as int,
      best1RM: null == best1RM
          ? _value.best1RM
          : best1RM // ignore: cast_nullable_to_non_nullable
              as double,
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TopExerciseImpl implements _TopExercise {
  const _$TopExerciseImpl(
      {required this.exerciseId,
      required this.exerciseName,
      required this.totalSets,
      required this.totalReps,
      required this.totalVolume,
      required this.sessionCount,
      required this.best1RM,
      required this.rank});

  factory _$TopExerciseImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopExerciseImplFromJson(json);

  /// Exercise ID
  @override
  final String exerciseId;

  /// Exercise name
  @override
  final String exerciseName;

  /// Total sets performed
  @override
  final int totalSets;

  /// Total reps performed
  @override
  final int totalReps;

  /// Total volume (kg)
  @override
  final int totalVolume;

  /// Number of sessions including this exercise
  @override
  final int sessionCount;

  /// Best estimated 1RM achieved
  @override
  final double best1RM;

  /// Rank (1 = top)
  @override
  final int rank;

  @override
  String toString() {
    return 'TopExercise(exerciseId: $exerciseId, exerciseName: $exerciseName, totalSets: $totalSets, totalReps: $totalReps, totalVolume: $totalVolume, sessionCount: $sessionCount, best1RM: $best1RM, rank: $rank)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopExerciseImpl &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.totalSets, totalSets) ||
                other.totalSets == totalSets) &&
            (identical(other.totalReps, totalReps) ||
                other.totalReps == totalReps) &&
            (identical(other.totalVolume, totalVolume) ||
                other.totalVolume == totalVolume) &&
            (identical(other.sessionCount, sessionCount) ||
                other.sessionCount == sessionCount) &&
            (identical(other.best1RM, best1RM) || other.best1RM == best1RM) &&
            (identical(other.rank, rank) || other.rank == rank));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, exerciseId, exerciseName,
      totalSets, totalReps, totalVolume, sessionCount, best1RM, rank);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TopExerciseImplCopyWith<_$TopExerciseImpl> get copyWith =>
      __$$TopExerciseImplCopyWithImpl<_$TopExerciseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TopExerciseImplToJson(
      this,
    );
  }
}

abstract class _TopExercise implements TopExercise {
  const factory _TopExercise(
      {required final String exerciseId,
      required final String exerciseName,
      required final int totalSets,
      required final int totalReps,
      required final int totalVolume,
      required final int sessionCount,
      required final double best1RM,
      required final int rank}) = _$TopExerciseImpl;

  factory _TopExercise.fromJson(Map<String, dynamic> json) =
      _$TopExerciseImpl.fromJson;

  @override

  /// Exercise ID
  String get exerciseId;
  @override

  /// Exercise name
  String get exerciseName;
  @override

  /// Total sets performed
  int get totalSets;
  @override

  /// Total reps performed
  int get totalReps;
  @override

  /// Total volume (kg)
  int get totalVolume;
  @override

  /// Number of sessions including this exercise
  int get sessionCount;
  @override

  /// Best estimated 1RM achieved
  double get best1RM;
  @override

  /// Rank (1 = top)
  int get rank;
  @override
  @JsonKey(ignore: true)
  _$$TopExerciseImplCopyWith<_$TopExerciseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

YearlyPR _$YearlyPRFromJson(Map<String, dynamic> json) {
  return _YearlyPR.fromJson(json);
}

/// @nodoc
mixin _$YearlyPR {
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

  /// Date achieved
  DateTime get achievedAt => throw _privateConstructorUsedError;

  /// Improvement from start of year (if applicable)
  double? get improvementFromYearStart => throw _privateConstructorUsedError;

  /// Whether this is an all-time PR
  bool get isAllTimePR => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $YearlyPRCopyWith<YearlyPR> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YearlyPRCopyWith<$Res> {
  factory $YearlyPRCopyWith(YearlyPR value, $Res Function(YearlyPR) then) =
      _$YearlyPRCopyWithImpl<$Res, YearlyPR>;
  @useResult
  $Res call(
      {String exerciseId,
      String exerciseName,
      double weight,
      int reps,
      double estimated1RM,
      DateTime achievedAt,
      double? improvementFromYearStart,
      bool isAllTimePR});
}

/// @nodoc
class _$YearlyPRCopyWithImpl<$Res, $Val extends YearlyPR>
    implements $YearlyPRCopyWith<$Res> {
  _$YearlyPRCopyWithImpl(this._value, this._then);

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
    Object? achievedAt = null,
    Object? improvementFromYearStart = freezed,
    Object? isAllTimePR = null,
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
      achievedAt: null == achievedAt
          ? _value.achievedAt
          : achievedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      improvementFromYearStart: freezed == improvementFromYearStart
          ? _value.improvementFromYearStart
          : improvementFromYearStart // ignore: cast_nullable_to_non_nullable
              as double?,
      isAllTimePR: null == isAllTimePR
          ? _value.isAllTimePR
          : isAllTimePR // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$YearlyPRImplCopyWith<$Res>
    implements $YearlyPRCopyWith<$Res> {
  factory _$$YearlyPRImplCopyWith(
          _$YearlyPRImpl value, $Res Function(_$YearlyPRImpl) then) =
      __$$YearlyPRImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseId,
      String exerciseName,
      double weight,
      int reps,
      double estimated1RM,
      DateTime achievedAt,
      double? improvementFromYearStart,
      bool isAllTimePR});
}

/// @nodoc
class __$$YearlyPRImplCopyWithImpl<$Res>
    extends _$YearlyPRCopyWithImpl<$Res, _$YearlyPRImpl>
    implements _$$YearlyPRImplCopyWith<$Res> {
  __$$YearlyPRImplCopyWithImpl(
      _$YearlyPRImpl _value, $Res Function(_$YearlyPRImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? weight = null,
    Object? reps = null,
    Object? estimated1RM = null,
    Object? achievedAt = null,
    Object? improvementFromYearStart = freezed,
    Object? isAllTimePR = null,
  }) {
    return _then(_$YearlyPRImpl(
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
      achievedAt: null == achievedAt
          ? _value.achievedAt
          : achievedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      improvementFromYearStart: freezed == improvementFromYearStart
          ? _value.improvementFromYearStart
          : improvementFromYearStart // ignore: cast_nullable_to_non_nullable
              as double?,
      isAllTimePR: null == isAllTimePR
          ? _value.isAllTimePR
          : isAllTimePR // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$YearlyPRImpl implements _YearlyPR {
  const _$YearlyPRImpl(
      {required this.exerciseId,
      required this.exerciseName,
      required this.weight,
      required this.reps,
      required this.estimated1RM,
      required this.achievedAt,
      this.improvementFromYearStart,
      this.isAllTimePR = true});

  factory _$YearlyPRImpl.fromJson(Map<String, dynamic> json) =>
      _$$YearlyPRImplFromJson(json);

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

  /// Date achieved
  @override
  final DateTime achievedAt;

  /// Improvement from start of year (if applicable)
  @override
  final double? improvementFromYearStart;

  /// Whether this is an all-time PR
  @override
  @JsonKey()
  final bool isAllTimePR;

  @override
  String toString() {
    return 'YearlyPR(exerciseId: $exerciseId, exerciseName: $exerciseName, weight: $weight, reps: $reps, estimated1RM: $estimated1RM, achievedAt: $achievedAt, improvementFromYearStart: $improvementFromYearStart, isAllTimePR: $isAllTimePR)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YearlyPRImpl &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.estimated1RM, estimated1RM) ||
                other.estimated1RM == estimated1RM) &&
            (identical(other.achievedAt, achievedAt) ||
                other.achievedAt == achievedAt) &&
            (identical(
                    other.improvementFromYearStart, improvementFromYearStart) ||
                other.improvementFromYearStart == improvementFromYearStart) &&
            (identical(other.isAllTimePR, isAllTimePR) ||
                other.isAllTimePR == isAllTimePR));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, exerciseId, exerciseName, weight,
      reps, estimated1RM, achievedAt, improvementFromYearStart, isAllTimePR);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$YearlyPRImplCopyWith<_$YearlyPRImpl> get copyWith =>
      __$$YearlyPRImplCopyWithImpl<_$YearlyPRImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$YearlyPRImplToJson(
      this,
    );
  }
}

abstract class _YearlyPR implements YearlyPR {
  const factory _YearlyPR(
      {required final String exerciseId,
      required final String exerciseName,
      required final double weight,
      required final int reps,
      required final double estimated1RM,
      required final DateTime achievedAt,
      final double? improvementFromYearStart,
      final bool isAllTimePR}) = _$YearlyPRImpl;

  factory _YearlyPR.fromJson(Map<String, dynamic> json) =
      _$YearlyPRImpl.fromJson;

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

  /// Date achieved
  DateTime get achievedAt;
  @override

  /// Improvement from start of year (if applicable)
  double? get improvementFromYearStart;
  @override

  /// Whether this is an all-time PR
  bool get isAllTimePR;
  @override
  @JsonKey(ignore: true)
  _$$YearlyPRImplCopyWith<_$YearlyPRImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MonthlyStats _$MonthlyStatsFromJson(Map<String, dynamic> json) {
  return _MonthlyStats.fromJson(json);
}

/// @nodoc
mixin _$MonthlyStats {
  /// Month (1-12)
  int get month => throw _privateConstructorUsedError;

  /// Number of workouts
  int get workoutCount => throw _privateConstructorUsedError;

  /// Total volume in kg
  int get totalVolume => throw _privateConstructorUsedError;

  /// Total duration in minutes
  int get totalMinutes => throw _privateConstructorUsedError;

  /// PRs achieved this month
  int get prsAchieved => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MonthlyStatsCopyWith<MonthlyStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyStatsCopyWith<$Res> {
  factory $MonthlyStatsCopyWith(
          MonthlyStats value, $Res Function(MonthlyStats) then) =
      _$MonthlyStatsCopyWithImpl<$Res, MonthlyStats>;
  @useResult
  $Res call(
      {int month,
      int workoutCount,
      int totalVolume,
      int totalMinutes,
      int prsAchieved});
}

/// @nodoc
class _$MonthlyStatsCopyWithImpl<$Res, $Val extends MonthlyStats>
    implements $MonthlyStatsCopyWith<$Res> {
  _$MonthlyStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? workoutCount = null,
    Object? totalVolume = null,
    Object? totalMinutes = null,
    Object? prsAchieved = null,
  }) {
    return _then(_value.copyWith(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      workoutCount: null == workoutCount
          ? _value.workoutCount
          : workoutCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume: null == totalVolume
          ? _value.totalVolume
          : totalVolume // ignore: cast_nullable_to_non_nullable
              as int,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      prsAchieved: null == prsAchieved
          ? _value.prsAchieved
          : prsAchieved // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonthlyStatsImplCopyWith<$Res>
    implements $MonthlyStatsCopyWith<$Res> {
  factory _$$MonthlyStatsImplCopyWith(
          _$MonthlyStatsImpl value, $Res Function(_$MonthlyStatsImpl) then) =
      __$$MonthlyStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int month,
      int workoutCount,
      int totalVolume,
      int totalMinutes,
      int prsAchieved});
}

/// @nodoc
class __$$MonthlyStatsImplCopyWithImpl<$Res>
    extends _$MonthlyStatsCopyWithImpl<$Res, _$MonthlyStatsImpl>
    implements _$$MonthlyStatsImplCopyWith<$Res> {
  __$$MonthlyStatsImplCopyWithImpl(
      _$MonthlyStatsImpl _value, $Res Function(_$MonthlyStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
    Object? workoutCount = null,
    Object? totalVolume = null,
    Object? totalMinutes = null,
    Object? prsAchieved = null,
  }) {
    return _then(_$MonthlyStatsImpl(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      workoutCount: null == workoutCount
          ? _value.workoutCount
          : workoutCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalVolume: null == totalVolume
          ? _value.totalVolume
          : totalVolume // ignore: cast_nullable_to_non_nullable
              as int,
      totalMinutes: null == totalMinutes
          ? _value.totalMinutes
          : totalMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      prsAchieved: null == prsAchieved
          ? _value.prsAchieved
          : prsAchieved // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthlyStatsImpl implements _MonthlyStats {
  const _$MonthlyStatsImpl(
      {required this.month,
      required this.workoutCount,
      required this.totalVolume,
      required this.totalMinutes,
      required this.prsAchieved});

  factory _$MonthlyStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthlyStatsImplFromJson(json);

  /// Month (1-12)
  @override
  final int month;

  /// Number of workouts
  @override
  final int workoutCount;

  /// Total volume in kg
  @override
  final int totalVolume;

  /// Total duration in minutes
  @override
  final int totalMinutes;

  /// PRs achieved this month
  @override
  final int prsAchieved;

  @override
  String toString() {
    return 'MonthlyStats(month: $month, workoutCount: $workoutCount, totalVolume: $totalVolume, totalMinutes: $totalMinutes, prsAchieved: $prsAchieved)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyStatsImpl &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.workoutCount, workoutCount) ||
                other.workoutCount == workoutCount) &&
            (identical(other.totalVolume, totalVolume) ||
                other.totalVolume == totalVolume) &&
            (identical(other.totalMinutes, totalMinutes) ||
                other.totalMinutes == totalMinutes) &&
            (identical(other.prsAchieved, prsAchieved) ||
                other.prsAchieved == prsAchieved));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, month, workoutCount, totalVolume, totalMinutes, prsAchieved);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyStatsImplCopyWith<_$MonthlyStatsImpl> get copyWith =>
      __$$MonthlyStatsImplCopyWithImpl<_$MonthlyStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlyStatsImplToJson(
      this,
    );
  }
}

abstract class _MonthlyStats implements MonthlyStats {
  const factory _MonthlyStats(
      {required final int month,
      required final int workoutCount,
      required final int totalVolume,
      required final int totalMinutes,
      required final int prsAchieved}) = _$MonthlyStatsImpl;

  factory _MonthlyStats.fromJson(Map<String, dynamic> json) =
      _$MonthlyStatsImpl.fromJson;

  @override

  /// Month (1-12)
  int get month;
  @override

  /// Number of workouts
  int get workoutCount;
  @override

  /// Total volume in kg
  int get totalVolume;
  @override

  /// Total duration in minutes
  int get totalMinutes;
  @override

  /// PRs achieved this month
  int get prsAchieved;
  @override
  @JsonKey(ignore: true)
  _$$MonthlyStatsImplCopyWith<_$MonthlyStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

YearlyMilestone _$YearlyMilestoneFromJson(Map<String, dynamic> json) {
  return _YearlyMilestone.fromJson(json);
}

/// @nodoc
mixin _$YearlyMilestone {
  /// Milestone type
  MilestoneType get type => throw _privateConstructorUsedError;

  /// Title of the milestone
  String get title => throw _privateConstructorUsedError;

  /// Description
  String get description => throw _privateConstructorUsedError;

  /// Date achieved
  DateTime get achievedAt => throw _privateConstructorUsedError;

  /// Associated value (e.g., weight, workout count)
  double get value => throw _privateConstructorUsedError;

  /// Unit for the value
  String get unit => throw _privateConstructorUsedError;

  /// Emoji for this milestone
  String get emoji => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $YearlyMilestoneCopyWith<YearlyMilestone> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YearlyMilestoneCopyWith<$Res> {
  factory $YearlyMilestoneCopyWith(
          YearlyMilestone value, $Res Function(YearlyMilestone) then) =
      _$YearlyMilestoneCopyWithImpl<$Res, YearlyMilestone>;
  @useResult
  $Res call(
      {MilestoneType type,
      String title,
      String description,
      DateTime achievedAt,
      double value,
      String unit,
      String emoji});
}

/// @nodoc
class _$YearlyMilestoneCopyWithImpl<$Res, $Val extends YearlyMilestone>
    implements $YearlyMilestoneCopyWith<$Res> {
  _$YearlyMilestoneCopyWithImpl(this._value, this._then);

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
    Object? achievedAt = null,
    Object? value = null,
    Object? unit = null,
    Object? emoji = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MilestoneType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      achievedAt: null == achievedAt
          ? _value.achievedAt
          : achievedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$YearlyMilestoneImplCopyWith<$Res>
    implements $YearlyMilestoneCopyWith<$Res> {
  factory _$$YearlyMilestoneImplCopyWith(_$YearlyMilestoneImpl value,
          $Res Function(_$YearlyMilestoneImpl) then) =
      __$$YearlyMilestoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {MilestoneType type,
      String title,
      String description,
      DateTime achievedAt,
      double value,
      String unit,
      String emoji});
}

/// @nodoc
class __$$YearlyMilestoneImplCopyWithImpl<$Res>
    extends _$YearlyMilestoneCopyWithImpl<$Res, _$YearlyMilestoneImpl>
    implements _$$YearlyMilestoneImplCopyWith<$Res> {
  __$$YearlyMilestoneImplCopyWithImpl(
      _$YearlyMilestoneImpl _value, $Res Function(_$YearlyMilestoneImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? title = null,
    Object? description = null,
    Object? achievedAt = null,
    Object? value = null,
    Object? unit = null,
    Object? emoji = null,
  }) {
    return _then(_$YearlyMilestoneImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MilestoneType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      achievedAt: null == achievedAt
          ? _value.achievedAt
          : achievedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$YearlyMilestoneImpl implements _YearlyMilestone {
  const _$YearlyMilestoneImpl(
      {required this.type,
      required this.title,
      required this.description,
      required this.achievedAt,
      required this.value,
      required this.unit,
      required this.emoji});

  factory _$YearlyMilestoneImpl.fromJson(Map<String, dynamic> json) =>
      _$$YearlyMilestoneImplFromJson(json);

  /// Milestone type
  @override
  final MilestoneType type;

  /// Title of the milestone
  @override
  final String title;

  /// Description
  @override
  final String description;

  /// Date achieved
  @override
  final DateTime achievedAt;

  /// Associated value (e.g., weight, workout count)
  @override
  final double value;

  /// Unit for the value
  @override
  final String unit;

  /// Emoji for this milestone
  @override
  final String emoji;

  @override
  String toString() {
    return 'YearlyMilestone(type: $type, title: $title, description: $description, achievedAt: $achievedAt, value: $value, unit: $unit, emoji: $emoji)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YearlyMilestoneImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.achievedAt, achievedAt) ||
                other.achievedAt == achievedAt) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.emoji, emoji) || other.emoji == emoji));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, type, title, description, achievedAt, value, unit, emoji);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$YearlyMilestoneImplCopyWith<_$YearlyMilestoneImpl> get copyWith =>
      __$$YearlyMilestoneImplCopyWithImpl<_$YearlyMilestoneImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$YearlyMilestoneImplToJson(
      this,
    );
  }
}

abstract class _YearlyMilestone implements YearlyMilestone {
  const factory _YearlyMilestone(
      {required final MilestoneType type,
      required final String title,
      required final String description,
      required final DateTime achievedAt,
      required final double value,
      required final String unit,
      required final String emoji}) = _$YearlyMilestoneImpl;

  factory _YearlyMilestone.fromJson(Map<String, dynamic> json) =
      _$YearlyMilestoneImpl.fromJson;

  @override

  /// Milestone type
  MilestoneType get type;
  @override

  /// Title of the milestone
  String get title;
  @override

  /// Description
  String get description;
  @override

  /// Date achieved
  DateTime get achievedAt;
  @override

  /// Associated value (e.g., weight, workout count)
  double get value;
  @override

  /// Unit for the value
  String get unit;
  @override

  /// Emoji for this milestone
  String get emoji;
  @override
  @JsonKey(ignore: true)
  _$$YearlyMilestoneImplCopyWith<_$YearlyMilestoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WrappedFunFact _$WrappedFunFactFromJson(Map<String, dynamic> json) {
  return _WrappedFunFact.fromJson(json);
}

/// @nodoc
mixin _$WrappedFunFact {
  /// Title of the fun fact
  String get title => throw _privateConstructorUsedError;

  /// The actual fact/insight
  String get fact => throw _privateConstructorUsedError;

  /// Emoji for this fact
  String get emoji => throw _privateConstructorUsedError;

  /// Category of this fact
  FunFactCategory get category => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WrappedFunFactCopyWith<WrappedFunFact> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WrappedFunFactCopyWith<$Res> {
  factory $WrappedFunFactCopyWith(
          WrappedFunFact value, $Res Function(WrappedFunFact) then) =
      _$WrappedFunFactCopyWithImpl<$Res, WrappedFunFact>;
  @useResult
  $Res call(
      {String title, String fact, String emoji, FunFactCategory category});
}

/// @nodoc
class _$WrappedFunFactCopyWithImpl<$Res, $Val extends WrappedFunFact>
    implements $WrappedFunFactCopyWith<$Res> {
  _$WrappedFunFactCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? fact = null,
    Object? emoji = null,
    Object? category = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      fact: null == fact
          ? _value.fact
          : fact // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as FunFactCategory,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WrappedFunFactImplCopyWith<$Res>
    implements $WrappedFunFactCopyWith<$Res> {
  factory _$$WrappedFunFactImplCopyWith(_$WrappedFunFactImpl value,
          $Res Function(_$WrappedFunFactImpl) then) =
      __$$WrappedFunFactImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title, String fact, String emoji, FunFactCategory category});
}

/// @nodoc
class __$$WrappedFunFactImplCopyWithImpl<$Res>
    extends _$WrappedFunFactCopyWithImpl<$Res, _$WrappedFunFactImpl>
    implements _$$WrappedFunFactImplCopyWith<$Res> {
  __$$WrappedFunFactImplCopyWithImpl(
      _$WrappedFunFactImpl _value, $Res Function(_$WrappedFunFactImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? fact = null,
    Object? emoji = null,
    Object? category = null,
  }) {
    return _then(_$WrappedFunFactImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      fact: null == fact
          ? _value.fact
          : fact // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as FunFactCategory,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WrappedFunFactImpl implements _WrappedFunFact {
  const _$WrappedFunFactImpl(
      {required this.title,
      required this.fact,
      required this.emoji,
      required this.category});

  factory _$WrappedFunFactImpl.fromJson(Map<String, dynamic> json) =>
      _$$WrappedFunFactImplFromJson(json);

  /// Title of the fun fact
  @override
  final String title;

  /// The actual fact/insight
  @override
  final String fact;

  /// Emoji for this fact
  @override
  final String emoji;

  /// Category of this fact
  @override
  final FunFactCategory category;

  @override
  String toString() {
    return 'WrappedFunFact(title: $title, fact: $fact, emoji: $emoji, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WrappedFunFactImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.fact, fact) || other.fact == fact) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, title, fact, emoji, category);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WrappedFunFactImplCopyWith<_$WrappedFunFactImpl> get copyWith =>
      __$$WrappedFunFactImplCopyWithImpl<_$WrappedFunFactImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WrappedFunFactImplToJson(
      this,
    );
  }
}

abstract class _WrappedFunFact implements WrappedFunFact {
  const factory _WrappedFunFact(
      {required final String title,
      required final String fact,
      required final String emoji,
      required final FunFactCategory category}) = _$WrappedFunFactImpl;

  factory _WrappedFunFact.fromJson(Map<String, dynamic> json) =
      _$WrappedFunFactImpl.fromJson;

  @override

  /// Title of the fun fact
  String get title;
  @override

  /// The actual fact/insight
  String get fact;
  @override

  /// Emoji for this fact
  String get emoji;
  @override

  /// Category of this fact
  FunFactCategory get category;
  @override
  @JsonKey(ignore: true)
  _$$WrappedFunFactImplCopyWith<_$WrappedFunFactImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

YearOverYearComparison _$YearOverYearComparisonFromJson(
    Map<String, dynamic> json) {
  return _YearOverYearComparison.fromJson(json);
}

/// @nodoc
mixin _$YearOverYearComparison {
  /// Workout count change percentage
  double get workoutCountChange => throw _privateConstructorUsedError;

  /// Volume change percentage
  double get volumeChange => throw _privateConstructorUsedError;

  /// Average 1RM change percentage
  double get strengthChange => throw _privateConstructorUsedError;

  /// Consistency change (workouts per week)
  double get consistencyChange => throw _privateConstructorUsedError;

  /// Summary text
  String get summaryText => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $YearOverYearComparisonCopyWith<YearOverYearComparison> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YearOverYearComparisonCopyWith<$Res> {
  factory $YearOverYearComparisonCopyWith(YearOverYearComparison value,
          $Res Function(YearOverYearComparison) then) =
      _$YearOverYearComparisonCopyWithImpl<$Res, YearOverYearComparison>;
  @useResult
  $Res call(
      {double workoutCountChange,
      double volumeChange,
      double strengthChange,
      double consistencyChange,
      String summaryText});
}

/// @nodoc
class _$YearOverYearComparisonCopyWithImpl<$Res,
        $Val extends YearOverYearComparison>
    implements $YearOverYearComparisonCopyWith<$Res> {
  _$YearOverYearComparisonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workoutCountChange = null,
    Object? volumeChange = null,
    Object? strengthChange = null,
    Object? consistencyChange = null,
    Object? summaryText = null,
  }) {
    return _then(_value.copyWith(
      workoutCountChange: null == workoutCountChange
          ? _value.workoutCountChange
          : workoutCountChange // ignore: cast_nullable_to_non_nullable
              as double,
      volumeChange: null == volumeChange
          ? _value.volumeChange
          : volumeChange // ignore: cast_nullable_to_non_nullable
              as double,
      strengthChange: null == strengthChange
          ? _value.strengthChange
          : strengthChange // ignore: cast_nullable_to_non_nullable
              as double,
      consistencyChange: null == consistencyChange
          ? _value.consistencyChange
          : consistencyChange // ignore: cast_nullable_to_non_nullable
              as double,
      summaryText: null == summaryText
          ? _value.summaryText
          : summaryText // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$YearOverYearComparisonImplCopyWith<$Res>
    implements $YearOverYearComparisonCopyWith<$Res> {
  factory _$$YearOverYearComparisonImplCopyWith(
          _$YearOverYearComparisonImpl value,
          $Res Function(_$YearOverYearComparisonImpl) then) =
      __$$YearOverYearComparisonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double workoutCountChange,
      double volumeChange,
      double strengthChange,
      double consistencyChange,
      String summaryText});
}

/// @nodoc
class __$$YearOverYearComparisonImplCopyWithImpl<$Res>
    extends _$YearOverYearComparisonCopyWithImpl<$Res,
        _$YearOverYearComparisonImpl>
    implements _$$YearOverYearComparisonImplCopyWith<$Res> {
  __$$YearOverYearComparisonImplCopyWithImpl(
      _$YearOverYearComparisonImpl _value,
      $Res Function(_$YearOverYearComparisonImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workoutCountChange = null,
    Object? volumeChange = null,
    Object? strengthChange = null,
    Object? consistencyChange = null,
    Object? summaryText = null,
  }) {
    return _then(_$YearOverYearComparisonImpl(
      workoutCountChange: null == workoutCountChange
          ? _value.workoutCountChange
          : workoutCountChange // ignore: cast_nullable_to_non_nullable
              as double,
      volumeChange: null == volumeChange
          ? _value.volumeChange
          : volumeChange // ignore: cast_nullable_to_non_nullable
              as double,
      strengthChange: null == strengthChange
          ? _value.strengthChange
          : strengthChange // ignore: cast_nullable_to_non_nullable
              as double,
      consistencyChange: null == consistencyChange
          ? _value.consistencyChange
          : consistencyChange // ignore: cast_nullable_to_non_nullable
              as double,
      summaryText: null == summaryText
          ? _value.summaryText
          : summaryText // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$YearOverYearComparisonImpl implements _YearOverYearComparison {
  const _$YearOverYearComparisonImpl(
      {required this.workoutCountChange,
      required this.volumeChange,
      required this.strengthChange,
      required this.consistencyChange,
      required this.summaryText});

  factory _$YearOverYearComparisonImpl.fromJson(Map<String, dynamic> json) =>
      _$$YearOverYearComparisonImplFromJson(json);

  /// Workout count change percentage
  @override
  final double workoutCountChange;

  /// Volume change percentage
  @override
  final double volumeChange;

  /// Average 1RM change percentage
  @override
  final double strengthChange;

  /// Consistency change (workouts per week)
  @override
  final double consistencyChange;

  /// Summary text
  @override
  final String summaryText;

  @override
  String toString() {
    return 'YearOverYearComparison(workoutCountChange: $workoutCountChange, volumeChange: $volumeChange, strengthChange: $strengthChange, consistencyChange: $consistencyChange, summaryText: $summaryText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YearOverYearComparisonImpl &&
            (identical(other.workoutCountChange, workoutCountChange) ||
                other.workoutCountChange == workoutCountChange) &&
            (identical(other.volumeChange, volumeChange) ||
                other.volumeChange == volumeChange) &&
            (identical(other.strengthChange, strengthChange) ||
                other.strengthChange == strengthChange) &&
            (identical(other.consistencyChange, consistencyChange) ||
                other.consistencyChange == consistencyChange) &&
            (identical(other.summaryText, summaryText) ||
                other.summaryText == summaryText));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, workoutCountChange, volumeChange,
      strengthChange, consistencyChange, summaryText);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$YearOverYearComparisonImplCopyWith<_$YearOverYearComparisonImpl>
      get copyWith => __$$YearOverYearComparisonImplCopyWithImpl<
          _$YearOverYearComparisonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$YearOverYearComparisonImplToJson(
      this,
    );
  }
}

abstract class _YearOverYearComparison implements YearOverYearComparison {
  const factory _YearOverYearComparison(
      {required final double workoutCountChange,
      required final double volumeChange,
      required final double strengthChange,
      required final double consistencyChange,
      required final String summaryText}) = _$YearOverYearComparisonImpl;

  factory _YearOverYearComparison.fromJson(Map<String, dynamic> json) =
      _$YearOverYearComparisonImpl.fromJson;

  @override

  /// Workout count change percentage
  double get workoutCountChange;
  @override

  /// Volume change percentage
  double get volumeChange;
  @override

  /// Average 1RM change percentage
  double get strengthChange;
  @override

  /// Consistency change (workouts per week)
  double get consistencyChange;
  @override

  /// Summary text
  String get summaryText;
  @override
  @JsonKey(ignore: true)
  _$$YearOverYearComparisonImplCopyWith<_$YearOverYearComparisonImpl>
      get copyWith => throw _privateConstructorUsedError;
}
