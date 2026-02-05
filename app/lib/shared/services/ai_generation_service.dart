/// LiftIQ - AI Generation Service
///
/// Provides AI-assisted generation of workout templates and training programs.
/// Uses GroqService for LLM interactions with structured prompts.
///
/// Features:
/// - Generate single workout templates from descriptions
/// - Generate full training programs with multiple templates
/// - Mock fallback when no API key is configured
library;

import 'package:flutter/foundation.dart';

import '../../core/config/app_config.dart';
import '../../features/settings/models/user_settings.dart';
import '../../features/templates/models/training_program.dart';
import '../../features/templates/models/workout_template.dart';
import '../../features/ai_coach/utils/template_parser.dart';
import 'groq_service.dart';

/// Service for AI-assisted workout and program generation.
///
/// ## Usage
/// ```dart
/// final service = AIGenerationService();
///
/// // Generate a single template
/// final template = await service.generateTemplate('chest and triceps day');
///
/// // Generate a full program
/// final program = await service.generateProgram(
///   '12-week hypertrophy, 4 days/week, intermediate',
/// );
/// ```
class AIGenerationService {
  final GroqService _groqService = GroqService();
  final TemplateParser _templateParser = TemplateParser();

  /// System prompt for generating a single workout template.
  static String _getTemplateSystemPrompt({
    List<String> favorites = const [],
    List<String> dislikes = const [],
    ProgressionPhilosophy? progressionPhilosophy,
    TrainingPreferences? trainingPrefs,
  }) {
    // Determine which columns to include based on preferences
    final includeSets = trainingPrefs?.includeSetsInGeneration ?? true;
    final includeReps = trainingPrefs?.includeRepsInGeneration ?? true;

    // Build the header row
    final headerParts = <String>['Exercise'];
    if (includeSets) headerParts.add('Sets');
    if (includeReps) headerParts.add('Reps');
    headerParts.add('Rest');

    final headerRow = '| ${headerParts.join(' | ')} |';
    final dividerRow = '|${headerParts.map((_) => '------').join('|')}|';

    // Build example row
    final exampleParts = <String>['Exercise Name'];
    if (includeSets) exampleParts.add('3');
    if (includeReps) exampleParts.add('8-10');
    exampleParts.add('90s');
    final exampleRow = '| ${exampleParts.join(' | ')} |';

    final buffer = StringBuffer('''
You are a professional strength coach creating workout templates for a fitness app.

Generate a workout template based on the user's description. Output ONLY in this exact markdown format:

## [Template Name]
$headerRow
$dividerRow
$exampleRow

RULES:
- Include 4-8 exercises
- Start with compound movements, then isolation exercises
''');

    // Add set count preference if specified
    if (includeSets) {
      if (trainingPrefs?.preferredSetCount != null) {
        buffer.writeln('- Use ${trainingPrefs!.preferredSetCount} sets per exercise');
      } else {
        buffer.writeln('- Use realistic sets (2-5)');
      }
    }

    // Add rep range preference if specified
    if (includeReps) {
      if (trainingPrefs?.preferredRepRangeMin != null && trainingPrefs?.preferredRepRangeMax != null) {
        buffer.writeln('- Use rep range ${trainingPrefs!.preferredRepRangeMin}-${trainingPrefs!.preferredRepRangeMax}');
      } else {
        buffer.writeln('- Use realistic reps (5-20)');
      }
    }

    buffer.writeln('''- Use rest times (30s-180s)
- Rest format: use "s" for seconds (e.g., "90s", "120s")
- Use common exercise names (e.g., "Bench Press", "Barbell Row", "Lat Pulldown")
- DO NOT include any text before or after the template
- DO NOT include any explanations
''');

    // Add progression philosophy
    if (progressionPhilosophy != null) {
      buffer.writeln();
      buffer.writeln('PROGRESSION PHILOSOPHY: ${progressionPhilosophy.label}');
      buffer.writeln(_getPhilosophyInstructions(progressionPhilosophy));
    }

    // Add favorites preference
    if (favorites.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('USER PREFERENCES - FAVORITES (prioritize these exercises when appropriate):');
      for (final exercise in favorites) {
        buffer.writeln('- $exercise');
      }
    }

    // Add dislikes preference
    if (dislikes.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('USER PREFERENCES - DISLIKES (DO NOT include these exercises, use alternatives):');
      for (final exercise in dislikes) {
        buffer.writeln('- $exercise');
      }
    }

    return buffer.toString();
  }

