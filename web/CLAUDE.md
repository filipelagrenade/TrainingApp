# LiftIQ Web Dashboard

Next.js web application providing analytics, program building, and detailed progress tracking on larger screens.

## Directory Structure

```
web/
├── CLAUDE.md                 # This file
├── package.json
├── next.config.js
├── tailwind.config.ts
├── tsconfig.json
├── .env.example
├── src/
│   ├── app/
│   │   ├── layout.tsx        # Root layout with providers
│   │   ├── page.tsx          # Home/dashboard
│   │   ├── (auth)/
│   │   │   ├── login/
│   │   │   └── signup/
│   │   ├── workouts/
│   │   │   ├── page.tsx      # Workout history
│   │   │   └── [id]/
│   │   ├── exercises/
│   │   ├── programs/
│   │   ├── analytics/
│   │   ├── settings/
│   │   └── api/              # API routes (if needed)
│   ├── components/
│   │   ├── ui/               # shadcn/ui components (DO NOT EDIT)
│   │   ├── layout/           # Header, Sidebar, Footer
│   │   ├── charts/           # Chart components
│   │   ├── workouts/         # Workout-related components
│   │   ├── exercises/        # Exercise-related components
│   │   └── programs/         # Program builder components
│   ├── lib/
│   │   ├── api.ts            # API client
│   │   ├── auth.ts           # Auth utilities
│   │   ├── utils.ts          # Helper functions
│   │   └── constants.ts      # App constants
│   ├── hooks/
│   │   ├── useWorkouts.ts
│   │   ├── useExercises.ts
│   │   └── useAnalytics.ts
│   ├── stores/               # Jotai atoms for UI state
│   │   ├── sidebar.ts
│   │   └── filters.ts
│   └── types/
│       └── index.ts
└── tests/
    ├── unit/
    └── e2e/
```

## Commands

```bash
pnpm install                  # Install dependencies
pnpm dev                      # Dev server (localhost:3000)
pnpm build                    # Production build
pnpm start                    # Run production build
pnpm test                     # Run tests
pnpm test:e2e                 # Run Playwright E2E tests
pnpm lint                     # Run ESLint
pnpm lint:fix                 # Fix ESLint issues
pnpm add:ui [component]       # Add shadcn/ui component
```

## Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Next.js 14+ (App Router) |
| Styling | Tailwind CSS |
| Components | shadcn/ui |
| Server State | TanStack Query |
| UI State | Jotai |
| Charts | Recharts |
| Forms | React Hook Form + Zod |
| Testing | Vitest + Playwright |

## Critical Rules

### 1. Always Use Theme Variables

Never hardcode colors. Always use CSS variables from the theme.

```tsx
// WRONG - Hardcoded colors
<div className="bg-gray-100 text-gray-900 border-gray-200">

// CORRECT - Theme variables
<div className="bg-muted text-foreground border-border">

// WRONG - Hardcoded dark mode
<div className="bg-white dark:bg-gray-900">

// CORRECT - Theme handles dark mode automatically
<div className="bg-background">
```

Theme variables are defined in `src/app/globals.css`:
- `background`, `foreground` - Main bg/text
- `card`, `card-foreground` - Card surfaces
- `primary`, `primary-foreground` - Primary actions
- `secondary`, `secondary-foreground` - Secondary actions
- `muted`, `muted-foreground` - Muted elements
- `accent`, `accent-foreground` - Accents
- `destructive`, `destructive-foreground` - Danger/delete
- `border`, `input`, `ring` - Borders and focus

### 2. Use TanStack Query for Server State

All API calls must use TanStack Query hooks.

```tsx
// WRONG - Direct fetch
const [workouts, setWorkouts] = useState([]);
useEffect(() => {
  fetch('/api/workouts').then(r => r.json()).then(setWorkouts);
}, []);

// CORRECT - TanStack Query
import { useQuery } from '@tanstack/react-query';
import { getWorkouts } from '@/lib/api';

const { data: workouts, isLoading, error } = useQuery({
  queryKey: ['workouts'],
  queryFn: getWorkouts,
});
```

### 3. Use Jotai for UI State Only

Jotai is for UI state (filters, sidebar, modals). Never for server data.

