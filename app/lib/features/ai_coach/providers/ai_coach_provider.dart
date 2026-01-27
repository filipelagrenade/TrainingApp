/// LiftIQ - AI Coach Provider
///
/// Manages the state for AI chat and coaching features.
/// Uses Groq API for real AI responses with fallback to mock data.
/// Chat history is persisted to SharedPreferences.
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../models/chat_message.dart';
import '../models/quick_prompt.dart';
import '../services/chat_persistence_service.dart';
import '../../../shared/services/groq_service.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/user_storage_keys.dart';

// ============================================================================
// GROQ SERVICE PROVIDER
// ============================================================================

/// Provider for the Groq AI service.
final groqServiceProvider = Provider<GroqService>((ref) {
  return GroqService();
});

// ============================================================================
// CHAT PERSISTENCE PROVIDER
// ============================================================================

/// Provider for the chat persistence service.
///
/// Creates a user-specific persistence service that handles saving
/// and loading chat history from SharedPreferences.
final chatPersistenceServiceProvider = Provider<ChatPersistenceService>((ref) {
  final userId = ref.watch(currentUserStorageIdProvider);
  return ChatPersistenceService(userId);
});

// ============================================================================
// CHAT STATE
// ============================================================================

/// State for the chat conversation.
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ============================================================================
// CHAT PROVIDER
// ============================================================================

/// Provider for managing chat conversation state.
///
/// Automatically loads persisted chat history on initialization
/// and saves after each message (debounced).
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) {
    final groqService = ref.watch(groqServiceProvider);
    final persistenceService = ref.watch(chatPersistenceServiceProvider);
    final notifier = ChatNotifier(groqService, persistenceService);

    // Dispose the persistence service timer when provider is disposed
    ref.onDispose(() {
      persistenceService.dispose();
    });

    return notifier;
  },
);

/// Notifier for chat state management.
///
/// Handles:
/// - Sending messages and receiving AI responses
/// - Persisting chat history to local storage
/// - Loading chat history on initialization
class ChatNotifier extends StateNotifier<ChatState> {
  final GroqService _groqService;
  final ChatPersistenceService _persistenceService;
  bool _hasLoadedHistory = false;

  ChatNotifier(this._groqService, this._persistenceService)
      : super(const ChatState()) {
    // Load persisted chat history on initialization
    _loadChatHistory();
  }

  /// Loads chat history from persistence.
  Future<void> _loadChatHistory() async {
    if (_hasLoadedHistory) return;
    _hasLoadedHistory = true;

    try {
      final messages = await _persistenceService.loadChatHistory();
      if (messages.isNotEmpty && mounted) {
        state = state.copyWith(messages: messages);
        debugPrint('ChatNotifier: Loaded ${messages.length} messages from persistence');
      }
    } on Exception catch (e) {
      debugPrint('ChatNotifier: Error loading chat history: $e');
    }
  }

  /// Sends a message and gets AI response.
  ///
  /// First attempts to use the Groq API for real AI responses.
  /// Falls back to mock responses if:
  /// - No API key is configured
  /// - API call fails
  /// - Network is unavailable
  ///
  /// Messages are automatically persisted after each exchange.
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatRole.user,
      content: content,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    // Schedule save of user message
    _persistenceService.scheduleSave(state.messages);

    try {
      AIResponse? aiResponse;

      // Try real API first if configured
      if (AppConfig.hasGroqApiKey) {
        debugPrint('ChatNotifier: Using Groq API');
        aiResponse = await _groqService.chat(state.messages);
      }

      // Fall back to mock if API fails or not configured
      if (aiResponse == null) {
        debugPrint('ChatNotifier: Using mock response');
        await Future.delayed(const Duration(milliseconds: 500));
        final intent = _classifyIntent(content.toLowerCase());
        aiResponse = switch (intent) {
          UserIntent.greeting => _handleGreeting(),
          UserIntent.programRequest => _generateProgramResponse(content.toLowerCase()),
          UserIntent.alternativeExercise => _handleAlternativeRequest(content.toLowerCase()),
          UserIntent.formAdvice => _handleFormAdvice(content.toLowerCase()),
          UserIntent.progressionAdvice => _handleProgressionAdvice(content.toLowerCase()),
          UserIntent.motivation => _handleMotivation(content.toLowerCase()),
          UserIntent.plateauHelp => _handlePlateauHelp(content.toLowerCase()),
          UserIntent.restRecovery => _handleRestRecovery(content.toLowerCase()),
          UserIntent.nutrition => _handleNutrition(content.toLowerCase()),
          UserIntent.general => _handleGeneral(content.toLowerCase()),
        };
      }

      final assistantMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        role: ChatRole.assistant,
        content: aiResponse.message,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
      );

      // Schedule save of assistant response
      _persistenceService.scheduleSave(state.messages);
    } catch (e) {
      debugPrint('ChatNotifier error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get response. Please try again.',
      );
    }
  }

  /// Clears the chat history from both state and persistence.
  Future<void> clearChat() async {
    state = const ChatState();
    await _persistenceService.clearChatHistory();
    debugPrint('ChatNotifier: Chat history cleared');
  }

  /// Removes an error message.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============================================================================
// QUICK PROMPT PROVIDER
// ============================================================================

/// Provider for quick prompt responses.
final quickPromptProvider = FutureProvider.autoDispose
    .family<AIResponse, ({QuickPromptCategory category, String? exerciseId})>(
  (ref, params) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.post('/ai/quick', data: {
        'category': params.category.name,
        if (params.exerciseId != null) 'exerciseId': params.exerciseId,
      });

      final data = response.data as Map<String, dynamic>;
      final responseJson = data['data'] as Map<String, dynamic>;

      return AIResponse(
        message: responseJson['message'] as String,
        suggestions: (responseJson['suggestions'] as List<dynamic>?)
            ?.map((s) => s as String)
            .toList() ?? [],
      );
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  },
);

