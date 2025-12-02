import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/conversation.dart';
import '../../shared/providers/conversation_provider.dart';
import '../../core/theme/openai_theme.dart';

/// AI Conversation screen with chat interface
class AIConversationScreen extends ConsumerStatefulWidget {
  final ConversationScenario scenario;

  const AIConversationScreen({
    super.key,
    required this.scenario,
  });

  @override
  ConsumerState<AIConversationScreen> createState() =>
      _AIConversationScreenState();
}

class _AIConversationScreenState extends ConsumerState<AIConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    ref
        .read(conversationProvider(widget.scenario).notifier)
        .sendMessage(message);
    _messageController.clear();

    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 300), () {
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
    final conversationState = ref.watch(conversationProvider(widget.scenario));
    final role = conversationState.role;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${widget.scenario.icon} ${widget.scenario.nameIt}'),
              ],
            ),
            Text(
              '对话：${role.nameZh}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          // Level selector
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [OpenAITheme.openaiGreen, OpenAITheme.openaiGreenDark]),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: OpenAITheme.openaiGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                conversationState.userLevel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            onSelected: (level) {
              ref
                  .read(conversationProvider(widget.scenario).notifier)
                  .setUserLevel(level);
            },
            itemBuilder: (context) => [
              'A1',
              'A2',
              'B1',
              'B2',
              'C1',
              'C2'
            ].map((level) {
              return PopupMenuItem(
                value: level,
                child: Text(level),
              );
            }).toList(),
          ),
          // Reset button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('重新开始'),
                  content: const Text('确定要重新开始对话吗？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(conversationProvider(widget.scenario).notifier)
                            .reset();
                        Navigator.pop(context);
                      },
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Scenario description banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  OpenAITheme.openaiGreen.withValues(alpha: 0.1),
                  OpenAITheme.info.withValues(alpha: 0.1),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: OpenAITheme.openaiGreen.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
            ),
            child: Text(
              widget.scenario.description,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: OpenAITheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Error banner
          if (conversationState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade100,
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      conversationState.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      ref
                          .read(conversationProvider(widget.scenario).notifier)
                          .clearError();
                    },
                  ),
                ],
              ),
            ),

          // Messages list
          Expanded(
            child: conversationState.messages.isEmpty &&
                    !conversationState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: conversationState.messages.length +
                        (conversationState.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= conversationState.messages.length) {
                        // Loading indicator
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 12),
                              Text('正在输入...'),
                            ],
                          ),
                        );
                      }

                      final message = conversationState.messages[index];
                      return _MessageBubble(
                        message: message,
                        roleName: message.isUser ? '你' : role.nameZh,
                      );
                    },
                  ),
          ),

          // Input area
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '用意大利语输入...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: conversationState.isLoading ? null : _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Message bubble widget
class _MessageBubble extends StatelessWidget {
  final ConversationMessage message;
  final String roleName;

  const _MessageBubble({
    required this.message,
    required this.roleName,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [OpenAITheme.info, Color(0xFF2563EB)]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: OpenAITheme.info.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Role name
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
                  child: Text(
                    roleName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Message content
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: isUser ? LinearGradient(colors: [OpenAITheme.openaiGreen, OpenAITheme.openaiGreenDark]) : null,
                    color: isUser ? null : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isUser
                        ? [
                            BoxShadow(
                              color: OpenAITheme.openaiGreen.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
                // Grammar corrections
                if (message.corrections != null &&
                    message.corrections!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(color: Colors.orange.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb,
                                size: 16, color: Colors.orange.shade700),
                            const SizedBox(width: 4),
                            Text(
                              '语法提示',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...message.corrections!.map((correction) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: correction.originalText,
                                              style: const TextStyle(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                color: Colors.red,
                                              ),
                                            ),
                                            const TextSpan(text: ' → '),
                                            TextSpan(
                                              text: correction.correctedText,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  correction.explanation,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
                // Timestamp
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                  child: Text(
                    '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [OpenAITheme.openaiGreen, OpenAITheme.openaiGreenDark]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: OpenAITheme.openaiGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 22),
            ),
          ],
        ],
      ),
    );
  }
}
