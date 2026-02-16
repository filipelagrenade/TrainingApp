/**
 * LiftIQ - AI Coach Service
 *
 * Provides AI-powered coaching through the Groq API (Llama 3).
 * Offers contextual workout advice, form cues, and progression guidance.
 *
 * ## Key Features
 *
 * - Chat-based interaction with workout context
 * - Exercise form cues and tips
 * - Progressive overload explanations
 * - Exercise alternatives for limitations
 * - Safety guardrails (no medical advice)
 *
 * ## Design Notes
 *
 * - Uses Groq API with Llama 3 model
 * - Injects user context (history, current program)
 * - Maintains conversation history per session
 * - Rate limited to prevent abuse
 */

import { logger } from '../utils/logger';
import { prisma } from '../utils/prisma';
import { progressionService } from './progression.service';

// ============================================================================
// TYPES AND INTERFACES
// ============================================================================

/**
 * Role in a chat conversation.
 */
export type ChatRole = 'system' | 'user' | 'assistant';

/**
 * A single chat message.
 */
export interface ChatMessage {
  role: ChatRole;
  content: string;
  timestamp?: Date;
}

/**
 * Context about the user for AI responses.
 */
export interface UserContext {
  displayName?: string;
  unitPreference: 'KG' | 'LBS';
  currentProgram?: string;
  recentExercises: string[];
  recentPRs: { exercise: string; weight: number; reps: number }[];
  plateauedExercises: string[];
  workoutStreak: number;
  totalWorkouts: number;
}

/**
 * Chat session with history.
 */
export interface ChatSession {
  id: string;
  userId: string;
  messages: ChatMessage[];
  context: UserContext;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Response from the AI coach.
 */
export interface AIResponse {
  message: string;
  suggestions?: string[];
  relatedExercises?: string[];
  safetyNote?: string;
}

/**
 * Quick prompt categories.
 */
export type QuickPromptCategory =
  | 'form'
  | 'progression'
  | 'alternative'
  | 'explanation'
  | 'motivation';

// ============================================================================
// SYSTEM PROMPTS
// ============================================================================

/**
 * Base system prompt for the AI coach.
 */
const SYSTEM_PROMPT = `You are LiftIQ Coach, an AI fitness assistant specialized in strength training and progressive overload.

## Your Role
- Help users with workout advice, exercise form, and progression strategies
- Explain the science behind training in simple terms
- Provide motivation and accountability
- Suggest exercise alternatives when needed

## Your Knowledge
- Progressive overload principles (double progression, linear progression)
- Proper exercise form and common mistakes
- Muscle groups and exercise selection
- Recovery and deload strategies
- RPE (Rate of Perceived Exertion) and RIR (Reps in Reserve)

## Guidelines
1. Keep responses concise and actionable (2-4 sentences usually)
2. Use the user's preferred unit system (kg or lbs)
3. Reference their actual workout data when relevant
4. Be encouraging but honest about progress
5. Suggest specific, practical next steps

## Safety Rules (CRITICAL)
- NEVER provide medical advice or diagnose injuries
- NEVER recommend specific supplements or medications
- Always suggest consulting a doctor for pain or injuries
- Don't make claims about specific weight loss or muscle gain
- If asked about medical topics, redirect to healthcare professionals

## Response Style
- Friendly and supportive tone
- Use fitness terminology but explain when needed
- Include specific numbers from their data when helpful
- End with a clear action item or question when appropriate`;

/**
 * Context injection template.
 */
const CONTEXT_TEMPLATE = `
## User Context
- Name: {displayName}
- Units: {unitPreference}
- Current Program: {currentProgram}
- Workout Streak: {workoutStreak} days
- Total Workouts: {totalWorkouts}

## Recent Activity
- Recent exercises: {recentExercises}
- Recent PRs: {recentPRs}
- Plateaued exercises: {plateauedExercises}
`;

// ============================================================================
// AI SERVICE
// ============================================================================

/**
 * AIService provides AI-powered coaching functionality.
 */
export class AIService {
  private apiKey: string;
  private baseUrl: string = 'https://api.groq.com/openai/v1';
  private model: string = 'llama-3.1-70b-versatile';

  constructor() {
    this.apiKey = process.env.GROQ_API_KEY || '';
    if (!this.apiKey) {
      logger.warn('GROQ_API_KEY not set - AI features will be disabled');
    }
  }