// ============================================================================
// FORM CUES PROVIDER
// ============================================================================

/// Provider for exercise form cues.
final formCuesProvider = FutureProvider.autoDispose.family<FormCues, String>(
  (ref, exerciseId) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.get('/ai/form/$exerciseId');
      final data = response.data as Map<String, dynamic>;
      final cuesJson = data['data'] as Map<String, dynamic>;

      return FormCues(
        exerciseId: exerciseId,
        cues: (cuesJson['cues'] as List<dynamic>?)
                ?.map((s) => s as String)
                .toList() ??
            [],
        commonMistakes: (cuesJson['commonMistakes'] as List<dynamic>?)
                ?.map((s) => s as String)
                .toList() ??
            [],
        tips: (cuesJson['tips'] as List<dynamic>?)
                ?.map((s) => s as String)
                .toList() ??
            [],
      );
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  },
);

// ============================================================================
// AI STATUS PROVIDER
// ============================================================================

/// Provider for AI service status.
final aiStatusProvider = FutureProvider.autoDispose<AIServiceStatus>(
  (ref) async {
    final groqService = ref.watch(groqServiceProvider);

    // Check if API key is configured
    if (!AppConfig.hasGroqApiKey) {
      return const AIServiceStatus(
        available: true,
        model: 'Mock Responses',
        message: 'Using built-in responses. Add a Groq API key for real AI.',
      );
    }

    // Check if Groq API is reachable
    final isAvailable = await groqService.checkAvailability();

    if (isAvailable) {
      return AIServiceStatus(
        available: true,
        model: AppConfig.groqModel,
        message: 'AI coach powered by Groq is ready!',
      );
    } else {
      return const AIServiceStatus(
        available: true,
        model: 'Mock Responses (Fallback)',
        message: 'Groq API unavailable, using built-in responses.',
      );
    }
  },
);

// ============================================================================
// CONTEXTUAL SUGGESTIONS PROVIDER
// ============================================================================

/// Provider for contextual suggestions based on workout state.
final contextualSuggestionProvider = FutureProvider.autoDispose
    .family<ContextualSuggestion, String>(
  (ref, context) async {
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.get('/ai/suggestions', queryParameters: {
        'context': context,
      });

      final data = response.data as Map<String, dynamic>;
      final suggestionJson = data['data'] as Map<String, dynamic>;

      return ContextualSuggestion(
        context: suggestionJson['context'] as String? ?? context,
        suggestion: suggestionJson['suggestion'] as String? ?? '',
      );
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      throw Exception(error.message);
    }
  },
);

// ============================================================================
// PROGRESSION EXPLANATION PROVIDER
// ============================================================================

/// Provider for explaining a progression suggestion.
final progressionExplanationProvider = FutureProvider.autoDispose.family<
    String,
    ({String exerciseId, String action, String reasoning})>(
  (ref, params) async {
    final api = ref.read(apiClientProvider);

    final response = await api.get(
      '/ai-coach/explain-progression',
      queryParameters: {
        'exerciseId': params.exerciseId,
        'action': params.action,
        'reasoning': params.reasoning,
      },
    );

    return response.data['data']['explanation'] as String;
  },
);

/// User intent classification for better NLU.
enum UserIntent {
  programRequest,
  alternativeExercise,
  formAdvice,
  progressionAdvice,
  motivation,
  plateauHelp,
  restRecovery,
  nutrition,
  greeting,
  general,
}

/// Classifies user intent using weighted keyword matching.
///
/// Returns the most likely intent based on keyword presence.
UserIntent _classifyIntent(String message) {
  // Check for greetings first
  if (_isGreeting(message)) {
    return UserIntent.greeting;
  }

  // Check for program requests
  if (_isProgramRequest(message)) {
    return UserIntent.programRequest;
  }

  // Calculate scores for each intent
  final scores = <UserIntent, int>{};

  // Alternative exercise keywords
  final altScore = _countMatches(message, [
    'alternative', 'substitute', 'instead of', 'replace', 'swap',
    'different exercise', 'can\'t do', 'what else', 'similar to',
    'other options', 'variation', 'replacement', 'switch from',
  ]);
  scores[UserIntent.alternativeExercise] = altScore;

  // Form advice keywords
  final formScore = _countMatches(message, [
    'form', 'technique', 'how to', 'proper way', 'correct way',
    'am I doing', 'doing it right', 'cues', 'tips for', 'mistakes',
    'hurts when', 'pain during', 'feel it in', 'which muscles',
  ]);
  scores[UserIntent.formAdvice] = formScore;

  // Progression advice keywords
  final progressScore = _countMatches(message, [
    'progress', 'increase weight', 'add more', 'get stronger',
    'not improving', 'stalling', 'how much weight', 'when to add',
    'linear progression', 'deload', 'periodization', 'programming',
  ]);
  scores[UserIntent.progressionAdvice] = progressScore;

  // Motivation keywords
  final motivationScore = _countMatches(message, [
    'motivation', 'tired', 'don\'t feel like', 'skip workout',
    'lazy', 'struggling', 'hard day', 'give up', 'discouraged',
    'not seeing results', 'is it worth', 'keep going', 'inspire',
  ]);
  scores[UserIntent.motivation] = motivationScore;

  // Plateau keywords
  final plateauScore = _countMatches(message, [
    'plateau', 'stuck', 'not progressing', 'same weight',
    'can\'t lift more', 'stalled', 'hit a wall', 'break through',
    'been stuck', 'for weeks', 'not going up', 'maxed out',
  ]);
  scores[UserIntent.plateauHelp] = plateauScore;

  // Rest/recovery keywords
  final restScore = _countMatches(message, [
    'rest', 'recovery', 'how long between', 'rest time',
    'sore', 'doms', 'between sets', 'between workouts',
    'overtrained', 'sleep', 'days off', 'rest day',
  ]);
  scores[UserIntent.restRecovery] = restScore;

  // Nutrition keywords
  final nutritionScore = _countMatches(message, [
    'protein', 'eat', 'diet', 'calories', 'nutrition',
    'food', 'supplements', 'creatine', 'pre-workout',
    'post-workout', 'meal', 'macro', 'bulk', 'cut',
  ]);
  scores[UserIntent.nutrition] = nutritionScore;

  // Find highest scoring intent
  int maxScore = 0;
  UserIntent bestIntent = UserIntent.general;
  for (final entry in scores.entries) {
    if (entry.value > maxScore) {
      maxScore = entry.value;
      bestIntent = entry.key;
    }
  }

  return maxScore > 0 ? bestIntent : UserIntent.general;
}