```tsx
// stores/filters.ts
import { atom } from 'jotai';

// UI state - use Jotai
export const dateRangeAtom = atom<DateRange>({ from: null, to: null });
export const muscleFilterAtom = atom<string[]>([]);
export const sidebarOpenAtom = atom(true);

// Usage in component
import { useAtom } from 'jotai';
import { dateRangeAtom } from '@/stores/filters';

const [dateRange, setDateRange] = useAtom(dateRangeAtom);
```

### 4. Use shadcn/ui Components

Always check if a shadcn/ui component exists before building custom UI.

| Need | Use |
|------|-----|
| Modal/dialog | `@/components/ui/dialog` |
| Dropdown menu | `@/components/ui/dropdown-menu` |
| Select/combobox | `@/components/ui/select` or `@/components/ui/command` |
| Tabs | `@/components/ui/tabs` |
| Toast/notification | `sonner` via `toast()` |
| Loading state | `@/components/ui/skeleton` |
| Badge/tag | `@/components/ui/badge` |
| Tooltip | `@/components/ui/tooltip` |
| Data table | `@/components/ui/table` + TanStack Table |
| Form inputs | `@/components/ui/input`, `textarea`, etc. |
| Buttons | `@/components/ui/button` with variants |
| Cards | `@/components/ui/card` |
| Charts | Recharts with custom styling |

To add a new shadcn/ui component:
```bash
pnpm dlx shadcn-ui@latest add [component-name]
```

### 5. File Size Limits

- **Max 500 lines per file** - Split if larger
- **Components: ~200 lines** - Extract sub-components
- **Hooks: ~150 lines** - Single responsibility

### 6. Component Documentation

Every component must have a usage comment:

```tsx
/**
 * WorkoutCard displays a summary of a single workout.
 *
 * @example
 * <WorkoutCard
 *   workout={workout}
 *   onSelect={(id) => router.push(`/workouts/${id}`)}
 * />
 *
 * Features:
 * - Shows date, duration, and exercise count
 * - Displays PR badges if any were hit
 * - Click to view workout details
 */
interface WorkoutCardProps {
  /** The workout to display */
  workout: Workout;
  /** Called when user clicks the card */
  onSelect: (id: string) => void;
}

export const WorkoutCard = ({ workout, onSelect }: WorkoutCardProps): JSX.Element => {
  // Implementation...
};
```

### 7. Arrow Functions and TypeScript

```tsx
// WRONG - Function declaration
function handleClick() { ... }

// CORRECT - Arrow function
const handleClick = () => { ... };

// WRONG - Missing return type
const getWorkout = (id: string) => { ... };

// CORRECT - Explicit return type
const getWorkout = (id: string): Workout | null => { ... };

// WRONG - Using any
const parseData = (data: any) => { ... };

// CORRECT - Use unknown or generics
const parseData = <T>(data: unknown): T => { ... };
```

### 8. Import Organization

```tsx
// 1. React
import { useState, useEffect } from 'react';

// 2. External libraries
import { useQuery } from '@tanstack/react-query';
import { useAtom } from 'jotai';
import { format } from 'date-fns';

// 3. Internal - UI components
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader } from '@/components/ui/card';

// 4. Internal - Custom components
import { WorkoutCard } from '@/components/workouts/WorkoutCard';
import { ExerciseList } from '@/components/exercises/ExerciseList';

// 5. Internal - Hooks and utilities
import { useWorkouts } from '@/hooks/useWorkouts';
import { cn } from '@/lib/utils';

// 6. Types
import type { Workout, Exercise } from '@/types';
```

## Page Implementation Pattern

