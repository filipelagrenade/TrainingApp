/// LiftIQ - AI Program Parser
///
/// Parses AI-generated training program responses (markdown format)
/// into structured TrainingProgram and WorkoutTemplate objects.
///
/// Supports parsing:
/// - Program headers and metadata
/// - Workout day sections (e.g., "## Day 1: Push")
/// - Exercise tables with sets x reps
/// - Rest period specifications
library;

import 'package:flutter/foundation.dart';
import '../../templates/models/workout_template.dart';
import '../../templates/models/training_program.dart';

/// Result of parsing an AI-generated program.
class ParsedProgram {
  /// Parsed training program with metadata
  final TrainingProgram? program;

  /// Individual workout templates for each day
  final List<WorkoutTemplate> workouts;

  /// Whether the content appears to contain a valid program
  final bool isProgramResponse;

  /// Any parsing errors encountered
  final List<String> errors;

  const ParsedProgram({
    this.program,
    this.workouts = const [],
    this.isProgramResponse = false,
    this.errors = const [],
  });

  /// Returns true if a program was successfully parsed.
  bool get hasProgram => program != null && workouts.isNotEmpty;

  /// Returns the number of workout days parsed.
  int get dayCount => workouts.length;
}

/// Parses AI responses for training program content.
///
/// Looks for structured content like:
/// ```
/// # 4-Week Strength Program
///
/// ## Day 1: Upper Body
/// | Exercise | Sets | Reps | Rest |
/// |----------|------|------|------|
/// | Bench Press | 4 | 8 | 2 min |
/// ```
class ProgramParser {
  /// Checks if the content appears to contain a training program.
  ///
  /// Returns true if the content has:
  /// - "Day" sections (##Day or ## Day)
  /// - Exercise tables or lists
  /// - Multiple exercises mentioned
  static bool containsProgram(String content) {
    // Check for day markers
    final hasDayMarkers = RegExp(
      r'(#+\s*Day\s*\d|Day\s*\d\s*:|Week\s*\d)',
      caseSensitive: false,
    ).hasMatch(content);

    // Check for exercise tables (markdown tables with exercise-like content)
    final hasExerciseTable = content.contains('|') &&
        (content.toLowerCase().contains('sets') ||
            content.toLowerCase().contains('reps'));

    // Check for exercise lists (numbered or bulleted)
    final hasExerciseList = RegExp(
      r'(?:^|\n)\s*(?:\d+\.|[-*])\s*\w+.*(?:sets?|reps?|x\d)',
      caseSensitive: false,
    ).hasMatch(content);

    // Check for multiple exercise names (common compound/isolation exercises)
    final exercisePattern = RegExp(
      r'(bench\s*press|squat|deadlift|row|curl|press|pull[-\s]?up|lat\s*pulldown|'
      r'tricep|bicep|shoulder|leg\s*press|lunge|fly|raise|extension|'
      r'dumbbell|barbell|cable)',
      caseSensitive: false,
    );
    final exerciseMatches = exercisePattern.allMatches(content);

    return hasDayMarkers && (hasExerciseTable || hasExerciseList || exerciseMatches.length >= 3);
  }

