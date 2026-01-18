# AI Coach - Feature Documentation

## Overview

The AI Coach feature provides an intelligent conversational interface for users to get personalized fitness advice. It integrates with Groq's Llama 3.1 70B model to provide context-aware responses about exercise form, progression strategies, exercise alternatives, and motivation.

## Architecture Decisions

### Backend Architecture

1. **Groq API Integration**: We chose Groq for its fast inference speeds (ideal for chat) and cost-effective pricing. The service uses Llama 3.1 70B for high-quality fitness advice.

2. **System Prompt Engineering**: The AI is given detailed context about being a fitness coach with guardrails against medical advice. This ensures safe, helpful responses.

3. **Context Injection**: User workout data (recent sessions, PRs, exercise history) is injected into the system prompt to provide personalized advice.

4. **Service Pattern**: All AI logic is encapsulated in `AIService` following the existing backend patterns.

### Flutter Architecture

1. **Freezed Models**: All data classes use Freezed for immutability and automatic JSON serialization.

2. **StateNotifier Pattern**: The `ChatNotifier` uses StateNotifier for chat state management, providing optimistic updates and error handling.

3. **AutoDispose Providers**: Quick prompt and form cue providers use `autoDispose` to prevent memory leaks.

4. **Mock Data**: Currently using mock responses for development; real API integration requires `GROQ_API_KEY` environment variable.

## Key Files

### Backend

| File | Purpose |
|------|---------|
| `backend/src/services/ai.service.ts` | Core AI service with Groq integration |
| `backend/src/routes/ai.routes.ts` | REST API endpoints for AI features |
| `backend/src/routes/index.ts` | Route aggregator (updated) |

### Flutter

| File | Purpose |
|------|---------|
| `app/lib/features/ai_coach/models/chat_message.dart` | ChatMessage, AIResponse models |
| `app/lib/features/ai_coach/models/quick_prompt.dart` | QuickPromptCategory, FormCues, AIServiceStatus |
| `app/lib/features/ai_coach/providers/ai_coach_provider.dart` | ChatNotifier, all AI providers |
| `app/lib/features/ai_coach/screens/chat_screen.dart` | Full chat UI implementation |
| `app/lib/core/router/app_router.dart` | Router (updated with /ai-coach route) |

## Data Models

### ChatMessage

```dart
@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required ChatRole role,  // system, user, assistant
    required String content,
    required DateTime timestamp,
    @Default(false) bool isStreaming,
    String? error,
  }) = _ChatMessage;
}
```

### AIResponse

```dart
@freezed
class AIResponse with _$AIResponse {
  const factory AIResponse({
    required String message,
    @Default([]) List<String> suggestions,
    @Default([]) List<String> relatedExercises,
    String? safetyNote,
  }) = _AIResponse;
}
```

### QuickPromptCategory

An enum with 5 categories:
- `form` - Form tips and technique
- `progression` - Progression strategies
- `alternative` - Exercise alternatives
- `explanation` - Exercise explanations
- `motivation` - Motivation and encouragement

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/ai/chat` | Send a chat message and get AI response |
| POST | `/api/v1/ai/quick` | Get quick response for a category |
| GET | `/api/v1/ai/form/:exerciseId` | Get form cues for an exercise |
| POST | `/api/v1/ai/explain-progression` | Explain a progression suggestion |
| GET | `/api/v1/ai/suggestions` | Get contextual workout suggestions |
| GET | `/api/v1/ai/status` | Check AI service status |

## Testing Approach

### Unit Tests (TODO)
- Test ChatNotifier state transitions
- Test message formatting and timestamps
- Test quick prompt category handling

### Widget Tests (TODO)
- Test message bubble rendering
- Test input field behavior
- Test quick prompt chip interactions

### Integration Tests (TODO)
- Test full chat flow from input to response
- Test error handling and retry
- Test AI service availability checking

## Known Limitations

1. **Mock Responses**: Currently using mock data; real API requires GROQ_API_KEY
2. **No Streaming**: Responses are not streamed; full response waits for completion
3. **No Persistence**: Chat history is not persisted; cleared on app restart
4. **No Rate Limiting**: Client-side rate limiting not yet implemented
5. **Basic Context**: User workout context not yet injected (requires workout history integration)

## Learning Resources

- [Groq API Documentation](https://console.groq.com/docs)
- [Llama 3 Model Card](https://github.com/meta-llama/llama3)
- [Flutter StateNotifier](https://pub.dev/packages/state_notifier)
- [Freezed Package](https://pub.dev/packages/freezed)
- [Riverpod State Management](https://riverpod.dev/)

## Future Improvements

1. **Streaming Responses**: Implement SSE or WebSocket streaming for real-time response display
2. **Chat Persistence**: Save chat history to local storage (Isar) for session continuity
3. **Workout Context**: Inject user's recent workout data for personalized advice
4. **Voice Input**: Add speech-to-text for hands-free gym use
5. **Exercise Recognition**: Link mentioned exercises to exercise library
6. **Workout Suggestions**: Generate workout recommendations based on chat history