  /// Returns AI instructions for a specific progression philosophy.
  static String _getPhilosophyInstructions(ProgressionPhilosophy philosophy) {
    return switch (philosophy) {
      ProgressionPhilosophy.standard => '''
Design for LINEAR PROGRESSION:
- Use fixed rep ranges (e.g., 3x8, not 3x8-10)
- Include primarily compounds with moderate rest (90-120s)
- User will add weight each session when they hit their reps''',
      ProgressionPhilosophy.doubleProgression => '''
Design for DOUBLE PROGRESSION:
- Use rep ranges (e.g., 3x8-12)
- User will increase reps until hitting top of range, then add weight
- Good for isolation exercises and accessories''',
      ProgressionPhilosophy.waveLoading => '''
Design for WAVE LOADING:
- Vary rep ranges across weeks (5s, 8s, 12s)
- Include notes about intensity variation
- Consider light/medium/heavy week structure''',
      ProgressionPhilosophy.rpeBased => '''
Design for RPE-BASED TRAINING:
- Use moderate rep ranges
- Include RPE targets in notes (e.g., "RPE 7-8")
- User will adjust weight based on daily readiness''',
      ProgressionPhilosophy.dailyUndulating => '''
Design for DAILY UNDULATING PERIODIZATION (DUP):
- Vary rep ranges each session (strength: 5x5, hypertrophy: 3x10, power: 4x6)
- Same exercises with different intensities
- Good for 3-4 day programs''',
      ProgressionPhilosophy.blockPeriodization => '''
Design for BLOCK PERIODIZATION:
- Structure for specific training phases
- Higher volume at start, higher intensity later
- Consider accumulation, intensification, realization blocks''',
    };
  }

  /// System prompt for generating a full training program.
  static String _getProgramSystemPrompt({
    List<String> favorites = const [],
    List<String> dislikes = const [],
    ProgressionPhilosophy? progressionPhilosophy,
    TrainingPreferences? trainingPrefs,
  }) {
    // Determine which columns to include based on preferences
    final includeSets = trainingPrefs?.includeSetsInGeneration ?? true;
    final includeReps = trainingPrefs?.includeRepsInGeneration ?? true;

    // Build the header row
    final headerParts = <String>['Exercise'];
    if (includeSets) headerParts.add('Sets');
    if (includeReps) headerParts.add('Reps');
    headerParts.add('Rest');

    final headerRow = '| ${headerParts.join(' | ')} |';
    final dividerRow = '|${headerParts.map((_) => '------').join('|')}|';

    // Build example row
    final exampleParts = <String>['Exercise Name'];
    if (includeSets) exampleParts.add('3');
    if (includeReps) exampleParts.add('8-10');
    exampleParts.add('90s');
    final exampleRow = '| ${exampleParts.join(' | ')} |';

    final buffer = StringBuffer('''
You are a professional strength coach creating a training program for a fitness app.

Generate a training program based on the user's description. Output ONLY in this exact markdown format:

# [Program Name]
**Duration:** X weeks | **Days:** X/week | **Goal:** X | **Difficulty:** X

## Day 1: [Day Name]
$headerRow
$dividerRow
$exampleRow

## Day 2: [Day Name]
$headerRow
$dividerRow
...

[Continue for all days]

RULES:
- Create workout days equal to the days/week specified
- Each day should have 4-8 exercises
- Start each day with compound movements, then isolation
''');

    // Add set count preference if specified
    if (includeSets) {
      if (trainingPrefs?.preferredSetCount != null) {
        buffer.writeln('- Use ${trainingPrefs!.preferredSetCount} sets per exercise');
      } else {
        buffer.writeln('- Use realistic sets (2-5)');
      }
    }

    // Add rep range preference if specified
    if (includeReps) {
      if (trainingPrefs?.preferredRepRangeMin != null && trainingPrefs?.preferredRepRangeMax != null) {
        buffer.writeln('- Use rep range ${trainingPrefs!.preferredRepRangeMin}-${trainingPrefs!.preferredRepRangeMax}');
      } else {
        buffer.writeln('- Use realistic reps (5-20)');
      }
    }

    buffer.writeln('''- Use rest times (30s-180s)
- Difficulty must be one of: Beginner, Intermediate, Advanced
- Goal must be one of: Strength, Hypertrophy, General Fitness, Powerlifting
- Rest format: use "s" for seconds
- Use common exercise names
- Ensure balanced muscle group coverage across the week
- DO NOT include any text before or after the program
- DO NOT include any explanations
''');

    // Add progression philosophy
    if (progressionPhilosophy != null) {
      buffer.writeln();
      buffer.writeln('PROGRESSION PHILOSOPHY: ${progressionPhilosophy.label}');
      buffer.writeln(_getPhilosophyInstructions(progressionPhilosophy));
    }

    // Add favorites preference
    if (favorites.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('USER PREFERENCES - FAVORITES (prioritize these exercises when appropriate):');
      for (final exercise in favorites) {
        buffer.writeln('- $exercise');
      }
    }

    // Add dislikes preference
    if (dislikes.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('USER PREFERENCES - DISLIKES (DO NOT include these exercises, use alternatives):');
      for (final exercise in dislikes) {
        buffer.writeln('- $exercise');
      }
    }

    return buffer.toString();
  }

