/// LiftIQ - Chat Persistence Service
///
/// Handles saving and loading AI coach chat history to SharedPreferences.
/// Uses user-specific storage keys to isolate data between users.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/user_storage_keys.dart';
import '../models/chat_message.dart';

/// Service for persisting AI chat history to local storage.
///
/// Chat messages are saved as JSON to SharedPreferences with user-specific keys.
/// This ensures:
/// - Chat history persists across app restarts
/// - Each user has their own isolated chat history
/// - Auto-save is debounced to prevent excessive writes
///
/// ## Usage
/// ```dart
/// final service = ChatPersistenceService(userId);
/// final messages = await service.loadChatHistory();
/// await service.saveChatHistory(messages);
/// ```
class ChatPersistenceService {
  /// The user ID this service is scoped to.
  final String _userId;

  /// Debounce timer for auto-save functionality.
  Timer? _saveDebounceTimer;

  /// Gets the storage key for this user's chat history.
  String get _storageKey => UserStorageKeys.aiChatHistory(_userId);

  /// Creates a new ChatPersistenceService for the given user.
  ///
  /// [userId] is the unique identifier for the user, used to create
  /// user-specific storage keys.
  ChatPersistenceService(this._userId);

  /// Loads chat history from SharedPreferences.
  ///
  /// Returns an empty list if no history exists or if loading fails.
  /// Messages are sorted by timestamp in ascending order.
  Future<List<ChatMessage>> loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        debugPrint('ChatPersistenceService: No chat history found for user $_userId');
        return [];
      }

      final decoded = jsonDecode(jsonString) as List<dynamic>;
      final messages = decoded
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();

      // Sort by timestamp to ensure correct order
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      debugPrint('ChatPersistenceService: Loaded ${messages.length} messages for user $_userId');
      return messages;
    } on Exception catch (e) {
      debugPrint('ChatPersistenceService: Error loading chat history: $e');
      return [];
    }
  }

  /// Saves chat history to SharedPreferences.
  ///
  /// [messages] is the list of chat messages to save.
  /// Overwrites any existing chat history for this user.
  Future<void> saveChatHistory(List<ChatMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = messages.map((m) => m.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await prefs.setString(_storageKey, jsonString);
      debugPrint('ChatPersistenceService: Saved ${messages.length} messages for user $_userId');
    } on Exception catch (e) {
      debugPrint('ChatPersistenceService: Error saving chat history: $e');
    }
  }

  /// Schedules a debounced save of chat history.
  ///
  /// This prevents excessive writes when messages are being sent rapidly.
  /// The save will occur after [delay] (default 500ms) of inactivity.
  ///
  /// [messages] is the list of chat messages to save.
  /// [delay] is the debounce duration (default 500ms).
  void scheduleSave(List<ChatMessage> messages, {Duration delay = const Duration(milliseconds: 500)}) {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(delay, () {
      saveChatHistory(messages);
    });
  }

  /// Clears all chat history for this user.
  ///
  /// This removes the chat history from SharedPreferences entirely.
  Future<void> clearChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      debugPrint('ChatPersistenceService: Cleared chat history for user $_userId');
    } on Exception catch (e) {
      debugPrint('ChatPersistenceService: Error clearing chat history: $e');
    }
  }

  /// Cancels any pending debounced save operations.
  ///
  /// Call this when disposing the service to prevent memory leaks.
  void dispose() {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = null;
  }
}