  /**
   * Sends a chat message and gets a response.
   *
   * @param userId - User ID for context
   * @param message - User's message
   * @param conversationHistory - Previous messages in conversation
   * @returns AI response with suggestions
   */
  async chat(
    userId: string,
    message: string,
    conversationHistory: ChatMessage[] = []
  ): Promise<AIResponse> {
    logger.info({ userId, messageLength: message.length }, 'Processing chat message');

    // Check if API key is configured
    if (!this.apiKey) {
      return {
        message:
          "I'm currently offline. Please check that the AI service is configured properly.",
        safetyNote: 'AI features require a valid API key.',
      };
    }

    try {
      // Get user context
      const context = await this.getUserContext(userId);

      // Build messages array
      const messages = this.buildMessages(message, conversationHistory, context);

      // Call Groq API
      const response = await this.callGroqAPI(messages);

      // Check for safety concerns
      const safetyNote = this.checkSafety(message, response);

      return {
        message: response,
        suggestions: this.extractSuggestions(response),
        safetyNote,
      };
    } catch (error) {
      logger.error({ error, userId }, 'AI chat error');
      return {
        message:
          "I'm having trouble connecting right now. Please try again in a moment.",
        safetyNote: 'If this persists, check your connection.',
      };
    }
  }

  /**
   * Gets a quick response for common queries.
   *
   * @param category - Type of quick prompt
   * @param exerciseId - Related exercise (optional)
   * @param userId - User ID for context
   * @returns AI response
   */
  async quickPrompt(
    category: QuickPromptCategory,
    exerciseId: string | null,
    userId: string
  ): Promise<AIResponse> {
    const prompts: Record<QuickPromptCategory, string> = {
      form: exerciseId
        ? `What are the key form cues for ${exerciseId}? Give me 3-4 important points.`
        : 'What are general tips for maintaining good form during strength training?',
      progression: exerciseId
        ? `I'm stuck on ${exerciseId}. What strategies can help me break through this plateau?`
        : 'Explain how progressive overload works and how I should apply it.',
      alternative: exerciseId
        ? `What are good alternatives to ${exerciseId} that work similar muscles?`
        : 'What exercises can I do if I have limited equipment?',
      explanation: exerciseId
        ? `Why is ${exerciseId} important and what muscles does it primarily work?`
        : 'Explain the difference between strength training and hypertrophy training.',
      motivation:
        "I'm feeling unmotivated today. Can you give me some encouragement to get my workout in?",
    };

    return this.chat(userId, prompts[category], []);
  }

  /**
   * Gets form cues for an exercise.
   *
   * @param exerciseId - Exercise to get cues for
   * @returns Form cues and common mistakes
   */
  async getFormCues(exerciseId: string): Promise<{
    cues: string[];
    commonMistakes: string[];
    tips: string[];
  }> {
    // First check if we have stored form cues in the database
    const exercise = await prisma.exercise.findUnique({
      where: { id: exerciseId },
      select: {
        name: true,
        formCues: true,
        commonMistakes: true,
      },
    });

    if (exercise && exercise.formCues.length > 0) {
      return {
        cues: exercise.formCues,
        commonMistakes: exercise.commonMistakes,
        tips: [],
      };
    }

    // Fall back to AI-generated cues
    if (!this.apiKey) {
      return {
        cues: ['Focus on controlled movement', 'Maintain proper posture', 'Breathe consistently'],
        commonMistakes: ['Using too much weight', 'Rushing through reps'],
        tips: ['Start light and focus on form'],
      };
    }

    const response = await this.chat(
      'system',
      `Give me exactly 4 form cues, 3 common mistakes, and 2 tips for ${exercise?.name || exerciseId}. Format as JSON with keys: cues, commonMistakes, tips (all arrays of strings).`,
      []
    );

    try {
      // Try to parse JSON from response
      const jsonMatch = response.message.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        const parsed = JSON.parse(jsonMatch[0]);
        return {
          cues: parsed.cues || [],
          commonMistakes: parsed.commonMistakes || [],
          tips: parsed.tips || [],
        };
      }
    } catch {
      // If parsing fails, return default
    }

