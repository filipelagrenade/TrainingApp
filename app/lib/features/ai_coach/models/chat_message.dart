/// LiftIQ - Chat Message Model
///
/// Represents a message in the AI coach chat conversation.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

/// Role of the message sender.
enum ChatRole {
  /// System message (context/instructions)
  system,
  /// User's message
  user,
  /// AI assistant's response
  assistant,
}

/// A single chat message.
///
/// ## Usage
/// ```dart
/// final message = ChatMessage(
///   id: 'msg-1',
///   role: ChatRole.user,
///   content: 'How do I improve my bench press?',
///   timestamp: DateTime.now(),
/// );
/// ```
@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    /// Unique message ID
    required String id,

    /// Role of the sender
    required ChatRole role,

    /// Message content
    required String content,

    /// When the message was sent
    required DateTime timestamp,

    /// Whether the message is still being typed (streaming)
    @Default(false) bool isStreaming,

    /// Error message if response failed
    String? error,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

/// Extension methods for ChatMessage.
extension ChatMessageExtensions on ChatMessage {
  /// Returns true if this is a user message.
  bool get isUser => role == ChatRole.user;

  /// Returns true if this is an AI response.
  bool get isAssistant => role == ChatRole.assistant;

  /// Returns true if this message has an error.
  bool get hasError => error != null;

  /// Returns formatted time string.
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// AI response with additional metadata.
@freezed
class AIResponse with _$AIResponse {
  const factory AIResponse({
    /// Main response message
    required String message,

    /// Actionable suggestions extracted from response
    @Default([]) List<String> suggestions,

    /// Related exercises mentioned
    @Default([]) List<String> relatedExercises,

    /// Safety note if medical topics detected
    String? safetyNote,
  }) = _AIResponse;

  factory AIResponse.fromJson(Map<String, dynamic> json) =>
      _$AIResponseFromJson(json);
}

/// Extension for AIResponse.
extension AIResponseExtensions on AIResponse {
  /// Returns true if there are suggestions.
  bool get hasSuggestions => suggestions.isNotEmpty;

  /// Returns true if there's a safety note.
  bool get hasSafetyNote => safetyNote != null;
}
