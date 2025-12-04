import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/daily_conversation.dart';
import '../../core/theme/openai_theme.dart';
import '../../core/utils/api_check_helper.dart';

class DailyConversationDetailScreen extends ConsumerStatefulWidget {
  final DailyConversation conversation;

  const DailyConversationDetailScreen({
    super.key,
    required this.conversation,
  });

  @override
  ConsumerState<DailyConversationDetailScreen> createState() => _DailyConversationDetailScreenState();
}

class _DailyConversationDetailScreenState extends ConsumerState<DailyConversationDetailScreen> {
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeWordTooltip();
    super.dispose();
  }

  void _showWordTooltip(BuildContext context, ConversationWord word, TapUpDetails details) {
    _removeWordTooltip();

    // 获取屏幕尺寸
    final screenSize = MediaQuery.of(context).size;

    // 预估翻译卡片尺寸
    const tooltipWidth = 200.0;
    const tooltipHeight = 120.0;
    const cardMargin = 10.0;

    // 计算最佳位置
    double left = details.globalPosition.dx;
    double top = details.globalPosition.dy - tooltipHeight - 10;

    // 处理右边界
    if (left + tooltipWidth > screenSize.width - cardMargin) {
      left = screenSize.width - tooltipWidth - cardMargin;
    }

    // 处理左边界
    if (left < cardMargin) {
      left = cardMargin;
    }

    // 处理上边界，如果上方空间不够，显示在单词下方
    if (top < cardMargin) {
      top = details.globalPosition.dy + 10;
    }

    // 处理下边界
    if (top + tooltipHeight > screenSize.height - cardMargin) {
      top = screenSize.height - tooltipHeight - cardMargin;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeWordTooltip,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // 全屏透明背景，用于点击关闭
            Positioned.fill(
              child: Container(color: Colors.transparent),
            ),
            // 翻译卡片
            Positioned(
              left: left,
              top: top,
              child: GestureDetector(
                onTap: () {}, // 阻止事件冒泡到父级
                child: _WordTooltip(
                  word: word,
                  onClose: () => _removeWordTooltip(),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeWordTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onWordTap(ConversationWord word, TapUpDetails details) {
    if (word.isPunctuation) return;

    _showWordTooltip(context, word, details);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OpenAITheme.bgPrimary,
      appBar: AppBar(
        title: Text(widget.conversation.title),
        backgroundColor: OpenAITheme.bgPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: OpenAITheme.openaiGreen),
            onPressed: () async {
              // Play first message as example
              if (widget.conversation.messages.isNotEmpty) {
                await ApiCheckHelper.speakWithCheck(
                  context,
                  widget.conversation.messages.first.italian,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题信息卡片 - OpenAI 风格
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: OpenAITheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: OpenAITheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.conversation.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.conversation.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: OpenAITheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.conversation.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: OpenAITheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: OpenAITheme.bgSecondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.conversation.level.toUpperCase(),
                          style: const TextStyle(
                            color: OpenAITheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: OpenAITheme.openaiGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${widget.conversation.messages.length} 对话',
                          style: const TextStyle(
                            color: OpenAITheme.openaiGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 场景描述 - OpenAI 风格
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: OpenAITheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: OpenAITheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: OpenAITheme.openaiGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '场景',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: OpenAITheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.conversation.scenario,
                    style: const TextStyle(
                      fontSize: 14,
                      color: OpenAITheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 文化注释（如果有的话）- OpenAI 风格
            if (widget.conversation.culturalNote != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OpenAITheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: OpenAITheme.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Color(0xFFF59E0B),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '文化小贴士',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: OpenAITheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.conversation.culturalNote!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: OpenAITheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 对话内容标题
            const Text(
              '对话内容',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: OpenAITheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            ...widget.conversation.messages.asMap().entries.map((entry) {
              final message = entry.value;
              final isUser = entry.key.isEven; // 假设偶数索引是用户

              return _MessageBubble(
                message: message,
                isUser: isUser,
                onWordTap: _onWordTap,
              );
            }),

            const SizedBox(height: 20),

            // 词汇表标题
            const Text(
              '重点词汇',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: OpenAITheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // 词汇表 - OpenAI 风格
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: OpenAITheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: OpenAITheme.borderLight),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.conversation.vocabulary.map((vocab) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: OpenAITheme.bgSecondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      vocab,
                      style: const TextStyle(
                        color: OpenAITheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ConversationMessage message;
  final bool isUser;
  final Function(ConversationWord, TapUpDetails) onWordTap;

  const _MessageBubble({
    required this.message,
    required this.isUser,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: OpenAITheme.bgSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                size: 18,
                color: OpenAITheme.textTertiary,
              ),
            ),
            const SizedBox(width: 12),
          ],

          Expanded(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser ? OpenAITheme.charcoal : OpenAITheme.white,
                    borderRadius: BorderRadius.circular(12).copyWith(
                      bottomLeft: isUser ? const Radius.circular(12) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(12),
                    ),
                    border: isUser ? null : Border.all(color: OpenAITheme.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 说话人标签
                      if (!isUser)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            message.speaker,
                            style: const TextStyle(
                              fontSize: 12,
                              color: OpenAITheme.textTertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      // 可点击的单词文本
                      _ClickableWordText(
                        words: message.words,
                        isUser: isUser,
                        onWordTap: onWordTap,
                      ),

                      const SizedBox(height: 8),

                      // 中文翻译
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.white.withValues(alpha: 0.1)
                              : OpenAITheme.bgSecondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message.chinese,
                          style: TextStyle(
                            fontSize: 14,
                            color: isUser ? Colors.white70 : OpenAITheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  message.context,
                  style: const TextStyle(
                    fontSize: 12,
                    color: OpenAITheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: OpenAITheme.openaiGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ClickableWordText extends StatelessWidget {
  final List<ConversationWord> words;
  final bool isUser;
  final Function(ConversationWord, TapUpDetails) onWordTap;

  const _ClickableWordText({
    required this.words,
    required this.isUser,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: words.map((word) {
        if (word.isPunctuation) {
          return Text(
            word.text,
            style: TextStyle(
              fontSize: 16,
              color: isUser ? Colors.white70 : OpenAITheme.textSecondary,
              height: 1.4,
            ),
          );
        }

        return GestureDetector(
          onTapUp: (details) => onWordTap(word, details),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            child: Text(
              word.text,
              style: TextStyle(
                fontSize: 16,
                color: isUser ? Colors.white : OpenAITheme.textPrimary,
                fontWeight: FontWeight.w500,
                height: 1.4,
                decoration: TextDecoration.underline,
                decorationColor: isUser ? Colors.white30 : OpenAITheme.openaiGreen.withValues(alpha: 0.3),
                decorationThickness: 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WordTooltip extends StatelessWidget {
  final ConversationWord word;
  final VoidCallback onClose;

  const _WordTooltip({
    required this.word,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: OpenAITheme.charcoal,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    word.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 16,
                  ),
                ),
              ],
            ),
            if (word.phonetic != null) ...[
              const SizedBox(height: 4),
              Text(
                word.phonetic!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              word.translation,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getWordTypeColor(word.type).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getWordTypeName(word.type),
                style: TextStyle(
                  color: _getWordTypeColor(word.type),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getWordTypeColor(WordType type) {
    switch (type) {
      case WordType.noun:
        return Colors.blue.shade300;
      case WordType.verb:
        return OpenAITheme.openaiGreen;
      case WordType.adjective:
        return Colors.orange.shade300;
      case WordType.adverb:
        return Colors.purple.shade300;
      case WordType.preposition:
        return Colors.red.shade300;
      case WordType.conjunction:
        return Colors.teal.shade300;
      case WordType.pronoun:
        return Colors.indigo.shade300;
      case WordType.article:
        return Colors.grey.shade400;
      case WordType.interjection:
        return Colors.amber.shade300;
      default:
        return Colors.grey.shade400;
    }
  }

  String _getWordTypeName(WordType type) {
    switch (type) {
      case WordType.noun:
        return '名词';
      case WordType.verb:
        return '动词';
      case WordType.adjective:
        return '形容词';
      case WordType.adverb:
        return '副词';
      case WordType.preposition:
        return '介词';
      case WordType.conjunction:
        return '连词';
      case WordType.pronoun:
        return '代词';
      case WordType.article:
        return '冠词';
      case WordType.interjection:
        return '感叹词';
      default:
        return '其他';
    }
  }
}
