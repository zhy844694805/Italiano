import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/grammar.dart';
import '../../shared/providers/grammar_provider.dart';
import 'grammar_detail_screen.dart';

class GrammarListScreen extends ConsumerStatefulWidget {
  const GrammarListScreen({super.key});

  @override
  ConsumerState<GrammarListScreen> createState() => _GrammarListScreenState();
}

class _GrammarListScreenState extends ConsumerState<GrammarListScreen> {
  String _selectedCategory = '全部';
  String _selectedLevel = '全部';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final grammarAsync = ref.watch(allGrammarProvider);
    final categoriesAsync = ref.watch(grammarCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('语法课程'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: grammarAsync.when(
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
        data: (grammarPoints) {
          // 应用过滤
          var filteredGrammar = grammarPoints.where((point) {
            if (_selectedCategory != '全部' && point.category != _selectedCategory) {
              return false;
            }
            if (_selectedLevel != '全部' && point.level != _selectedLevel) {
              return false;
            }
            return true;
          }).toList();

          return Column(
            children: [
              // 分类标签栏
              categoriesAsync.when(
                data: (categories) => _buildCategoryTabs(['全部', ...categories]),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // 等级过滤器
              _buildLevelFilter(theme, colorScheme),

              // 语法点列表
              Expanded(
                child: filteredGrammar.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_outlined, size: 64, color: colorScheme.primary),
                            const SizedBox(height: 16),
                            const Text('暂无语法课程'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredGrammar.length,
                        itemBuilder: (context, index) {
                          final grammarPoint = filteredGrammar[index];
                          return _buildGrammarCard(grammarPoint, theme, colorScheme);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryTabs(List<String> categories) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelFilter(ThemeData theme, ColorScheme colorScheme) {
    final levels = ['全部', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text('等级:', style: theme.textTheme.titleSmall),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: levels.map((level) {
                  final isSelected = level == _selectedLevel;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(level),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedLevel = level;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrammarCard(GrammarPoint grammarPoint, ThemeData theme, ColorScheme colorScheme) {
    final progress = ref.watch(grammarProgressProvider)[grammarPoint.id];
    final isCompleted = progress?.completed ?? false;
    final isFavorite = progress?.isFavorite ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GrammarDetailScreen(grammarPoint: grammarPoint),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 等级标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getLevelColor(grammarPoint.level).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      grammarPoint.level,
                      style: TextStyle(
                        color: _getLevelColor(grammarPoint.level),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 分类标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      grammarPoint.category,
                      style: TextStyle(
                        color: colorScheme.onSecondaryContainer,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // 完成状态图标
                  if (isCompleted)
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  // 收藏图标
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    onPressed: () {
                      ref.read(grammarProgressProvider.notifier).toggleFavorite(grammarPoint.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 标题
              Text(
                grammarPoint.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // 描述
              Text(
                grammarPoint.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // 底部信息
              Row(
                children: [
                  Icon(Icons.list_alt, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${grammarPoint.rules.length} 条规则',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.lightbulb_outline, size: 16, color: colorScheme.tertiary),
                  const SizedBox(width: 4),
                  Text(
                    '${grammarPoint.examples.length} 个例句',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (grammarPoint.exercises.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.quiz_outlined, size: 16, color: colorScheme.secondary),
                    const SizedBox(width: 4),
                    Text(
                      '${grammarPoint.exercises.length} 道练习',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              // 练习进度
              if (progress != null && progress.exercisesTotal > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress.exercisesCorrect / progress.exercisesTotal,
                          minHeight: 6,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${progress.exercisesCorrect}/${progress.exercisesTotal}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'A1':
        return Colors.green;
      case 'A2':
        return Colors.lightGreen;
      case 'B1':
        return Colors.blue;
      case 'B2':
        return Colors.indigo;
      case 'C1':
        return Colors.purple;
      case 'C2':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选语法课程'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('分类'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['全部', '时态', '冠词', '代词', '名词', '介词'].map((category) {
                return ChoiceChip(
                  label: Text(category),
                  selected: category == _selectedCategory,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('等级'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['全部', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'].map((level) {
                return ChoiceChip(
                  label: Text(level),
                  selected: level == _selectedLevel,
                  onSelected: (selected) {
                    setState(() {
                      _selectedLevel = level;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = '全部';
                _selectedLevel = '全部';
              });
              Navigator.pop(context);
            },
            child: const Text('重置'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
