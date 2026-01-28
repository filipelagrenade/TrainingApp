# Overnight Autonomous Run — PostgreSQL Sync Implementation

> **Instructions for each iteration**: Read `CLAUDE.md` at project root, read the latest handover in `.claude/`, then execute the next unchecked phase below. After completing a phase, run `flutter build web` in `app/`, copy `app/build/web/*` to `backend/public/`, git commit, create a handover doc, and check off the phase.

**STATUS**: COMPLETE — 6/6 phases complete

## Overview

Implement real-time bi-directional sync between Flutter local storage and backend PostgreSQL. Local storage remains source of truth for current session (offline-first), with background sync to PostgreSQL on every data change. Use last-write-wins conflict resolution based on `lastModifiedAt` timestamps.

**Data to Sync**: Workouts, templates, measurements, progression states, settings, mesocycles, achievements, personal records.

## Phase Checklist

> **Tick off each phase as you complete it. The overnight runner MUST update this checklist after each phase.**

- [x] **Phase 1** — Backend Sync Infrastructure
- [x] **Phase 2** — Flutter Sync Models & Queue
- [x] **Phase 3** — Flutter Sync Service
- [x] **Phase 4** — Integrate Sync into Existing Services
- [x] **Phase 5** — App Lifecycle & Background Sync
- [x] **Phase 6** — Testing & Verification

---

## Phase 1: Backend Sync Infrastructure

**Goal**: Create backend sync endpoints and add sync metadata to Prisma schema.

**Files to modify/create**:
- `backend/prisma/schema.prisma` — add sync fields
- `backend/src/services/sync.service.ts` — create new
- `backend/src/routes/sync.routes.ts` — create new
- `backend/src/routes/index.ts` — mount sync routes

**Tasks**:
- [ ] Update Prisma schema — add to WorkoutSession, WorkoutTemplate, BodyMeasurement, Mesocycle, MesocycleWeek:
  ```prisma
  lastModifiedAt DateTime @updatedAt
  clientId       String?
  ```
- [ ] Run `npx prisma migrate dev --name add_sync_fields`
- [ ] Create `backend/src/services/sync.service.ts`:
  - `processChanges(userId, changes[])` — apply batch changes with last-write-wins
  - `getChangesSince(userId, timestamp)` — get all changes since timestamp
  - `resolveConflict(local, remote)` — compare lastModifiedAt, newer wins
- [ ] Create `backend/src/routes/sync.routes.ts`:
  - `POST /api/v1/sync/push` — receive batch of changes from client, return success/failed
  - `GET /api/v1/sync/pull?since=<timestamp>` — return changes since timestamp with serverTime
- [ ] Mount routes in `backend/src/routes/index.ts`
- [ ] Test endpoints manually with curl (create test user, push a workout, pull it back)
- [ ] `cd backend && npm run build` succeeds

**Commit**: `feat(backend): add sync endpoints with last-write-wins conflict resolution`

---

## Phase 2: Flutter Sync Models & Queue

**Goal**: Create sync queue model and service for offline-first queuing of changes.

**Files to create**:
- `app/lib/shared/models/sync_queue_item.dart`
- `app/lib/shared/services/sync_queue_service.dart`

**Files to modify**:
- `app/pubspec.yaml` — add connectivity_plus

**Tasks**:
- [ ] Add to `pubspec.yaml`:
  ```yaml
  connectivity_plus: ^6.0.0
  ```
- [ ] Run `flutter pub get`
- [ ] Create `app/lib/shared/models/sync_queue_item.dart`:
  ```dart
  enum SyncEntityType { workout, template, measurement, progression, settings, mesocycle, achievement }
  enum SyncAction { create, update, delete }

  class SyncQueueItem {
    final String id;
    final SyncEntityType entityType;
    final SyncAction action;
    final String entityId;
    final Map<String, dynamic> data;
    final DateTime createdAt;
    final int retryCount;
    // JSON serialization methods
  }
  ```
