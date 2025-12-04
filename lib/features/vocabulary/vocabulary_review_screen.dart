import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/word.dart';
import '../../shared/widgets/swipeable_word_card.dart';
import '../../shared/widgets/achievement_unlock_dialog.dart';
import '../../shared/providers/vocabulary_provider.dart';
import '../../shared/providers/voice_preference_provider.dart';
import '../../shared/providers/achievement_provider.dart';
import '../../core/theme/openai_theme.dart';
import '../../core/utils/api_check_helper.dart';

class VocabularyReviewScreen extends ConsumerStatefulWidget {
  const VocabularyReviewScreen({super.key});

  @override
  ConsumerState<VocabularyReviewScreen> createState() => _VocabularyReviewScreenState();
}

class _VocabularyReviewScreenState extends ConsumerState<VocabularyReviewScreen> {
  int _currentIndex = 0;
  final List<Word> _remainingWords = [];
  bool _isInitialized = false;
  int _correctCount = 0;
  int _incorrectCount = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final wordsToReviewAsync = ref.watch(wordsToReviewProvider);

    return Scaffold(
      backgroundColor: OpenAITheme.bgPrimary,
      appBar: AppBar(
        title: const Text('复习单词'),
        backgroundColor: OpenAITheme.bgPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '重新开始',
            onPressed: () {
              setState(() {
                _currentIndex = 0;
                _correctCount = 0;
                _incorrectCount = 0;
                _isInitialized = false;
              });
            },
          ),
        ],
      ),
      body: wordsToReviewAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: OpenAITheme.textTertiary),
              const SizedBox(height: 16),
              Text(
                '加载失败',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: OpenAITheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: OpenAITheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (words) {
          if (words.isEmpty) {
            return _buildNoReviewScreen();
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
                _buildProgressBar(theme, words.length, progress),

                // 复习统计
                _buildReviewStats(),

                const SizedBox(height: 20),

                // 卡片堆叠
                Expanded(
                  child: _buildCardStack(currentWord),
                ),

                // 提示文本
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '点击卡片翻转 | 左滑不记得 | 右滑记得',
                    style: theme.textTheme.bodyMedium?.copyWith(
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

  Widget _buildProgressBar(ThemeData theme, int total, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '已复习 $_currentIndex / $total',
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

  Widget _buildReviewStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.check_circle_outline,
            label: '记得',
            value: '$_correctCount',
            color: OpenAITheme.openaiGreen,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.highlight_off,
            label: '不记得',
            value: '$_incorrectCount',
            color: OpenAITheme.textTertiary,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.trending_up,
            label: '正确率',
            value: _currentIndex == 0
                ? '0%'
                : '${((_correctCount / _currentIndex) * 100).toStringAsFixed(0)}%',
            color: OpenAITheme.charcoal,
          ),
        ],
      ),
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
                // 使用KOKORO TTS播放意大利语单词发音（带API检查）
                final selectedVoice = ref.read(voicePreferenceProvider);
                await ApiCheckHelper.speakWithCheck(
                  context,
                  currentWord.italian,
                  voice: selectedVoice,
                );
              },
              onSwipeLeft: () => _handleSwipe(currentWord, false),
              onSwipeRight: () => _handleSwipe(currentWord, true),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSwipe(Word word, bool remembered) async {
    // 记录学习进度
    await ref.read(learningProgressProvider.notifier).recordWordStudied(word, remembered);

    if (!mounted) return;

    setState(() {
      _currentIndex++;
      _remainingWords.removeAt(0);
      if (remembered) {
        _correctCount++;
      } else {
        _incorrectCount++;
      }
    });

    // 显示提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(remembered ? '✓ 记得！下次复习时间已更新' : '✗ 不记得，1小时后再次复习'),
          duration: const Duration(milliseconds: 800),
          behavior: SnackBarBehavior.floating,
          backgroundColor: remembered ? Colors.green : Colors.orange,
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

  Widget _buildNoReviewScreen() {
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
                Icons.check_circle_outline,
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
            const Text(
              '暂时没有需要复习的单词',
              style: TextStyle(
                fontSize: 16,
                color: OpenAITheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '继续学习新单词，或者稍后再来复习吧',
              style: TextStyle(
                fontSize: 14,
                color: OpenAITheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // OpenAI 风格按钮
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
        ),
      ),
    );
  }

  Widget _buildCompletionScreen(int total) {
    final accuracy = _currentIndex == 0 ? 0.0 : (_correctCount / _currentIndex);

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
                Icons.emoji_events,
                size: 64,
                color: OpenAITheme.openaiGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '复习完成！',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: OpenAITheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '你已经完成了 $total 个单词的复习',
              style: const TextStyle(
                fontSize: 16,
                color: OpenAITheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // OpenAI 风格复习统计摘要
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: OpenAITheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: OpenAITheme.borderLight),
              ),
              child: Column(
                children: [
                  const Text(
                    '复习成绩',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: OpenAITheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow('复习单词数', '$total'),
                  _buildStatRow('记得', '$_correctCount'),
                  _buildStatRow('不记得', '$_incorrectCount'),
                  _buildStatRow('正确率', '${(accuracy * 100).toStringAsFixed(1)}%'),
                ],
              ),
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
                          _correctCount = 0;
                          _incorrectCount = 0;
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
                              '再次复习',
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