  /// Parses an AI response into a structured program.
  ///
  /// @param content The AI response text
  /// @param programName Optional name for the program
  /// @returns ParsedProgram with extracted data
  static ParsedProgram parseProgram(String content, {String? programName}) {
    if (!containsProgram(content)) {
      return const ParsedProgram(isProgramResponse: false);
    }

    final errors = <String>[];
    final workouts = <WorkoutTemplate>[];

    try {
      // Extract program name from title if not provided
      final name = programName ?? _extractProgramName(content);

      // Split into day sections
      final daySections = _splitIntoDays(content);

      for (var i = 0; i < daySections.length; i++) {
        final section = daySections[i];
        final dayName = _extractDayName(section) ?? 'Day ${i + 1}';
        final exercises = _parseExercises(section);

        if (exercises.isNotEmpty) {
          workouts.add(WorkoutTemplate(
            id: 'ai-workout-${DateTime.now().millisecondsSinceEpoch}-$i',
            name: dayName,
            description: _extractDayDescription(section),
            exercises: exercises,
            estimatedDuration: _estimateDuration(exercises),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
        }
      }

      if (workouts.isEmpty) {
        errors.add('No valid workout days found');
        return ParsedProgram(
          isProgramResponse: true,
          errors: errors,
        );
      }

      // Create the program
      final program = TrainingProgram(
        id: 'ai-prog-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: _extractProgramDescription(content),
        durationWeeks: _inferDurationWeeks(content, workouts.length),
        daysPerWeek: workouts.length,
        difficulty: _inferDifficulty(workouts),
        goalType: _inferGoalType(content),
        isBuiltIn: false,
        templates: workouts,
      );

      return ParsedProgram(
        program: program,
        workouts: workouts,
        isProgramResponse: true,
        errors: errors,
      );
    } catch (e) {
      debugPrint('ProgramParser: Error parsing program: $e');
      errors.add('Failed to parse program: $e');
      return ParsedProgram(
        isProgramResponse: true,
        errors: errors,
      );
    }
  }

  /// Extracts the program name from the content.
  static String _extractProgramName(String content) {
    // Look for markdown headers
    final headerMatch = RegExp(r'^#+\s*(.+?)(?:\n|$)', multiLine: true)
        .firstMatch(content);
    if (headerMatch != null) {
      final title = headerMatch.group(1)?.trim() ?? '';
      // Clean up the title
      if (title.isNotEmpty &&
          !title.toLowerCase().startsWith('day') &&
          !title.toLowerCase().startsWith('week')) {
        return title;
      }
    }

    // Look for "program" keyword
    final programMatch = RegExp(
      r'(?:^|\n)([^#\n]+(?:program|routine|plan)[^#\n]*)',
      caseSensitive: false,
    ).firstMatch(content);
    if (programMatch != null) {
      return programMatch.group(1)?.trim() ?? 'Custom Program';
    }

    return 'AI Generated Program';
  }

  /// Extracts program description from the content.
  static String _extractProgramDescription(String content) {
    // Look for description after the title, before the first day
    final descMatch = RegExp(
      r'^#+[^\n]+\n+([^#]+?)(?=\n#+\s*Day|\n#+\s*Week|$)',
      multiLine: true,
    ).firstMatch(content);

    if (descMatch != null) {
      final desc = descMatch.group(1)?.trim() ?? '';
      // Take first 2-3 sentences
      final sentences = desc.split(RegExp(r'[.!?]'));
      if (sentences.length > 3) {
        return '${sentences.take(3).join('. ').trim()}.';
      }
      return desc;
    }

    return 'AI-generated training program';
  }

  /// Splits content into day sections.
  static List<String> _splitIntoDays(String content) {
    // Split by day headers
    final dayPattern = RegExp(
      r'(?:^|\n)(#+\s*Day\s*\d[^\n]*|Day\s*\d\s*:[^\n]*)',
      caseSensitive: false,
    );

    final matches = dayPattern.allMatches(content).toList();
    if (matches.isEmpty) {
      // Try splitting by "Week X Day Y" pattern
      final weekDayPattern = RegExp(
        r'(?:^|\n)(#+\s*Week\s*\d+\s*,?\s*Day\s*\d[^\n]*)',
        caseSensitive: false,
      );
      matches.addAll(weekDayPattern.allMatches(content));
    }

    if (matches.isEmpty) {
      return [content]; // Treat entire content as one day
    }

    final sections = <String>[];
    for (var i = 0; i < matches.length; i++) {
      final start = matches[i].start;
      final end = i + 1 < matches.length ? matches[i + 1].start : content.length;
      sections.add(content.substring(start, end).trim());
    }

    return sections;
  }

  /// Extracts the day name from a section.
  static String? _extractDayName(String section) {
    final match = RegExp(
      r'(?:#+\s*)?(?:Day\s*\d+\s*:?\s*)?([A-Za-z][A-Za-z\s/&]+)',
      caseSensitive: false,
    ).firstMatch(section);

    if (match != null) {
      final name = match.group(1)?.trim();
      if (name != null && name.length > 2 && name.length < 50) {
        return name;
      }
    }

    // Fallback to day number
    final dayNumMatch = RegExp(r'Day\s*(\d+)', caseSensitive: false)
        .firstMatch(section);
    if (dayNumMatch != null) {
      return 'Day ${dayNumMatch.group(1)}';
    }

    return null;
  }

  /// Extracts day description (muscle groups, focus, etc.).
  static String? _extractDayDescription(String section) {
    // Look for description after day title
    final lines = section.split('\n');
    for (final line in lines.skip(1)) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty &&
          !trimmed.startsWith('|') &&
          !trimmed.startsWith('-') &&
          !trimmed.startsWith('*') &&
          !RegExp(r'^\d+\.').hasMatch(trimmed)) {
        return trimmed;
      }
      // Stop at table or list
      if (trimmed.startsWith('|') || trimmed.startsWith('-')) break;
    }
    return null;
  }