  /// Generates a workout template from a natural language description.
  ///
  /// Returns a [WorkoutTemplate] if successful, or null if generation fails.
  /// Falls back to mock data if no API key is configured.
  ///
  /// [favorites] - List of exercise names the user prefers (will be prioritized)
  /// [dislikes] - List of exercise names the user dislikes (will be excluded)
  /// [progressionPhilosophy] - The progression philosophy to use for recommendations
  /// [trainingPrefs] - User's training preferences for AI generation options
  ///
  /// Example:
  /// ```dart
  /// final template = await service.generateTemplate(
  ///   'chest and triceps day',
  ///   favorites: ['Bench Press', 'Dumbbell Fly'],
  ///   dislikes: ['Push-ups'],
  ///   progressionPhilosophy: ProgressionPhilosophy.doubleProgression,
  /// );
  /// if (template != null) {
  ///   // Use the generated template
  /// }
  /// ```
  Future<WorkoutTemplate?> generateTemplate(
    String description, {
    List<String> favorites = const [],
    List<String> dislikes = const [],
    ProgressionPhilosophy? progressionPhilosophy,
    TrainingPreferences? trainingPrefs,
  }) async {
    debugPrint('AIGenerationService: Generating template for "$description"');
    debugPrint('AIGenerationService: Favorites: $favorites, Dislikes: $dislikes');
    debugPrint('AIGenerationService: Philosophy: ${progressionPhilosophy?.label ?? 'default'}');

    // Check for API key
    if (!AppConfig.hasGroqApiKey) {
      debugPrint('AIGenerationService: No API key, returning mock template');
      return _getMockTemplate(description);
    }

    try {
      final systemPrompt = _getTemplateSystemPrompt(
        favorites: favorites,
        dislikes: dislikes,
        progressionPhilosophy: progressionPhilosophy,
        trainingPrefs: trainingPrefs,
      );

      final response = await _groqService.chatWithSystemPrompt(
        systemPrompt: systemPrompt,
        userMessage: 'Create a workout template for: $description',
        temperature: 0.7,
        maxTokens: 1024,
      );

      if (response == null || response.isEmpty) {
        debugPrint('AIGenerationService: Empty response, returning mock');
        return _getMockTemplate(description);
      }

      debugPrint('AIGenerationService: Received response:\n$response');

      // Parse the response
      final template = _templateParser.parseTemplate(response);

      if (template == null) {
        debugPrint('AIGenerationService: Failed to parse, returning mock');
        return _getMockTemplate(description);
      }

      return template;
    } catch (e) {
      debugPrint('AIGenerationService: Error generating template: $e');
      return _getMockTemplate(description);
    }
  }