- [ ] Create `app/lib/shared/services/sync_queue_service.dart`:
  - `addToQueue(item)` — add change to queue, persist to SharedPreferences
  - `getQueuedItems()` — get all pending items
  - `removeFromQueue(id)` — remove after successful sync
  - `incrementRetryCount(id)` — track failed attempts (max 5 retries)
  - `clearQueue()` — remove all items
  - Use user-scoped storage keys from `UserStorageKeys`
- [ ] `flutter build web` succeeds

**Commit**: `feat(sync): add sync queue model and service for offline-first changes`

---

## Phase 3: Flutter Sync Service

**Goal**: Create main sync orchestration service and connectivity monitoring.

**Files to create**:
- `app/lib/shared/services/connectivity_service.dart`
- `app/lib/shared/services/sync_service.dart`
- `app/lib/providers/sync_provider.dart`

**Tasks**:
- [ ] Create `app/lib/shared/services/connectivity_service.dart`:
  - Use `connectivity_plus` package
  - Expose `Stream<bool> onConnectivityChanged`
  - `Future<bool> isOnline()` method
  - Auto-trigger callback when connection restored
- [ ] Create `app/lib/shared/services/sync_service.dart`:
  - Constructor takes: ApiClient, SyncQueueService, ConnectivityService
  - `pushChanges()` — send queued items to `POST /api/v1/sync/push`, remove successful items from queue
  - `pullChanges()` — fetch from `GET /api/v1/sync/pull?since=<lastSync>`, apply to local storage
  - `syncAll()` — push then pull
  - `getLastSyncTimestamp()` / `setLastSyncTimestamp()` — persist in SharedPreferences
  - Retry logic with exponential backoff (1s, 2s, 4s, 8s, 16s)
  - Listen to connectivity changes, auto-sync when online
- [ ] Create `app/lib/providers/sync_provider.dart`:
  - `syncStatusProvider` — enum: idle, syncing, error, offline
  - `pendingChangesCountProvider` — count of queued items
  - `lastSyncTimeProvider` — DateTime of last successful sync
  - `syncServiceProvider` — singleton instance
- [ ] `flutter build web` succeeds

**Commit**: `feat(sync): add sync service with connectivity monitoring and auto-sync`

---

## Phase 4: Integrate Sync into Existing Services

**Goal**: Hook sync queue into all data mutation points across the app.

**Files to modify**:
- `app/lib/shared/services/workout_history_service.dart`
- `app/lib/features/templates/providers/templates_provider.dart`
- `app/lib/shared/services/progression_state_service.dart`
- `app/lib/features/periodization/providers/periodization_provider.dart`
- `app/lib/features/settings/providers/settings_provider.dart`
- `app/lib/features/measurements/` (if exists)

**Tasks**:
- [ ] Modify `WorkoutHistoryService`:
  - Inject `SyncQueueService` via provider
  - After `saveWorkout()` → `syncQueue.addToQueue(SyncQueueItem(entityType: workout, action: create, ...))`
  - After `deleteWorkout()` → queue delete action
  - Add `applyRemoteChanges(List<Change>)` method for incoming sync data
- [ ] Modify `UserTemplatesNotifier` in templates_provider.dart:
  - After `addTemplate()` → queue create
  - After `updateTemplate()` → queue update
  - After `deleteTemplate()` → queue delete
- [ ] Modify `ProgressionStateService`:
  - After `saveState()` → queue update
  - Add method to apply remote progression states
- [ ] Modify `MesocyclesNotifier` in periodization_provider.dart:
  - After `createMesocycle()` → queue create
  - After `startMesocycle()`, `advanceWeek()`, `abandonMesocycle()` → queue update
- [ ] Modify settings provider (if exists) or create sync hook for user settings
- [ ] `flutter build web` succeeds

**Commit**: `feat(sync): integrate sync queue into all data mutation services`

---

## Phase 5: App Lifecycle & Background Sync

**Goal**: Trigger sync on app lifecycle events and add UI indicators.

