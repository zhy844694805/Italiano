import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/word.dart';
import '../../shared/widgets/swipeable_word_card.dart';
import '../../shared/providers/vocabulary_provider.dart';
import '../../shared/providers/tts_provider.dart';
import '../../shared/providers/voice_preference_provider.dart';
import '../../core/theme/openai_theme.dart';
import '../../shared/widgets/openai_widgets.dart';

class VocabularyLearningScreen extends ConsumerStatefulWidget {
  final String? level;
  final String? category;
  final bool newWordsOnly;

  const VocabularyLearningScreen({
    super.key,
    this.level,
    this.category,
    this.newWordsOnly = false,
  });

  @override
  ConsumerState<VocabularyLearningScreen> createState() => _VocabularyLearningScreenState();
}

class _VocabularyLearningScreenState extends ConsumerState<VocabularyLearningScreen> {
  int _currentIndex = 0;
  final List<Word> _remainingWords = [];
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final wordsAsync = widget.newWordsOnly
        ? ref.watch(newWordsProvider)
        : ref.watch(allWordsProvider);

    return Scaffold(
      backgroundColor: OpenAITheme.white,
      appBar: AppBar(
        title: Text(widget.newWordsOnly ? '学习新词' : '学习单词'),
        backgroundColor: OpenAITheme.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: OpenAITheme.gray600),
            onPressed: () {
              setState(() {
                _currentIndex = 0;
                _isInitialized = false;
              });
            },
          ),
        ],
      ),
      body: wordsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: OpenAITheme.gray900),
        ),
        error: (error, stack) => OEmptyState(
          icon: Icons.error_outline,
          title: '加载失败',
          subtitle: error.toString(),
        ),
        data: (words) {
          if (words.isEmpty) {
            return OEmptyState(
              icon: widget.newWordsOnly ? Icons.check_circle_outline : Icons.library_books,
              title: widget.newWordsOnly ? '太棒了！' : '暂无单词',
              subtitle: widget.newWordsOnly ? '所有单词都已学习过了' : '请先添加一些单词数据',
              action: widget.newWordsOnly
                  ? OButton(
                      text: '返回首页',
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
            );
          }

          if (!_isInitialized) {
            _remainingWords.clear();
            _remainingWords.addAll(words);
            _isInitialized = true;
          }

          if (_remainingWords.isEmpty) {
            return _buildCompletionScreen(words.length);
          }

          final currentWord = _remainingWords.first;
          final progress = _currentIndex / words.length;

          return SafeArea(
            child: Column(
              children: [
                // 进度条
                _buildProgressBar(words.length, progress),

                // 统计信息
                _buildStats(),

                const SizedBox(height: 24),

                // 卡片堆叠
                Expanded(
                  child: _buildCardStack(currentWord),
                ),

                // 提示文本
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    '点击卡片翻转 · 左滑不认识 · 右滑认识',
                    style: const TextStyle(
                      fontSize: 13,
                      color: OpenAITheme.gray400,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(int total, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已学习 $_currentIndex / $total',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: OpenAITheme.gray700,
                ),
              ),
              Text(
                '剩余 ${_remainingWords.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: OpenAITheme.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OProgressBar(
            progress: progress,
            height: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final progressNotifier = ref.watch(learningProgressProvider.notifier);

    return FutureBuilder<Map<String, dynamic>>(
      future: progressNotifier.getStatistics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 60);

        final stats = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _StatChip(
                icon: Icons.star_outline,
                value: '${(stats['averageMastery'] * 100).toStringAsFixed(0)}%',
                label: '掌握度',
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.favorite_outline,
                value: '${stats['favoriteWords']}',
                label: '收藏',
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.refresh,
                value: '${stats['wordsToReview']}',
                label: '待复习',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardStack(Word currentWord) {
    final ttsService = ref.watch(ttsServiceProvider);

    return Stack(
      children: [
        // 下一张卡片（堆叠效果）
        if (_remainingWords.length > 1)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 28, right: 28),
              child: Transform.scale(
                scale: 0.95,
                child: Container(
                  decoration: BoxDecoration(
                    color: OpenAITheme.gray100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: OpenAITheme.gray200),
                  ),
                ),
              ),
            ),
          ),

        // 当前卡片
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SwipeableWordCard(
              key: ValueKey(currentWord.id),
              word: currentWord,
              showAudioButton: true,
              onAudioTap: () async {
                final selectedVoice = ref.read(voicePreferenceProvider);
                final success = await ttsService.speak(currentWord.italian, voice: selectedVoice);
                if (!success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('语音播放失败'),
                      backgroundColor: OpenAITheme.gray900,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                }
              },
              onSwipeLeft: () => _handleSwipe(currentWord, false),
              onSwipeRight: () => _handleSwipe(currentWord, true),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSwipe(Word word, bool correct) async {
    await ref.read(learningProgressProvider.notifier).recordWordStudied(word, correct);

    setState(() {
      _currentIndex++;
      _remainingWords.removeAt(0);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(correct ? '认识！继续加油' : '不认识，稍后复习'),
          duration: const Duration(milliseconds: 800),
          behavior: SnackBarBehavior.floating,
          backgroundColor: correct ? OpenAITheme.green : OpenAITheme.gray700,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Widget _buildCompletionScreen(int total) {
    final progressNotifier = ref.watch(learningProgressProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: OpenAITheme.gray100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 48,
              color: OpenAITheme.gray900,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '学习完成',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: OpenAITheme.gray900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '你已经完成了 $total 个单词的学习',
            style: const TextStyle(
              fontSize: 15,
              color: OpenAITheme.gray500,
            ),
          ),
          const SizedBox(height: 32),

          // 统计摘要
          FutureBuilder<Map<String, dynamic>>(
            future: progressNotifier.getStatistics(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator(color: OpenAITheme.gray900);
              }

              final stats = snapshot.data!;
              return OCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      '学习统计',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: OpenAITheme.gray500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _CompletionStatRow('总学习单词', '${stats['totalWords']}'),
                    _CompletionStatRow('平均掌握度', '${(stats['averageMastery'] * 100).toStringAsFixed(1)}%'),
                    _CompletionStatRow('收藏单词', '${stats['favoriteWords']}'),
                    _CompletionStatRow('待复习单词', '${stats['wordsToReview']}'),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: OButtonOutlined(
                  text: '返回',
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.pop(context),
                  fullWidth: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OButton(
                  text: '重新学习',
                  icon: Icons.refresh,
                  onPressed: () {
                    setState(() {
                      _currentIndex = 0;
                      _isInitialized = false;
                    });
                  },
                  fullWidth: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: OpenAITheme.gray50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: OpenAITheme.gray200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: OpenAITheme.gray500),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: OpenAITheme.gray900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: OpenAITheme.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionStatRow extends StatelessWidget {
  final String label;
  final String value;

  const _CompletionStatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: OpenAITheme.gray500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: OpenAITheme.gray900,
            ),
          ),
        ],
      ),
    );
  }
}