  /// Generates a full training program from a natural language description.
  ///
  /// Returns a [TrainingProgram] if successful, or null if generation fails.
  /// Falls back to mock data if no API key is configured.
  ///
  /// [favorites] - List of exercise names the user prefers (will be prioritized)
  /// [dislikes] - List of exercise names the user dislikes (will be excluded)
  /// [progressionPhilosophy] - The progression philosophy to use for recommendations
  /// [trainingPrefs] - User's training preferences for AI generation options
  ///
  /// Example:
  /// ```dart
  /// final program = await service.generateProgram(
  ///   '12-week upper/lower split for intermediate lifters',
  ///   favorites: ['Squat', 'Deadlift'],
  ///   dislikes: ['Leg Press'],
  ///   progressionPhilosophy: ProgressionPhilosophy.waveLoading,
  /// );
  /// ```
  Future<TrainingProgram?> generateProgram(
    String description, {
    List<String> favorites = const [],
    List<String> dislikes = const [],
    ProgressionPhilosophy? progressionPhilosophy,
    TrainingPreferences? trainingPrefs,
  }) async {
    debugPrint('AIGenerationService: Generating program for "$description"');
    debugPrint('AIGenerationService: Favorites: $favorites, Dislikes: $dislikes');
    debugPrint('AIGenerationService: Philosophy: ${progressionPhilosophy?.label ?? 'default'}');

    // Check for API key
    if (!AppConfig.hasGroqApiKey) {
      debugPrint('AIGenerationService: No API key, returning mock program');
      return _getMockProgram(description);
    }

    try {
      final systemPrompt = _getProgramSystemPrompt(
        favorites: favorites,
        dislikes: dislikes,
        progressionPhilosophy: progressionPhilosophy,
        trainingPrefs: trainingPrefs,
      );

      // Use a larger model for program generation since it requires more output tokens
      // llama-3.1-8b-instant truncates long responses
      final response = await _groqService.chatWithSystemPrompt(
        systemPrompt: systemPrompt,
        userMessage: 'Create a training program for: $description',
        temperature: 0.7,
        maxTokens: 8192,
        model: 'llama-3.3-70b-versatile', // Use larger model for complex program generation
      );

      if (response == null || response.isEmpty) {
        debugPrint('AIGenerationService: Empty response, returning mock');
        return _getMockProgram(description);
      }

      debugPrint('AIGenerationService: Received program response:\n$response');

      // Parse the response
      final program = _templateParser.parseProgram(response);

      if (program == null) {
        debugPrint('AIGenerationService: Failed to parse, returning mock');
        return _getMockProgram(description);
      }

      return program;
    } catch (e) {
      debugPrint('AIGenerationService: Error generating program: $e');
      return _getMockProgram(description);
    }
  }

  /// Returns a mock template for offline/demo mode.
  WorkoutTemplate _getMockTemplate(String description) {
    final descLower = description.toLowerCase();

    // Determine template type from description
    if (descLower.contains('push') ||
        descLower.contains('chest') ||
        descLower.contains('tricep')) {
      return _createPushTemplate();
    } else if (descLower.contains('pull') ||
        descLower.contains('back') ||
        descLower.contains('bicep')) {
      return _createPullTemplate();
    } else if (descLower.contains('leg') ||
        descLower.contains('lower') ||
        descLower.contains('squat')) {
      return _createLegTemplate();
    } else if (descLower.contains('upper')) {
      return _createUpperTemplate();
    } else if (descLower.contains('full') || descLower.contains('body')) {
      return _createFullBodyTemplate();
    }

    // Default to push template
    return _createPushTemplate();
  }

