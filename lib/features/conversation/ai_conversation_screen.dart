import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/conversation.dart';
import '../../shared/providers/conversation_provider.dart';
import '../../shared/providers/voice_preference_provider.dart';
import '../../core/theme/openai_theme.dart';
import '../../core/utils/api_check_helper.dart';

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

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // 检查 DeepSeek API 是否已配置
    final isConfigured = await ApiCheckHelper.checkDeepSeekApi(context);
    if (!isConfigured) return;

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
          // Level selector - OpenAI style
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: OpenAITheme.openaiGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: OpenAITheme.openaiGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                conversationState.userLevel,
                style: const TextStyle(
                  color: OpenAITheme.openaiGreen,
                  fontWeight: FontWeight.w600,
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
          // Scenario description banner - OpenAI style
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: OpenAITheme.bgSecondary,
              border: Border(
                bottom: BorderSide(
                  color: OpenAITheme.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: Text(
              widget.scenario.description,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: OpenAITheme.textSecondary,
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

          // Input area - OpenAI style
          Container(
            decoration: const BoxDecoration(
              color: OpenAITheme.bgPrimary,
              border: Border(
                top: BorderSide(color: OpenAITheme.borderLight, width: 1),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '用意大利语输入...',
                      hintStyle: const TextStyle(color: OpenAITheme.textTertiary),
                      filled: true,
                      fillColor: OpenAITheme.bgSecondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: OpenAITheme.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: OpenAITheme.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: OpenAITheme.openaiGreen),
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
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: conversationState.isLoading
                        ? OpenAITheme.gray200
                        : OpenAITheme.openaiGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: conversationState.isLoading ? null : _sendMessage,
                    icon: Icon(
                      Icons.send,
                      color: conversationState.isLoading
                          ? OpenAITheme.textTertiary
                          : Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Message bubble widget with TTS and translation
class _MessageBubble extends ConsumerStatefulWidget {
  final ConversationMessage message;
  final String roleName;

  const _MessageBubble({
    required this.message,
    required this.roleName,
  });

  @override
  ConsumerState<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends ConsumerState<_MessageBubble> {
  bool _showTranslation = false;
  bool _isPlaying = false;

  Future<void> _playTTS() async {
    if (_isPlaying) return;

    setState(() => _isPlaying = true);

    try {
      final selectedVoice = ref.read(voicePreferenceProvider);
      await ApiCheckHelper.speakWithCheck(
        context,
        widget.message.content,
        voice: selectedVoice,
      );
    } finally {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUser;
    final message = widget.message;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: OpenAITheme.charcoal,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Role name - OpenAI style
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 4, bottom: 6),
                  child: Text(
                    widget.roleName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: OpenAITheme.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Message content - OpenAI style
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? OpenAITheme.charcoal : OpenAITheme.bgSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: isUser ? null : Border.all(color: OpenAITheme.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Italian text
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isUser ? Colors.white : OpenAITheme.textPrimary,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      // Translation (toggle)
                      if (_showTranslation && message.translation != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.white.withValues(alpha: 0.1)
                                : OpenAITheme.bgPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            message.translation!,
                            style: TextStyle(
                              color: isUser ? Colors.white70 : OpenAITheme.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Action buttons (TTS + Translation) - Only for AI messages
                if (!isUser) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TTS button
                      _ActionButton(
                        icon: _isPlaying ? Icons.stop : Icons.volume_up,
                        label: _isPlaying ? '播放中' : '播放',
                        onTap: _playTTS,
                        isActive: _isPlaying,
                      ),
                      const SizedBox(width: 8),
                      // Translation toggle button
                      if (message.translation != null)
                        _ActionButton(
                          icon: Icons.translate,
                          label: _showTranslation ? '隐藏翻译' : '翻译',
                          onTap: () => setState(() => _showTranslation = !_showTranslation),
                          isActive: _showTranslation,
                        ),
                    ],
                  ),
                ],
                // Grammar corrections - OpenAI style
                if (message.corrections != null &&
                    message.corrections!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: OpenAITheme.bgSecondary,
                      border: Border.all(color: OpenAITheme.borderLight),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline,
                                size: 16, color: OpenAITheme.openaiGreen),
                            const SizedBox(width: 6),
                            const Text(
                              '语法提示',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: OpenAITheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
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
                                            color: OpenAITheme.textPrimary,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: correction.originalText,
                                              style: const TextStyle(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                color: OpenAITheme.textTertiary,
                                              ),
                                            ),
                                            const TextSpan(text: ' → '),
                                            TextSpan(
                                              text: correction.correctedText,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: OpenAITheme.openaiGreen,
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
                                    color: OpenAITheme.textSecondary,
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
                // Timestamp - OpenAI style
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 4, top: 6),
                  child: Text(
                    '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: OpenAITheme.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: OpenAITheme.openaiGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small action button for message actions
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? OpenAITheme.openaiGreen.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive
                  ? OpenAITheme.openaiGreen.withValues(alpha: 0.3)
                  : OpenAITheme.borderLight,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive ? OpenAITheme.openaiGreen : OpenAITheme.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? OpenAITheme.openaiGreen : OpenAITheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
