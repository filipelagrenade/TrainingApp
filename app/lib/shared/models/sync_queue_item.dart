/// LiftIQ - Sync Queue Item Model
///
/// Defines the data structure for items in the sync queue.
/// Used for offline-first sync with the PostgreSQL backend.
///
/// Features:
/// - Entity types for all syncable data
/// - Actions for CRUD operations
/// - JSON serialization for SharedPreferences storage
/// - Retry tracking for failed sync attempts
library;

import 'package:uuid/uuid.dart';

// ============================================================================
// ENUMS
// ============================================================================

/// Types of entities that can be synced.
///
/// Maps to the backend sync service entity types.
enum SyncEntityType {
  /// Workout sessions
  workout,

  /// User-created workout templates
  template,

  /// Body measurements
  measurement,

  /// Exercise progression states
  progression,

  /// User settings/preferences
  settings,

  /// Training mesocycles
  mesocycle,

  /// Individual weeks within mesocycles
  mesocycleWeek,

  /// User achievements
  achievement,

  /// Custom exercises
  exercise,

  /// Training programs
  program,

  /// AI chat history
  chatHistory,
}

/// Extension to convert SyncEntityType to/from string.
extension SyncEntityTypeExtension on SyncEntityType {
  /// Converts to API-compatible string.
  String get apiName {
    switch (this) {
      case SyncEntityType.workout:
        return 'workout';
      case SyncEntityType.template:
        return 'template';
      case SyncEntityType.measurement:
        return 'measurement';
      case SyncEntityType.progression:
        return 'progression';
      case SyncEntityType.settings:
        return 'settings';
      case SyncEntityType.mesocycle:
        return 'mesocycle';
      case SyncEntityType.mesocycleWeek:
        return 'mesocycleWeek';
      case SyncEntityType.achievement:
        return 'achievement';
      case SyncEntityType.exercise:
        return 'exercise';
      case SyncEntityType.program:
        return 'program';
      case SyncEntityType.chatHistory:
        return 'chatHistory';
    }
  }

  /// Parses from API string.
  static SyncEntityType fromApiName(String name) {
    switch (name) {
      case 'workout':
        return SyncEntityType.workout;
      case 'template':
        return SyncEntityType.template;
      case 'measurement':
        return SyncEntityType.measurement;
      case 'progression':
        return SyncEntityType.progression;
      case 'settings':
        return SyncEntityType.settings;
      case 'mesocycle':
        return SyncEntityType.mesocycle;
      case 'mesocycleWeek':
        return SyncEntityType.mesocycleWeek;
      case 'achievement':
        return SyncEntityType.achievement;
      case 'exercise':
        return SyncEntityType.exercise;
      case 'program':
        return SyncEntityType.program;
      case 'chatHistory':
        return SyncEntityType.chatHistory;
      default:
        throw ArgumentError('Unknown SyncEntityType: $name');
    }
  }
}

/// Actions that can be performed on synced entities.
enum SyncAction {
  /// Create a new entity
  create,

  /// Update an existing entity
  update,

  /// Delete an entity
  delete,
}

/// Extension to convert SyncAction to/from string.
extension SyncActionExtension on SyncAction {
  /// Converts to API-compatible string.
  String get apiName {
    switch (this) {
      case SyncAction.create:
        return 'create';
      case SyncAction.update:
        return 'update';
      case SyncAction.delete:
        return 'delete';
    }
  }

  /// Parses from API string.
  static SyncAction fromApiName(String name) {
    switch (name) {
      case 'create':
        return SyncAction.create;
      case 'update':
        return SyncAction.update;
      case 'delete':
        return SyncAction.delete;
      default:
        throw ArgumentError('Unknown SyncAction: $name');
    }
  }
}

// ============================================================================
// SYNC QUEUE ITEM
// ============================================================================

/// Represents a single item in the sync queue.
///
/// When data is modified locally, a SyncQueueItem is created and stored.
/// The sync service processes these items when connectivity is available.
///
/// Example:
/// ```dart
/// final item = SyncQueueItem(
///   entityType: SyncEntityType.workout,
///   action: SyncAction.create,
///   entityId: 'workout-123',
///   data: workoutJson,
/// );
/// await syncQueueService.addToQueue(item);
/// ```
class SyncQueueItem {
  /// Unique ID for this queue item (client-generated).
  final String id;

  /// The type of entity being synced.
  final SyncEntityType entityType;

  /// The action to perform.
  final SyncAction action;

  /// The ID of the entity being modified.
  final String entityId;

