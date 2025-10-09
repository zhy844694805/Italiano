import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/word.dart';
import '../../shared/widgets/swipeable_word_card.dart';
import '../../shared/providers/vocabulary_provider.dart';
import '../../shared/providers/tts_provider.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 根据模式选择不同的Provider
    final wordsAsync = widget.newWordsOnly
        ? ref.watch(newWordsProvider)
        : ref.watch(allWordsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: Text(widget.newWordsOnly ? '学习新词' : '学习单词'),
        backgroundColor: colorScheme.surfaceContainerHighest,
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.newWordsOnly ? Icons.check_circle_outline : Icons.library_books,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.newWordsOnly ? '🎉 太棒了！' : '暂无单词',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.newWordsOnly
                        ? '所有单词都已学习过了'
                        : '请先添加一些单词数据',
                  ),
                  if (widget.newWordsOnly) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('返回首页'),
                    ),
                  ],
                ],
              ),
            );
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

                // 统计信息
                _buildStats(theme, colorScheme, words.length),

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
                '已学习 $_currentIndex / $total',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '剩余 ${_remainingWords.length}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
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
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(ThemeData theme, ColorScheme colorScheme, int total) {
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
                color: colorScheme.tertiary,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.favorite,
                label: '收藏',
                value: '${stats['favoriteWords']}',
                color: Colors.red,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.repeat,
                label: '待复习',
                value: '${stats['wordsToReview']}',
                color: colorScheme.secondary,
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
          backgroundColor: correct ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  Widget _buildCompletionScreen(int total) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progressNotifier = ref.watch(learningProgressProvider.notifier);

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
                Icons.celebration,
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
              '你已经完成了 $total 个单词的学习',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // 统计摘要
            FutureBuilder<Map<String, dynamic>>(
              future: progressNotifier.getStatistics(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final stats = snapshot.data!;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text('学习统计', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 16),
                        _buildStatRow('总学习单词', '${stats['totalWords']}'),
                        _buildStatRow('平均掌握度', '${(stats['averageMastery'] * 100).toStringAsFixed(1)}%'),
                        _buildStatRow('收藏单词', '${stats['favoriteWords']}'),
                        _buildStatRow('待复习单词', '${stats['wordsToReview']}'),
                      ],
                    ),
                  ),
                );
              },
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
                        _isInitialized = false;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('重新学习'),
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