  /// Returns a mock program for offline/demo mode.
  TrainingProgram _getMockProgram(String description) {
    final descLower = description.toLowerCase();

    // Determine program type from description
    int daysPerWeek = 4;
    int durationWeeks = 8;
    ProgramDifficulty difficulty = ProgramDifficulty.intermediate;
    ProgramGoalType goalType = ProgramGoalType.hypertrophy;

    // Parse days per week
    final daysMatch = RegExp(r'(\d)\s*days?').firstMatch(descLower);
    if (daysMatch != null) {
      daysPerWeek = int.tryParse(daysMatch.group(1)!) ?? 4;
    }

    // Parse duration
    final weeksMatch = RegExp(r'(\d+)\s*weeks?').firstMatch(descLower);
    if (weeksMatch != null) {
      durationWeeks = int.tryParse(weeksMatch.group(1)!) ?? 8;
    }

    // Parse difficulty
    if (descLower.contains('beginner')) {
      difficulty = ProgramDifficulty.beginner;
    } else if (descLower.contains('advanced')) {
      difficulty = ProgramDifficulty.advanced;
    }

    // Parse goal
    if (descLower.contains('strength')) {
      goalType = ProgramGoalType.strength;
    } else if (descLower.contains('general') || descLower.contains('fitness')) {
      goalType = ProgramGoalType.generalFitness;
    } else if (descLower.contains('powerlifting')) {
      goalType = ProgramGoalType.powerlifting;
    }

    // Generate templates based on days per week
    final templates = _generateMockTemplates(daysPerWeek);

    final programName = _generateProgramName(daysPerWeek, goalType);

    return TrainingProgram(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: programName,
      description: 'A $durationWeeks-week ${_goalLabel(goalType)} program '
          'designed for ${_difficultyLabel(difficulty)} lifters, '
          'training $daysPerWeek days per week.',
      durationWeeks: durationWeeks,
      daysPerWeek: daysPerWeek,
      difficulty: difficulty,
      goalType: goalType,
      templates: templates,
    );
  }

  /// Generates mock templates based on days per week.
  List<WorkoutTemplate> _generateMockTemplates(int daysPerWeek) {
    switch (daysPerWeek) {
      case 2:
        return [_createFullBodyTemplate(), _createFullBodyTemplate()];
      case 3:
        return [
          _createPushTemplate(),
          _createPullTemplate(),
          _createLegTemplate(),
        ];
      case 4:
        return [
          _createUpperTemplate(),
          _createLowerTemplate(),
          _createUpperTemplate(),
          _createLowerTemplate(),
        ];
      case 5:
        return [
          _createPushTemplate(),
          _createPullTemplate(),
          _createLegTemplate(),
          _createUpperTemplate(),
          _createLowerTemplate(),
        ];
      case 6:
        return [
          _createPushTemplate(),
          _createPullTemplate(),
          _createLegTemplate(),
          _createPushTemplate(),
          _createPullTemplate(),
          _createLegTemplate(),
        ];
      default:
        return [
          _createUpperTemplate(),
          _createLowerTemplate(),
          _createUpperTemplate(),
          _createLowerTemplate(),
        ];
    }
  }

  String _generateProgramName(int daysPerWeek, ProgramGoalType goal) {
    final goalName = _goalLabel(goal);
    switch (daysPerWeek) {
      case 2:
        return 'Full Body $goalName';
      case 3:
        return 'Push/Pull/Legs $goalName';
      case 4:
        return 'Upper/Lower $goalName';
      case 5:
        return '5-Day $goalName Split';
      case 6:
        return 'PPL $goalName (6-Day)';
      default:
        return '$daysPerWeek-Day $goalName';
    }
  }

  String _difficultyLabel(ProgramDifficulty d) => switch (d) {
        ProgramDifficulty.beginner => 'beginner',
        ProgramDifficulty.intermediate => 'intermediate',
        ProgramDifficulty.advanced => 'advanced',
      };

  String _goalLabel(ProgramGoalType g) => switch (g) {
        ProgramGoalType.strength => 'Strength',
        ProgramGoalType.hypertrophy => 'Hypertrophy',
        ProgramGoalType.generalFitness => 'Fitness',
        ProgramGoalType.powerlifting => 'Powerlifting',
      };