  /// The entity data (for create/update actions).
  /// Not needed for delete actions.
  final Map<String, dynamic>? data;

  /// When this change was made locally.
  final DateTime createdAt;

  /// When the entity was last modified.
  /// Used for conflict resolution (last-write-wins).
  final DateTime lastModifiedAt;

  /// Number of failed sync attempts.
  /// Items are removed after [maxRetries] failures.
  final int retryCount;

  /// Maximum number of retry attempts before giving up.
  static const int maxRetries = 5;

  /// Creates a new sync queue item.
  SyncQueueItem({
    String? id,
    required this.entityType,
    required this.action,
    required this.entityId,
    this.data,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    this.retryCount = 0,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        lastModifiedAt = lastModifiedAt ?? DateTime.now();

  /// Creates a copy with updated fields.
  SyncQueueItem copyWith({
    String? id,
    SyncEntityType? entityType,
    SyncAction? action,
    String? entityId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    int? retryCount,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      action: action ?? this.action,
      entityId: entityId ?? this.entityId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  /// Increments the retry count.
  SyncQueueItem incrementRetry() {
    return copyWith(retryCount: retryCount + 1);
  }

  /// Whether this item has exceeded max retries.
  bool get hasExceededRetries => retryCount >= maxRetries;

  /// Creates from JSON (for storage deserialization).
  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as String,
      entityType: SyncEntityTypeExtension.fromApiName(json['entityType'] as String),
      action: SyncActionExtension.fromApiName(json['action'] as String),
      entityId: json['entityId'] as String,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModifiedAt: DateTime.parse(json['lastModifiedAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }

  /// Converts to JSON (for storage serialization).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType.apiName,
      'action': action.apiName,
      'entityId': entityId,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  /// Converts to API payload format for sync push.
  Map<String, dynamic> toApiPayload() {
    return {
      'id': id,
      'entityType': entityType.apiName,
      'action': action.apiName,
      'entityId': entityId,
      'data': data,
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
      'clientId': entityId, // Use entityId as clientId for tracking
    };
  }

  @override
  String toString() {
    return 'SyncQueueItem(id: $id, type: ${entityType.apiName}, '
        'action: ${action.apiName}, entityId: $entityId, retries: $retryCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncQueueItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ============================================================================
// SYNC CHANGE RESULT
// ============================================================================

/// Result of syncing a single queue item.
///
/// Returned by the sync service after processing a change.
class SyncChangeResult {
  /// The ID of the queue item that was processed.
  final String id;

  /// Whether the sync was successful.
  final bool success;

  /// Error message if sync failed.
  final String? error;

  /// The resulting entity data after sync.
  final Map<String, dynamic>? entity;

  /// Server timestamp of when the change was applied.
  final DateTime? serverTimestamp;

  const SyncChangeResult({
    required this.id,
    required this.success,
    this.error,
    this.entity,
    this.serverTimestamp,
  });

  /// Creates from API response JSON.
  factory SyncChangeResult.fromJson(Map<String, dynamic> json) {
    return SyncChangeResult(
      id: json['id'] as String,
      success: json['success'] as bool,
      error: json['error'] as String?,
      entity: json['entity'] as Map<String, dynamic>?,
      serverTimestamp: json['serverTimestamp'] != null
          ? DateTime.parse(json['serverTimestamp'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'SyncChangeResult(id: $id, success: $success${error != null ? ', error: $error' : ''})';
  }
}

// ============================================================================
// SYNC PULL CHANGE
// ============================================================================

/// A change received from the server during pull sync.
///
/// Represents an entity that was modified on the server and needs
/// to be applied to local storage.
class SyncPullChange {
  /// The type of entity.
  final SyncEntityType entityType;

  /// The ID of the entity.
  final String entityId;

  /// The action that was performed.
  final SyncAction action;

  /// The entity data.
  final Map<String, dynamic> data;

  /// When the change was made on the server.
  final DateTime lastModifiedAt;

  const SyncPullChange({
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.data,
    required this.lastModifiedAt,
  });

  /// Creates from API response JSON.
  factory SyncPullChange.fromJson(Map<String, dynamic> json) {
    return SyncPullChange(
      entityType: SyncEntityTypeExtension.fromApiName(json['entityType'] as String),
      entityId: json['entityId'] as String,
      action: SyncActionExtension.fromApiName(json['action'] as String),
      data: json['data'] as Map<String, dynamic>,
      lastModifiedAt: DateTime.parse(json['lastModifiedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'SyncPullChange(type: ${entityType.apiName}, '
        'id: $entityId, action: ${action.apiName})';
  }
}