/// Counts keyword matches in a message.
int _countMatches(String message, List<String> keywords) {
  int count = 0;
  for (final keyword in keywords) {
    if (message.contains(keyword)) {
      count++;
    }
  }
  return count;
}

/// Checks if message is a greeting.
bool _isGreeting(String message) {
  final greetings = ['hello', 'hi ', 'hey', 'good morning', 'good afternoon',
    'good evening', 'what\'s up', 'sup', 'yo '];
  for (final greeting in greetings) {
    if (message.startsWith(greeting) || message == greeting.trim()) {
      return true;
    }
  }
  return false;
}

/// Handles greeting messages.
AIResponse _handleGreeting() {
  return const AIResponse(
    message: '''Hey! I'm your LiftIQ AI coach. I'm here to help you with:

• **Exercise form** and technique tips
• **Program advice** - just ask me to build you a routine!
• **Progression strategies** for breaking plateaus
• **Exercise alternatives** when equipment isn't available
• **Motivation** when you need a boost

What can I help you with today?''',
    suggestions: [
      'Build me a program',
      'Help with bench press form',
      'I feel stuck on my lifts',
    ],
  );
}

/// Handles alternative exercise requests.
AIResponse _handleAlternativeRequest(String message) {
  // Determine which exercise they're asking about
  if (message.contains('bench') ||
      message.contains('dumbbell press') ||
      message.contains('chest press')) {
    return const AIResponse(
      message:
          "Here are some great alternatives to bench press:\n\n"
          "**Push-up Variations:**\n"
          "• Standard push-ups - bodyweight classic\n"
          "• Incline push-ups - easier, great for beginners\n"
          "• Decline push-ups - more chest emphasis\n\n"
          "**Other Pressing Movements:**\n"
          "• Machine chest press - stable, good for isolation\n"
          "• Cable flyes - constant tension\n"
          "• Floor press - limits range, easier on shoulders\n\n"
          "**Dumbbell Variations:**\n"
            "• Incline dumbbell press - upper chest focus\n"
            "• Dumbbell flyes - stretch emphasis\n"
            "• Single-arm dumbbell press - core challenge",
        suggestions: [
          'Try push-ups for a bodyweight option',
          'Use cables for constant tension',
          'Incline pressing for upper chest',
        ],
      );
  }

  if (message.contains('squat')) {
    return const AIResponse(
      message:
          "Here are excellent squat alternatives:\n\n"
          "**Barbell Variations:**\n"
          "• Front squat - more quad dominant\n"
          "• Goblet squat - great for learning\n"
          "• Bulgarian split squat - unilateral strength\n\n"
          "**Machine Options:**\n"
          "• Leg press - heavy loading, less spinal stress\n"
          "• Hack squat - guided movement pattern\n"
          "• Smith machine squat - added stability\n\n"
          "**Bodyweight:**\n"
          "• Pistol squats - advanced single-leg\n"
          "• Step-ups - functional movement\n"
          "• Lunges - walking or stationary",
      suggestions: [
        'Leg press for heavy quad work',
        'Bulgarian splits for unilateral training',
        'Goblet squats to improve form',
      ],
    );
  }

  if (message.contains('deadlift')) {
    return const AIResponse(
      message:
          "Here are great deadlift alternatives:\n\n"
          "**Barbell Variations:**\n"
          "• Romanian deadlift (RDL) - hamstring focus\n"
          "• Sumo deadlift - different hip angle\n"
          "• Trap bar deadlift - easier on lower back\n\n"
          "**Other Hip Hinges:**\n"
          "• Kettlebell swings - explosive power\n"
          "• Good mornings - posterior chain\n"
          "• Hip thrusts - glute emphasis\n"
          "• Cable pull-throughs - constant tension\n\n"
          "**Machine Options:**\n"
          "• Lying leg curl - hamstring isolation\n"
          "• Back extension - lower back strength",
      suggestions: [
        'RDLs for hamstring focus',
        'Trap bar for easier setup',
        'Hip thrusts for glute strength',
      ],
    );
  }

  // Generic alternatives response
  return const AIResponse(
    message:
        "When looking for exercise alternatives, consider:\n\n"
        "**Same Movement Pattern:**\n"
        "• Push → other pushing exercises\n"
        "• Pull → other pulling exercises\n"
        "• Hinge → other hip hinge movements\n"
        "• Squat → other knee-dominant exercises\n\n"
        "**Equipment Swaps:**\n"
        "• Barbell ↔ Dumbbells ↔ Cables ↔ Machines\n"
        "• Free weights ↔ Bodyweight\n\n"
        "Tell me which specific exercise you want to replace and I'll give you targeted alternatives!",
    suggestions: [
      'Ask about a specific exercise',
      'Consider your equipment available',
      'Match the muscle groups',
    ],
  );
}

