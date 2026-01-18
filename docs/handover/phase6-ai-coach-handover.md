# Phase 6: AI Coach - Handover Document

## Summary

Phase 6 implements the AI Coach feature for LiftIQ. This includes a full backend service for AI chat via Groq's Llama 3.1 70B model, REST API endpoints, and a complete Flutter chat UI with message bubbles, quick prompts, and typing indicators.

## How It Works

### Backend Flow

1. **Chat Request**: User sends message via POST `/api/v1/ai/chat`
2. **Context Building**: AIService builds system prompt with fitness coaching context
3. **API Call**: Request sent to Groq API with conversation history
4. **Response Parsing**: AI response parsed for suggestions and safety notes
5. **Return**: Response sent back to client with suggestions array

### Flutter Flow

1. **User Input**: User types message or taps quick prompt
2. **State Update**: ChatNotifier adds user message, sets loading true
3. **Mock Response**: Currently returns mock data (TODO: call real API)
4. **Display**: Message appears in chat with typing indicator during load
5. **Quick Prompts**: Predefined prompts for common questions (form, progression, etc.)

## How to Test Manually

### Backend

```bash
# Start the backend
cd backend && npm run dev

# Test chat endpoint (with auth token)
curl -X POST http://localhost:3000/api/v1/ai/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"message": "How do I improve my bench press?"}'

# Test status endpoint
curl http://localhost:3000/api/v1/ai/status
```

### Flutter

1. Run the app: `flutter run`
2. Navigate to AI Coach (via home screen or `/ai-coach` route)
3. Type a message and tap send
4. Observe mock response appears with typing indicator
5. Tap quick prompt chips to test predefined questions
6. Clear chat via app bar button

## How to Extend

### Adding New Quick Prompt Categories

1. Add to `QuickPromptCategory` enum in `quick_prompt.dart`
2. Add icon mapping in `_getCategoryIcon()` in `chat_screen.dart`
3. Add mock response in `_getMockQuickResponse()` in provider

### Integrating Real API

1. Set `GROQ_API_KEY` environment variable
2. Remove mock delay and response in `ai_coach_provider.dart`
3. Add Dio HTTP client to make real API calls
4. Parse actual API response into `AIResponse` model

### Adding Chat Persistence

1. Create Isar schema for chat messages
2. Save messages after each send/receive
3. Load messages on screen init
4. Add clear confirmation that also clears storage

## Dependencies

### Backend
- `groq-sdk`: Groq API client (to be added when implementing real calls)
- `zod`: Request validation

### Flutter
- `freezed_annotation`: Immutable models
- `flutter_riverpod`: State management
- `go_router`: Navigation

## Gotchas and Pitfalls

1. **Mock Data**: The provider currently returns mock responses - don't forget to implement real API calls before production

2. **Token Management**: Backend requires valid Firebase auth token for all AI endpoints

3. **Rate Limiting**: Groq has rate limits - implement client-side throttling before production

4. **System Prompt Size**: Keep system prompts under 4000 tokens to leave room for conversation history

5. **Safety**: AI is instructed not to give medical advice - maintain this guardrail

## Related Documentation

- [Groq API Docs](https://console.groq.com/docs)
- [Flutter Riverpod](https://riverpod.dev/)
- [Freezed Package](https://pub.dev/packages/freezed)

## Files Created/Modified

### Created
- `backend/src/services/ai.service.ts`
- `backend/src/routes/ai.routes.ts`
- `app/lib/features/ai_coach/models/chat_message.dart`
- `app/lib/features/ai_coach/models/quick_prompt.dart`
- `app/lib/features/ai_coach/models/models.dart`
- `app/lib/features/ai_coach/providers/ai_coach_provider.dart`
- `app/lib/features/ai_coach/providers/providers.dart`
- `app/lib/features/ai_coach/screens/chat_screen.dart`
- `app/lib/features/ai_coach/screens/screens.dart`
- `app/lib/features/ai_coach/ai_coach.dart`

### Modified
- `backend/src/routes/index.ts` - Added AI routes
- `app/lib/core/router/app_router.dart` - Added /ai-coach route

## Next Steps

Phase 7 and beyond could include:

1. **Social Features**: Activity feed, challenges, friend workouts
2. **Notifications**: Rest timers, workout reminders, PR celebrations
3. **Data Export**: GDPR-compliant data export functionality
4. **Settings Screen**: User preferences, units, themes
5. **Offline Sync**: Proper offline-first architecture with sync queue

## Agent Continuation Prompt

If resuming work:

```
Read docs/handover/phase6-ai-coach-handover.md to understand what was just completed.
Then read FEATURES.md and the project plan to determine the next task.
Continue implementation from where the previous agent left off.
```
