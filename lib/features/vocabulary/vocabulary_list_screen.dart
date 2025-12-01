import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/word.dart';
import '../../shared/providers/vocabulary_provider.dart';
import '../../shared/providers/tts_provider.dart';
import '../../shared/providers/voice_preference_provider.dart';
import '../../core/theme/openai_theme.dart';
import '../../shared/widgets/openai_widgets.dart';
import 'vocabulary_learning_screen.dart';

class VocabularyListScreen extends ConsumerStatefulWidget {
  const VocabularyListScreen({super.key});

  @override
  ConsumerState<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends ConsumerState<VocabularyListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedLevel;
  String? _selectedCategory;
  String _sortBy = 'default';
  bool _showOnlyFavorites = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wordsAsync = ref.watch(allWordsProvider);
    final learningProgress = ref.watch(learningProgressProvider);

    return Scaffold(
      backgroundColor: OpenAITheme.white,
      appBar: AppBar(
        title: const Text('词汇'),
        backgroundColor: OpenAITheme.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              _showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
              color: _showOnlyFavorites ? OpenAITheme.red : OpenAITheme.gray500,
            ),
            onPressed: () {
              setState(() {
                _showOnlyFavorites = !_showOnlyFavorites;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: OpenAITheme.gray600),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              _buildPopupItem('default', '默认排序', _sortBy == 'default'),
              _buildPopupItem('mastery', '按掌握度', _sortBy == 'mastery'),
              _buildPopupItem('recent', '最近学习', _sortBy == 'recent'),
            ],
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
        data: (allWords) {
          // 筛选
          var filteredWords = allWords.where((word) {
            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();
              if (!word.italian.toLowerCase().contains(query) &&
                  !word.chinese.toLowerCase().contains(query) &&
                  !(word.english?.toLowerCase().contains(query) ?? false)) {
                return false;
              }
            }
            if (_selectedLevel != null && word.level != _selectedLevel) {
              return false;
            }
            if (_selectedCategory != null && word.category != _selectedCategory) {
              return false;
            }
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
              return masteryB.compareTo(masteryA);
            });
          } else if (_sortBy == 'recent') {
            filteredWords.sort((a, b) {
              final dateA = learningProgress[a.id]?.lastReviewed;
              final dateB = learningProgress[b.id]?.lastReviewed;
              if (dateA == null && dateB == null) return 0;
              if (dateA == null) return 1;
              if (dateB == null) return -1;
              return dateB.compareTo(dateA);
            });
          }

          final levels = allWords.map((w) => w.level).toSet().toList()..sort();
          final categories = allWords.map((w) => w.category).toSet().toList()..sort();

          return Column(
            children: [
              // 搜索栏
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索单词...',
                    hintStyle: const TextStyle(color: OpenAITheme.gray400),
                    prefixIcon: const Icon(Icons.search, color: OpenAITheme.gray400, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: OpenAITheme.gray400, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: OpenAITheme.gray50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: OpenAITheme.gray200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: OpenAITheme.gray200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: OpenAITheme.gray900, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    _FilterChip(
                      label: _selectedLevel ?? '级别',
                      selected: _selectedLevel != null,
                      onTap: () => _showLevelFilter(context, levels),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: _selectedCategory ?? '分类',
                      selected: _selectedCategory != null,
                      onTap: () => _showCategoryFilter(context, categories),
                    ),
                    if (_selectedLevel != null || _selectedCategory != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedLevel = null;
                            _selectedCategory = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: const Text(
                            '清除',
                            style: TextStyle(
                              fontSize: 13,
                              color: OpenAITheme.gray500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 结果统计
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text(
                      '共 ${filteredWords.length} 个单词',
                      style: const TextStyle(
                        fontSize: 13,
                        color: OpenAITheme.gray500,
                      ),
                    ),
                    const Spacer(),
                    if (filteredWords.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VocabularyLearningScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          '全部学习',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: OpenAITheme.gray900,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const Divider(height: 1, color: OpenAITheme.gray200),

              // 单词列表
              Expanded(
                child: filteredWords.isEmpty
                    ? const OEmptyState(
                        icon: Icons.search_off,
                        title: '没有找到单词',
                        subtitle: '尝试调整搜索条件',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredWords.length,
                        itemBuilder: (context, index) {
                          final word = filteredWords[index];
                          final record = learningProgress[word.id];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _WordListItem(
                              word: word,
                              record: record,
                              onTap: () => _showWordDetail(context, word, record),
                            ),
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

  PopupMenuItem<String> _buildPopupItem(String value, String text, bool selected) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (selected)
            const Icon(Icons.check, size: 18, color: OpenAITheme.gray900)
          else
            const SizedBox(width: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  void _showLevelFilter(BuildContext context, List<String> levels) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OpenAITheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _FilterSheet(
        title: '选择级别',
        options: ['全部', ...levels],
        selected: _selectedLevel ?? '全部',
        onSelected: (value) {
          setState(() {
            _selectedLevel = value == '全部' ? null : value;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCategoryFilter(BuildContext context, List<String> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OpenAITheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _FilterSheet(
          title: '选择分类',
          options: ['全部', ...categories],
          selected: _selectedCategory ?? '全部',
          onSelected: (value) {
            setState(() {
              _selectedCategory = value == '全部' ? null : value;
            });
            Navigator.pop(context);
          },
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showWordDetail(BuildContext context, Word word, LearningRecord? record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: OpenAITheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _WordDetailSheet(word: word, record: record),
    );
  }
}

// 筛选按钮
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? OpenAITheme.gray900 : OpenAITheme.gray100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? OpenAITheme.white : OpenAITheme.gray700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: selected ? OpenAITheme.white : OpenAITheme.gray500,
            ),
          ],
        ),
      ),
    );
  }
}

// 筛选面板
class _FilterSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final ScrollController? scrollController;

  const _FilterSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: OpenAITheme.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: OpenAITheme.gray900,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView(
              controller: scrollController,
              shrinkWrap: scrollController == null,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: options.map((option) {
                    final isSelected = option == selected;
                    return GestureDetector(
                      onTap: () => onSelected(option),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? OpenAITheme.gray900 : OpenAITheme.gray100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? OpenAITheme.white : OpenAITheme.gray700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 单词列表项
class _WordListItem extends ConsumerWidget {
  final Word word;
  final LearningRecord? record;
  final VoidCallback onTap;

  const _WordListItem({
    required this.word,
    required this.record,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mastery = record?.mastery ?? 0.0;
    final isFavorite = record?.isFavorite ?? false;

    return OCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          word.italian,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: OpenAITheme.gray900,
                          ),
                        ),
                        if (isFavorite) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.favorite, size: 14, color: OpenAITheme.red),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      word.chinese,
                      style: const TextStyle(
                        fontSize: 15,
                        color: OpenAITheme.gray600,
                      ),
                    ),
                    if (word.pronunciation != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '/${word.pronunciation}/',
                        style: const TextStyle(
                          fontSize: 13,
                          color: OpenAITheme.gray400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 播放按钮
              IconButton(
                icon: const Icon(Icons.volume_up_outlined, size: 20),
                color: OpenAITheme.gray500,
                onPressed: () async {
                  final ttsService = ref.read(ttsServiceProvider);
                  final selectedVoice = ref.read(voicePreferenceProvider);
                  await ttsService.speak(word.italian, voice: selectedVoice);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 标签和进度
          Row(
            children: [
              OBadge(text: word.level, small: true),
              const SizedBox(width: 6),
              OBadge(text: word.category, small: true),
              const Spacer(),
              Text(
                '${(mastery * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getMasteryColor(mastery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OProgressBar(
            progress: mastery,
            height: 3,
            color: _getMasteryColor(mastery),
          ),
        ],
      ),
    );
  }

  Color _getMasteryColor(double mastery) {
    if (mastery >= 0.8) return OpenAITheme.green;
    if (mastery >= 0.5) return OpenAITheme.gray600;
    return OpenAITheme.gray400;
  }
}

// 单词详情面板
class _WordDetailSheet extends ConsumerWidget {
  final Word word;
  final LearningRecord? record;

  const _WordDetailSheet({
    required this.word,
    required this.record,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsService = ref.watch(ttsServiceProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              // 拖动指示器
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: OpenAITheme.gray300,
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
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: OpenAITheme.gray900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (word.pronunciation != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '/${word.pronunciation}/',
                            style: const TextStyle(
                              fontSize: 16,
                              color: OpenAITheme.gray500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: OpenAITheme.gray100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.volume_up),
                      iconSize: 28,
                      color: OpenAITheme.gray700,
                      onPressed: () async {
                        final selectedVoice = ref.read(voicePreferenceProvider);
                        await ttsService.speak(word.italian, voice: selectedVoice);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(color: OpenAITheme.gray200),
              const SizedBox(height: 24),

              // 释义
              const Text(
                '释义',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: OpenAITheme.gray500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                word.chinese,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: OpenAITheme.gray900,
                ),
              ),
              if (word.english != null) ...[
                const SizedBox(height: 4),
                Text(
                  word.english!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: OpenAITheme.gray500,
                  ),
                ),
              ],

              // 例句
              if (word.examples.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  '例句',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: OpenAITheme.gray500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                ...word.examples.map((example) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '• $example',
                    style: const TextStyle(
                      fontSize: 15,
                      color: OpenAITheme.gray700,
                      height: 1.5,
                    ),
                  ),
                )),
              ],

              // 学习统计
              if (record != null) ...[
                const SizedBox(height: 24),
                const Text(
                  '学习统计',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: OpenAITheme.gray500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final rec = record!;
                    return OCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _StatRow('复习次数', '${rec.reviewCount}'),
                          _StatRow('正确次数', '${rec.correctCount}'),
                          _StatRow('正确率', '${((rec.reviewCount > 0 ? rec.correctCount / rec.reviewCount : 0) * 100).toInt()}%'),
                          _StatRow('掌握度', '${(rec.mastery * 100).toInt()}%'),
                          if (rec.nextReviewDate != null)
                            _StatRow('下次复习', _formatDate(rec.nextReviewDate!)),
                        ],
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 32),

              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: OButtonOutlined(
                      text: record?.isFavorite ?? false ? '取消收藏' : '收藏',
                      icon: record?.isFavorite ?? false ? Icons.favorite : Icons.favorite_border,
                      onPressed: () {
                        ref.read(learningProgressProvider.notifier).toggleFavorite(word.id);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OButton(
                      text: '开始学习',
                      icon: Icons.school,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);
    if (diff.isNegative) return '需要复习';
    if (diff.inDays == 0) return '今天';
    if (diff.inDays == 1) return '明天';
    if (diff.inDays < 7) return '${diff.inDays} 天后';
    return '${date.month}/${date.day}';
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
