import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/word.dart';
import '../../shared/providers/vocabulary_provider.dart';
import '../../shared/providers/tts_provider.dart';
import '../../shared/providers/voice_preference_provider.dart';
import '../../core/theme/openai_theme.dart';
import '../../shared/widgets/gradient_card.dart';
import 'vocabulary_learning_screen.dart';

class VocabularyListScreen extends ConsumerStatefulWidget {
  const VocabularyListScreen({super.key});

  @override
  ConsumerState<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends ConsumerState<VocabularyListScreen> {
  String _searchQuery = '';
  String? _selectedLevel;
  String? _selectedCategory;
  String _sortBy = 'default'; // default, mastery, recent
  bool _showOnlyFavorites = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final wordsAsync = ref.watch(allWordsProvider);
    final learningProgress = ref.watch(learningProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('词汇列表'),
        actions: [
          IconButton(
            icon: Icon(_showOnlyFavorites ? Icons.favorite : Icons.favorite_border),
            tooltip: '只看收藏',
            onPressed: () {
              setState(() {
                _showOnlyFavorites = !_showOnlyFavorites;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: '排序',
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'default', child: Text('默认排序')),
              const PopupMenuItem(value: 'mastery', child: Text('按掌握度')),
              const PopupMenuItem(value: 'recent', child: Text('最近学习')),
            ],
          ),
        ],
      ),
      body: wordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('加载失败: $error'),
            ],
          ),
        ),
        data: (allWords) {
          // 筛选单词
          var filteredWords = allWords.where((word) {
            // 搜索过滤
            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();
              if (!word.italian.toLowerCase().contains(query) &&
                  !word.chinese.toLowerCase().contains(query) &&
                  !(word.english?.toLowerCase().contains(query) ?? false)) {
                return false;
              }
            }

            // 级别过滤
            if (_selectedLevel != null && word.level != _selectedLevel) {
              return false;
            }

            // 分类过滤
            if (_selectedCategory != null && word.category != _selectedCategory) {
              return false;
            }

            // 收藏过滤
            if (_showOnlyFavorites) {
              final record = learningProgress[word.id];
              if (record == null || !record.isFavorite) {
                return false;
              }
            }

            return true;
          }).toList();

          // 排序
          if (_sortBy == 'mastery') {
            filteredWords.sort((a, b) {
              final masteryA = learningProgress[a.id]?.mastery ?? 0.0;
              final masteryB = learningProgress[b.id]?.mastery ?? 0.0;
              return masteryB.compareTo(masteryA); // 降序
            });
          } else if (_sortBy == 'recent') {
            filteredWords.sort((a, b) {
              final dateA = learningProgress[a.id]?.lastReviewed;
              final dateB = learningProgress[b.id]?.lastReviewed;
              if (dateA == null && dateB == null) return 0;
              if (dateA == null) return 1;
              if (dateB == null) return -1;
              return dateB.compareTo(dateA); // 降序
            });
          }

          // 获取所有级别和分类
          final levels = allWords.map((w) => w.level).toSet().toList()..sort();
          final categories = allWords.map((w) => w.category).toSet().toList()..sort();

          return Column(
            children: [
              // 搜索栏
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索单词...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // 筛选器
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // 级别筛选
                    _buildFilterChip(
                      label: _selectedLevel ?? '所有级别',
                      selected: _selectedLevel != null,
                      onTap: () => _showLevelFilter(context, levels),
                    ),
                    const SizedBox(width: 8),
                    // 分类筛选
                    _buildFilterChip(
                      label: _selectedCategory ?? '所有分类',
                      selected: _selectedCategory != null,
                      onTap: () => _showCategoryFilter(context, categories),
                    ),
                    const SizedBox(width: 8),
                    // 清除筛选
                    if (_selectedLevel != null || _selectedCategory != null)
                      TextButton.icon(
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('清除筛选'),
                        onPressed: () {
                          setState(() {
                            _selectedLevel = null;
                            _selectedCategory = null;
                          });
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // 结果统计
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '共 ${filteredWords.length} 个单词',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const Spacer(),
                    if (filteredWords.isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.school, size: 18),
                        label: const Text('全部学习'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VocabularyLearningScreen(),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 单词列表
              Expanded(
                child: filteredWords.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '没有找到单词',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredWords.length,
                        addAutomaticKeepAlives: false, // 优化：减少内存占用
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final word = filteredWords[index];
                          return _WordListItemOptimized(
                            key: ValueKey(word.id), // 优化：添加 Key 避免不必要重建
                            word: word,
                            onTap: () => _showWordDetail(context, word, learningProgress[word.id]),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: selected
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }

  void _showLevelFilter(BuildContext context, List<String> levels) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择级别',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('全部'),
                  selected: _selectedLevel == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedLevel = null;
                    });
                    Navigator.pop(context);
                  },
                ),
                ...levels.map((level) => ChoiceChip(
                      label: Text(level),
                      selected: _selectedLevel == level,
                      onSelected: (selected) {
                        setState(() {
                          _selectedLevel = selected ? level : null;
                        });
                        Navigator.pop(context);
                      },
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter(BuildContext context, List<String> categories) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择分类',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('全部'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = null;
                    });
                    Navigator.pop(context);
                  },
                ),
                ...categories.map((category) => ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                        Navigator.pop(context);
                      },
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWordDetail(BuildContext context, Word word, LearningRecord? record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _WordDetailSheet(word: word, record: record),
    );
  }
}