  // Mock template generators
  WorkoutTemplate _createPushTemplate() {
    return WorkoutTemplate(
      id: 'ai-push-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Push Day',
      description: 'Chest, shoulders, and triceps',
      estimatedDuration: 60,
      exercises: [
        const TemplateExercise(
          exerciseId: 'bench-press',
          exerciseName: 'Bench Press',
          primaryMuscles: ['Chest'],
          orderIndex: 0,
          defaultSets: 4,
          defaultReps: 8,
          defaultRestSeconds: 120,
        ),
        const TemplateExercise(
          exerciseId: 'incline-db-press',
          exerciseName: 'Incline Dumbbell Press',
          primaryMuscles: ['Chest', 'Shoulders'],
          orderIndex: 1,
          defaultSets: 3,
          defaultReps: 10,
          defaultRestSeconds: 90,
        ),
        const TemplateExercise(
          exerciseId: 'ohp',
          exerciseName: 'Overhead Press',
          primaryMuscles: ['Shoulders'],
          orderIndex: 2,
          defaultSets: 4,
          defaultReps: 8,
          defaultRestSeconds: 120,
        ),
        const TemplateExercise(
          exerciseId: 'lateral-raise',
          exerciseName: 'Lateral Raise',
          primaryMuscles: ['Shoulders'],
          orderIndex: 3,
          defaultSets: 3,
          defaultReps: 12,
          defaultRestSeconds: 60,
        ),
        const TemplateExercise(
          exerciseId: 'tricep-pushdown',
          exerciseName: 'Tricep Pushdown',
          primaryMuscles: ['Triceps'],
          orderIndex: 4,
          defaultSets: 3,
          defaultReps: 12,
          defaultRestSeconds: 60,
        ),
        const TemplateExercise(
          exerciseId: 'overhead-tricep-ext',
          exerciseName: 'Overhead Tricep Extension',
          primaryMuscles: ['Triceps'],
          orderIndex: 5,
          defaultSets: 3,
          defaultReps: 12,
          defaultRestSeconds: 60,
        ),
      ],
    );
  }

  WorkoutTemplate _createPullTemplate() {
    return WorkoutTemplate(
      id: 'ai-pull-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Pull Day',
      description: 'Back and biceps',
      estimatedDuration: 60,
      exercises: [
        const TemplateExercise(
          exerciseId: 'deadlift',
          exerciseName: 'Deadlift',
          primaryMuscles: ['Back', 'Hamstrings'],
          orderIndex: 0,
          defaultSets: 4,
          defaultReps: 6,
          defaultRestSeconds: 180,
        ),
        const TemplateExercise(
          exerciseId: 'barbell-row',
          exerciseName: 'Barbell Row',
          primaryMuscles: ['Back'],
          orderIndex: 1,
          defaultSets: 4,
          defaultReps: 8,
          defaultRestSeconds: 120,
        ),
        const TemplateExercise(
          exerciseId: 'lat-pulldown',
          exerciseName: 'Lat Pulldown',
          primaryMuscles: ['Back'],
          orderIndex: 2,
          defaultSets: 3,
          defaultReps: 10,
          defaultRestSeconds: 90,
        ),
        const TemplateExercise(
          exerciseId: 'face-pull',
          exerciseName: 'Face Pull',
          primaryMuscles: ['Shoulders', 'Back'],
          orderIndex: 3,
          defaultSets: 3,
          defaultReps: 15,
          defaultRestSeconds: 60,
        ),
        const TemplateExercise(
          exerciseId: 'barbell-curl',
          exerciseName: 'Barbell Curl',
          primaryMuscles: ['Biceps'],
          orderIndex: 4,
          defaultSets: 3,
          defaultReps: 10,
          defaultRestSeconds: 60,
        ),
        const TemplateExercise(
          exerciseId: 'hammer-curl',
          exerciseName: 'Hammer Curl',
          primaryMuscles: ['Biceps'],
          orderIndex: 5,
          defaultSets: 3,
          defaultReps: 12,
          defaultRestSeconds: 60,
        ),
      ],
    );
  }

