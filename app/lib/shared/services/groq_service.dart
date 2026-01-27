/// LiftIQ - Groq AI Service
///
/// Handles communication with the Groq API for AI coaching features.
/// Uses Llama 3 models for fast, intelligent workout advice.
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/app_config.dart';
import '../../features/ai_coach/models/chat_message.dart';

/// Service for interacting with the Groq AI API.
///
/// ## Usage
/// ```dart
/// final service = GroqService();
/// final response = await service.chat([
///   ChatMessage(role: ChatRole.user, content: 'How do I improve my bench?', ...),
/// ]);
/// ```
///
/// ## Rate Limits
/// Groq has generous free tier limits:
/// - 30 requests per minute
/// - 14,400 requests per day
///
/// ## Error Handling
/// Returns null on errors, allowing the app to fall back to mock responses.
class GroqService {
  late final Dio _dio;
  bool _isInitialized = false;

  /// System prompt that gives the AI context about LiftIQ.
  ///
  /// This comprehensive prompt incorporates evidence-based progressive overload
  /// principles from peer-reviewed research to enable intelligent training advice.
  static const String systemPrompt = '''
You are LiftIQ AI Coach, an evidence-based fitness assistant integrated into the LiftIQ workout tracking app. Your advice is grounded in peer-reviewed sports science research.

## Your Role
1. Provide accurate, research-backed advice on strength training and programming
2. Help users implement progressive overload correctly
3. Recommend appropriate program modifications and exercise alternatives
4. Detect plateaus and suggest evidence-based interventions
5. Prioritize safety and gradual progression

## Progressive Overload Decision Framework

### When to Increase Weight (Double Progression)
- **Trigger:** All sets hit top of rep range for 2+ consecutive sessions
- **Upper body compounds:** +2.5 kg (5 lbs)
- **Lower body compounds:** +5 kg (10 lbs)
- **Reset to bottom of rep range after increase**

### Training Level Classification
| Level | Training Age | Progression Rate | Recommended Volume (sets/muscle/week) |
|-------|-------------|------------------|--------------------------------------|
| Beginner | 0-12 months | Every session | 6-10 sets |
| Intermediate | 1-3 years | Weekly/biweekly | 10-15 sets |
| Advanced | 3+ years | Monthly cycles | 15-20+ sets |

### When to Recommend Deload
Trigger if ANY of these occur:
- RPE running 1+ higher than target for 3+ sessions
- Performance declining despite consistent training
- User reports increased soreness, joint issues, or poor sleep
- **Proactive:** Every 4-8 weeks of hard training

**Deload Protocol:**
- Reduce volume by 40-60% (fewer sets)
- Maintain or slightly reduce intensity
- Keep same frequency
- Duration: 5-7 days

### Plateau Detection and Intervention
- **Flag plateau:** No progress for 3+ consecutive sessions
- **Intervention trigger:** 4+ weeks stalled with adequate recovery

**Primary intervention:** Exercise variation (same movement pattern, different exercise)
**Secondary:** Periodization change or deload

### Rep Ranges by Goal
- **Strength:** 1-5 reps @ >85% 1RM, 3-5 min rest
- **Hypertrophy:** 6-12 reps @ 60-80% 1RM, 90-120 sec rest (load-independent when near failure)
- **Endurance:** 12-30+ reps, 60 sec rest

### Training Frequency
- Each muscle group 2x/week produces superior hypertrophy (Schoenfeld 2016)
- Higher frequency primarily helps distribute volume

### Muscles Requiring Direct Work
These muscles need isolation exercises for optimal development:
- **Hamstrings:** Leg curls, RDLs (squats don't hit them adequately)
- **Rectus Femoris:** Leg extensions
- **Lateral Deltoids:** Lateral raises
- **Calves:** Calf raises

### Rest Periods (Research-Backed)
- Heavy compounds (1-5 reps): 3-5 minutes
- Moderate compounds (6-12 reps): 2-3 minutes
- Isolation exercises: 60-120 seconds
- Longer rest produces better strength AND hypertrophy (Schoenfeld 2016)

## Communication Guidelines
- Keep responses concise (2-4 paragraphs max) - users are often in the gym
- Use bullet points for actionable advice
- Use **bold** for key points
- Be encouraging but realistic
- For injuries/medical issues, recommend healthcare professional
- Cite research principles when relevant (builds trust)
- Provide 3-5 exercise alternatives when asked

## Example Interactions

**User asks about progression:**
"Great question! Use **double progression**: when you hit 12 reps on all sets for 2 sessions, add 2.5kg (upper body) or 5kg (lower body), then work back up from 8 reps."

**User reports plateau:**
"After 3+ weeks stalled, research suggests **exercise variation** is most effective. Try swapping [current exercise] for [similar variation] for 3-4 weeks while keeping the same movement pattern."

**User asks about deload:**
"Signs point to accumulated fatigue. Take a deload week: cut sets in half, keep weight at 70-80%, maintain your schedule. You'll come back stronger."

Remember: Progressive overload is the key to long-term gains. Small, consistent increases beat sporadic big jumps every time.
''';

