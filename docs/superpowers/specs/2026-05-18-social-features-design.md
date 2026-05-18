# Social Features: Kudos, Copy Programs, Train with Mates

## Overview

Three social features that build on LiftIQ's existing follow system and activity feed. Built in order of dependency: kudos (standalone), copy programs (standalone), train with mates (requires new notification infrastructure).

**Platform:** Web only (Next.js).

---

## Feature 1: Kudos / Reactions

### Data Model

New `Reaction` model:

```prisma
model Reaction {
  id              String        @id @default(cuid())
  activityEventId String
  userId          String
  emoji           String        // Validated: "fire" | "flex" | "clap" | "trophy" | "heart"
  createdAt       DateTime      @default(now())

  activityEvent   ActivityEvent @relation(fields: [activityEventId], references: [id], onDelete: Cascade)
  user            User          @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([activityEventId, userId, emoji])
  @@index([activityEventId])
}
```

Five fixed emoji types, validated server-side via Zod enum. One of each type per user per event (unique constraint). Users can give multiple different emojis to the same event.

### API

**Add reaction:**
`POST /api/v1/social/feed/:eventId/reactions`
- Body: `{ emoji: "fire" | "flex" | "clap" | "trophy" | "heart" }`
- Upserts (idempotent). Returns the reaction.
- Auth: requires login. User must follow the event owner OR be the event owner.

**Remove reaction:**
`DELETE /api/v1/social/feed/:eventId/reactions/:emoji`
- Removes the calling user's reaction of that emoji type.
- Auth: same as above.

**Feed response change:**
Extend the `GET /api/v1/social/feed` response. Each event gains:
```ts
reactions: Array<{
  emoji: string;
  count: number;
  userReacted: boolean; // whether the current user gave this emoji
}>
```

### Frontend

Each activity feed event card (`social-screen.tsx`, lines 310-315) gets a reaction bar below the existing content:
- Row of 5 emoji buttons (fire, flex, clap, trophy, heart)
- Each button shows the emoji icon + count (if > 0)
- User's own reactions are visually highlighted (filled vs outline)
- Tap toggles: adds if not reacted, removes if already reacted
- Optimistic UI updates via TanStack Query mutation

### Files to Modify

| File | Change |
|------|--------|
| `backend/prisma/schema.prisma` | Add `Reaction` model, add `reactions` relation to `ActivityEvent` and `User` |
| `backend/src/services/social.service.ts` | Add `addReaction`, `removeReaction`, update `getFeed` to include reaction aggregates |
| `backend/src/routes/social.routes.ts` | Add reaction endpoints |
| `web/src/lib/api-client.ts` | Add `addReaction`, `removeReaction` functions |
| `web/src/lib/types.ts` | Extend `ActivityEvent` type with `reactions` array |
| `web/src/components/social/social-screen.tsx` | Add reaction bar to feed event cards |

---

## Feature 2: Copy Programs

### Data Model

Add field to existing `Program` model:

```prisma
model Program {
  // ... existing fields ...
  allowCopy Boolean @default(false)
}
```

### API

**Copy a program:**
`POST /api/v1/programs/:programId/copy`
- Clones the full program structure: Program, ProgramWeeks, ProgramWorkouts, ProgramWorkoutExercises (including all progression settings: increment, deloadFactor, repMin, repMax, RPE targets, rest seconds).
- The clone belongs to the requesting user, status PAUSED, currentWeek 1, adherenceStreak 0.
- No link back to the original — fully independent copy.
- Auth: caller must follow the program owner AND `allowCopy` must be true.
- Returns the new program.

**Profile programs:**
Extend `GET /api/v1/profile/:userId` response with:
```ts
copyablePrograms: Array<{
  id: string;
  name: string;
  goal: string;
  description: string | null;
  weekCount: number;
  workoutsPerWeek: number; // from first week
}>
```
Only includes programs where `allowCopy = true`. Only returned when the viewer follows the profile owner.

### Frontend

**Friend's profile page** (`profile-screen.tsx` for `/profile/[userId]`):
New "Programs" card section showing copyable programs. Each program card shows name, goal, week count, workouts/week, and a "Copy to my library" button. On success, toast + navigate to program library.