    return {
      cues: ['Focus on controlled movement', 'Maintain proper posture'],
      commonMistakes: ['Using momentum instead of muscle'],
      tips: ['Start with lighter weight to perfect form'],
    };
  }

  /**
   * Explains why a progression suggestion was made.
   *
   * @param exerciseId - Exercise with suggestion
   * @param action - Suggested action (increase, maintain, deload)
   * @param reasoning - Original reasoning from progression service
   * @returns Expanded explanation
   */
  async explainProgression(
    exerciseId: string,
    action: string,
    reasoning: string
  ): Promise<string> {
    if (!this.apiKey) {
      return reasoning;
    }

    const response = await this.chat(
      'system',
      `Explain this progression suggestion in a friendly way: For ${exerciseId}, the suggestion is to ${action}. The reason given is: "${reasoning}". Keep it to 2-3 sentences and be encouraging.`,
      []
    );

    return response.message;
  }

  // ===========================================================================
  // PRIVATE METHODS
  // ===========================================================================

  /**
   * Gets context about the user for AI responses.
   */
  private async getUserContext(userId: string): Promise<UserContext> {
    try {
      const [user, recentSessions, totalWorkouts, latestSessionWithProgram, recentPRLogs] =
        await Promise.all([
          prisma.user.findUnique({
            where: { id: userId },
            select: {
              displayName: true,
              unitPreference: true,
            },
          }),
          prisma.workoutSession.findMany({
            where: {
              userId,
              completedAt: { not: null },
            },
            include: {
              exerciseLogs: {
                include: {
                  exercise: { select: { id: true, name: true } },
                },
              },
            },
            orderBy: { startedAt: 'desc' },
            take: 10,
          }),
          prisma.workoutSession.count({
            where: {
              userId,
              completedAt: { not: null },
            },
          }),
          prisma.workoutSession.findFirst({
            where: {
              userId,
              completedAt: { not: null },
              template: {
                programId: { not: null },
              },
            },
            orderBy: { startedAt: 'desc' },
            select: {
              template: {
                select: {
                  program: {
                    select: { name: true },
                  },
                },
              },
            },
          }),
          prisma.exerciseLog.findMany({
            where: {
              isPR: true,
              session: {
                userId,
                completedAt: { not: null },
              },
            },
            orderBy: {
              session: {
                startedAt: 'desc',
              },
            },
            take: 5,
            include: {
              exercise: { select: { name: true } },
              sets: {
                where: { setType: 'WORKING' },
                orderBy: [{ weight: 'desc' }, { reps: 'desc' }],
                take: 1,
              },
            },
          }),
        ]);

      const recentExercises = new Set<string>();
      const recentExerciseIds = new Set<string>();
      recentSessions.forEach((s) => {
        s.exerciseLogs.forEach((l) => {
          recentExerciseIds.add(l.exercise.id);
          recentExercises.add(l.exercise.name);
        });
      });
      const workoutStreak = this.calculateWorkoutStreak(recentSessions.map((s) => s.startedAt));
      const recentPRs = recentPRLogs
        .map((log) => ({
          exercise: log.exercise.name,
          weight: log.sets[0]?.weight || 0,
          reps: log.sets[0]?.reps || 0,
        }))
        .filter((pr) => pr.weight > 0 && pr.reps > 0);

      const plateauCandidates = Array.from(recentExerciseIds).slice(0, 5);
      const plateauResults = await Promise.all(
        plateauCandidates.map(async (exerciseId) => {
          try {
            const plateau = await progressionService.detectPlateau(userId, exerciseId);
            if (!plateau.isPlateaued) {
              return null;
            }
            const exercise = await prisma.exercise.findUnique({
              where: { id: exerciseId },
              select: { name: true },
            });
            return exercise?.name || null;
          } catch {
            return null;
          }
        })
      );
      const plateauedExercises = plateauResults.filter(
        (exercise): exercise is string => !!exercise
      );

      return {
        displayName: user?.displayName || 'Athlete',
        unitPreference: (user?.unitPreference as 'KG' | 'LBS') || 'KG',
        currentProgram: latestSessionWithProgram?.template?.program?.name || undefined,
        recentExercises: Array.from(recentExercises).slice(0, 5),
        recentPRs,
        plateauedExercises,
        workoutStreak,
        totalWorkouts,
      };
    } catch (error) {
      logger.error({ error, userId }, 'Failed to get user context');
      return {
        displayName: 'Athlete',
        unitPreference: 'KG',
        recentExercises: [],
        recentPRs: [],
        plateauedExercises: [],
        workoutStreak: 0,
        totalWorkouts: 0,
      };
    }
  }

