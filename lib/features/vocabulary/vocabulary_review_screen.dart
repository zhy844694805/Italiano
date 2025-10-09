import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/word.dart';
import '../../shared/widgets/swipeable_word_card.dart';
import '../../shared/providers/vocabulary_provider.dart';
import '../../shared/providers/tts_provider.dart';

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
    final colorScheme = theme.colorScheme;

    final wordsToReviewAsync = ref.watch(wordsToReviewProvider);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: const Text('复习单词'),
        backgroundColor: colorScheme.surfaceContainerHighest,
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
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                '加载失败',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodyMedium,
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
                _buildProgressBar(theme, colorScheme, words.length, progress),

                // 复习统计
                _buildReviewStats(theme, colorScheme),

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
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
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

  Widget _buildProgressBar(ThemeData theme, ColorScheme colorScheme, int total, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已复习 $_currentIndex / $total',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '剩余 ${_remainingWords.length}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStats(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.check_circle,
            label: '记得',
            value: '$_correctCount',
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.cancel,
            label: '不记得',
            value: '$_incorrectCount',
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.percent,
            label: '正确率',
            value: _currentIndex == 0
                ? '0%'
                : '${((_correctCount / _currentIndex) * 100).toStringAsFixed(0)}%',
            color: colorScheme.primary,
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
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
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
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
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
        // 下一张卡片的占位符（显示堆叠效果）
        if (_remainingWords.length > 1)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 24, right: 24),
              child: Transform.scale(
                scale: 0.95,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(24),
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
                final success = await ttsService.speak(currentWord.italian);
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

  void _handleSwipe(Word word, bool remembered) async {
    // 记录学习进度
    await ref.read(learningProgressProvider.notifier).recordWordStudied(word, remembered);

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
  }

  Widget _buildNoReviewScreen() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 80,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '🎉 太棒了！',
              style: theme.textTheme.displayMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '暂时没有需要复习的单词',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '继续学习新单词，或者稍后再来复习吧',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('返回首页'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionScreen(int total) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accuracy = _currentIndex == 0 ? 0.0 : (_correctCount / _currentIndex);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events,
                size: 80,
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '🎊 复习完成！',
              style: theme.textTheme.displayMedium?.copyWith(
                color: colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '你已经完成了 $total 个单词的复习',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // 复习统计摘要
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text('复习成绩', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 16),
                    _buildStatRow('复习单词数', '$total'),
                    _buildStatRow('记得', '$_correctCount'),
                    _buildStatRow('不记得', '$_incorrectCount'),
                    _buildStatRow('正确率', '${(accuracy * 100).toStringAsFixed(1)}%'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('返回'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 0;
                        _correctCount = 0;
                        _incorrectCount = 0;
                        _isInitialized = false;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('再次复习'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
