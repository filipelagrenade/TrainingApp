/// LiftIQ - Weight Recommendation Service
///
/// Generates intelligent weight and rep recommendations using proper
/// double progression logic with a state machine approach.
///
/// ## Architecture
/// ```
/// ┌─────────────────────────────────────────────────────────────────────┐
/// │  WeightRecommendationService                                        │
/// │  ├── AI Path (Groq API with context)                                │
/// │  └── Offline Path (Double Progression State Machine)                │
/// └─────────────────────────────────────────────────────────────────────┘
/// ```
///
/// ## Double Progression State Machine
/// ```
/// BUILDING → READY_TO_PROGRESS → JUST_PROGRESSED → BUILDING
///                                      ↓
///                                 STRUGGLING
///                                      ↓
///                                 DELOADING
/// ```
///
/// ## Key Changes from Previous Implementation
/// 1. Uses progression STATE to understand context (not just raw history)
/// 2. Tracks WHERE user is in progression cycle
/// 3. Exercise-specific rep ranges and increments
/// 4. Phase-aware recommendations (expects rep drop after weight increase)
/// 5. User-customizable progression settings
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/models/user_settings.dart';
import '../../features/workouts/models/weight_recommendation.dart';
import '../../features/workouts/models/exercise_progression_state.dart';
import '../../features/workouts/models/rep_range.dart';
import '../../core/config/app_config.dart';
import 'groq_service.dart';
import 'workout_history_service.dart';

// ============================================================================
// WEIGHT RECOMMENDATION SERVICE
// ============================================================================

/// Service for generating weight and rep recommendations.
///
/// Uses double progression logic with state machine approach.
/// AI path available when online, falls back to offline algorithm.
class WeightRecommendationService {
  final GroqService _groqService;
  final WorkoutHistoryService _historyService;

  WeightRecommendationService({
    required GroqService groqService,
    required WorkoutHistoryService historyService,
  })  : _groqService = groqService,
        _historyService = historyService;

  /// Generates recommendations for a workout template.
  ///
  /// @param templateId The template ID to generate recommendations for
  /// @param templateName Human-readable name for AI context
  /// @param exerciseIds List of exercise IDs in the template
  /// @param exerciseNames Map of exercise ID to name
  /// @param userSettings User's settings (includes progression preferences)
  /// @param progressionStates Current progression state for each exercise
  /// @param programWeek Current program week (affects periodization)
  Future<WorkoutRecommendations> generateRecommendations({
    required String templateId,
    required String templateName,
    required List<String> exerciseIds,
    required Map<String, String> exerciseNames,
    required UserSettings userSettings,
    Map<String, ExerciseProgressionState>? progressionStates,
    int? programWeek,
  }) async {
    debugPrint('WeightRecommendationService: Generating for $templateName');

    // Initialize history service if needed
    await _historyService.initialize();

    // Get workout history for this template
    final history = _getHistoryForTemplate(templateId, exerciseIds);
    final sessionsAnalyzed = _countSessions(history);

    debugPrint('WeightRecommendationService: Found $sessionsAnalyzed sessions');

    // Try AI path first if available and we have history
    if (AppConfig.hasGroqApiKey && sessionsAnalyzed > 0) {
      try {
        final aiRecommendations = await _generateAIRecommendations(
          templateName: templateName,
          history: history,
          exerciseNames: exerciseNames,
          userSettings: userSettings,
          progressionStates: progressionStates,
          programWeek: programWeek,
        );

        if (aiRecommendations != null) {
          debugPrint('WeightRecommendationService: AI recommendations generated');
          return WorkoutRecommendations(
            templateId: templateId,
            exercises: aiRecommendations,
            generatedAt: DateTime.now(),
            sessionsAnalyzed: sessionsAnalyzed,
            programWeek: programWeek,
          );
        }
      } catch (e) {
        debugPrint('WeightRecommendationService: AI failed, falling back: $e');
      }
    }

    // Offline algorithm path - uses double progression state machine
    final offlineRecommendations = _generateOfflineRecommendations(
      history: history,
      exerciseNames: exerciseNames,
      userSettings: userSettings,
      progressionStates: progressionStates ?? {},
    );

    return WorkoutRecommendations(
      templateId: templateId,
      exercises: offlineRecommendations,
      generatedAt: DateTime.now(),
      sessionsAnalyzed: sessionsAnalyzed,
      programWeek: programWeek,
    );
  }