  /// Parses exercises from a day section.
  static List<TemplateExercise> _parseExercises(String section) {
    final exercises = <TemplateExercise>[];

    // Try parsing markdown table first
    final tableExercises = _parseExerciseTable(section);
    if (tableExercises.isNotEmpty) {
      return tableExercises;
    }

    // Try parsing list format
    final listExercises = _parseExerciseList(section);
    if (listExercises.isNotEmpty) {
      return listExercises;
    }

    return exercises;
  }

  /// Parses exercises from a markdown table.
  static List<TemplateExercise> _parseExerciseTable(String section) {
    final exercises = <TemplateExercise>[];

    // Find table rows
    final tableRows = RegExp(r'^\|(.+)\|$', multiLine: true)
        .allMatches(section)
        .toList();

    if (tableRows.length < 2) return exercises; // Need header + at least one row

    // Skip header and separator rows
    var dataStart = 1;
    for (var i = 1; i < tableRows.length; i++) {
      final row = tableRows[i].group(1) ?? '';
      if (row.contains('---') || row.contains('===')) {
        dataStart = i + 1;
        break;
      }
    }

    for (var i = dataStart; i < tableRows.length; i++) {
      final row = tableRows[i].group(1) ?? '';
      final cells = row.split('|').map((c) => c.trim()).toList();

      if (cells.isEmpty) continue;

      // First cell is usually exercise name
      final exerciseName = _cleanExerciseName(cells[0]);
      if (exerciseName.isEmpty) continue;

      // Try to extract sets and reps
      int sets = 3;
      int reps = 10;
      int rest = 90;

      for (var j = 1; j < cells.length; j++) {
        final cell = cells[j].toLowerCase();

        // Parse sets x reps format (e.g., "3x10", "4 x 8-12")
        final setsRepsMatch = RegExp(r'(\d+)\s*[x×]\s*(\d+)').firstMatch(cell);
        if (setsRepsMatch != null) {
          sets = int.tryParse(setsRepsMatch.group(1) ?? '') ?? sets;
          reps = int.tryParse(setsRepsMatch.group(2) ?? '') ?? reps;
          continue;
        }

        // Parse standalone sets
        if (cell.contains('set')) {
          final setsMatch = RegExp(r'(\d+)').firstMatch(cell);
          if (setsMatch != null) {
            sets = int.tryParse(setsMatch.group(1) ?? '') ?? sets;
          }
          continue;
        }

        // Parse standalone reps
        if (cell.contains('rep')) {
          final repsMatch = RegExp(r'(\d+)').firstMatch(cell);
          if (repsMatch != null) {
            reps = int.tryParse(repsMatch.group(1) ?? '') ?? reps;
          }
          continue;
        }

        // Parse rest (e.g., "2 min", "90s", "60-90s")
        if (cell.contains('min') || cell.contains('sec') || cell.contains('rest')) {
          rest = _parseRestTime(cell);
          continue;
        }

        // Try parsing plain numbers
        final num = int.tryParse(cells[j]);
        if (num != null) {
          if (num <= 10) {
            sets = num;
          } else if (num <= 30) {
            reps = num;
          }
        }
      }

      exercises.add(TemplateExercise(
        id: 'ex-${DateTime.now().millisecondsSinceEpoch}-${exercises.length}',
        exerciseId: _generateExerciseId(exerciseName),
        exerciseName: exerciseName,
        primaryMuscles: _inferMuscleGroups(exerciseName),
        orderIndex: exercises.length,
        defaultSets: sets,
        defaultReps: reps,
        defaultRestSeconds: rest,
      ));
    }

    return exercises;
  }