/// Handles form advice requests.
AIResponse _handleFormAdvice(String message) {
  if (message.contains('bench') || message.contains('press')) {
    return const AIResponse(
      message:
          "Great question about the bench press! Here are the key form cues:\n\n"
          "**Setup:**\n"
          "1. **Arch your back** slightly and squeeze your shoulder blades together\n"
          "2. Plant feet firmly on the floor\n"
          "3. Grip slightly wider than shoulder-width\n\n"
          "**Execution:**\n"
          "• Lower bar to mid-chest with elbows at 45-75°\n"
          "• Control the descent - about 2 seconds down\n"
          "• Drive up explosively, keeping shoulders pinned\n\n"
          "**Common Mistakes:**\n"
          "• Flaring elbows too wide\n"
          "• Bouncing off chest\n"
          "• Lifting hips off bench",
      suggestions: [
        'Add pause reps to improve strength off chest',
        'Work on tricep lockout',
        'Try close-grip bench as accessory',
      ],
    );
  }

  if (message.contains('squat')) {
    return const AIResponse(
      message:
          "Squats are foundational! Key form points:\n\n"
          "**Setup:**\n"
          "• Bar on upper back (not neck)\n"
          "• Feet shoulder-width or slightly wider\n"
          "• Toes pointed slightly outward (15-30°)\n\n"
          "**Execution:**\n"
          "• Brace core and take a deep breath\n"
          "• Push knees out over toes as you descend\n"
          "• Keep chest up throughout\n"
          "• Hit depth (hip crease below knee)\n"
          "• Drive through whole foot on the way up\n\n"
          "**Common Mistakes:**\n"
          "• Knees caving inward\n"
          "• Rounding lower back\n"
          "• Rising on toes",
      suggestions: [
        'Add pause squats for control',
        'Work on hip and ankle mobility',
        'Try goblet squats to learn pattern',
      ],
    );
  }

  if (message.contains('deadlift')) {
    return const AIResponse(
      message:
          "Deadlift form essentials:\n\n"
          "**Setup:**\n"
          "• Bar over mid-foot\n"
          "• Shoulder-width stance (conventional)\n"
          "• Grip just outside knees\n"
          "• Shoulders slightly in front of bar\n\n"
          "**Execution:**\n"
          "• Brace core hard\n"
          "• Push floor away with legs first\n"
          "• Keep bar close to body\n"
          "• Lock out hips and knees together\n"
          "• Control the descent\n\n"
          "**Common Mistakes:**\n"
          "• Rounding lower back\n"
          "• Jerking the bar\n"
          "• Hips rising too fast",
      suggestions: [
        'Romanian deadlifts for hamstring work',
        'Deficit deadlifts for strength off floor',
        'Rack pulls for lockout',
      ],
    );
  }

  // Generic form advice
  return const AIResponse(
    message:
        "General form principles that apply to most exercises:\n\n"
        "**Before Every Rep:**\n"
        "• Set your position\n"
        "• Take a breath and brace your core\n"
        "• Create tension before moving\n\n"
        "**During the Rep:**\n"
        "• Control the weight - don't let it control you\n"
        "• Full range of motion when possible\n"
        "• Focus on the muscles working\n\n"
        "**Which exercise would you like specific form tips for?**",
    suggestions: [
      'Bench press form',
      'Squat form tips',
      'Deadlift technique',
    ],
  );
}

/// Handles progression advice requests.
AIResponse _handleProgressionAdvice(String message) {
  return const AIResponse(
    message:
        "Progressive overload is the key to getting stronger! Here's how to do it:\n\n"
        "**Double Progression Method:**\n"
        "1. Pick a rep range (e.g., 8-12 reps)\n"
        "2. When you hit the top of the range for all sets, add weight\n"
        "3. Drop back to the bottom of the range\n"
        "4. Build back up and repeat\n\n"
        "**Example:**\n"
        "Week 1: 60kg x 8, 8, 7 (not ready to add weight)\n"
        "Week 2: 60kg x 8, 8, 8 (ready!)\n"
        "Week 3: 62.5kg x 6, 6, 5 (dropped reps, that's normal)\n"
        "Week 4: 62.5kg x 7, 7, 6 (progressing!)\n\n"
        "**How Much to Add:**\n"
        "• Upper body: 2.5kg per increase\n"
        "• Lower body: 5kg per increase\n"
        "• Smaller muscles: 1-2.5kg",
    suggestions: [
      'What if I can\'t add weight?',
      'How often should I deload?',
      'Rep range for my goals',
    ],
  );
}

/// Handles motivation requests.
AIResponse _handleMotivation(String message) {
  return const AIResponse(
    message:
        "We all have those days! Remember:\n\n"
        "**Perspective:**\n"
        "• **Showing up is half the battle** - even a lighter workout counts\n"
        "• Bad workouts build character and consistency\n"
        "• You never regret going, only skipping\n\n"
        "**The Truth:**\n"
        "• Progress isn't linear - it's a zigzag upward\n"
        "• Rest days are part of getting stronger\n"
        "• Discipline > Motivation\n\n"
        "**Your Journey:**\n"
        "You're already ahead of 95% of people by just being here and trying to improve. That dedication is something to be proud of.\n\n"
        "Trust the process - every rep, every set, every workout is building the stronger version of you.",
  );
}