  // ==========================================================================
  // HISTORY EXTRACTION
  // ==========================================================================

  /// Extracts exercise history from completed workouts.
  ///
  /// Returns a map of exercise ID to historical data.
  ///
  /// IMPORTANT: Searches ALL workouts for each exercise, not just template-specific ones.
  /// This ensures progression data from quick workouts carries over to programs and vice versa.
  Map<String, ExerciseHistoryData> _getHistoryForTemplate(
    String templateId,
    List<String> exerciseIds,
  ) {
    final history = <String, ExerciseHistoryData>{};

    for (final exerciseId in exerciseIds) {
      final sessions = <SessionExerciseData>[];

      // Search ALL workouts for this exercise (not just template-specific)
      // This ensures quick workout history carries over to programs
      for (final workout in _historyService.workouts.take(50)) {
        final exercise = workout.exercises
            .where((e) => e.exerciseId == exerciseId)
            .firstOrNull;

        if (exercise != null && exercise.sets.isNotEmpty) {
          final sets = exercise.sets
              .map((s) => HistoricalSetData(
                    weight: s.weight,
                    reps: s.reps,
                    rpe: s.rpe,
                  ))
              .toList();

          // Calculate if all reps were achieved (assuming target was achieved if reps >= 1)
          final allRepsAchieved = sets.every((s) => s.reps >= 1);

          // Calculate average RPE
          final rpeSets = sets.where((s) => s.rpe != null);
          final averageRpe = rpeSets.isNotEmpty
              ? rpeSets.map((s) => s.rpe!).reduce((a, b) => a + b) / rpeSets.length
              : null;

          sessions.add(SessionExerciseData(
            date: workout.completedAt,
            sets: sets,
            allRepsAchieved: allRepsAchieved,
            averageRpe: averageRpe,
          ));
        }

        // Limit to 8 most recent sessions per exercise
        if (sessions.length >= 8) break;
      }

      if (sessions.isNotEmpty) {
        history[exerciseId] = ExerciseHistoryData(
          exerciseId: exerciseId,
          exerciseName: _historyService.workouts
                  .expand((w) => w.exercises)
                  .where((e) => e.exerciseId == exerciseId)
                  .firstOrNull
                  ?.exerciseName ??
              exerciseId,
          sessions: sessions,
        );
      }
    }

    return history;
  }

  /// Counts total sessions analyzed.
  int _countSessions(Map<String, ExerciseHistoryData> history) {
    if (history.isEmpty) return 0;
    return history.values
        .map((h) => h.sessions.length)
        .reduce((a, b) => a > b ? a : b);
  }

  // ==========================================================================
  // AI RECOMMENDATIONS
  // ==========================================================================

  /// Generates recommendations using the Groq AI API.
  Future<Map<String, ExerciseRecommendation>?> _generateAIRecommendations({
    required String templateName,
    required Map<String, ExerciseHistoryData> history,
    required Map<String, String> exerciseNames,
    required UserSettings userSettings,
    Map<String, ExerciseProgressionState>? progressionStates,
    int? programWeek,
  }) async {
    // Build the prompt
    final systemPrompt = _buildSystemPrompt(userSettings);
    final userPrompt = _buildUserPrompt(
      templateName: templateName,
      history: history,
      exerciseNames: exerciseNames,
      userSettings: userSettings,
      progressionStates: progressionStates,
      programWeek: programWeek,
    );

    // Call the AI
    final response = await _groqService.chatWithSystemPrompt(
      systemPrompt: systemPrompt,
      userMessage: userPrompt,
      temperature: 0.3, // Low temperature for deterministic output
      maxTokens: 2048,
    );

    if (response == null) return null;

    // Parse the JSON response
    try {
      return _parseAIResponse(response, exerciseNames);
    } catch (e) {
      debugPrint('WeightRecommendationService: Failed to parse AI response: $e');
      return null;
    }
  }