**Program detail/edit screen** (`program-detail-screen.tsx`):
Add toggle: "Allow followers to copy this program" — visible only to the program owner. Calls `PATCH /api/v1/programs/:programId` with `{ allowCopy: boolean }`.

### Files to Modify

| File | Change |
|------|--------|
| `backend/prisma/schema.prisma` | Add `allowCopy` field to `Program` |
| `backend/src/services/program.service.ts` | Add `copyProgram` function |
| `backend/src/routes/programs.routes.ts` | Add `POST /:programId/copy` route |
| `backend/src/services/profile.service.ts` | Include copyable programs in profile response |
| `web/src/lib/api-client.ts` | Add `copyProgram` function |
| `web/src/lib/types.ts` | Add `copyablePrograms` to `ProfileView`, add `allowCopy` to `Program` |
| `web/src/components/profile/profile-screen.tsx` | Add copyable programs section on friend profiles |
| `web/src/components/programs/program-detail-screen.tsx` | Add allowCopy toggle for owner |

---

## Feature 3: Train with Mates

### New Infrastructure: Notifications

**Data model:**

```prisma
model Notification {
  id        String   @id @default(cuid())
  userId    String
  type      String   // "WORKOUT_INVITE" | extensible for future types
  title     String
  body      String?
  payload   Json?    // type-specific data: { inviteId, eventId, etc. }
  read      Boolean  @default(false)
  createdAt DateTime @default(now())

  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId, read, createdAt])
}
```

**API:**
- `GET /api/v1/notifications` — returns unread + recent read (last 50), newest first
- `GET /api/v1/notifications/unread-count` — returns `{ count: number }` for badge
- `PATCH /api/v1/notifications/:id/read` — mark single as read
- `POST /api/v1/notifications/read-all` — mark all as read

**Frontend:**
- Notification bell icon added to `app-shell.tsx` or `primary-nav.tsx` header area
- Unread count badge (red dot with number)
- Bell opens a Sheet listing notifications
- Each notification is tappable — payload determines navigation (e.g., workout invite goes to invite accept/decline)
- Poll for unread count every 30 seconds via TanStack Query refetch interval

### Workout Invites

**Data model:**

```prisma
model WorkoutInvite {
  id               String   @id @default(cuid())
  fromUserId       String
  toUserId         String
  programWorkoutId String?
  templateId       String?
  workoutTitle     String
  exercises        Json     // Snapshot: Array<{ exerciseId, exerciseName, sets, repMin, repMax, ... }>
  status           String   @default("PENDING") // "PENDING" | "ACCEPTED" | "DECLINED" | "EXPIRED"
  expiresAt        DateTime
  createdAt        DateTime @default(now())

  fromSessionId    String?  // The inviter's active workout session ID
  fromUser         User     @relation("SentInvites", fields: [fromUserId], references: [id], onDelete: Cascade)
  toUser           User     @relation("ReceivedInvites", fields: [toUserId], references: [id], onDelete: Cascade)

  @@index([toUserId, status])
}
```

**API:**

`POST /api/v1/workouts/invite`
- Body: `{ toUserId, programWorkoutId?, templateId?, workoutTitle }`
- Snapshots the exercise lineup from the source (program workout or template)
- Creates the invite with 24-hour expiry
- Creates a Notification for the recipient
- Auth: caller must follow the target user
- Returns the invite

`POST /api/v1/workouts/invite/:inviteId/accept`
- Creates a new WorkoutSession for the recipient using the snapshotted exercises
- Marks invite as ACCEPTED
- Returns the new session ID so frontend can navigate to the workout editor
- Stores inviteId on the new session (add `inviteId String?` to WorkoutSession) for comparison linkage

`POST /api/v1/workouts/invite/:inviteId/decline`
- Marks invite as DECLINED

**Expiry:** A scheduled cleanup or lazy check — when fetching pending invites, filter out expired ones and mark them. No cron needed; check `expiresAt < now()` on read.

### Post-Workout Comparison

When both users (inviter and invitee) have completed their workout sessions linked by the same invite, a comparison becomes available.

