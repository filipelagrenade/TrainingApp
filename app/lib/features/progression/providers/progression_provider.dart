/// LiftIQ - Progression Provider
///
/// Manages the state for progressive overload features.
/// Fetches weight suggestions, plateau detection, and PR tracking from the API.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../models/progression_suggestion.dart';
import '../models/plateau_info.dart';
import '../models/pr_info.dart';
import '../models/deload.dart';

// ============================================================================
// SUGGESTION PROVIDERS
// ============================================================================

/// Provider for getting a progression suggestion for an exercise.
///
/// Usage:
/// ```dart
/// final suggestion = ref.watch(suggestionProvider('bench-press'));
///
/// suggestion.when(
///   data: (s) => WeightSuggestionWidget(suggestion: s),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
final suggestionProvider =
    FutureProvider.autoDispose.family<ProgressionSuggestion, String>(
  (ref, exerciseId) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.get('/progression/suggest/$exerciseId');
      final data = response.data as Map<String, dynamic>;
      final suggestionJson = data['data'] as Map<String, dynamic>;
      return _parseSuggestion(suggestionJson);
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  },
);

/// Provider for batch suggestions (multiple exercises at once).
///
/// Useful for pre-populating a workout template with suggestions.
final batchSuggestionsProvider = FutureProvider.autoDispose
    .family<Map<String, ProgressionSuggestion>, List<String>>(
  (ref, exerciseIds) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.post('/progression/suggest/batch', data: {
        'exerciseIds': exerciseIds,
      });

      final data = response.data as Map<String, dynamic>;
      final suggestionsJson = data['data'] as Map<String, dynamic>;

      final suggestions = <String, ProgressionSuggestion>{};
      suggestionsJson.forEach((key, value) {
        suggestions[key] = _parseSuggestion(value as Map<String, dynamic>);
      });

      return suggestions;
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  },
);

// ============================================================================
// PLATEAU DETECTION PROVIDERS
// ============================================================================

/// Provider for detecting plateaus on an exercise.
///
/// Usage:
/// ```dart
/// final plateau = ref.watch(plateauProvider('bench-press'));
///
/// if (plateau.value?.isPlateaued == true) {
///   showPlateauAlert(context, plateau.value!);
/// }
/// ```
final plateauProvider = FutureProvider.autoDispose.family<PlateauInfo, String>(
  (ref, exerciseId) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.get('/progression/plateau/$exerciseId');
      final data = response.data as Map<String, dynamic>;
      final plateauJson = data['data'] as Map<String, dynamic>;
      return _parsePlateauInfo(plateauJson);
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  },
);

// ============================================================================
// PR TRACKING PROVIDERS
// ============================================================================

/// Provider for getting PR information for an exercise.
///
/// Usage:
/// ```dart
/// final prInfo = ref.watch(prInfoProvider('bench-press'));
///
/// prInfo.when(
///   data: (pr) => PRBadge(prWeight: pr.prWeight),
///   loading: () => Shimmer(),
///   error: (e, _) => SizedBox.shrink(),
/// );
/// ```
final prInfoProvider = FutureProvider.autoDispose.family<PRInfo, String>(
  (ref, exerciseId) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.get('/progression/pr/$exerciseId');
      final data = response.data as Map<String, dynamic>;
      final prJson = data['data'] as Map<String, dynamic>;
      return _parsePRInfo(prJson, exerciseId);
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  },
);

