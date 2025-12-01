import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/grammar.dart';
import '../../shared/providers/grammar_provider.dart';
import '../../core/theme/openai_theme.dart';
import '../../shared/widgets/openai_widgets.dart';
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
    final grammarAsync = ref.watch(allGrammarProvider);
    final categoriesAsync = ref.watch(grammarCategoriesProvider);

    return Scaffold(
      backgroundColor: OpenAITheme.white,
      appBar: AppBar(
        title: const Text('语法'),
        backgroundColor: OpenAITheme.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: OpenAITheme.gray600),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: grammarAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: OpenAITheme.gray900),
        ),
        error: (error, stack) => OEmptyState(
          icon: Icons.error_outline,
          title: '加载失败',
          subtitle: error.toString(),
        ),
        data: (grammarPoints) {
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

              // 等级筛选
              _buildLevelFilter(),

              // 结果统计
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Text(
                      '共 ${filteredGrammar.length} 个语法点',
                      style: const TextStyle(
                        fontSize: 13,
                        color: OpenAITheme.gray500,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: OpenAITheme.gray200),

              // 语法列表
              Expanded(
                child: filteredGrammar.isEmpty
                    ? const OEmptyState(
                        icon: Icons.school_outlined,
                        title: '暂无语法课程',
                        subtitle: '调整筛选条件试试',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredGrammar.length,
                        itemBuilder: (context, index) {
                          final grammarPoint = filteredGrammar[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _GrammarCard(grammarPoint: grammarPoint),
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
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? OpenAITheme.gray900 : OpenAITheme.gray100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? OpenAITheme.white : OpenAITheme.gray700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelFilter() {
    final levels = ['全部', 'A1', 'A2', 'B1', 'B2'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            '等级',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: OpenAITheme.gray500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: levels.map((level) {
                  final isSelected = level == _selectedLevel;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedLevel = level;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? OpenAITheme.gray900 : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected ? OpenAITheme.gray900 : OpenAITheme.gray300,
                          ),
                        ),
                        child: Text(
                          level,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? OpenAITheme.white : OpenAITheme.gray600,
                          ),
                        ),
                      ),
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

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OpenAITheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '筛选',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: OpenAITheme.gray900,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = '全部';
                      _selectedLevel = '全部';
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '重置',
                    style: TextStyle(
                      fontSize: 14,
                      color: OpenAITheme.gray500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '分类',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: OpenAITheme.gray500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['全部', '时态', '冠词', '代词', '名词', '介词', '动词', '形容词'].map((category) {
                final isSelected = category == _selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? OpenAITheme.gray900 : OpenAITheme.gray100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category,
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
            const SizedBox(height: 24),
            const Text(
              '等级',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: OpenAITheme.gray500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['全部', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'].map((level) {
                final isSelected = level == _selectedLevel;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLevel = level;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? OpenAITheme.gray900 : OpenAITheme.gray100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      level,
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _GrammarCard extends ConsumerWidget {
  final GrammarPoint grammarPoint;

  const _GrammarCard({required this.grammarPoint});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(grammarProgressProvider)[grammarPoint.id];
    final isCompleted = progress?.completed ?? false;
    final isFavorite = progress?.isFavorite ?? false;

    return OCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GrammarDetailScreen(grammarPoint: grammarPoint),
          ),
        );
      },
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              OBadge(text: grammarPoint.level, small: true),
              const SizedBox(width: 6),
              OBadge(text: grammarPoint.category, small: true),
              const Spacer(),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: OpenAITheme.greenLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: OpenAITheme.green, size: 14),
                ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  ref.read(grammarProgressProvider.notifier).toggleFavorite(grammarPoint.id);
                },
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? OpenAITheme.red : OpenAITheme.gray400,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            grammarPoint.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: OpenAITheme.gray900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            grammarPoint.description,
            style: const TextStyle(
              fontSize: 14,
              color: OpenAITheme.gray500,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(Icons.list_alt, '${grammarPoint.rules.length} 规则'),
              const SizedBox(width: 12),
              _InfoChip(Icons.lightbulb_outline, '${grammarPoint.examples.length} 例句'),
              if (grammarPoint.exercises.isNotEmpty) ...[
                const SizedBox(width: 12),
                _InfoChip(Icons.quiz_outlined, '${grammarPoint.exercises.length} 练习'),
              ],
            ],
          ),
          if (progress != null && progress.exercisesTotal > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OProgressBar(
                    progress: progress.exercisesCorrect / progress.exercisesTotal,
                    height: 4,
                    color: OpenAITheme.green,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${progress.exercisesCorrect}/${progress.exercisesTotal}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: OpenAITheme.gray500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: OpenAITheme.gray400),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: OpenAITheme.gray500,
          ),
        ),
      ],
    );
  }
}
