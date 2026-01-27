/// LiftIQ - Template Parser
///
/// Parses AI-generated markdown responses into workout templates and programs.
/// Handles various markdown formats and extracts exercise data.
///
/// Features:
/// - Parse single template from markdown table
/// - Parse full program with multiple templates
/// - Extract exercise details (sets, reps, rest)
/// - Robust error handling for malformed input
library;

import 'package:flutter/foundation.dart';

import '../../templates/models/training_program.dart';
import '../../templates/models/workout_template.dart';

/// Parser for converting AI markdown responses to workout data structures.
///
/// ## Usage
/// ```dart
/// final parser = TemplateParser();
///
/// // Parse a single template
/// final template = parser.parseTemplate(markdownResponse);
///
/// // Parse a full program
/// final program = parser.parseProgram(markdownResponse);
/// ```
class TemplateParser {
  /// Parses a single workout template from markdown format.
  ///
  /// Expected format:
  /// ```markdown
  /// ## Template Name
  /// | Exercise | Sets | Reps | Rest |
  /// |----------|------|------|------|
  /// | Bench Press | 4 | 8-10 | 120s |
  /// ```
  ///
  /// Returns null if parsing fails.
  WorkoutTemplate? parseTemplate(String markdown) {
    try {
      final lines = markdown.split('\n');

      // Find template name from ## header
      String? templateName;
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('## ')) {
          templateName = trimmed.substring(3).trim();
          break;
        }
      }

      if (templateName == null || templateName.isEmpty) {
        debugPrint('TemplateParser: No template name found');
        return null;
      }

      // Parse exercise table
      final exercises = _parseExerciseTable(lines);

      if (exercises.isEmpty) {
        debugPrint('TemplateParser: No exercises parsed');
        return null;
      }