  /// Parses exercises from a list format.
  static List<TemplateExercise> _parseExerciseList(String section) {
    final exercises = <TemplateExercise>[];

    // Match numbered or bulleted lists with exercise info
    final listPattern = RegExp(
      r'(?:^|\n)\s*(?:\d+\.|[-*])\s*(.+?)(?:\n|$)',
      multiLine: true,
    );

    for (final match in listPattern.allMatches(section)) {
      final line = match.group(1) ?? '';

      // Skip if too short or doesn't look like an exercise
      if (line.length < 5) continue;

      // Extract exercise name (before the colon, dash, or sets/reps info)
      var exerciseName = line.split(RegExp(r'[:–-]|(\d+\s*[x×])')).first.trim();
      exerciseName = _cleanExerciseName(exerciseName);

      if (exerciseName.isEmpty) continue;

      // Extract sets and reps
      int sets = 3;
      int reps = 10;
      int rest = 90;

      // Parse "3x10" or "4 sets x 8-12 reps"
      final setsRepsMatch = RegExp(r'(\d+)\s*(?:sets?\s*)?[x×]\s*(\d+)')
          .firstMatch(line.toLowerCase());
      if (setsRepsMatch != null) {
        sets = int.tryParse(setsRepsMatch.group(1) ?? '') ?? sets;
        reps = int.tryParse(setsRepsMatch.group(2) ?? '') ?? reps;
      }

      // Parse rest time
      final restMatch = RegExp(r'(\d+)\s*(?:sec|s|min|m)(?:utes?)?(?:\s*rest)?')
          .firstMatch(line.toLowerCase());
      if (restMatch != null) {
        rest = _parseRestTime(restMatch.group(0) ?? '');
      }

      exercises.add(TemplateExercise(
        id: 'ex-${DateTime.now().millisecondsSinceEpoch}-${exercises.length}',
        exerciseId: _generateExerciseId(exerciseName),
        exerciseName: exerciseName,
        primaryMuscles: _inferMuscleGroups(exerciseName),
        orderIndex: exercises.length,
        defaultSets: sets,
        defaultReps: reps,
        defaultRestSeconds: rest,
      ));
    }

    return exercises;
  }

  /// Cleans up an exercise name.
  static String _cleanExerciseName(String name) {
    // Remove markdown formatting
    var clean = name
        .replaceAll(RegExp(r'\*+'), '')
        .replaceAll(RegExp(r'_+'), '')
        .replaceAll(RegExp(r'`+'), '')
        .trim();

    // Remove leading numbers and punctuation
    clean = clean.replaceFirst(RegExp(r'^[\d.)\-*]+\s*'), '');

    // Capitalize words
    clean = clean.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return clean.trim();
  }

  /// Parses rest time from a string (returns seconds).
  static int _parseRestTime(String text) {
    final lower = text.toLowerCase();

    // Parse minutes
    final minMatch = RegExp(r'(\d+)\s*(?:min|m(?:inutes?)?)').firstMatch(lower);
    if (minMatch != null) {
      return (int.tryParse(minMatch.group(1) ?? '') ?? 2) * 60;
    }

    // Parse seconds
    final secMatch = RegExp(r'(\d+)\s*(?:sec|s(?:econds?)?)').firstMatch(lower);
    if (secMatch != null) {
      return int.tryParse(secMatch.group(1) ?? '') ?? 90;
    }

    return 90; // Default
  }