/// Handles plateau help requests.
AIResponse _handlePlateauHelp(String message) {
  return const AIResponse(
    message:
        "Plateaus happen to everyone - they're actually a sign you've been training hard! "
        "Here's how to break through:\n\n"
        "**Strategy 1: Deload (Most Common Fix)**\n"
        "• Drop weight by 10-20% for one week\n"
        "• Keep reps the same\n"
        "• Come back stronger next week\n\n"
        "**Strategy 2: Change Variables**\n"
        "• Switch rep range (3x8 → 5x5 or 4x10)\n"
        "• Try a different exercise variation\n"
        "• Adjust rest periods\n\n"
        "**Strategy 3: Check Recovery**\n"
        "• Are you sleeping 7-9 hours?\n"
        "• Eating enough protein (1.6-2.2g/kg)?\n"
        "• Taking enough rest days?\n\n"
        "**Strategy 4: Add Volume**\n"
        "• Add an extra set\n"
        "• Add a back-off set at lighter weight\n"
        "• Include an accessory exercise",
    suggestions: [
      'Take a deload week',
      'Try different rep scheme',
      'Check my sleep and nutrition',
    ],
  );
}

/// Handles rest and recovery requests.
AIResponse _handleRestRecovery(String message) {
  if (message.contains('between sets')) {
    return const AIResponse(
      message:
          "Rest between sets depends on your goals:\n\n"
          "**Strength (1-5 reps):**\n"
          "• 3-5 minutes between sets\n"
          "• Full ATP recovery for max effort\n\n"
          "**Hypertrophy (6-12 reps):**\n"
          "• 90 seconds - 2 minutes\n"
          "• Partial recovery maintains metabolic stress\n\n"
          "**Endurance (12+ reps):**\n"
          "• 60-90 seconds\n"
          "• Shorter rest builds conditioning\n\n"
          "**Compound vs Isolation:**\n"
          "• Squats/Deadlifts: rest longer (2-5 min)\n"
          "• Curls/Laterals: rest less (60-90s)",
      suggestions: [
        'How long between workouts?',
        'Do I need rest days?',
        'Deload timing',
      ],
    );
  }

  return const AIResponse(
    message:
        "Recovery is when you actually get stronger! Here's the breakdown:\n\n"
        "**Between Workouts:**\n"
        "• 48-72 hours for same muscle group\n"
        "• Upper/Lower splits: 2-3 days between same muscles\n"
        "• Full body: minimum 1 day between sessions\n\n"
        "**Deload Weeks:**\n"
        "• Every 4-6 weeks\n"
        "• Cut volume or intensity by 40-50%\n"
        "• Helps prevent burnout and overtraining\n\n"
        "**Sleep:**\n"
        "• 7-9 hours per night\n"
        "• This is when most muscle repair happens\n"
        "• Poor sleep = poor gains\n\n"
        "**Signs You Need More Rest:**\n"
        "• Constant fatigue\n"
        "• Strength going backwards\n"
        "• Nagging aches that won't go away",
    suggestions: [
      'Rest time between sets',
      'When to take a deload',
      'How to improve sleep quality',
    ],
  );
}

/// Handles nutrition questions.
AIResponse _handleNutrition(String message) {
  return const AIResponse(
    message:
        "I'm primarily a workout coach, but here are the basics:\n\n"
        "**Protein:**\n"
        "• 1.6-2.2g per kg bodyweight for muscle building\n"
        "• Spread across 4-5 meals\n"
        "• Quality sources: meat, fish, eggs, dairy, legumes\n\n"
        "**Calories:**\n"
        "• Muscle gain: 200-500 calorie surplus\n"
        "• Fat loss: 300-500 calorie deficit\n"
        "• Maintenance: balance in and out\n\n"
        "**Timing:**\n"
        "• Pre-workout: light meal 1-2 hours before\n"
        "• Post-workout: protein within 2-3 hours\n"
        "• Sleep: avoid heavy meals right before bed\n\n"
        "*For detailed nutrition advice, consider consulting a registered dietitian.*",
    suggestions: [
      'How much protein do I need?',
      'What should I eat pre-workout?',
      'Supplement recommendations',
    ],
  );
}

/// Handles general/unknown queries.
AIResponse _handleGeneral(String message) {
  return const AIResponse(
    message:
        "I'm here to help with all things lifting! I can assist with:\n\n"
        "• **Exercise form** - proper technique and cues\n"
        "• **Programming** - build you a workout routine\n"
        "• **Progression** - how to keep getting stronger\n"
        "• **Alternatives** - exercise swaps for any situation\n"
        "• **Plateaus** - strategies to break through\n"
        "• **Recovery** - rest and deload advice\n\n"
        "What would you like to focus on today?",
    suggestions: [
      'Ask about form cues',
      'Get progression advice',
      'Find exercise alternatives',
    ],
  );
}

