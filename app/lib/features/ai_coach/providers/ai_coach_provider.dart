/// LiftIQ - AI Coach Provider
///
/// Manages the state for AI chat and coaching features.
/// Connects to the Groq-powered backend AI service.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
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
  (ref) => ChatNotifier(ref),
);

/// Notifier for chat state management.
class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;

  ChatNotifier(this._ref) : super(const ChatState());

  /// Sends a message and gets AI response from the API.
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
      final api = _ref.read(apiClientProvider);

      // Build conversation history for context
      final conversationHistory = state.messages
          .take(20) // Limit to last 20 messages
          .map((m) => {
                'role': m.role == ChatRole.user ? 'user' : 'assistant',
                'content': m.content,
              })
          .toList();

      final response = await api.post('/ai/chat', data: {
        'message': content,
        'conversationHistory': conversationHistory,
      });

      final data = response.data as Map<String, dynamic>;
      final aiResponseJson = data['data'] as Map<String, dynamic>;

      final assistantMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        role: ChatRole.assistant,
        content: aiResponseJson['message'] as String,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
      );
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      state = state.copyWith(
        isLoading: false,
        error: error.message,
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
    final api = ref.read(apiClientProvider);

    try {
      final response = await api.get('/ai/status');
      final data = response.data as Map<String, dynamic>;
      final statusJson = data['data'] as Map<String, dynamic>;

      return AIServiceStatus(
        available: statusJson['available'] as bool? ?? false,
        model: statusJson['model'] as String?,
        message: statusJson['message'] as String? ?? '',
      );
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      return AIServiceStatus(
        available: false,
        model: null,
        message: error.message,
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

    try {
      final response = await api.post('/ai/explain-progression', data: {
        'exerciseId': params.exerciseId,
        'action': params.action,
        'reasoning': params.reasoning,
      });

      final data = response.data as Map<String, dynamic>;
      final explainJson = data['data'] as Map<String, dynamic>;

      return explainJson['explanation'] as String? ?? params.reasoning;
    } on DioException catch (e) {
      final error = ApiClient.getApiException(e);
      // Return original reasoning if API call fails
      return params.reasoning;
    }
  },
);