```tsx
// app/workouts/page.tsx
import { Suspense } from 'react';
import { WorkoutList } from '@/components/workouts/WorkoutList';
import { WorkoutFilters } from '@/components/workouts/WorkoutFilters';
import { Skeleton } from '@/components/ui/skeleton';

/**
 * Workouts page - displays workout history with filters.
 *
 * Features:
 * - Paginated workout list
 * - Date range filter
 * - Exercise/muscle group filter
 * - Search by notes
 */
export default function WorkoutsPage(): JSX.Element {
  return (
    <div className="container mx-auto py-6 space-y-6">
      {/* Page header */}
      <div className="flex items-center justify-between">
        <h1 className="text-3xl font-bold tracking-tight">Workout History</h1>
      </div>

      {/* Filters */}
      <WorkoutFilters />

      {/* Workout list with loading state */}
      <Suspense fallback={<WorkoutListSkeleton />}>
        <WorkoutList />
      </Suspense>
    </div>
  );
}

/**
 * Skeleton loader for workout list.
 * Matches the layout of WorkoutList for smooth loading.
 */
const WorkoutListSkeleton = (): JSX.Element => {
  return (
    <div className="space-y-4">
      {Array.from({ length: 5 }).map((_, i) => (
        <Skeleton key={i} className="h-24 w-full" />
      ))}
    </div>
  );
};
```

## Component Implementation Pattern

```tsx
// components/workouts/WorkoutCard.tsx
'use client';

import { format } from 'date-fns';
import { Clock, Dumbbell, Trophy } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { cn } from '@/lib/utils';
import type { Workout } from '@/types';

/**
 * WorkoutCard displays a summary of a single workout session.
 *
 * @example
 * <WorkoutCard
 *   workout={workout}
 *   onSelect={(id) => router.push(`/workouts/${id}`)}
 * />
 */
interface WorkoutCardProps {
  /** The workout to display */
  workout: Workout;
  /** Called when user clicks the card */
  onSelect: (id: string) => void;
  /** Additional CSS classes */
  className?: string;
}

export const WorkoutCard = ({
  workout,
  onSelect,
  className,
}: WorkoutCardProps): JSX.Element => {
  // Format duration from seconds to readable string
  const formatDuration = (seconds: number): string => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    if (hours > 0) {
      return `${hours}h ${minutes}m`;
    }
    return `${minutes}m`;
  };

  // Count total exercises and sets
  const exerciseCount = workout.exerciseLogs.length;
  const setCount = workout.exerciseLogs.reduce(
    (total, log) => total + log.sets.length,
    0
  );

  // Check if any PRs were hit
  const prCount = workout.exerciseLogs.reduce(
    (total, log) => total + (log.isPR ? 1 : 0),
    0
  );

  return (
    <Card
      className={cn(
        'cursor-pointer transition-colors hover:bg-accent/50',
        className
      )}
      onClick={() => onSelect(workout.id)}
    >
      <CardHeader className="pb-2">
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg">
            {workout.template?.name ?? 'Quick Workout'}
          </CardTitle>
          {prCount > 0 && (
            <Badge variant="secondary" className="gap-1">
              <Trophy className="h-3 w-3" />
              {prCount} PR{prCount > 1 ? 's' : ''}
            </Badge>
          )}
        </div>
        <p className="text-sm text-muted-foreground">
          {format(new Date(workout.startedAt), 'EEEE, MMMM d, yyyy')}
        </p>
      </CardHeader>
      <CardContent>
        <div className="flex items-center gap-4 text-sm text-muted-foreground">
          <div className="flex items-center gap-1">
            <Clock className="h-4 w-4" />
            {workout.durationSeconds
              ? formatDuration(workout.durationSeconds)
              : 'In progress'}
          </div>
          <div className="flex items-center gap-1">
            <Dumbbell className="h-4 w-4" />
            {exerciseCount} exercises, {setCount} sets
          </div>
        </div>
      </CardContent>
    </Card>
  );
};
```

## Chart Implementation