AIResponse _getMockQuickResponse(QuickPromptCategory category, String? exerciseId) {
  switch (category) {
    case QuickPromptCategory.form:
      return AIResponse(
        message: exerciseId != null
            ? "Here are the key form cues for $exerciseId:\n\n"
                "1. Set up with proper positioning\n"
                "2. Maintain tension throughout the movement\n"
                "3. Control the eccentric (lowering) phase\n"
                "4. Drive through the full range of motion"
            : "General form tips for strength training:\n\n"
                "• Always warm up before heavy sets\n"
                "• Focus on mind-muscle connection\n"
                "• Don't sacrifice form for weight",
        suggestions: ['Focus on breathing', 'Record yourself to check form'],
      );
    case QuickPromptCategory.progression:
      return const AIResponse(
        message:
            "Progressive overload is key to gains! The basic principle:\n\n"
            "1. Hit your target reps (e.g., 3x8)\n"
            "2. Once you can do this for 2 sessions, add weight\n"
            "3. Drop back to lower reps with new weight\n"
            "4. Build back up and repeat!\n\n"
            "This 'double progression' method is safe and effective.",
        suggestions: ['Track your workouts consistently', 'Be patient with progress'],
      );
    case QuickPromptCategory.alternative:
      return AIResponse(
        message: exerciseId != null
            ? "Looking for alternatives to $exerciseId? Here are some options:\n\n"
                "• Similar movement pattern variations\n"
                "• Machine versions for isolation\n"
                "• Dumbbell alternatives for unilateral work"
            : "When you need exercise alternatives, consider:\n\n"
                "• Same muscle groups targeted\n"
                "• Similar movement patterns\n"
                "• Your available equipment",
        suggestions: ['Match the muscle groups', 'Consider your limitations'],
      );
    case QuickPromptCategory.explanation:
      return AIResponse(
        message: exerciseId != null
            ? "$exerciseId is a compound movement that:\n\n"
                "• Works multiple muscle groups\n"
                "• Builds functional strength\n"
                "• Has good carryover to daily activities"
            : "Understanding your exercises helps you train smarter:\n\n"
                "• Know which muscles you're targeting\n"
                "• Understand proper range of motion\n"
                "• Learn optimal rep ranges for your goals",
      );
    case QuickPromptCategory.motivation:
      return const AIResponse(
        message:
            "You've got this! Remember:\n\n"
            "💪 Every rep counts toward your goals\n"
            "📈 Progress happens over weeks and months\n"
            "🏆 Showing up is already a win\n\n"
            "Your consistency is building something great. Let's crush this workout!",
      );
  }
}

FormCues _getMockFormCues(String exerciseId) {
  if (exerciseId.contains('bench')) {
    return const FormCues(
      exerciseId: 'bench-press',
      cues: [
        'Squeeze shoulder blades together',
        'Feet flat on floor, drive through legs',
        'Lower bar to mid-chest',
        'Press in a slight arc back to start',
      ],
      commonMistakes: [
        'Bouncing bar off chest',
        'Flaring elbows too wide',
        'Lifting hips off bench',
      ],
      tips: [
        'Use a spotter for heavy sets',
        'Pause briefly at the bottom for more control',
      ],
    );
  }

  if (exerciseId.contains('squat')) {
    return const FormCues(
      exerciseId: 'squat',
      cues: [
        'Brace core before descending',
        'Push knees out over toes',
        'Keep chest up throughout',
        'Drive through whole foot',
      ],
      commonMistakes: [
        'Knees caving inward',
        'Rounding lower back',
        'Coming up on toes',
      ],
      tips: [
        'Work on ankle mobility',
        'Start with goblet squats to learn pattern',
      ],
    );
  }

  // Default
  return FormCues(
    exerciseId: exerciseId,
    cues: [
      'Maintain proper posture',
      'Control the movement',
      'Breathe consistently',
      'Focus on the target muscles',
    ],
    commonMistakes: [
      'Using momentum',
      'Rushing through reps',
      'Using too much weight',
    ],
    tips: [
      'Start lighter to perfect form',
      'Mind-muscle connection matters',
    ],
  );
}

ContextualSuggestion _getMockContextualSuggestion(String context) {
  switch (context) {
    case 'pre_workout':
      return const ContextualSuggestion(
        context: 'pre_workout',
        suggestion:
            "Remember to warm up with some dynamic stretches and a few light sets before your working weight!",
      );
    case 'during_workout':
      return const ContextualSuggestion(
        context: 'during_workout',
        suggestion:
            "You're doing great! Focus on controlling each rep and maintaining good form throughout your sets.",
      );
    case 'post_workout':
      return const ContextualSuggestion(
        context: 'post_workout',
        suggestion:
            "Awesome workout! Don't forget to hydrate and get some protein within the next hour for optimal recovery.",
      );
    default:
      return const ContextualSuggestion(
        context: 'general',
        suggestion: "Stay consistent with your training - that's the real key to progress!",
      );
  }
}

// ============================================================================
// PROGRAM GENERATION
// ============================================================================

/// Checks if the user is requesting a workout program.
bool _isProgramRequest(String message) {
  final programKeywords = [
    'build me a program',
    'create a program',
    'create a routine',
    'build a routine',
    'make me a program',
    'design a program',
    'give me a program',
    'workout program',
    'training program',
    'weekly routine',
    'workout plan',
    'training plan',
    'split routine',
    'ppl program',
    'push pull legs',
    'upper lower',
    'full body program',
    'strength program',
    'hypertrophy program',
    'bodybuilding program',
    'beginner program',
    'intermediate program',
  ];

  for (final keyword in programKeywords) {
    if (message.contains(keyword)) {
      return true;
    }
  }
  return false;
}

/// Generates a workout program response based on user request.
AIResponse _generateProgramResponse(String message) {
  // Determine program type from message
  if (message.contains('strength') || message.contains('powerlifting') || message.contains('5x5')) {
    return _getStrengthProgram();
  } else if (message.contains('hypertrophy') || message.contains('bodybuilding') || message.contains('muscle')) {
    return _getHypertrophyProgram();
  } else if (message.contains('beginner') || message.contains('starting')) {
    return _getBeginnerProgram();
  } else if (message.contains('upper lower') || message.contains('4 day') || message.contains('4-day')) {
    return _getUpperLowerProgram();
  } else if (message.contains('push pull legs') || message.contains('ppl') || message.contains('6 day')) {
    return _getPPLProgram();
  } else if (message.contains('3 day') || message.contains('3-day') || message.contains('full body')) {
    return _getFullBodyProgram();
  }

  // Default to a balanced 3-day program
  return _getFullBodyProgram();
}