**Linkage:** Add `inviteId String?` to `WorkoutSession` and `fromSessionId String?` to `WorkoutInvite`. The inviter sends the invite from the workout editor (mid-workout), so their session ID is known and stored as `fromSessionId` on the invite. When the invitee accepts, their new session gets the same `inviteId`. To find both sessions for comparison: query WorkoutSessions where `inviteId` matches, plus the session referenced by `fromSessionId` on the invite.

**API:**
`GET /api/v1/workouts/:sessionId/comparison`
- Finds the paired session via inviteId
- For each exercise (matched by exerciseId):
  - Calculates % change in volume from each user's previous session on that exercise
  - Calculates % change in estimated 1RM from each user's previous session
- Returns:
```ts
{
  mySession: { completedAt, totalVolume },
  mateSession: { completedAt, displayName },
  exercises: Array<{
    exerciseName: string;
    myVolumeChange: number | null;      // percentage, e.g. +5.2
    mateVolumeChange: number | null;    // percentage
    myE1rmChange: number | null;        // percentage
    mateE1rmChange: number | null;      // percentage
  }>
}
```

No raw weights or volumes for the mate — only % deltas.

**Frontend:**
- On the workout completion screen and workout detail page, if the session has an inviteId and both sessions are complete, show a "Compare with [mate]" card
- Comparison view: exercise-by-exercise table with two columns of % changes, highlighted green (improved) or neutral (same/declined)
- Simple, celebratory tone — "You both crushed it" vibes

### Files to Modify

| File | Change |
|------|--------|
| `backend/prisma/schema.prisma` | Add `Notification`, `WorkoutInvite` models. Add `inviteId` to `WorkoutSession`. Add relations to `User`. |
| `backend/src/services/notification.service.ts` | **New** — CRUD for notifications |
| `backend/src/routes/notification.routes.ts` | **New** — notification endpoints |
| `backend/src/services/workout.service.ts` | Add invite creation, acceptance, decline. Add comparison logic. |
| `backend/src/routes/workouts.routes.ts` | Add invite and comparison endpoints |
| `web/src/lib/api-client.ts` | Add notification, invite, and comparison API functions |
| `web/src/lib/types.ts` | Add Notification, WorkoutInvite, WorkoutComparison types |
| `web/src/components/layout/app-shell.tsx` | Add notification bell with unread count |
| `web/src/components/notifications/notification-sheet.tsx` | **New** — notification list sheet |
| `web/src/components/workouts/workout-editor.tsx` | Add "Invite mate" button |
| `web/src/components/workouts/invite-mate-sheet.tsx` | **New** — pick a friend to invite |
| `web/src/components/workouts/workout-comparison.tsx` | **New** — post-workout % comparison view |

---

## Implementation Order

1. **Kudos/Reactions** — standalone, no dependencies
2. **Copy Programs** — standalone, no dependencies
3. **Notifications infrastructure** — needed by train-with-mates
4. **Workout Invites** — depends on notifications
5. **Post-Workout Comparison** — depends on workout invites

---

## Verification Plan

### Kudos
1. Open social feed, verify emoji buttons appear under each event
2. Tap an emoji — verify count increments, button highlights
3. Tap again — verify it toggles off
4. Refresh page — verify reactions persist
5. Check as a different user — verify their reactions are independent

### Copy Programs
1. Create a program, toggle "Allow copying" on
2. As a different user who follows the first, visit their profile
3. Verify the program appears in a "Programs" section
4. Tap "Copy to my library" — verify a full clone appears in your program list
5. Verify the clone is independent (editing doesn't affect original)
6. Toggle allowCopy off — verify the program disappears from the profile

### Notifications
1. Verify bell icon appears in the header
2. Trigger a notification (via workout invite)
3. Verify unread count badge updates
4. Open notification sheet — verify notification appears
5. Tap "Mark all read" — verify badge clears

### Workout Invites
1. Start a workout, tap "Invite mate"
2. Pick a followed user, send invite
3. As the recipient, verify notification arrives
4. Accept the invite — verify a new workout session starts with the same exercise lineup
5. Both users complete the workout
6. Verify "Compare with [mate]" card appears
7. Open comparison — verify only % deltas shown, no raw numbers for the mate
8. Test invite expiry — create invite, wait (or manually set expiry in DB), verify it shows as expired
9. Test decline flow