  WorkoutTemplate _createLegTemplate() {
    return WorkoutTemplate(
      id: 'ai-legs-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Leg Day',
      description: 'Quads, hamstrings, and calves',
      estimatedDuration: 65,
      exercises: [
        const TemplateExercise(
          exerciseId: 'squat',
          exerciseName: 'Barbell Squat',
          primaryMuscles: ['Quads', 'Glutes'],
          orderIndex: 0,
          defaultSets: 4,
          defaultReps: 6,
          defaultRestSeconds: 180,
        ),
        const TemplateExercise(
          exerciseId: 'rdl',
          exerciseName: 'Romanian Deadlift',
          primaryMuscles: ['Hamstrings', 'Glutes'],
          orderIndex: 1,
          defaultSets: 4,
          defaultReps: 8,
          defaultRestSeconds: 120,
        ),
        const TemplateExercise(
          exerciseId: 'leg-press',
          exerciseName: 'Leg Press',
          primaryMuscles: ['Quads', 'Glutes'],
          orderIndex: 2,
          defaultSets: 3,
          defaultReps: 10,
          defaultRestSeconds: 90,
        ),
        const TemplateExercise(
          exerciseId: 'leg-curl',
          exerciseName: 'Lying Leg Curl',
          primaryMuscles: ['Hamstrings'],
          orderIndex: 3,
          defaultSets: 3,
          defaultReps: 12,
          defaultRestSeconds: 60,
        ),
        const TemplateExercise(
          exerciseId: 'leg-extension',
          exerciseName: 'Leg Extension',
          primaryMuscles: ['Quads'],
          orderIndex: 4,
          defaultSets: 3,
          defaultReps: 12,
          defaultRestSeconds: 60,
        ),
        const TemplateExercise(
          exerciseId: 'calf-raise',
          exerciseName: 'Standing Calf Raise',
          primaryMuscles: ['Calves'],
          orderIndex: 5,
          defaultSets: 4,
          defaultReps: 15,
          defaultRestSeconds: 45,
        ),
      ],
    );
  }

  WorkoutTemplate _createUpperTemplate() {
    return WorkoutTemplate(
      id: 'ai-upper-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Upper Body',
      description: 'Chest, back, shoulders, and arms',
      estimatedDuration: 70,
      exercises: [
        const TemplateExercise(
          exerciseId: 'bench-press',
          exerciseName: 'Bench Press',
          primaryMuscles: ['Chest'],
          orderIndex: 0,
          defaultSets: 4,
          defaultReps: 6,
          defaultRestSeconds: 120,
        ),
        const TemplateExercise(
          exerciseId: 'barbell-row',
          exerciseName: 'Barbell Row',
          primaryMuscles: ['Back'],
          orderIndex: 1,
          defaultSets: 4,
          defaultReps: 8,
          defaultRestSeconds: 120,
        ),
        const TemplateExercise(
          exerciseId: 'ohp',
          exerciseName: 'Overhead Press',
          primaryMuscles: ['Shoulders'],
          orderIndex: 2,
          defaultSets: 3,
          defaultReps: 8,
          defaultRestSeconds: 90,
        ),
        const TemplateExercise(
          exerciseId: 'lat-pulldown',
          exerciseName: 'Lat Pulldown',
          primaryMuscles: ['Back'],
          orderIndex: 3,
          defaultSets: 3,
          defaultReps: 10,
          defaultRestSeconds: 90,
        ),
        const TemplateExercise(
          exerciseId: 'incline-db-press',
          exerciseName: 'Incline Dumbbell Press',
          primaryMuscles: ['Chest'],
          orderIndex: 4,
          defaultSets: 3,
          defaultReps: 10,
          defaultRestSeconds: 90,
        ),
        const TemplateExercise(
          exerciseId: 'barbell-curl',
          exerciseName: 'Barbell Curl',
          primaryMuscles: ['Biceps'],
          orderIndex: 5,
          defaultSets: 3,
          defaultReps: 10,
          defaultRestSeconds: 60,
        ),
        const TemplateExercise(
          exerciseId: 'tricep-pushdown',
          exerciseName: 'Tricep Pushdown',
          primaryMuscles: ['Triceps'],
          orderIndex: 6,
          defaultSets: 3,
          defaultReps: 12,
          defaultRestSeconds: 60,
        ),
      ],
    );
  }