AIResponse _getStrengthProgram() {
  return const AIResponse(
    message: '''Here's a **Strength-Focused 3-Day Program** designed for building raw strength on the main lifts:

## Day 1: Squat Focus
| Exercise | Sets x Reps | Rest |
|----------|-------------|------|
| Barbell Squat | 5x5 | 3-5 min |
| Pause Squat | 3x3 | 3 min |
| Leg Press | 3x8-10 | 2 min |
| Leg Curl | 3x10-12 | 90s |

## Day 2: Bench Focus
| Exercise | Sets x Reps | Rest |
|----------|-------------|------|
| Bench Press | 5x5 | 3-5 min |
| Close-Grip Bench | 3x6-8 | 2 min |
| Overhead Press | 3x6-8 | 2 min |
| Tricep Pushdown | 3x12 | 90s |
| Face Pulls | 3x15 | 60s |

## Day 3: Deadlift Focus
| Exercise | Sets x Reps | Rest |
|----------|-------------|------|
| Deadlift | 5x5 | 3-5 min |
| Barbell Row | 4x6-8 | 2 min |
| Lat Pulldown | 3x8-10 | 90s |
| Barbell Curl | 3x10 | 60s |

**Key Points:**
- Add 2.5kg to upper body lifts and 5kg to lower body lifts each week when you complete all reps
- Rest at least 1 day between sessions
- Deload every 4th week (reduce weight by 10%)

Would you like me to save this as a template you can start using?''',
    suggestions: [
      'Save as a template',
      'Modify for 4-day split',
      'Add accessory work',
    ],
  );
}

AIResponse _getHypertrophyProgram() {
  return const AIResponse(
    message: '''Here's a **Hypertrophy-Focused 4-Day Upper/Lower Split** for maximum muscle growth:

## Day 1: Upper A (Strength)
| Exercise | Sets x Reps | Rest |
|----------|-------------|------|
| Bench Press | 4x6-8 | 2-3 min |
| Barbell Row | 4x6-8 | 2-3 min |
| Overhead Press | 3x8-10 | 2 min |
| Pull-Ups | 3x8-10 | 2 min |
| Lateral Raises | 3x12-15 | 60s |
| Tricep Pushdown | 3x12-15 | 60s |
| Barbell Curl | 3x12-15 | 60s |

## Day 2: Lower A (Strength)
| Exercise | Sets x Reps | Rest |
|----------|-------------|------|
| Squat | 4x6-8 | 2-3 min |
| Romanian Deadlift | 4x8-10 | 2 min |
| Leg Press | 3x10-12 | 90s |
| Leg Curl | 3x10-12 | 90s |
| Calf Raises | 4x12-15 | 60s |

## Day 3: Upper B (Volume)
| Exercise | Sets x Reps | Rest |
|----------|-------------|------|
| Incline DB Press | 4x10-12 | 90s |
| Cable Row | 4x10-12 | 90s |
| Dumbbell Shoulder Press | 3x10-12 | 90s |
| Lat Pulldown | 3x10-12 | 90s |
| Face Pulls | 3x15-20 | 60s |
| Incline Curl | 3x12-15 | 60s |
| Overhead Extension | 3x12-15 | 60s |

## Day 4: Lower B (Volume)
| Exercise | Sets x Reps | Rest |
|----------|-------------|------|
| Leg Press | 4x12-15 | 90s |
| Romanian Deadlift | 3x10-12 | 90s |
| Walking Lunges | 3x12 each | 90s |
| Leg Curl | 3x12-15 | 60s |
| Leg Extension | 3x12-15 | 60s |
| Calf Raises | 4x15-20 | 60s |

**Training Split:** Mon/Tue/Thu/Fri with Wed/Sat/Sun off

Would you like me to save this as a template?''',
    suggestions: [
      'Save as a template',
      'Adjust for 5-day split',
      'Focus more on specific muscles',
    ],
  );
}

AIResponse _getBeginnerProgram() {
  return const AIResponse(
    message: '''Here's a **Beginner 3-Day Full Body Program** - perfect for building a foundation:

## Workout A
| Exercise | Sets x Reps | Rest |
|----------|-------------|------|
| Barbell Squat | 3x8 | 2-3 min |
| Bench Press | 3x8 | 2-3 min |
| Barbell Row | 3x8 | 2-3 min |
| Overhead Press | 2x10 | 2 min |
| Plank | 3x30-60s | 60s |

## Workout B
| Exercise | Sets x Reps | Rest |
|----------|-------------|------|
| Deadlift | 3x5 | 3 min |
| Incline DB Press | 3x10 | 2 min |
| Lat Pulldown | 3x10 | 2 min |
| Leg Press | 3x12 | 90s |
| Bicep Curls | 2x12 | 60s |

## Weekly Schedule
- **Monday:** Workout A
- **Wednesday:** Workout B
- **Friday:** Workout A
- Next week: B, A, B

**Progression:**
- When you complete all reps with good form for 2 sessions, add 2.5kg
- Focus on learning proper technique before adding weight
- Rest 1-2 minutes between sets (up to 3 min for heavy compounds)

**Key Tips:**
- Watch form videos for each exercise
- Start light and focus on technique
- Consistency is more important than intensity

Would you like me to save this as a template?''',
    suggestions: [
      'Save as a template',
      'Show me exercise form tips',
      'What if I can only train 2 days?',
    ],
  );
}