// 优化版本：使用 select 只监听特定单词的学习记录
class _WordListItemOptimized extends ConsumerWidget {
  final Word word;
  final VoidCallback onTap;

  const _WordListItemOptimized({
    super.key,
    required this.word,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 优化：使用 select 只监听当前单词的记录，避免其他单词更新时重建
    final record = ref.watch(
      learningProgressProvider.select((progress) => progress[word.id])
    );
    final mastery = record?.mastery ?? 0.0;
    final isFavorite = record?.isFavorite ?? false;

    return FloatingCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              Row(
                children: [
                  // 单词信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              word.italian,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isFavorite)
                              Icon(
                                Icons.favorite,
                                size: 16,
                                color: Colors.red,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          word.chinese,
                          style: theme.textTheme.bodyLarge,
                        ),
                        if (word.pronunciation != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '/${word.pronunciation}/',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 音频按钮
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () async {
                      final ttsService = ref.read(ttsServiceProvider);
                      final selectedVoice = ref.read(voicePreferenceProvider);
                      await ttsService.speak(word.italian, voice: selectedVoice);
                    },
                  ),

                  // 收藏按钮
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      ref.read(learningProgressProvider.notifier).toggleFavorite(word.id);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 标签
              Row(
                children: [
                  _buildTag(word.level, LinearGradient(colors: [OpenAITheme.openaiGreen, OpenAITheme.openaiGreenDark])),
                  const SizedBox(width: 8),
                  _buildTag(word.category, LinearGradient(colors: [OpenAITheme.info, Color(0xFF2563EB)])),
                ],
              ),

              const SizedBox(height: 12),

              // 掌握度进度条（渐变）
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '掌握度',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: OpenAITheme.textSecondary,
                        ),
                      ),
                      Text(
                        '${(mastery * 100).toInt()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _getMasteryColor(mastery),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GradientProgressBar(
                    progress: mastery,
                    height: 8,
                    gradient: _getMasteryGradient(mastery),
                  ),
                ],
              ),

              if (record != null) ...[
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final rec = record!;
                    return Text(
                      '已学习 ${rec.reviewCount} 次 · 正确 ${rec.correctCount} 次',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    );
                  },
                ),
              ],
        ],
      ),
    );
  }

  Widget _buildTag(String text, Gradient gradient) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getMasteryColor(double mastery) {
    if (mastery >= 0.8) return Colors.green;
    if (mastery >= 0.5) return OpenAITheme.warning;
    return OpenAITheme.textSecondary;
  }

  Gradient _getMasteryGradient(double mastery) {
    if (mastery >= 0.8) {
      return const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
      );
    }
    if (mastery >= 0.5) {
      return LinearGradient(colors: [OpenAITheme.warning, Color(0xFFD97706)]);
    }
    return const LinearGradient(
      colors: [Color(0xFFBDBDBD), Color(0xFF9E9E9E)],
    );
  }
}

class _WordDetailSheet extends ConsumerWidget {
  final Word word;
  final LearningRecord? record;

  const _WordDetailSheet({
    required this.word,
    required this.record,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ttsService = ref.watch(ttsServiceProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              // 拖动指示器
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 单词标题
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.italian,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (word.pronunciation != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '/${word.pronunciation}/',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton.filled(
                    icon: const Icon(Icons.volume_up),
                    iconSize: 32,
                    onPressed: () async {
                      final selectedVoice = ref.read(voicePreferenceProvider);
                      await ttsService.speak(word.italian, voice: selectedVoice);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 释义
              _buildSection(
                title: '释义',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🇨🇳 ${word.chinese}',
                      style: theme.textTheme.titleLarge,
                    ),
                    if (word.english != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '🇬🇧 ${word.english}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 例句
              if (word.examples.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildSection(
                  title: '例句',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: word.examples.map((example) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          '• $example',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              // 学习统计
              if (record != null) ...[
                const SizedBox(height: 24),
                Builder(
                  builder: (context) {
                    final rec = record!;
                    return _buildSection(
                      title: '学习统计',
                      child: Column(
                        children: [
                          _buildStatRow('总复习次数', '${rec.reviewCount}'),
                          _buildStatRow('正确次数', '${rec.correctCount}'),
                          _buildStatRow('正确率', '${((rec.reviewCount > 0 ? rec.correctCount / rec.reviewCount : 0) * 100).toInt()}%'),
                          _buildStatRow('掌握度', '${(rec.mastery * 100).toInt()}%'),
                          if (rec.nextReviewDate != null)
                            _buildStatRow(
                              '下次复习',
                              _formatDate(rec.nextReviewDate!),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 24),

              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(
                        record?.isFavorite ?? false ? Icons.favorite : Icons.favorite_border,
                      ),
                      label: Text(record?.isFavorite ?? false ? '取消收藏' : '收藏'),
                      onPressed: () {
                        ref.read(learningProgressProvider.notifier).toggleFavorite(word.id);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.school),
                      label: const Text('开始学习'),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VocabularyLearningScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
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
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.isNegative) {
      return '需要复习';
    } else if (diff.inDays == 0) {
      return '今天';
    } else if (diff.inDays == 1) {
      return '明天';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} 天后';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