```tsx
// components/charts/OneRMTrendChart.tsx
'use client';

import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { useTheme } from 'next-themes';

/**
 * OneRMTrendChart displays estimated 1RM progression over time.
 *
 * Features:
 * - Line chart with smooth curves
 * - Responsive sizing
 * - Theme-aware colors
 * - Tooltip with details
 */
interface OneRMTrendChartProps {
  /** Exercise name for the title */
  exerciseName: string;
  /** Data points with date and estimated 1RM */
  data: Array<{ date: string; estimated1RM: number }>;
}

export const OneRMTrendChart = ({
  exerciseName,
  data,
}: OneRMTrendChartProps): JSX.Element => {
  const { theme } = useTheme();

  // Use theme-appropriate colors
  const lineColor = theme === 'dark' ? '#818cf8' : '#6366f1';
  const gridColor = theme === 'dark' ? '#374151' : '#e5e7eb';

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-lg">{exerciseName} - Estimated 1RM</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="h-[300px] w-full">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={data} margin={{ top: 5, right: 20, bottom: 5, left: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke={gridColor} />
              <XAxis
                dataKey="date"
                tick={{ fontSize: 12 }}
                tickMargin={10}
              />
              <YAxis
                tick={{ fontSize: 12 }}
                tickMargin={10}
                unit=" lbs"
              />
              <Tooltip
                contentStyle={{
                  backgroundColor: theme === 'dark' ? '#1f2937' : '#ffffff',
                  border: 'none',
                  borderRadius: '8px',
                  boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)',
                }}
              />
              <Line
                type="monotone"
                dataKey="estimated1RM"
                stroke={lineColor}
                strokeWidth={2}
                dot={{ fill: lineColor, strokeWidth: 2 }}
                activeDot={{ r: 6 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </CardContent>
    </Card>
  );
};
```

## API Client Pattern

```tsx
// lib/api.ts
import { QueryClient } from '@tanstack/react-query';

const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api/v1';

/**
 * API client for making requests to the backend.
 *
 * All responses follow the format:
 * { success: boolean, data?: T, error?: { code, message, details } }
 */

/**
 * Makes an authenticated API request.
 */
const fetchApi = async <T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> => {
  const token = localStorage.getItem('auth_token');

  const response = await fetch(`${API_BASE}${endpoint}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(token && { Authorization: `Bearer ${token}` }),
      ...options.headers,
    },
  });

  const data = await response.json();

  if (!data.success) {
    throw new Error(data.error?.message || 'An error occurred');
  }

  return data.data;
};

/**
 * Gets all workouts for the current user.
 */
export const getWorkouts = async (): Promise<Workout[]> => {
  return fetchApi<Workout[]>('/workouts');
};

/**
 * Gets a single workout by ID.
 */
export const getWorkout = async (id: string): Promise<Workout> => {
  return fetchApi<Workout>(`/workouts/${id}`);
};

/**
 * Gets analytics data for the dashboard.
 */
export const getAnalytics = async (dateRange: DateRange): Promise<Analytics> => {
  const params = new URLSearchParams({
    from: dateRange.from.toISOString(),
    to: dateRange.to.toISOString(),
  });
  return fetchApi<Analytics>(`/analytics?${params}`);
};
```

## Testing Requirements

### Unit Tests
- All hooks
- Utility functions
- API client functions

### Component Tests
- All custom components
- User interactions
- Loading/error states

### E2E Tests (Playwright)
- Login flow
- View workout history
- Analytics dashboard
- Program builder

```tsx
// tests/e2e/workouts.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Workouts Page', () => {
  test.beforeEach(async ({ page }) => {
    // Login before each test
    await page.goto('/login');
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'password');
    await page.click('button[type="submit"]');
    await page.waitForURL('/');
  });

  test('displays workout history', async ({ page }) => {
    await page.goto('/workouts');

    // Should show workout cards
    await expect(page.getByRole('heading', { name: 'Workout History' })).toBeVisible();
    await expect(page.locator('[data-testid="workout-card"]').first()).toBeVisible();
  });

  test('filters workouts by date range', async ({ page }) => {
    await page.goto('/workouts');

    // Open date picker and select range
    await page.click('[data-testid="date-range-picker"]');
    await page.click('text=Last 7 days');

    // Should update the list
    await expect(page.locator('[data-testid="workout-card"]')).toHaveCount(3);
  });
});
```

## Environment Variables

```env
# API
NEXT_PUBLIC_API_URL=http://localhost:3001/api/v1

# Firebase (client-side)
NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=
NEXT_PUBLIC_FIREBASE_PROJECT_ID=

# Analytics (optional)
NEXT_PUBLIC_MIXPANEL_TOKEN=
```

## Learning Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [shadcn/ui Components](https://ui.shadcn.com/)
- [TanStack Query](https://tanstack.com/query/latest)
- [Jotai Documentation](https://jotai.org/)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [Recharts](https://recharts.org/)
- [Playwright Testing](https://playwright.dev/)