**Files to modify**:
- `app/lib/main.dart` or `app/lib/app.dart`
- `app/lib/features/settings/screens/settings_screen.dart`
- Create `app/lib/shared/widgets/sync_status_indicator.dart`

**Tasks**:
- [ ] Add `WidgetsBindingObserver` to main app widget:
  - On `resumed` (app foreground) → trigger `syncService.syncAll()`
  - On `paused` (app background) → trigger `syncService.pushChanges()` if queue not empty
- [ ] Create `SyncStatusIndicator` widget:
  - Small icon showing: cloud-check (synced), cloud-sync (syncing), cloud-off (offline), cloud-alert (error)
  - Show pending count badge when items queued
  - Tap to trigger manual sync
- [ ] Add `SyncStatusIndicator` to app bar (home screen or global)
- [ ] Add sync section to settings screen:
  - Last sync time display
  - Manual "Sync Now" button
  - Pending changes count
  - "Clear sync queue" option (with confirmation)
- [ ] `flutter build web` succeeds

**Commit**: `feat(sync): add app lifecycle sync triggers and UI status indicator`

---

## Phase 6: Testing & Verification

**Goal**: Verify sync works end-to-end in various scenarios.

**Tasks**:
- [ ] Test offline queue:
  - Enable airplane mode (or disconnect network)
  - Complete a workout
  - Check SharedPreferences for queued item
  - Reconnect network
  - Verify sync triggers automatically and queue empties
  - Verify workout appears in database (check via Prisma Studio or API)
- [ ] Test pull sync:
  - Insert a workout directly in PostgreSQL via Prisma Studio
  - Pull on app
  - Verify workout appears in local workout history
- [ ] Test conflict resolution:
  - Create template locally
  - Sync to server
  - Modify template on server (change name, update lastModifiedAt)
  - Modify same template locally with older timestamp
  - Sync
  - Verify server version wins (newer timestamp)
- [ ] Test app lifecycle:
  - Start workout, log some sets
  - Background app
  - Check logs for push attempt
  - Resume app
  - Check logs for full sync
- [ ] Build and deploy:
  - `cd app && flutter build web --release`
  - `rm -rf ../backend/public/* && cp -r build/web/* ../backend/public/`
  - Test on Railway deployment
- [ ] `flutter build web` succeeds

**Commit**: `test(sync): verify sync functionality across all scenarios`

---

## Post-Completion

After all 6 phases:
1. Run full `flutter build web` and copy to `backend/public/`
2. Create final handover at `.claude/handover.md`
3. Update `FEATURES.md` with sync feature documentation
4. Final commit: `feat: PostgreSQL sync implementation complete`
5. Push to remote: `git push`

---

## Key Files Reference

**Backend (new)**:
| File | Purpose |
|------|---------|
| `backend/src/services/sync.service.ts` | Sync business logic, conflict resolution |
| `backend/src/routes/sync.routes.ts` | POST /sync/push, GET /sync/pull endpoints |

**Flutter (new)**:
| File | Purpose |
|------|---------|
| `app/lib/shared/models/sync_queue_item.dart` | Queue item model with enums |
| `app/lib/shared/services/sync_queue_service.dart` | Local queue persistence |
| `app/lib/shared/services/sync_service.dart` | Sync orchestration |
| `app/lib/shared/services/connectivity_service.dart` | Network monitoring |
| `app/lib/providers/sync_provider.dart` | Riverpod providers for sync state |
| `app/lib/shared/widgets/sync_status_indicator.dart` | UI indicator widget |

**Modified**:
| File | Change |
|------|--------|
| `backend/prisma/schema.prisma` | Add lastModifiedAt, clientId fields |
| `app/pubspec.yaml` | Add connectivity_plus |
| `app/lib/shared/services/workout_history_service.dart` | Queue sync on mutations |
| `app/lib/features/templates/providers/templates_provider.dart` | Queue sync on mutations |
| `app/lib/shared/services/progression_state_service.dart` | Queue sync on mutations |
| `app/lib/features/periodization/providers/periodization_provider.dart` | Queue sync on mutations |