  WorkoutTemplate _createLowerTemplate() {
    return WorkoutTemplate(
      id: 'ai-lower-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Lower Body',
      description: 'Quads, hamstrings, glutes, and calves',
      estimatedDuration: 65,
      exercises: [
        const TemplateExercise(
          exerciseId: 'squat',
          exerciseName: 'Barbell Squat',
          primaryMuscles: ['Quads', 'Glutes'],
          orderIndex: 0,
          defaultSets: 4,
          defaultReps: 6,
          defaultRestSeconds: 180,
        ),
        const TemplateExercise(
          exerciseId: 'rdl',
          exerciseName: 'Romanian Deadlift',
          primaryMuscles: ['Hamstrings', 'Glutes'],
          orderIndex: 1,
          defaultSets: 4,
          defaultReps: 8,
          defaultRestSeconds: 120,
        ),
        const TemplateExercise(
          exerciseId: 'bulgarian-split',
          exerciseName: 'Bulgarian Split Squat',
          primaryMuscles: ['Quads', 'Glutes'],
          orderIndex: 2,
          defaultSets: 3,
          defaultReps: 10,
          defaultRestSeconds: 90,
        ),
        const TemplateExercise(
          exerciseId: 'leg-curl',
          exerciseName: 'Lying Leg Curl',
          primaryMuscles: ['Hamstrings'],
          orderIndex: 3,
          defaultSets: 3,
          defaultReps: 12,
          defaultRestSeconds: 60,
        ),
        const TemplateExercise(
          exerciseId: 'hip-thrust',
          exerciseName: 'Hip Thrust',
          primaryMuscles: ['Glutes'],
          orderIndex: 4,
          defaultSets: 3,
          defaultReps: 10,
          defaultRestSeconds: 90,
        ),
        const TemplateExercise(
          exerciseId: 'calf-raise',
          exerciseName: 'Standing Calf Raise',
          primaryMuscles: ['Calves'],
          orderIndex: 5,
          defaultSets: 4,
          defaultReps: 15,
          defaultRestSeconds: 45,
        ),
      ],
    );
  }

  WorkoutTemplate _createFullBodyTemplate() {
    return WorkoutTemplate(
      id: 'ai-fullbody-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Full Body',
      description: 'All major muscle groups',
      estimatedDuration: 75,
      exercises: [
        const TemplateExercise(
          exerciseId: 'squat',
          exerciseName: 'Barbell Squat',
          primaryMuscles: ['Quads', 'Glutes'],
          orderIndex: 0,
          defaultSets: 3,
          defaultReps: 6,
          defaultRestSeconds: 180,
        ),
        const TemplateExercise(
          exerciseId: 'bench-press',
          exerciseName: 'Bench Press',
          primaryMuscles: ['Chest'],
          orderIndex: 1,
          defaultSets: 3,
          defaultReps: 8,
          defaultRestSeconds: 120,
        ),
        const TemplateExercise(
          exerciseId: 'barbell-row',
          exerciseName: 'Barbell Row',
          primaryMuscles: ['Back'],
          orderIndex: 2,
          defaultSets: 3,
          defaultReps: 8,
          defaultRestSeconds: 120,
        ),
        const TemplateExercise(
          exerciseId: 'ohp',
          exerciseName: 'Overhead Press',
          primaryMuscles: ['Shoulders'],
          orderIndex: 3,
          defaultSets: 3,
          defaultReps: 8,
          defaultRestSeconds: 90,
        ),
        const TemplateExercise(
          exerciseId: 'rdl',
          exerciseName: 'Romanian Deadlift',
          primaryMuscles: ['Hamstrings', 'Glutes'],
          orderIndex: 4,
          defaultSets: 3,
          defaultReps: 10,
          defaultRestSeconds: 90,
        ),
        const TemplateExercise(
          exerciseId: 'lat-pulldown',
          exerciseName: 'Lat Pulldown',
          primaryMuscles: ['Back'],
          orderIndex: 5,
          defaultSets: 3,
          defaultReps: 10,
          defaultRestSeconds: 60,
        ),
      ],
    );
  }
}