AIResponse _getUpperLowerProgram() {
  return const AIResponse(
    message: '''Here's a **4-Day Upper/Lower Split** - great balance of frequency and recovery:

## Day 1: Upper A
| Exercise | Sets x Reps | Rest |
|----------|-------------|------|
| Bench Press | 4x6-8 | 2-3 min |
| Barbell Row | 4x6-8 | 2-3 min |
| Overhead Press | 3x8-10 | 2 min |
| Pull-Ups | 3x6-10 | 2 min |
| Tricep Pushdown | 3x10-12 | 60s |

## Day 2: Lower A
| Exercise | Sets x Reps | Rest |
|----------|-------------|------|
| Squat | 4x6-8 | 2-3 min |
| Romanian Deadlift | 3x8-10 | 2 min |
| Leg Press | 3x10-12 | 90s |
| Leg Curl | 3x10-12 | 90s |
| Calf Raises | 4x12-15 | 60s |

## Day 3: Upper B
| Exercise | Sets x Reps | Rest |
|----------|-------------|------|
| Incline DB Press | 4x8-10 | 2 min |
| Lat Pulldown | 4x8-10 | 2 min |
| Lateral Raises | 3x12-15 | 60s |
| Face Pulls | 3x15 | 60s |
| Barbell Curl | 3x10-12 | 60s |

## Day 4: Lower B
| Exercise | Sets x Reps | Rest |
|----------|-------------|------|
| Deadlift | 4x5 | 3 min |
| Leg Press | 3x12-15 | 90s |
| Lunges | 3x10 each | 90s |
| Leg Curl | 3x12-15 | 60s |
| Calf Raises | 4x15-20 | 60s |

**Schedule:** Mon/Tue/Thu/Fri

Would you like me to save this as a template?''',
    suggestions: [
      'Save as a template',
      'Modify rest days',
      'Add more arm work',
    ],
  );
}

AIResponse _getPPLProgram() {
  return const AIResponse(
    message: '''Here's a **Push/Pull/Legs 6-Day Split** - high frequency for maximum gains:

## Push Day
| Exercise | Sets x Reps | Rest |
|----------|-------------|------|
| Bench Press | 4x6-8 | 2-3 min |
| Overhead Press | 3x8-10 | 2 min |
| Incline DB Press | 3x10-12 | 90s |
| Lateral Raises | 4x12-15 | 60s |
| Tricep Pushdown | 3x12-15 | 60s |
| Overhead Extension | 2x15 | 60s |

## Pull Day
| Exercise | Sets x Reps | Rest |
|----------|-------------|------|
| Deadlift | 4x5 | 3 min |
| Barbell Row | 4x6-8 | 2 min |
| Lat Pulldown | 3x8-10 | 90s |
| Face Pulls | 3x15-20 | 60s |
| Barbell Curl | 3x10-12 | 60s |
| Hammer Curl | 2x12-15 | 60s |

## Leg Day
| Exercise | Sets x Reps | Rest |
|----------|-------------|------|
| Squat | 4x6-8 | 2-3 min |
| Romanian Deadlift | 3x8-10 | 2 min |
| Leg Press | 3x10-12 | 90s |
| Leg Curl | 3x10-12 | 60s |
| Calf Raises | 4x12-15 | 60s |

**Schedule:** Push-Pull-Legs-Rest-Push-Pull-Legs (or with 1 rest day after each cycle)

**Progression:**
- Increase weight when you hit the top of rep ranges for 2 sessions
- Deload every 4-6 weeks

Would you like me to save this as a template?''',
    suggestions: [
      'Save as a template',
      'Reduce to 5 days',
      'Add more volume',
    ],
  );
}

AIResponse _getFullBodyProgram() {
  return const AIResponse(
    message: '''Here's a **3-Day Full Body Program** - efficient and effective:

## Workout A
| Exercise | Sets x Reps | Rest |
|----------|-------------|------|
| Squat | 4x6-8 | 2-3 min |
| Bench Press | 4x6-8 | 2-3 min |
| Barbell Row | 4x6-8 | 2 min |
| Overhead Press | 3x8-10 | 2 min |
| Bicep Curl | 2x10-12 | 60s |
| Plank | 3x30-60s | 60s |

## Workout B
| Exercise | Sets x Reps | Rest |
|----------|-------------|------|
| Deadlift | 4x5 | 3 min |
| Incline DB Press | 4x8-10 | 2 min |
| Lat Pulldown | 4x8-10 | 2 min |
| Leg Press | 3x10-12 | 90s |
| Face Pulls | 3x15 | 60s |
| Tricep Pushdown | 2x12-15 | 60s |

## Workout C
| Exercise | Sets x Reps | Rest |
|----------|-------------|------|
| Front Squat | 3x8-10 | 2-3 min |
| Dumbbell Press | 3x8-10 | 2 min |
| Cable Row | 3x10-12 | 90s |
| Romanian Deadlift | 3x10-12 | 2 min |
| Lateral Raises | 3x12-15 | 60s |
| Calf Raises | 3x15 | 60s |

**Schedule:** Mon (A) - Wed (B) - Fri (C), repeat

**This program is great because:**
- Each muscle gets trained 3x per week
- Hits all movement patterns
- Good balance of strength and volume
- Plenty of recovery time

Would you like me to save this as a template?''',
    suggestions: [
      'Save as a template',
      'Switch to 4-day split',
      'Add more arm work',
    ],
  );
}
