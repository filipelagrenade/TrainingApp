/**
 * LiftIQ - AI Coach Routes
 *
 * API endpoints for AI-powered coaching features.
 * Provides chat interface, quick prompts, and contextual help.
 *
 * @module routes/ai
 */

import { Router } from 'express';
import { z } from 'zod';
import { aiService, ChatMessage, QuickPromptCategory } from '../services/ai.service';
import { successResponse } from '../utils/response';

const router = Router();

// ============================================================================
// VALIDATION SCHEMAS
// ============================================================================

/**
 * Schema for chat message.
 */
const ChatMessageSchema = z.object({
  message: z.string().min(1).max(1000),
  conversationHistory: z
    .array(
      z.object({
        role: z.enum(['system', 'user', 'assistant']),
        content: z.string(),
      })
    )
    .max(20)
    .optional(),
});

/**
 * Schema for quick prompt.
 */
const QuickPromptSchema = z.object({
  category: z.enum(['form', 'progression', 'alternative', 'explanation', 'motivation']),
  exerciseId: z.string().optional(),
});

/**
 * Schema for form cues request.
 */
const FormCuesSchema = z.object({
  exerciseId: z.string().min(1),
});

/**
 * Schema for progression explanation.
 */
const ProgressionExplanationSchema = z.object({
  exerciseId: z.string().min(1),
  action: z.string().min(1),
  reasoning: z.string().min(1),
});

// ============================================================================
// ROUTES
// ============================================================================

/**
 * POST /api/v1/ai/chat
 *
 * Sends a message to the AI coach and gets a response.
 *
 * @body message - User's message (max 1000 chars)
 * @body conversationHistory - Previous messages (max 20)
 * @returns AI response with suggestions
 *
 * @example
 * POST /api/v1/ai/chat
 * {
 *   "message": "How do I improve my bench press?",
 *   "conversationHistory": []
 * }
 *
 * Response:
 * {
 *   "success": true,
 *   "data": {
 *     "message": "To improve your bench press, focus on...",
 *     "suggestions": ["Add pause reps", "Work on triceps"],
 *     "safetyNote": null
 *   }
 * }
 */
router.post('/chat', async (req, res, next) => {
  try {
    const userId = req.user?.id ?? 'temp-user-id';
    const { message, conversationHistory } = ChatMessageSchema.parse(req.body);

    const response = await aiService.chat(
      userId,
      message,
      (conversationHistory as ChatMessage[]) || []
    );

    res.json(successResponse(response));
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/v1/ai/quick
 *
 * Gets a quick response for common queries.
 *
 * @body category - Type of prompt (form, progression, alternative, explanation, motivation)
 * @body exerciseId - Related exercise (optional)
 * @returns AI response
 *
 * @example
 * POST /api/v1/ai/quick
 * {
 *   "category": "form",
 *   "exerciseId": "bench-press"
 * }
 */
router.post('/quick', async (req, res, next) => {
  try {
    const userId = req.user?.id ?? 'temp-user-id';
    const { category, exerciseId } = QuickPromptSchema.parse(req.body);

    const response = await aiService.quickPrompt(
      category as QuickPromptCategory,
      exerciseId || null,
      userId
    );

    res.json(successResponse(response));
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/ai/form/:exerciseId
 *
 * Gets form cues for an exercise.
 *
 * @param exerciseId - Exercise to get cues for
 * @returns Form cues, common mistakes, and tips
 *
 * @example
 * GET /api/v1/ai/form/squat
 *
 * Response:
 * {
 *   "success": true,
 *   "data": {
 *     "cues": ["Keep chest up", "Drive through heels"],
 *     "commonMistakes": ["Knees caving in"],
 *     "tips": ["Start with goblet squats"]
 *   }
 * }
 */
router.get('/form/:exerciseId', async (req, res, next) => {
  try {
    const { exerciseId } = req.params;

    const formCues = await aiService.getFormCues(exerciseId);

    res.json(successResponse(formCues));
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/v1/ai/explain-progression
 *
 * Explains a progression suggestion in a friendly way.
 *
 * @body exerciseId - Exercise with suggestion
 * @body action - Suggested action
 * @body reasoning - Original reasoning
 * @returns Expanded explanation
 *
 * @example
 * POST /api/v1/ai/explain-progression
 * {
 *   "exerciseId": "bench-press",
 *   "action": "increase",
 *   "reasoning": "You hit 8 reps for 2 sessions"
 * }
 */
router.post('/explain-progression', async (req, res, next) => {
  try {
    const { exerciseId, action, reasoning } = ProgressionExplanationSchema.parse(req.body);

    const explanation = await aiService.explainProgression(exerciseId, action, reasoning);

    res.json(successResponse({ explanation }));
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/ai/suggestions
 *
 * Gets contextual suggestions based on user's current state.
 * Returns workout tips, form reminders, or motivation.
 *
 * @query context - Current context (pre_workout, during_workout, post_workout)
 * @returns Contextual suggestions
 */
router.get('/suggestions', async (req, res, next) => {
  try {
    const userId = req.user?.id ?? 'temp-user-id';
    const context = z
      .enum(['pre_workout', 'during_workout', 'post_workout'])
      .default('pre_workout')
      .parse(req.query.context);

    const prompts: Record<string, string> = {
      pre_workout:
        "Give me a quick tip to prepare for today's workout. Keep it to 1-2 sentences.",
      during_workout:
        'Give me a quick form reminder or motivation boost for my workout. Keep it brief.',
      post_workout:
        'My workout is done. Give me a quick recovery tip or encouragement. Keep it brief.',
    };

    const response = await aiService.chat(userId, prompts[context], []);

    res.json(
      successResponse({
        context,
        suggestion: response.message,
      })
    );
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/v1/ai/status
 *
 * Checks if the AI service is available.
 *
 * @returns Service status
 */
router.get('/status', async (req, res) => {
  const hasApiKey = !!process.env.GROQ_API_KEY;

  res.json(
    successResponse({
      available: hasApiKey,
      model: hasApiKey ? 'llama-3.1-70b-versatile' : null,
      message: hasApiKey
        ? 'AI coach is ready to help!'
        : 'AI features are currently unavailable. Please configure the API key.',
    })
  );
});

export default router;