  /// Builds the system prompt for AI recommendations.
  String _buildSystemPrompt(UserSettings userSettings) {
    final preferences = userSettings.trainingPreferences;
    final goalRange = userSettings.trainingGoal.defaultRepRange;

    return '''
You are LiftIQ's progressive overload algorithm using DOUBLE PROGRESSION.

## Double Progression Rules
1. User builds REPS at current weight until hitting ceiling (${goalRange.ceiling} reps)
2. After ${userSettings.sessionsAtCeilingRequired} sessions at ceiling → INCREASE WEIGHT
3. After weight increase → expect rep drop to floor (${goalRange.floor} reps) - THIS IS NORMAL
4. If reps < floor for 2+ sessions → weight was too aggressive, go back
5. Upper body increment: ${userSettings.upperBodyWeightIncrement}kg
6. Lower body increment: ${userSettings.lowerBodyWeightIncrement}kg

## Progression Phases
- BUILDING: Working up through rep range
- READY_TO_PROGRESS: Hit ceiling for required sessions
- JUST_PROGRESSED: Recently increased weight (expect rep drop!)
- STRUGGLING: Can't hit floor reps at new weight
- DELOADING: Recovery week

## User Settings
- Goal: ${userSettings.trainingGoal.label}
- Target rep range: ${goalRange.floor}-${goalRange.ceiling}
- Progression style: ${preferences.progressionPreference.name}
- Sessions at ceiling required: ${userSettings.sessionsAtCeilingRequired}

## Output Format
Respond ONLY with valid JSON:
{
  "recommendations": [
    {
      "exerciseId": "id",
      "phase": "building|readyToProgress|justProgressed|struggling|deloading",
      "sets": [
        {"setNumber": 1, "weight": 82.5, "reps": 8, "targetRpe": 7.5}
      ],
      "reasoning": "Brief explanation",
      "isProgression": true,
      "weightIncrease": 2.5,
      "feedback": "Phase-specific feedback message"
    }
  ]
}

Important:
- Include 3-4 sets unless history shows different
- Round weights to nearest ${userSettings.upperBodyWeightIncrement}kg
- Be specific in reasoning (mention phase, rep targets)
- NEVER suggest progression if user just progressed and is adapting
''';
  }