/// Provider for exercise performance history.
///
/// Returns the last N sessions of performance data for charts.
final performanceHistoryProvider =
    FutureProvider.autoDispose.family<List<PerformanceHistoryEntry>, String>(
  (ref, exerciseId) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.get('/progression/history/$exerciseId', queryParameters: {
        'limit': 10,
      });

      final data = response.data as Map<String, dynamic>;
      final historyList = data['data'] as List<dynamic>;

      return historyList
          .map((json) => _parsePerformanceHistoryEntry(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  },
);

// ============================================================================
// DELOAD PROVIDERS
// ============================================================================

/// Provider for checking if a deload is recommended.
final deloadCheckProvider = FutureProvider.autoDispose<DeloadRecommendation?>((ref) async {
  final api = ref.read(apiClientProvider);

  try {
    final response = await api.get('/progression/deload-check');
    final data = response.data as Map<String, dynamic>;
    final deloadJson = data['data'];

    if (deloadJson == null) return null;
    return _parseDeloadRecommendation(deloadJson as Map<String, dynamic>);
  } on DioException catch (e) {
    final error = ApiClient.getApiException(e);
    throw Exception(error.message);
  }
});

// ============================================================================
// 1RM CALCULATION
// ============================================================================

/// Calculates estimated 1RM using the Epley formula.
///
/// Epley: 1RM = weight × (1 + reps/30)
///
/// This is a simple synchronous calculation, not a provider.
double calculate1RM(double weight, int reps) {
  if (reps == 1) return weight;
  if (reps <= 0) return 0;

  // Epley formula
  return (weight * (1 + reps / 30) * 10).round() / 10;
}

/// Provider that holds the current 1RM calculation inputs.
///
/// Used by the 1RM calculator widget.
final oneRMCalculatorProvider =
    StateNotifierProvider<OneRMCalculatorNotifier, OneRMCalculatorState>(
  (ref) => OneRMCalculatorNotifier(),
);

/// State for the 1RM calculator.
class OneRMCalculatorState {
  final double weight;
  final int reps;
  final double? estimated1RM;

  OneRMCalculatorState({
    this.weight = 0,
    this.reps = 0,
    this.estimated1RM,
  });

  OneRMCalculatorState copyWith({
    double? weight,
    int? reps,
    double? estimated1RM,
  }) {
    return OneRMCalculatorState(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      estimated1RM: estimated1RM ?? this.estimated1RM,
    );
  }
}

/// Notifier for the 1RM calculator.
class OneRMCalculatorNotifier extends StateNotifier<OneRMCalculatorState> {
  OneRMCalculatorNotifier() : super(OneRMCalculatorState());

  void setWeight(double weight) {
    state = state.copyWith(
      weight: weight,
      estimated1RM: state.reps > 0 ? calculate1RM(weight, state.reps) : null,
    );
  }

  void setReps(int reps) {
    state = state.copyWith(
      reps: reps,
      estimated1RM: state.weight > 0 ? calculate1RM(state.weight, reps) : null,
    );
  }

  void reset() {
    state = OneRMCalculatorState();
  }
}

// ============================================================================
// SUGGESTION ACCEPTANCE TRACKING
// ============================================================================

/// Tracks whether user accepted, modified, or dismissed suggestions.
///
/// This data helps improve the algorithm over time.
final suggestionFeedbackProvider =
    StateNotifierProvider<SuggestionFeedbackNotifier, SuggestionFeedbackState>(
  (ref) => SuggestionFeedbackNotifier(),
);

/// Feedback types for suggestions.
enum SuggestionFeedback {
  /// User accepted the suggested weight
  accepted,
  /// User modified the suggestion (went higher or lower)
  modified,
  /// User dismissed/ignored the suggestion
  dismissed,
}

/// State tracking suggestion feedback.
class SuggestionFeedbackState {
  final int totalSuggestions;
  final int acceptedCount;
  final int modifiedCount;
  final int dismissedCount;

  SuggestionFeedbackState({
    this.totalSuggestions = 0,
    this.acceptedCount = 0,
    this.modifiedCount = 0,
    this.dismissedCount = 0,
  });

  double get acceptanceRate =>
      totalSuggestions > 0 ? acceptedCount / totalSuggestions : 0;
}

/// Notifier for tracking suggestion feedback.
class SuggestionFeedbackNotifier extends StateNotifier<SuggestionFeedbackState> {
  SuggestionFeedbackNotifier() : super(SuggestionFeedbackState());

  void recordFeedback(SuggestionFeedback feedback) {
    state = SuggestionFeedbackState(
      totalSuggestions: state.totalSuggestions + 1,
      acceptedCount: state.acceptedCount + (feedback == SuggestionFeedback.accepted ? 1 : 0),
      modifiedCount: state.modifiedCount + (feedback == SuggestionFeedback.modified ? 1 : 0),
      dismissedCount: state.dismissedCount + (feedback == SuggestionFeedback.dismissed ? 1 : 0),
    );
  }
}

// ============================================================================
// API RESPONSE PARSING
// ============================================================================

/// Parses a ProgressionSuggestion from API response.
ProgressionSuggestion _parseSuggestion(Map<String, dynamic> json) {
  final actionStr = json['action'] as String? ?? 'MAINTAIN';
  ProgressionAction action;
  switch (actionStr.toUpperCase()) {
    case 'INCREASE':
      action = ProgressionAction.increase;
      break;
    case 'DELOAD':
      action = ProgressionAction.deload;
      break;
    case 'MAINTAIN':
    default:
      action = ProgressionAction.maintain;
  }

  return ProgressionSuggestion(
    suggestedWeight: (json['suggestedWeight'] as num?)?.toDouble() ?? 0,
    previousWeight: (json['previousWeight'] as num?)?.toDouble() ?? 0,
    action: action,
    reasoning: json['reasoning'] as String? ?? '',
    confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
    wouldBePR: json['wouldBePR'] as bool? ?? false,
    targetReps: json['targetReps'] as int? ?? 8,
    sessionsAtCurrentWeight: json['sessionsAtCurrentWeight'] as int? ?? 0,
  );
}

/// Parses PlateauInfo from API response.
PlateauInfo _parsePlateauInfo(Map<String, dynamic> json) {
  final suggestions = (json['suggestions'] as List<dynamic>?)
          ?.map((s) => s as String)
          .toList() ??
      [];

  return PlateauInfo(
    isPlateaued: json['isPlateaued'] as bool? ?? false,
    sessionsWithoutProgress: json['sessionsWithoutProgress'] as int? ?? 0,
    lastProgressDate: json['lastProgressDate'] != null
        ? DateTime.parse(json['lastProgressDate'] as String)
        : null,
    suggestions: suggestions,
  );
}

/// Parses PRInfo from API response.
PRInfo _parsePRInfo(Map<String, dynamic> json, String exerciseId) {
  final hasPR = json['hasPR'] as bool? ?? false;

  return PRInfo(
    exerciseId: exerciseId,
    prWeight: hasPR ? (json['prWeight'] as num?)?.toDouble() : null,
    estimated1RM: hasPR ? (json['estimated1RM'] as num?)?.toDouble() : null,
    hasPR: hasPR,
    prDate: json['prDate'] != null
        ? DateTime.parse(json['prDate'] as String)
        : null,
    prReps: json['prReps'] as int?,
  );
}

/// Parses PerformanceHistoryEntry from API response.
PerformanceHistoryEntry _parsePerformanceHistoryEntry(Map<String, dynamic> json) {
  final setsJson = json['sets'] as List<dynamic>? ?? [];
  final sets = setsJson.map((s) {
    final setJson = s as Map<String, dynamic>;
    return SetSummary(
      setNumber: setJson['setNumber'] as int,
      weight: (setJson['weight'] as num).toDouble(),
      reps: setJson['reps'] as int,
      rpe: (setJson['rpe'] as num?)?.toDouble(),
    );
  }).toList();

  return PerformanceHistoryEntry(
    sessionId: json['sessionId'] as String,
    date: DateTime.parse(json['date'] as String),
    completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'] as String)
        : null,
    topWeight: (json['topWeight'] as num?)?.toDouble() ?? 0,
    topReps: json['topReps'] as int? ?? 0,
    estimated1RM: (json['estimated1RM'] as num?)?.toDouble() ?? 0,
    sets: sets,
  );
}

/// Parses DeloadRecommendation from API response.
DeloadRecommendation _parseDeloadRecommendation(Map<String, dynamic> json) {
  final deloadTypeStr = json['deloadType'] as String? ?? 'VOLUME_REDUCTION';
  DeloadType deloadType;
  switch (deloadTypeStr.toUpperCase()) {
    case 'INTENSITY_REDUCTION':
      deloadType = DeloadType.intensityReduction;
    case 'ACTIVE_RECOVERY':
      deloadType = DeloadType.activeRecovery;
    default:
      deloadType = DeloadType.volumeReduction;
  }

  final metricsJson = json['metrics'] as Map<String, dynamic>? ?? {};

  return DeloadRecommendation(
    needed: json['needed'] as bool? ?? false,
    reason: json['reason'] as String? ?? '',
    suggestedWeek: json['suggestedWeek'] != null
        ? DateTime.parse(json['suggestedWeek'] as String)
        : DateTime.now(),
    deloadType: deloadType,
    confidence: json['confidence'] as int? ?? 0,
    metrics: DeloadMetrics(
      consecutiveWeeks: metricsJson['consecutiveWeeks'] as int? ?? 0,
      rpeTrend: (metricsJson['rpeTrend'] as num?)?.toDouble() ?? 0,
      decliningRepsSessions: metricsJson['decliningRepsSessions'] as int? ?? 0,
      daysSinceLastDeload: metricsJson['daysSinceLastDeload'] as int?,
      recentWorkoutCount: metricsJson['recentWorkoutCount'] as int? ?? 0,
      plateauExerciseCount: metricsJson['plateauExerciseCount'] as int? ?? 0,
    ),
  );
}