  /// Generates an exercise ID from the name.
  static String _generateExerciseId(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  /// Infers muscle groups from exercise name.
  static List<String> _inferMuscleGroups(String name) {
    final lower = name.toLowerCase();
    final muscles = <String>[];

    // Chest exercises
    if (lower.contains('bench') ||
        lower.contains('chest') ||
        lower.contains('fly') ||
        lower.contains('push-up') ||
        lower.contains('pushup')) {
      muscles.add('Chest');
    }

    // Back exercises
    if (lower.contains('row') ||
        lower.contains('pull') ||
        lower.contains('lat') ||
        lower.contains('deadlift') ||
        lower.contains('back')) {
      muscles.add('Back');
    }

    // Shoulder exercises
    if (lower.contains('shoulder') ||
        lower.contains('overhead') ||
        lower.contains('press') ||
        lower.contains('lateral') ||
        lower.contains('raise') ||
        lower.contains('delt')) {
      muscles.add('Shoulders');
    }

    // Arm exercises
    if (lower.contains('bicep') ||
        lower.contains('curl') ||
        lower.contains('hammer')) {
      muscles.add('Biceps');
    }
    if (lower.contains('tricep') ||
        lower.contains('pushdown') ||
        lower.contains('extension') ||
        lower.contains('skull')) {
      muscles.add('Triceps');
    }

    // Leg exercises
    if (lower.contains('squat') ||
        lower.contains('leg') ||
        lower.contains('quad')) {
      muscles.add('Quads');
    }
    if (lower.contains('hamstring') ||
        lower.contains('curl') && lower.contains('leg') ||
        lower.contains('romanian')) {
      muscles.add('Hamstrings');
    }
    if (lower.contains('glute') ||
        lower.contains('hip') ||
        lower.contains('lunge')) {
      muscles.add('Glutes');
    }
    if (lower.contains('calf') || lower.contains('calve')) {
      muscles.add('Calves');
    }

    // Core
    if (lower.contains('ab') ||
        lower.contains('core') ||
        lower.contains('plank') ||
        lower.contains('crunch')) {
      muscles.add('Core');
    }

    return muscles.isEmpty ? ['General'] : muscles;
  }

  /// Estimates workout duration based on exercises.
  static int _estimateDuration(List<TemplateExercise> exercises) {
    // Estimate 3-4 minutes per set (including rest and transition)
    final totalSets = exercises.fold<int>(0, (sum, e) => sum + e.defaultSets);
    return (totalSets * 3.5).round().clamp(20, 120);
  }

  /// Infers program duration in weeks.
  static int _inferDurationWeeks(String content, int daysPerWeek) {
    // Look for explicit week count
    final weekMatch = RegExp(r'(\d+)\s*-?\s*week', caseSensitive: false)
        .firstMatch(content);
    if (weekMatch != null) {
      final weeks = int.tryParse(weekMatch.group(1) ?? '');
      if (weeks != null && weeks > 0 && weeks <= 52) {
        return weeks;
      }
    }

    // Default based on complexity
    return daysPerWeek >= 5 ? 8 : 12;
  }

  /// Infers difficulty from exercises.
  static ProgramDifficulty _inferDifficulty(List<WorkoutTemplate> workouts) {
    // Check for complex exercises
    var hasAdvanced = false;
    var totalExercises = 0;

    for (final workout in workouts) {
      totalExercises += workout.exercises.length;
      for (final exercise in workout.exercises) {
        final name = exercise.exerciseName.toLowerCase();
        if (name.contains('snatch') ||
            name.contains('clean') ||
            name.contains('jerk') ||
            name.contains('muscle-up')) {
          hasAdvanced = true;
        }
      }
    }

    if (hasAdvanced) return ProgramDifficulty.advanced;
    if (workouts.length >= 5 || totalExercises > 20) {
      return ProgramDifficulty.intermediate;
    }
    return ProgramDifficulty.beginner;
  }

  /// Infers goal type from content.
  static ProgramGoalType _inferGoalType(String content) {
    final lower = content.toLowerCase();

    if (lower.contains('strength') ||
        lower.contains('powerlifting') ||
        lower.contains('1rm') ||
        lower.contains('heavy')) {
      if (lower.contains('powerlifting') ||
          lower.contains('competition') ||
          lower.contains('meet')) {
        return ProgramGoalType.powerlifting;
      }
      return ProgramGoalType.strength;
    }

    if (lower.contains('hypertrophy') ||
        lower.contains('muscle') ||
        lower.contains('bodybuilding') ||
        lower.contains('size') ||
        lower.contains('mass')) {
      return ProgramGoalType.hypertrophy;
    }

    return ProgramGoalType.generalFitness;
  }
}