  /// Builds the user prompt with history data and progression states.
  String _buildUserPrompt({
    required String templateName,
    required Map<String, ExerciseHistoryData> history,
    required Map<String, String> exerciseNames,
    required UserSettings userSettings,
    Map<String, ExerciseProgressionState>? progressionStates,
    int? programWeek,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('## Workout: $templateName');
    if (programWeek != null) {
      buffer.writeln('Program Week: $programWeek');
    }
    buffer.writeln();
    buffer.writeln('## Exercise Data');
    buffer.writeln();

    for (final entry in history.entries) {
      final exerciseId = entry.key;
      final data = entry.value;
      final name = exerciseNames[exerciseId] ?? data.exerciseName;
      final progressionState = progressionStates?[exerciseId];

      buffer.writeln('### $name (ID: $exerciseId)');

      // Include progression state if available
      if (progressionState != null) {
        buffer.writeln('**Current Phase: ${progressionState.phase.label}**');
        buffer.writeln('Sessions at ceiling: ${progressionState.consecutiveSessionsAtCeiling}');
        if (progressionState.currentWeight != null) {
          buffer.writeln('Current weight: ${progressionState.currentWeight}kg');
        }
        buffer.writeln();
      }

      buffer.writeln('History (most recent first):');
      for (var i = 0; i < data.sessions.length && i < 3; i++) {
        final session = data.sessions[i];
        final daysAgo = DateTime.now().difference(session.date).inDays;

        buffer.writeln('Session ${i + 1} ($daysAgo days ago):');
        for (final set in session.sets) {
          final rpeStr = set.rpe != null ? ' @ RPE ${set.rpe}' : '';
          buffer.writeln('  - ${set.weight}kg x ${set.reps}$rpeStr');
        }
        if (session.averageRpe != null) {
          buffer.writeln('  Avg RPE: ${session.averageRpe!.toStringAsFixed(1)}');
        }
        buffer.writeln();
      }
    }

    // Add exercises without history
    for (final entry in exerciseNames.entries) {
      if (!history.containsKey(entry.key)) {
        buffer.writeln('### ${entry.value} (ID: ${entry.key})');
        buffer.writeln('No history - suggest starting weights');
        buffer.writeln();
      }
    }

    buffer.writeln('Generate recommendations for all exercises.');
    return buffer.toString();
  }

  /// Parses the AI response JSON into recommendation objects.
  Map<String, ExerciseRecommendation> _parseAIResponse(
    String response,
    Map<String, String> exerciseNames,
  ) {
    // Find JSON in response (might have extra text)
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
    if (jsonMatch == null) {
      throw FormatException('No JSON found in AI response');
    }

    final jsonStr = jsonMatch.group(0)!;
    final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
    final recommendations = <String, ExerciseRecommendation>{};

    final recList = parsed['recommendations'] as List<dynamic>?;
    if (recList == null) return recommendations;

    for (final rec in recList) {
      final recMap = rec as Map<String, dynamic>;
      final exerciseId = recMap['exerciseId'] as String;

      final setsList = recMap['sets'] as List<dynamic>;
      final sets = setsList.map((s) {
        final setMap = s as Map<String, dynamic>;
        return SetRecommendation(
          setNumber: setMap['setNumber'] as int,
          weight: (setMap['weight'] as num).toDouble(),
          reps: setMap['reps'] as int,
          targetRpe: (setMap['targetRpe'] as num?)?.toDouble(),
        );
      }).toList();

      recommendations[exerciseId] = ExerciseRecommendation(
        exerciseId: exerciseId,
        exerciseName: exerciseNames[exerciseId] ?? exerciseId,
        sets: sets,
        confidence: RecommendationConfidence.high,
        source: RecommendationSource.ai,
        reasoning: recMap['reasoning'] as String?,
        isProgression: recMap['isProgression'] as bool? ?? false,
        weightIncrease: (recMap['weightIncrease'] as num?)?.toDouble(),
        phaseFeedback: recMap['feedback'] as String?,
      );
    }

    return recommendations;
  }

  // ==========================================================================
  // OFFLINE ALGORITHM - DOUBLE PROGRESSION STATE MACHINE
  // ==========================================================================

  /// Generates recommendations using the local double progression algorithm.
  Map<String, ExerciseRecommendation> _generateOfflineRecommendations({
    required Map<String, ExerciseHistoryData> history,
    required Map<String, String> exerciseNames,
    required UserSettings userSettings,
    required Map<String, ExerciseProgressionState> progressionStates,
  }) {
    final recommendations = <String, ExerciseRecommendation>{};

    for (final entry in exerciseNames.entries) {
      final exerciseId = entry.key;
      final exerciseName = entry.value;

      // Get progression state (or create default)
      final progressionState = progressionStates[exerciseId] ??
          ExerciseProgressionState.initial(exerciseId);

      if (history.containsKey(exerciseId)) {
        // We have history - use double progression state machine
        recommendations[exerciseId] = _generatePhaseAwareRecommendation(
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          historyData: history[exerciseId]!,
          progressionState: progressionState,
          userSettings: userSettings,
        );
      } else {
        // No history - return template default
        recommendations[exerciseId] = ExerciseRecommendation(
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          sets: _generateDefaultSets(exerciseName, userSettings),
          confidence: RecommendationConfidence.low,
          source: RecommendationSource.templateDefault,
          reasoning: 'No previous data - starting weights suggested',
          isProgression: false,
          phaseFeedback: 'Start with a comfortable weight and focus on form',
        );
      }
    }

    return recommendations;
  }

  /// Generates a phase-aware recommendation using double progression logic.
  ///
  /// This is the CORE algorithm that understands WHERE the user is in
  /// their progression cycle and makes appropriate recommendations.
  ExerciseRecommendation _generatePhaseAwareRecommendation({
    required String exerciseId,
    required String exerciseName,
    required ExerciseHistoryData historyData,
    required ExerciseProgressionState progressionState,
    required UserSettings userSettings,
  }) {
    final lastSession = historyData.sessions.first;
    final lastSets = lastSession.sets;

    if (lastSets.isEmpty) {
      return ExerciseRecommendation(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        sets: _generateDefaultSets(exerciseName, userSettings),
        confidence: RecommendationConfidence.low,
        source: RecommendationSource.algorithm,
        reasoning: 'No sets in previous session',
        isProgression: false,
      );
    }

    // Get rep range for this user's goal
    final repRange = _getRepRangeForGoal(userSettings);

    // Get weight increment based on exercise type
    final isUpperBody = _isUpperBodyExercise(exerciseName);
    final increment = isUpperBody
        ? userSettings.upperBodyWeightIncrement
        : userSettings.lowerBodyWeightIncrement;

    // Apply progression multiplier
    final multiplier = userSettings.trainingPreferences.progressionMultiplier;
    final adjustedIncrement = increment * multiplier;

    // Analyze last session
    final lastWeight = lastSets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);
    final lastAvgReps = lastSets.map((s) => s.reps).reduce((a, b) => a + b) / lastSets.length;
    final lastTopReps = lastSets.first.reps;
    final avgRpe = lastSession.averageRpe;

    // Generate recommendation based on current phase
    return switch (progressionState.phase) {
      ProgressionPhase.building =>
        _recommendForBuilding(
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          lastWeight: lastWeight,
          lastAvgReps: lastAvgReps,
          repRange: repRange,
          progressionState: progressionState,
          userSettings: userSettings,
          historyData: historyData,
          avgRpe: avgRpe,
        ),
      ProgressionPhase.readyToProgress =>
        _recommendForReadyToProgress(
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          lastWeight: lastWeight,
          repRange: repRange,
          increment: adjustedIncrement,
          userSettings: userSettings,
          historyData: historyData,
        ),
      ProgressionPhase.justProgressed =>
        _recommendForJustProgressed(
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          lastWeight: lastWeight,
          lastAvgReps: lastAvgReps,
          repRange: repRange,
          progressionState: progressionState,
          userSettings: userSettings,
          historyData: historyData,
        ),
      ProgressionPhase.struggling =>
        _recommendForStruggling(
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          lastWeight: lastWeight,
          progressionState: progressionState,
          userSettings: userSettings,
          historyData: historyData,
        ),
      ProgressionPhase.deloading =>
        _recommendForDeloading(
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          lastWeight: lastWeight,
          repRange: repRange,
          userSettings: userSettings,
          historyData: historyData,
        ),
    };
  }