      return WorkoutTemplate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: templateName,
        description: 'AI-generated workout template',
        exercises: exercises,
        estimatedDuration: _estimateDuration(exercises),
      );
    } catch (e) {
      debugPrint('TemplateParser: Error parsing template: $e');
      return null;
    }
  }

  /// Parses a full training program from markdown format.
  ///
  /// Expected format:
  /// ```markdown
  /// # Program Name
  /// **Duration:** X weeks | **Days:** X/week | **Goal:** X | **Difficulty:** X
  ///
  /// ## Day 1: Day Name
  /// | Exercise | Sets | Reps | Rest |
  /// ...
  /// ```
  ///
  /// Returns null if parsing fails.
  TrainingProgram? parseProgram(String markdown) {
    try {
      final lines = markdown.split('\n');

      // Parse program name from # header
      String? programName;
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('# ') && !trimmed.startsWith('##')) {
          programName = trimmed.substring(2).trim();
          break;
        }
      }

      if (programName == null || programName.isEmpty) {
        debugPrint('TemplateParser: No program name found');
        return null;
      }

      // Parse metadata line
      final metadata = _parseProgramMetadata(lines);

      // Parse all templates (each ## Day X: Name section)
      final templates = _parseAllTemplates(lines);

      if (templates.isEmpty) {
        debugPrint('TemplateParser: No templates parsed');
        return null;
      }

      return TrainingProgram(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: programName,
        description: 'A ${metadata['weeks']}-week ${metadata['goal']} program '
            'for ${metadata['difficulty']} lifters, '
            'training ${metadata['days']} days per week.',
        durationWeeks: int.tryParse(metadata['weeks'] ?? '8') ?? 8,
        daysPerWeek: int.tryParse(metadata['days'] ?? '4') ?? 4,
        difficulty: _parseDifficulty(metadata['difficulty']),
        goalType: _parseGoalType(metadata['goal']),
        templates: templates,
      );
    } catch (e) {
      debugPrint('TemplateParser: Error parsing program: $e');
      return null;
    }
  }

  /// Parses the exercise table from markdown lines.
  List<TemplateExercise> _parseExerciseTable(List<String> lines) {
    final exercises = <TemplateExercise>[];
    var inTable = false;
    var headerParsed = false;
    int orderIndex = 0;

    for (final line in lines) {
      final trimmed = line.trim();

      // Skip empty lines
      if (trimmed.isEmpty) continue;

      // Detect table start (header row)
      if (trimmed.startsWith('|') && trimmed.contains('Exercise')) {
        inTable = true;
        continue;
      }

      // Skip separator row
      if (inTable && trimmed.contains('---')) {
        headerParsed = true;
        continue;
      }

      // Parse data rows
      if (inTable && headerParsed && trimmed.startsWith('|')) {
        final exercise = _parseExerciseRow(trimmed, orderIndex);
        if (exercise != null) {
          exercises.add(exercise);
          orderIndex++;
        }
      }

      // Stop at next section or non-table content
      if (inTable && headerParsed && !trimmed.startsWith('|') && trimmed.isNotEmpty) {
        break;
      }
    }

    return exercises;
  }

  /// Parses a single exercise row from the markdown table.
  TemplateExercise? _parseExerciseRow(String row, int orderIndex) {
    try {
      // Split by | and remove empty entries
      final cells = row
          .split('|')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();

      if (cells.length < 4) return null;

      final exerciseName = cells[0];
      final sets = int.tryParse(cells[1]) ?? 3;
      final reps = _parseReps(cells[2]);
      final restSeconds = _parseRestSeconds(cells[3]);

      if (exerciseName.isEmpty) return null;

      // Generate exercise ID from name
      final exerciseId = exerciseName
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
          .replaceAll(' ', '-');

      // Infer primary muscles from exercise name
      final primaryMuscles = _inferMuscles(exerciseName);

      return TemplateExercise(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        primaryMuscles: primaryMuscles,
        orderIndex: orderIndex,
        defaultSets: sets,
        defaultReps: reps,
        defaultRestSeconds: restSeconds,
      );
    } catch (e) {
      debugPrint('TemplateParser: Error parsing exercise row: $e');
      return null;
    }
  }

  /// Parses reps from various formats (e.g., "8-10", "10", "8-12").
  int _parseReps(String repsStr) {
    // Handle range format like "8-10"
    if (repsStr.contains('-')) {
      final parts = repsStr.split('-');
      // Take the lower end of the range
      return int.tryParse(parts.first.trim()) ?? 10;
    }
    return int.tryParse(repsStr.trim()) ?? 10;
  }

  /// Parses rest time from various formats (e.g., "90s", "90", "2min").
  int _parseRestSeconds(String restStr) {
    final clean = restStr.toLowerCase().trim();

    // Handle minutes format
    if (clean.contains('min')) {
      final mins = int.tryParse(clean.replaceAll(RegExp(r'[^0-9]'), '')) ?? 2;
      return mins * 60;
    }

    // Handle seconds format (with or without 's')
    final seconds = int.tryParse(clean.replaceAll(RegExp(r'[^0-9]'), '')) ?? 90;
    return seconds;
  }

  /// Infers primary muscles from exercise name.
  List<String> _inferMuscles(String exerciseName) {
    final name = exerciseName.toLowerCase();

    if (name.contains('bench') || name.contains('chest') || name.contains('fly')) {
      return ['Chest'];
    }
    if (name.contains('squat') || name.contains('leg press') || name.contains('extension')) {
      return ['Quads', 'Glutes'];
    }
    if (name.contains('deadlift')) {
      return ['Back', 'Hamstrings'];
    }
    if (name.contains('rdl') || name.contains('romanian')) {
      return ['Hamstrings', 'Glutes'];
    }
    if (name.contains('row') || name.contains('pulldown') || name.contains('pull-up')) {
      return ['Back'];
    }
    if (name.contains('overhead') || name.contains('shoulder') || name.contains('lateral')) {
      return ['Shoulders'];
    }
    if (name.contains('curl') && !name.contains('leg')) {
      return ['Biceps'];
    }
    if (name.contains('tricep') || name.contains('pushdown') || name.contains('skull')) {
      return ['Triceps'];
    }
    if (name.contains('calf')) {
      return ['Calves'];
    }
    if (name.contains('leg curl') || name.contains('hamstring')) {
      return ['Hamstrings'];
    }
    if (name.contains('hip thrust') || name.contains('glute')) {
      return ['Glutes'];
    }

    // Default
    return [];
  }

  /// Parses program metadata from the bold line.
  Map<String, String?> _parseProgramMetadata(List<String> lines) {
    final metadata = <String, String?>{
      'weeks': '8',
      'days': '4',
      'goal': 'Hypertrophy',
      'difficulty': 'Intermediate',
    };

    for (final line in lines) {
      final trimmed = line.trim();

      // Look for the metadata line with bold markers
      if (trimmed.contains('**Duration:**') || trimmed.contains('**Days:**')) {
        // Parse weeks
        final weeksMatch = RegExp(r'(\d+)\s*weeks?', caseSensitive: false).firstMatch(trimmed);
        if (weeksMatch != null) {
          metadata['weeks'] = weeksMatch.group(1);
        }

        // Parse days - must match "X/week" format, NOT "X weeks"
        // The regex looks for "Days: X/week" to avoid matching duration like "8 weeks"
        final daysMatch = RegExp(r'Days:\*?\*?\s*(\d+)\s*/\s*week', caseSensitive: false).firstMatch(trimmed);
        if (daysMatch != null) {
          metadata['days'] = daysMatch.group(1);
        } else {
          // Fallback: look for X/week pattern (requiring the slash)
          final altDaysMatch = RegExp(r'(\d+)\s*/\s*week', caseSensitive: false).firstMatch(trimmed);
          if (altDaysMatch != null) {
            metadata['days'] = altDaysMatch.group(1);
          }
        }

        // Parse goal
        final goalMatch = RegExp(
          r'Goal:\*?\*?\s*(Strength|Hypertrophy|General Fitness|Powerlifting)',
          caseSensitive: false,
        ).firstMatch(trimmed);
        if (goalMatch != null) {
          metadata['goal'] = goalMatch.group(1);
        }

        // Parse difficulty
        final diffMatch = RegExp(
          r'Difficulty:\*?\*?\s*(Beginner|Intermediate|Advanced)',
          caseSensitive: false,
        ).firstMatch(trimmed);
        if (diffMatch != null) {
          metadata['difficulty'] = diffMatch.group(1);
        }

        break;
      }
    }

    return metadata;
  }

  /// Parses all workout templates from the program markdown.
  List<WorkoutTemplate> _parseAllTemplates(List<String> lines) {
    final templates = <WorkoutTemplate>[];
    final daySections = <List<String>>[];

    List<String>? currentSection;

    for (final line in lines) {
      final trimmed = line.trim();

      // Detect day headers like "## Day 1: Push Day" or "## Day 1"
      if (trimmed.startsWith('## Day ') || trimmed.startsWith('## day ')) {
        // Save previous section
        if (currentSection != null && currentSection.isNotEmpty) {
          daySections.add(currentSection);
        }
        currentSection = [line];
      } else if (currentSection != null) {
        currentSection.add(line);
      }
    }

    // Don't forget the last section
    if (currentSection != null && currentSection.isNotEmpty) {
      daySections.add(currentSection);
    }

    // Parse each day section
    for (final section in daySections) {
      final template = _parseDaySection(section, templates.length);
      if (template != null) {
        templates.add(template);
      }
    }

    return templates;
  }

  /// Parses a single day section into a template.
  WorkoutTemplate? _parseDaySection(List<String> lines, int dayIndex) {
    if (lines.isEmpty) return null;

    // Parse day name from header
    String dayName = 'Day ${dayIndex + 1}';
    final header = lines.first.trim();
    final dayMatch = RegExp(r'##\s*Day\s*\d+:?\s*(.*)').firstMatch(header);
    if (dayMatch != null && dayMatch.group(1)!.isNotEmpty) {
      dayName = dayMatch.group(1)!.trim();
    }

    // Parse exercises from the table
    final exercises = _parseExerciseTable(lines);

    if (exercises.isEmpty) return null;

    return WorkoutTemplate(
      id: 'ai-day-${dayIndex + 1}-${DateTime.now().millisecondsSinceEpoch}',
      name: dayName,
      description: 'Day ${dayIndex + 1} of AI-generated program',
      exercises: exercises,
      estimatedDuration: _estimateDuration(exercises),
    );
  }

  /// Estimates workout duration based on exercises.
  int _estimateDuration(List<TemplateExercise> exercises) {
    int totalMinutes = 0;

    for (final exercise in exercises) {
      // Estimate ~2 minutes per set including rest
      totalMinutes += (exercise.defaultSets * 2);
    }

    // Add warm-up and transition time
    totalMinutes += 10;

    return totalMinutes;
  }

  /// Parses difficulty from string.
  ProgramDifficulty _parseDifficulty(String? difficultyStr) {
    final lower = difficultyStr?.toLowerCase() ?? 'intermediate';
    if (lower.contains('beginner')) return ProgramDifficulty.beginner;
    if (lower.contains('advanced')) return ProgramDifficulty.advanced;
    return ProgramDifficulty.intermediate;
  }

  /// Parses goal type from string.
  ProgramGoalType _parseGoalType(String? goalStr) {
    final lower = goalStr?.toLowerCase() ?? 'hypertrophy';
    if (lower.contains('strength')) return ProgramGoalType.strength;
    if (lower.contains('general') || lower.contains('fitness')) {
      return ProgramGoalType.generalFitness;
    }
    if (lower.contains('powerlifting')) return ProgramGoalType.powerlifting;
    return ProgramGoalType.hypertrophy;
  }
}