  /**
   * Builds the messages array for the API call.
   */
  private buildMessages(
    userMessage: string,
    history: ChatMessage[],
    context: UserContext
  ): ChatMessage[] {
    // Build context string
    const contextStr = CONTEXT_TEMPLATE.replace('{displayName}', context.displayName || 'Athlete')
      .replace('{unitPreference}', context.unitPreference)
      .replace('{currentProgram}', context.currentProgram || 'None')
      .replace('{workoutStreak}', context.workoutStreak.toString())
      .replace('{totalWorkouts}', context.totalWorkouts.toString())
      .replace('{recentExercises}', context.recentExercises.join(', ') || 'None')
      .replace(
        '{recentPRs}',
        context.recentPRs.map((p) => `${p.exercise}: ${p.weight}x${p.reps}`).join(', ') || 'None'
      )
      .replace('{plateauedExercises}', context.plateauedExercises.join(', ') || 'None');

    const messages: ChatMessage[] = [
      { role: 'system', content: SYSTEM_PROMPT + contextStr },
      ...history.slice(-10), // Keep last 10 messages for context
      { role: 'user', content: userMessage },
    ];

    return messages;
  }

  /**
   * Calls the Groq API.
   */
  private async callGroqAPI(messages: ChatMessage[]): Promise<string> {
    const response = await fetch(`${this.baseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: this.model,
        messages: messages.map((m) => ({ role: m.role, content: m.content })),
        temperature: 0.7,
        max_tokens: 500,
        top_p: 0.9,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      logger.error({ status: response.status, error }, 'Groq API error');
      throw new Error(`Groq API error: ${response.status}`);
    }

    const data = await response.json() as { choices: Array<{ message?: { content?: string } }> };
    return data.choices[0]?.message?.content || 'I apologize, but I could not generate a response.';
  }

  /**
   * Checks for safety concerns in the message.
   */
  private checkSafety(userMessage: string, response: string): string | undefined {
    const medicalKeywords = [
      'pain',
      'injury',
      'hurt',
      'doctor',
      'medical',
      'diagnosis',
      'treatment',
      'medication',
      'supplement',
      'steroid',
    ];

    const lowerMessage = userMessage.toLowerCase();
    const hasMedicalContent = medicalKeywords.some((k) => lowerMessage.includes(k));

    if (hasMedicalContent) {
      return 'For any pain, injuries, or medical concerns, please consult a healthcare professional.';
    }

    return undefined;
  }

  /**
   * Extracts actionable suggestions from the response.
   */
  private extractSuggestions(response: string): string[] | undefined {
    // Look for bullet points or numbered items
    const bulletMatch = response.match(/[-•]\s+.+/g);
    const numberedMatch = response.match(/\d+\.\s+.+/g);

    const suggestions = bulletMatch || numberedMatch;
    if (suggestions && suggestions.length > 0) {
      return suggestions.map((s) => s.replace(/^[-•\d.]\s+/, '').trim()).slice(0, 4);
    }

    return undefined;
  }

  private calculateWorkoutStreak(dates: Date[]): number {
    if (dates.length === 0) {
      return 0;
    }

    const normalizedDates = Array.from(
      new Set(
        dates.map((date) => {
          const day = new Date(date);
          day.setHours(0, 0, 0, 0);
          return day.getTime();
        })
      )
    ).sort((a, b) => b - a);

    let streak = 0;
    let expected = new Date();
    expected.setHours(0, 0, 0, 0);

    for (const workoutDayMs of normalizedDates) {
      if (workoutDayMs === expected.getTime()) {
        streak += 1;
        expected = new Date(expected.getTime() - 24 * 60 * 60 * 1000);
        continue;
      }

      if (streak === 0 && workoutDayMs === expected.getTime() - 24 * 60 * 60 * 1000) {
        streak += 1;
        expected = new Date(workoutDayMs - 24 * 60 * 60 * 1000);
        continue;
      }

      break;
    }

    return streak;
  }
}

// Singleton instance
export const aiService = new AIService();