  /// Recommendation for BUILDING phase.
  ///
  /// User is working up through rep range. Maintain weight, build reps.
  ExerciseRecommendation _recommendForBuilding({
    required String exerciseId,
    required String exerciseName,
    required double lastWeight,
    required double lastAvgReps,
    required RepRange repRange,
    required ExerciseProgressionState progressionState,
    required UserSettings userSettings,
    required ExerciseHistoryData historyData,
    double? avgRpe,
  }) {
    final repsToGo = repRange.repsToGo(lastAvgReps.round());
    final sessionsAtCeiling = progressionState.consecutiveSessionsAtCeiling;
    final sessionsRequired = userSettings.sessionsAtCeilingRequired;

    String reasoning;
    String feedback;

    if (lastAvgReps >= repRange.ceiling) {
      // At ceiling - building toward progression
      reasoning = 'At ceiling (${lastAvgReps.toStringAsFixed(0)} reps) - '
          '${sessionsAtCeiling + 1}/$sessionsRequired sessions';
      feedback = sessionsAtCeiling + 1 >= sessionsRequired
          ? 'One more session at ceiling and you\'re ready to progress!'
          : 'Keep it up! ${sessionsRequired - sessionsAtCeiling - 1} more session(s) at ceiling to progress';
    } else {
      reasoning = 'Building toward ${repRange.ceiling} reps '
          '(currently ${lastAvgReps.toStringAsFixed(0)}, ${repsToGo.toStringAsFixed(0)} to go)';
      feedback = '$repsToGo more reps to hit your target of ${repRange.ceiling}';
    }

    // Target reps: current + 1 (progressive), but NEVER exceed ceiling
    // The ceiling is the max reps before weight increase - we shouldn't suggest more
    final targetReps = (lastAvgReps + 1).clamp(repRange.floor, repRange.ceiling).round();

    // Determine confidence
    final confidence = historyData.sessions.length >= 3
        ? RecommendationConfidence.high
        : historyData.sessions.length >= 2
            ? RecommendationConfidence.medium
            : RecommendationConfidence.low;

    return ExerciseRecommendation(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      sets: _generateSets(
        weight: lastWeight,
        reps: targetReps,
        setCount: historyData.sessions.first.sets.length.clamp(3, 5),
        targetRpeLow: userSettings.trainingPreferences.targetRpeLow,
      ),
      confidence: confidence,
      source: RecommendationSource.algorithm,
      reasoning: reasoning,
      isProgression: false,
      previousWeight: lastWeight,
      previousReps: lastAvgReps.round(),
      phaseFeedback: feedback,
    );
  }

