/// LiftIQ - AI Coach Provider
///
/// Manages the state for AI chat and coaching features.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/quick_prompt.dart';

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
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(),
);

/// Notifier for chat state management.
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState());

  /// Sends a message and gets AI response.
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

    try {
      // TODO: Call API
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock AI response
      final aiResponse = _getMockResponse(content);

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
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get response. Please try again.',
      );
    }
  }

  /// Clears the chat history.
  void clearChat() {
    state = const ChatState();
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
    // TODO: Call API
    await Future.delayed(const Duration(milliseconds: 600));
    return _getMockQuickResponse(params.category, params.exerciseId);
  },
);

// ============================================================================
// FORM CUES PROVIDER
// ============================================================================

/// Provider for exercise form cues.
final formCuesProvider = FutureProvider.autoDispose.family<FormCues, String>(
  (ref, exerciseId) async {
    // TODO: Call API
    await Future.delayed(const Duration(milliseconds: 400));
    return _getMockFormCues(exerciseId);
  },
);

// ============================================================================
// AI STATUS PROVIDER
// ============================================================================

/// Provider for AI service status.
final aiStatusProvider = FutureProvider.autoDispose<AIServiceStatus>(
  (ref) async {
    // TODO: Call API
    await Future.delayed(const Duration(milliseconds: 200));
    return const AIServiceStatus(
      available: true,
      model: 'llama-3.1-70b-versatile',
      message: 'AI coach is ready to help!',
    );
  },
);

// ============================================================================
// CONTEXTUAL SUGGESTIONS PROVIDER
// ============================================================================

/// Provider for contextual suggestions based on workout state.
final contextualSuggestionProvider = FutureProvider.autoDispose
    .family<ContextualSuggestion, String>(
  (ref, context) async {
    // TODO: Call API
    await Future.delayed(const Duration(milliseconds: 400));
    return _getMockContextualSuggestion(context);
  },
);

// ============================================================================
// MOCK DATA
// ============================================================================

AIResponse _getMockResponse(String userMessage) {
  final lowerMessage = userMessage.toLowerCase();

  if (lowerMessage.contains('bench') || lowerMessage.contains('press')) {
    return const AIResponse(
      message:
          "Great question about the bench press! Here are some key tips:\n\n"
          "1. **Arch your back** slightly and squeeze your shoulder blades together\n"
          "2. **Grip width** should put your forearms vertical at the bottom\n"
          "3. **Control the descent** - about 2 seconds down, explosive up\n\n"
          "Based on your recent progress, you're doing well! Keep focusing on hitting 8 reps before adding weight.",
      suggestions: [
        'Add pause reps to improve off-chest strength',
        'Work on your tricep lockout',
        'Consider adding close-grip bench as accessory',
      ],
    );
  }

  if (lowerMessage.contains('squat')) {
    return const AIResponse(
      message:
          "Squats are foundational for lower body strength! Key points:\n\n"
          "• Keep your chest up and core braced\n"
          "• Push your knees out over your toes\n"
          "• Hit proper depth (hip crease below knee)\n\n"
          "Your squat numbers have been improving steadily. Keep up the great work!",
      suggestions: [
        'Add pause squats for better control',
        'Work on hip mobility',
        'Consider front squats for variety',
      ],
    );
  }

  if (lowerMessage.contains('plateau') || lowerMessage.contains('stuck')) {
    return const AIResponse(
      message:
          "Plateaus happen to everyone - they're actually a sign you've been training hard! "
          "Here are some strategies to break through:\n\n"
          "1. **Deload week** - Drop weight by 10% for a week to recover\n"
          "2. **Change rep range** - If doing 3x8, try 5x5 or 4x10\n"
          "3. **Add variation** - Try a different angle or grip\n\n"
          "Looking at your history, you might benefit from a slight deload followed by a fresh push.",
      suggestions: [
        'Take a deload week',
        'Try a different rep scheme',
        'Add more sleep and protein',
      ],
    );
  }

  if (lowerMessage.contains('motivation') || lowerMessage.contains('tired')) {
    return const AIResponse(
      message:
          "We all have those days! Remember:\n\n"
          "• **Showing up is half the battle** - even a lighter workout counts\n"
          "• Your workout streak shows real dedication\n"
          "• Progress isn't linear, but consistency is key\n\n"
          "You've already built great habits. Trust the process and be proud of your journey!",
    );
  }

  // Default response
  return const AIResponse(
    message:
        "That's a great question! As your AI coach, I'm here to help with:\n\n"
        "• **Exercise form** and technique\n"
        "• **Progression strategies** for your lifts\n"
        "• **Program advice** and workout planning\n"
        "• **Motivation** when you need a boost\n\n"
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
