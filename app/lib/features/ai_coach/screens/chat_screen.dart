/// LiftIQ - AI Coach Chat Screen
///
/// Main chat interface for conversing with the AI coach.
/// Provides a ChatGPT-like experience for workout advice.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/quick_prompt.dart';
import '../providers/ai_coach_provider.dart';

/// Main chat screen for AI coach interaction.
///
/// Features:
/// - Full chat history with scrolling
/// - Message input with send button
/// - Quick prompt chips for common questions
/// - Loading indicator during AI response
/// - Error handling with retry
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Sends a message to the AI coach.
  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    ref.read(chatProvider.notifier).sendMessage(message);
    _messageController.clear();
    _scrollToBottom();
  }

  /// Sends a quick prompt to the AI.
  void _sendQuickPrompt(QuickPromptCategory category) {
    final prompts = {
      QuickPromptCategory.form: 'Give me form tips for my current exercise',
      QuickPromptCategory.progression:
          'How should I progress my weights this week?',
      QuickPromptCategory.alternative:
          'What are some good alternative exercises?',
      QuickPromptCategory.explanation:
          'Explain why progressive overload is important',
      QuickPromptCategory.motivation: "I'm feeling unmotivated today",
    };

    final message = prompts[category] ?? category.description;
    ref.read(chatProvider.notifier).sendMessage(message);
    _scrollToBottom();
  }

  /// Scrolls to the bottom of the chat.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Scroll to bottom when new messages arrive
    ref.listen(chatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach'),
        actions: [
          // Clear chat button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear chat',
            onPressed: chatState.messages.isEmpty
                ? null
                : () => _showClearConfirmation(context),
          ),
          // AI status indicator
          const _AIStatusIndicator(),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: chatState.messages.isEmpty
                ? _buildEmptyState(theme, colors)
                : _buildMessageList(chatState, theme, colors),
          ),

          // Error message
          if (chatState.error != null)
            _buildErrorBanner(chatState.error!, colors),

          // Quick prompts (show when empty or few messages)
          if (chatState.messages.length < 4) _buildQuickPrompts(colors),

          // Message input
          _buildInputArea(chatState, theme, colors),
        ],
      ),
    );
  }

  /// Builds the empty state with welcome message.
  Widget _buildEmptyState(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: colors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'AI Coach',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "I'm here to help with your training!\nAsk me about form, progression, or anything fitness-related.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the list of chat messages.
  Widget _buildMessageList(
    ChatState chatState,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: chatState.messages.length + (chatState.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the end
        if (index == chatState.messages.length) {
          return const _TypingIndicator();
        }

        final message = chatState.messages[index];
        return _MessageBubble(message: message);
      },
    );
  }

  /// Builds the error banner.
  Widget _buildErrorBanner(String error, ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colors.errorContainer,
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.onErrorContainer, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(chatProvider.notifier).clearError(),
            child: Text(
              'Dismiss',
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the quick prompt chips.
  Widget _buildQuickPrompts(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick prompts',
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: QuickPromptCategory.values.map((category) {
              return ActionChip(
                avatar: Icon(_getCategoryIcon(category), size: 18),
                label: Text(category.label),
                onPressed: () => _sendQuickPrompt(category),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Gets the icon for a quick prompt category.
  IconData _getCategoryIcon(QuickPromptCategory category) {
    switch (category) {
      case QuickPromptCategory.form:
        return Icons.sports_gymnastics;
      case QuickPromptCategory.progression:
        return Icons.trending_up;
      case QuickPromptCategory.alternative:
        return Icons.swap_horiz;
      case QuickPromptCategory.explanation:
        return Icons.lightbulb_outline;
      case QuickPromptCategory.motivation:
        return Icons.psychology;
    }
  }

  /// Builds the message input area.
  Widget _buildInputArea(
    ChatState chatState,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.outlineVariant),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text input
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Ask your AI coach...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colors.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          IconButton.filled(
            icon: chatState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            onPressed: chatState.isLoading ? null : _sendMessage,
          ),
        ],
      ),
    );
  }

  /// Shows confirmation dialog for clearing chat.
  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text(
          'Are you sure you want to clear the chat history? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(chatProvider.notifier).clearChat();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

/// A single message bubble in the chat.
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI avatar
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: colors.primaryContainer,
              child: Icon(
                Icons.smart_toy,
                size: 18,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Message content
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? colors.primary : colors.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message text
                  Text(
                    message.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isUser ? colors.onPrimary : colors.onSurface,
                    ),
                  ),
                  // Timestamp
                  const SizedBox(height: 4),
                  Text(
                    message.formattedTime,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isUser
                          ? colors.onPrimary.withValues(alpha: 0.7)
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // User avatar space
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

/// Typing indicator shown when AI is responding.
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colors.primaryContainer,
            child: Icon(
              Icons.smart_toy,
              size: 18,
              color: colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final value =
                        ((_controller.value + delay) % 1.0 * 2 - 1).abs();
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.3 + value * 0.7),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// AI service status indicator in the app bar.
class _AIStatusIndicator extends ConsumerWidget {
  const _AIStatusIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(aiStatusProvider);
    final colors = Theme.of(context).colorScheme;

    return statusAsync.when(
      data: (status) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Tooltip(
          message: status.available
              ? 'AI Coach online'
              : 'AI Coach offline',
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: status.available ? Colors.green : colors.error,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
      loading: () => const Padding(
        padding: EdgeInsets.only(right: 8),
        child: SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Icon(
          Icons.warning_amber,
          size: 18,
          color: colors.error,
        ),
      ),
    );
  }
}