  /// Recommendation for READY_TO_PROGRESS phase.
  ///
  /// User hit ceiling for required sessions - time to increase weight!
  ExerciseRecommendation _recommendForReadyToProgress({
    required String exerciseId,
    required String exerciseName,
    required double lastWeight,
    required RepRange repRange,
    required double increment,
    required UserSettings userSettings,
    required ExerciseHistoryData historyData,
  }) {
    // Round to nearest 0.5kg (smallest common plate) to respect user's increment setting
    final newWeight = _roundToNearest(lastWeight + increment, 0.5);
    final targetReps = repRange.floor; // Start at floor after weight increase

    return ExerciseRecommendation(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      sets: _generateSets(
        weight: newWeight,
        reps: targetReps,
        setCount: historyData.sessions.first.sets.length.clamp(3, 5),
        targetRpeLow: userSettings.trainingPreferences.targetRpeLow,
      ),
      confidence: RecommendationConfidence.high,
      source: RecommendationSource.algorithm,
      reasoning: 'Great progress! Increasing weight by ${increment.toStringAsFixed(1)}kg',
      isProgression: true,
      weightIncrease: increment,
      previousWeight: lastWeight,
      previousReps: repRange.ceiling,
      phaseFeedback: 'Ready to increase weight! Aim for ${repRange.floor}+ reps at ${newWeight.toStringAsFixed(1)}kg',
    );
  }

  /// Recommendation for JUST_PROGRESSED phase.
  ///
  /// User recently increased weight. Rep drop is NORMAL - work back up.
  ExerciseRecommendation _recommendForJustProgressed({
    required String exerciseId,
    required String exerciseName,
    required double lastWeight,
    required double lastAvgReps,
    required RepRange repRange,
    required ExerciseProgressionState progressionState,
    required UserSettings userSettings,
    required ExerciseHistoryData historyData,
  }) {
    // Stay at current weight, aim to build reps
    final targetReps = (lastAvgReps + 1).clamp(repRange.floor, repRange.ceiling).round();

    String feedback;
    if (lastAvgReps >= repRange.floor) {
      feedback = 'Adapting well to new weight! Keep building to ${repRange.ceiling} reps';
    } else {
      feedback = 'Weight increased recently - ${repRange.floor}+ reps is the goal';
    }

    return ExerciseRecommendation(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      sets: _generateSets(
        weight: lastWeight,
        reps: targetReps,
        setCount: historyData.sessions.first.sets.length.clamp(3, 5),
        targetRpeLow: userSettings.trainingPreferences.targetRpeLow,
      ),
      confidence: RecommendationConfidence.high,
      source: RecommendationSource.algorithm,
      reasoning: 'Recently progressed - building back to ceiling '
          '(${lastAvgReps.toStringAsFixed(0)}/${repRange.ceiling} reps)',
      isProgression: false,
      previousWeight: lastWeight,
      previousReps: lastAvgReps.round(),
      phaseFeedback: feedback,
    );
  }

