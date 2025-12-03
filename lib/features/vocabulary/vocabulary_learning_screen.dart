import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/word.dart';
import '../../shared/widgets/swipeable_word_card.dart';
import '../../shared/widgets/achievement_unlock_dialog.dart';
import '../../shared/providers/vocabulary_provider.dart';
import '../../shared/providers/tts_provider.dart';
import '../../shared/providers/voice_preference_provider.dart';
import '../../shared/providers/achievement_provider.dart';
import '../../core/theme/openai_theme.dart';

class VocabularyLearningScreen extends ConsumerStatefulWidget {
  final String? level;
  final String? category;
  final bool newWordsOnly; // 只学习新词

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
    // 根据模式选择不同的Provider
    final wordsAsync = widget.newWordsOnly
        ? ref.watch(newWordsProvider)
        : ref.watch(allWordsProvider);

    return Scaffold(
      backgroundColor: OpenAITheme.bgPrimary,
      appBar: AppBar(
        title: Text(widget.newWordsOnly ? '学习新词' : '学习单词'),
        backgroundColor: OpenAITheme.bgPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '重新开始',
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
          child: CircularProgressIndicator(color: OpenAITheme.openaiGreen),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: OpenAITheme.textTertiary),
              const SizedBox(height: 16),
              const Text(
                '加载失败',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: OpenAITheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(
                  color: OpenAITheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (words) {
          if (words.isEmpty) {
            return _buildEmptyScreen();
          }

          // 初始化剩余单词列表
          if (!_isInitialized) {
            _remainingWords.clear();
            _remainingWords.addAll(words);
            _isInitialized = true;
          }

          if (_remainingWords.isEmpty) {
            return _buildCompletionScreen(words.length);
          }

          final currentWord = _remainingWords.first;
          final progress = (_currentIndex) / words.length;

          return SafeArea(
            child: Column(
              children: [
                // 进度条
                _buildProgressBar(words.length, progress),

                // 统计信息
                _buildStats(),

                const SizedBox(height: 20),

                // 卡片堆叠
                Expanded(
                  child: _buildCardStack(currentWord),
                ),

                // 提示文本
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '点击卡片翻转 | 左滑不认识 | 右滑认识',
                    style: const TextStyle(
                      color: OpenAITheme.textTertiary,
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

  Widget _buildEmptyScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: OpenAITheme.openaiGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.newWordsOnly ? Icons.check_circle_outline : Icons.library_books,
                size: 64,
                color: OpenAITheme.openaiGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.newWordsOnly ? '太棒了！' : '暂无单词',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: OpenAITheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.newWordsOnly
                  ? '所有单词都已学习过了'
                  : '请先添加一些单词数据',
              style: const TextStyle(
                fontSize: 16,
                color: OpenAITheme.textSecondary,
              ),
            ),
            if (widget.newWordsOnly) ...[
              const SizedBox(height: 32),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: OpenAITheme.charcoal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          '返回首页',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int total, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '已学习 $_currentIndex / $total',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: OpenAITheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '剩余 ${_remainingWords.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: OpenAITheme.openaiGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // OpenAI 风格进度条
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: OpenAITheme.gray100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: OpenAITheme.openaiGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
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
        if (!snapshot.hasData) return const SizedBox();

        final stats = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildStatCard(
                icon: Icons.star,
                label: '掌握度',
                value: '${(stats['averageMastery'] * 100).toStringAsFixed(0)}%',
                color: OpenAITheme.openaiGreen,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.favorite,
                label: '收藏',
                value: '${stats['favoriteWords']}',
                color: const Color(0xFFEF4444),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.repeat,
                label: '待复习',
                value: '${stats['wordsToReview']}',
                color: OpenAITheme.charcoal,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: OpenAITheme.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: OpenAITheme.borderLight),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: OpenAITheme.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardStack(Word currentWord) {
    final ttsService = ref.watch(ttsServiceProvider);

    return Stack(
      children: [
        // 下一张卡片的占位符（显示堆叠效果）- OpenAI 风格
        if (_remainingWords.length > 1)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 24, right: 24),
              child: Transform.scale(
                scale: 0.95,
                child: Container(
                  decoration: BoxDecoration(
                    color: OpenAITheme.bgSecondary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: OpenAITheme.borderLight),
                  ),
                ),
              ),
            ),
          ),

        // 当前卡片
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SwipeableWordCard(
              key: ValueKey(currentWord.id),
              word: currentWord,
              showAudioButton: true,
              onAudioTap: () async {
                // 使用KOKORO TTS播放意大利语单词发音
                final selectedVoice = ref.read(voicePreferenceProvider);
                final success = await ttsService.speak(currentWord.italian, voice: selectedVoice);
                if (!success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('语音播放失败'),
                      duration: Duration(seconds: 1),
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
    // 记录学习进度
    await ref.read(learningProgressProvider.notifier).recordWordStudied(word, correct);

    setState(() {
      _currentIndex++;
      _remainingWords.removeAt(0);
    });

    // 显示提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(correct ? '✓ 认识！继续加油' : '✗ 不认识，稍后会再次复习'),
          duration: const Duration(milliseconds: 800),
          behavior: SnackBarBehavior.floating,
          backgroundColor: correct ? OpenAITheme.openaiGreen : const Color(0xFFF59E0B),
        ),
      );
    }

    // 检查成就解锁
    if (mounted) {
      final achievement = await checkAchievements(ref);
      if (achievement != null && mounted) {
        await AchievementUnlockDialog.show(context, achievement);
      }
    }
  }

  Widget _buildCompletionScreen(int total) {
    final progressNotifier = ref.watch(learningProgressProvider.notifier);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // OpenAI 风格图标
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: OpenAITheme.openaiGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                size: 64,
                color: OpenAITheme.openaiGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '太棒了！',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: OpenAITheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '你已经完成了 $total 个单词的学习',
              style: const TextStyle(
                fontSize: 16,
                color: OpenAITheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // OpenAI 风格统计摘要
            FutureBuilder<Map<String, dynamic>>(
              future: progressNotifier.getStatistics(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator(color: OpenAITheme.openaiGreen);
                }

                final stats = snapshot.data!;
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: OpenAITheme.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: OpenAITheme.borderLight),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '学习统计',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: OpenAITheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow('总学习单词', '${stats['totalWords']}'),
                      _buildStatRow('平均掌握度', '${(stats['averageMastery'] * 100).toStringAsFixed(1)}%'),
                      _buildStatRow('收藏单词', '${stats['favoriteWords']}'),
                      _buildStatRow('待复习单词', '${stats['wordsToReview']}'),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // OpenAI 风格按钮
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: OpenAITheme.borderLight),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back, color: OpenAITheme.textSecondary, size: 18),
                            SizedBox(width: 8),
                            Text(
                              '返回',
                              style: TextStyle(
                                color: OpenAITheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentIndex = 0;
                          _isInitialized = false;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: OpenAITheme.openaiGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              '重新学习',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: OpenAITheme.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: OpenAITheme.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