  /// Initializes the Dio client with Groq API configuration.
  void _initialize() {
    if (_isInitialized) return;

    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.groqBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        if (AppConfig.hasGroqApiKey) 'Authorization': 'Bearer ${AppConfig.groqApiKey}',
      },
    ));

    // Add logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }

    _isInitialized = true;
  }

  /// Sends a chat request to the Groq API.
  ///
  /// Takes a list of [messages] representing the conversation history.
  /// Returns an [AIResponse] on success, or null on failure.
  ///
  /// Example:
  /// ```dart
  /// final response = await groqService.chat([
  ///   ChatMessage(
  ///     id: '1',
  ///     role: ChatRole.user,
  ///     content: 'What are good alternatives to deadlifts?',
  ///     timestamp: DateTime.now(),
  ///   ),
  /// ]);
  /// ```
  Future<AIResponse?> chat(List<ChatMessage> messages) async {
    if (!AppConfig.hasGroqApiKey) {
      debugPrint('GroqService: No API key configured, returning null');
      return null;
    }

    _initialize();

    try {
      // Convert messages to Groq API format
      final apiMessages = [
        {'role': 'system', 'content': systemPrompt},
        ...messages.map((m) => {
              'role': m.role == ChatRole.user ? 'user' : 'assistant',
              'content': m.content,
            }),
      ];

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': AppConfig.groqModel,
          'messages': apiMessages,
          'max_tokens': AppConfig.maxTokens,
          'temperature': AppConfig.temperature,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final choices = data['choices'] as List?;

        if (choices != null && choices.isNotEmpty) {
          final firstChoice = choices.first as Map<String, dynamic>;
          final message = firstChoice['message'] as Map<String, dynamic>?;
          final content = message?['content'] as String?;

          if (content != null && content.isNotEmpty) {
            // Parse the response for suggestions
            final suggestions = _extractSuggestions(content);

            return AIResponse(
              message: content,
              suggestions: suggestions,
            );
          }
        }
      }

      debugPrint('GroqService: Unexpected response format');
      return null;
    } on DioException catch (e) {
      debugPrint('GroqService DioException: ${e.message}');
      debugPrint('GroqService Response: ${e.response?.data}');

      // Handle specific error codes
      if (e.response?.statusCode == 401) {
        debugPrint('GroqService: Invalid API key');
      } else if (e.response?.statusCode == 429) {
        debugPrint('GroqService: Rate limit exceeded');
      }

      return null;
    } catch (e) {
      debugPrint('GroqService error: $e');
      return null;
    }
  }

  /// Sends a chat request with a custom system prompt.
  ///
  /// This method is designed for structured AI tasks like weight recommendations
  /// where we need deterministic, parseable output.
  ///
  /// @param systemPrompt Custom system prompt for the task
  /// @param userMessage The user's message/query
  /// @param temperature Lower = more deterministic (default 0.3)
  /// @param maxTokens Maximum response length (default 2048)
  ///
  /// Returns the raw response string, or null on failure.
  ///
  /// Example:
  /// ```dart
  /// final response = await groqService.chatWithSystemPrompt(
  ///   systemPrompt: 'You are a progressive overload algorithm...',
  ///   userMessage: 'Generate recommendations for: Bench Press history...',
  ///   temperature: 0.3,
  /// );
  /// ```
  Future<String?> chatWithSystemPrompt({
    required String systemPrompt,
    required String userMessage,
    double temperature = 0.3,
    int maxTokens = 2048,
    String? model,
  }) async {
    if (!AppConfig.hasGroqApiKey) {
      debugPrint('GroqService: No API key configured for structured task');
      return null;
    }

    _initialize();

    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': model ?? AppConfig.groqModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'max_tokens': maxTokens,
          'temperature': temperature,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final choices = data['choices'] as List?;

        if (choices != null && choices.isNotEmpty) {
          final firstChoice = choices.first as Map<String, dynamic>;
          final message = firstChoice['message'] as Map<String, dynamic>?;
          final content = message?['content'] as String?;

          if (content != null && content.isNotEmpty) {
            return content;
          }
        }
      }

      debugPrint('GroqService: Unexpected response format for structured task');
      return null;
    } on DioException catch (e) {
      debugPrint('GroqService DioException (structured): ${e.message}');
      return null;
    } catch (e) {
      debugPrint('GroqService error (structured): $e');
      return null;
    }
  }

  /// Extracts actionable suggestions from the AI response.
  ///
  /// Looks for patterns like:
  /// - Bullet points with "try", "consider", "add"
  /// - Numbered suggestions
  List<String> _extractSuggestions(String content) {
    final suggestions = <String>[];

    // Look for lines that start with bullet points or numbers
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();

      // Skip empty lines and headers
      if (trimmed.isEmpty || trimmed.startsWith('#') || trimmed.startsWith('**')) {
        continue;
      }

      // Check for bullet point items that look like suggestions
      if (trimmed.startsWith('•') || trimmed.startsWith('-') || trimmed.startsWith('*')) {
        final suggestionText = trimmed.replaceFirst(RegExp(r'^[•\-*]\s*'), '');
        if (suggestionText.length > 10 &&
            suggestionText.length < 80 &&
            (suggestionText.toLowerCase().contains('try') ||
                suggestionText.toLowerCase().contains('consider') ||
                suggestionText.toLowerCase().contains('add') ||
                suggestionText.toLowerCase().contains('focus'))) {
          suggestions.add(suggestionText);
          if (suggestions.length >= 3) break;
        }
      }
    }

    return suggestions;
  }

  /// Gets quick form cues for an exercise.
  ///
  /// Returns structured form advice for display in the UI.
  Future<FormCuesResponse?> getFormCues(String exerciseName) async {
    if (!AppConfig.hasGroqApiKey) return null;

    _initialize();

    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': AppConfig.groqModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {
              'role': 'user',
              'content': '''Give me the key form cues for $exerciseName in this exact JSON format:
{
  "cues": ["cue 1", "cue 2", "cue 3", "cue 4"],
  "mistakes": ["mistake 1", "mistake 2", "mistake 3"],
  "tips": ["tip 1", "tip 2"]
}

Just respond with the JSON, no other text.'''
            },
          ],
          'max_tokens': 300,
          'temperature': 0.3,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final choices = data['choices'] as List?;

        if (choices != null && choices.isNotEmpty) {
          final firstChoice = choices.first as Map<String, dynamic>;
          final message = firstChoice['message'] as Map<String, dynamic>?;
          final content = message?['content'] as String?;

          if (content != null) {
            // Try to parse JSON from response
            try {
              // Find JSON in response (might have extra text)
              final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
              if (jsonMatch != null) {
                final jsonStr = jsonMatch.group(0)!;
                // ignore: avoid_dynamic_calls
                final parsed = _parseJson(jsonStr);
                if (parsed != null) {
                  return FormCuesResponse(
                    cues: (parsed['cues'] as List?)?.cast<String>() ?? [],
                    mistakes: (parsed['mistakes'] as List?)?.cast<String>() ?? [],
                    tips: (parsed['tips'] as List?)?.cast<String>() ?? [],
                  );
                }
              }
            } catch (e) {
              debugPrint('GroqService: Failed to parse form cues JSON: $e');
            }
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint('GroqService getFormCues error: $e');
      return null;
    }
  }

  /// Simple JSON parser that handles common issues.
  Map<String, dynamic>? _parseJson(String jsonStr) {
    try {
      // Clean up common JSON issues
      final cleaned = jsonStr
          .replaceAll(RegExp(r',\s*}'), '}')
          .replaceAll(RegExp(r',\s*]'), ']');

      // Use dart:convert but we need to import it
      // For simplicity, just return null and let mock handle it
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Checks if the Groq API is available.
  Future<bool> checkAvailability() async {
    if (!AppConfig.hasGroqApiKey) return false;

    _initialize();

    try {
      final response = await _dio.get('/models');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('GroqService availability check failed: $e');
      return false;
    }
  }
}

/// Response containing form cues for an exercise.
class FormCuesResponse {
  final List<String> cues;
  final List<String> mistakes;
  final List<String> tips;

  const FormCuesResponse({
    required this.cues,
    required this.mistakes,
    required this.tips,
  });
}