  /// Recommendation for STRUGGLING phase.
  ///
  /// User can't hit floor reps. Recommend dropping back to previous weight.
  ExerciseRecommendation _recommendForStruggling({
    required String exerciseId,
    required String exerciseName,
    required double lastWeight,
    required ExerciseProgressionState progressionState,
    required UserSettings userSettings,
    required ExerciseHistoryData historyData,
  }) {
    // Recommend previous weight (or a 5% deload if no previous)
    final fallbackWeight = progressionState.lastProgressedWeight ??
        _roundToNearest(lastWeight * 0.95, 0.5);

    final repRange = _getRepRangeForGoal(userSettings);
    final targetReps = repRange.midpoint; // Aim for middle of range

    return ExerciseRecommendation(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      sets: _generateSets(
        weight: fallbackWeight,
        reps: targetReps,
        setCount: historyData.sessions.first.sets.length.clamp(3, 5),
        targetRpeLow: userSettings.trainingPreferences.targetRpeLow,
      ),
      confidence: RecommendationConfidence.high,
      source: RecommendationSource.algorithm,
      reasoning: 'Struggling at ${lastWeight.toStringAsFixed(1)}kg - '
          'dropping to ${fallbackWeight.toStringAsFixed(1)}kg to rebuild',
      isProgression: false,
      previousWeight: lastWeight,
      phaseFeedback: 'Consider dropping to ${fallbackWeight.toStringAsFixed(1)}kg to rebuild strength',
    );
  }

  /// Recommendation for DELOADING phase.
  ///
  /// Recovery week - reduce volume but maintain intensity.
  ExerciseRecommendation _recommendForDeloading({
    required String exerciseId,
    required String exerciseName,
    required double lastWeight,
    required RepRange repRange,
    required UserSettings userSettings,
    required ExerciseHistoryData historyData,
  }) {
    // Deload: same weight, fewer sets, moderate reps
    final setCount = (historyData.sessions.first.sets.length * 0.6).round().clamp(2, 3);

    return ExerciseRecommendation(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      sets: _generateSets(
        weight: lastWeight,
        reps: repRange.midpoint,
        setCount: setCount,
        targetRpeLow: 6.0, // Lower RPE during deload
      ),
      confidence: RecommendationConfidence.high,
      source: RecommendationSource.algorithm,
      reasoning: 'Deload week - reduced volume for recovery',
      isProgression: false,
      previousWeight: lastWeight,
      phaseFeedback: 'Recovery week - lighter volume, focus on quality movement',
    );
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /// Gets the rep range based on user's training goal.
  RepRange _getRepRangeForGoal(UserSettings userSettings) {
    final goal = userSettings.trainingGoal;
    final preference = userSettings.repRangePreference;
    final sessionsRequired = userSettings.sessionsAtCeilingRequired;

    final baseRange = goal.defaultRepRange;

    final (floor, ceiling) = switch (preference) {
      RepRangePreference.conservative => (
          baseRange.floor - 1,
          baseRange.ceiling - 2
        ),
      RepRangePreference.standard => (baseRange.floor, baseRange.ceiling),
      RepRangePreference.aggressive => (
          baseRange.floor + 2,
          baseRange.ceiling + 3
        ),
    };

    return RepRange(
      floor: floor.clamp(1, 30),
      ceiling: ceiling.clamp(2, 50),
      sessionsAtCeilingRequired: sessionsRequired,
    );
  }

  /// Generates a list of sets with the given parameters.
  List<SetRecommendation> _generateSets({
    required double weight,
    required int reps,
    required int setCount,
    required double targetRpeLow,
  }) {
    return List.generate(
      setCount,
      (i) => SetRecommendation(
        setNumber: i + 1,
        weight: weight,
        reps: reps,
        targetRpe: targetRpeLow + (i * 0.5),
      ),
    );
  }

  /// Generates default starting sets for an exercise with no history.
  List<SetRecommendation> _generateDefaultSets(
    String exerciseName,
    UserSettings userSettings,
  ) {
    final isUpperBody = _isUpperBodyExercise(exerciseName);
    final defaultWeight = isUpperBody ? 20.0 : 40.0;
    final repRange = _getRepRangeForGoal(userSettings);

    return _generateSets(
      weight: defaultWeight,
      reps: repRange.midpoint,
      setCount: 3,
      targetRpeLow: 6.0, // Conservative for starting weight
    );
  }

  /// Determines if an exercise is upper body based on name.
  bool _isUpperBodyExercise(String name) {
    final lowerName = name.toLowerCase();
    final lowerBodyKeywords = [
      'squat',
      'deadlift',
      'leg',
      'lunge',
      'calf',
      'hamstring',
      'glute',
      'hip',
      'romanian',
    ];
    return !lowerBodyKeywords.any((kw) => lowerName.contains(kw));
  }

  /// Rounds a number to the nearest increment.
  double _roundToNearest(double value, double increment) {
    return (value / increment).round() * increment;
  }

  // ==========================================================================
  // QUICK WORKOUT / SINGLE EXERCISE RECOMMENDATIONS
  // ==========================================================================

  /// Generates a recommendation for a single exercise in a quick workout.
  ///
  /// Unlike template-based recommendations, this searches ALL workout history
  /// for the exercise, not just workouts from a specific template.
  Future<ExerciseRecommendation?> generateForExercise({
    required String exerciseId,
    required String exerciseName,
    required UserSettings userSettings,
    ExerciseProgressionState? progressionState,
  }) async {
    debugPrint('WeightRecommendationService: Generating for $exerciseName (quick workout)');

    // Initialize history service if needed
    await _historyService.initialize();

    // Get history for this exercise across ALL workouts
    final historyData = _getHistoryForExercise(exerciseId, exerciseName);

    if (historyData == null || historyData.sessions.isEmpty) {
      debugPrint('WeightRecommendationService: No history for $exerciseName');
      return null;
    }

    debugPrint('WeightRecommendationService: Found ${historyData.sessions.length} sessions for $exerciseName');

    // Use progression state or create default
    final state = progressionState ?? ExerciseProgressionState.initial(exerciseId);

    // Calculate recommendation using phase-aware algorithm
    return _generatePhaseAwareRecommendation(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      historyData: historyData,
      progressionState: state,
      userSettings: userSettings,
    );
  }

  /// Gets exercise history across ALL workouts (not template-filtered).
  ExerciseHistoryData? _getHistoryForExercise(
    String exerciseId,
    String exerciseName,
  ) {
    final sessions = <SessionExerciseData>[];

    // Get all workouts that contain this exercise (last 8 sessions max)
    for (final workout in _historyService.workouts.take(50)) {
      final exercise = workout.exercises
          .where((e) => e.exerciseId == exerciseId)
          .firstOrNull;

      if (exercise != null && exercise.sets.isNotEmpty) {
        final sets = exercise.sets
            .map((s) => HistoricalSetData(
                  weight: s.weight,
                  reps: s.reps,
                  rpe: s.rpe,
                ))
            .toList();

        // Calculate if all reps were achieved
        final allRepsAchieved = sets.every((s) => s.reps >= 1);

        // Calculate average RPE
        final rpeSets = sets.where((s) => s.rpe != null);
        final averageRpe = rpeSets.isNotEmpty
            ? rpeSets.map((s) => s.rpe!).reduce((a, b) => a + b) / rpeSets.length
            : null;

        sessions.add(SessionExerciseData(
          date: workout.completedAt,
          sets: sets,
          allRepsAchieved: allRepsAchieved,
          averageRpe: averageRpe,
        ));
      }

      // Limit to 8 most recent sessions
      if (sessions.length >= 8) break;
    }

    if (sessions.isEmpty) return null;

    return ExerciseHistoryData(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      sessions: sessions,
    );
  }
}

// ============================================================================
// PROVIDER
// ============================================================================

/// Provider for the weight recommendation service.
final weightRecommendationServiceProvider = Provider<WeightRecommendationService>((ref) {
  return WeightRecommendationService(
    groqService: GroqService(),
    historyService: ref.watch(workoutHistoryServiceProvider),
  );
});
