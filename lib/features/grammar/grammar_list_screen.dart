import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/grammar.dart';
import '../../shared/providers/grammar_provider.dart';
import '../../core/theme/openai_theme.dart';
import 'grammar_detail_screen.dart';

class GrammarListScreen extends ConsumerStatefulWidget {
  const GrammarListScreen({super.key});

  @override
  ConsumerState<GrammarListScreen> createState() => _GrammarListScreenState();
}

class _GrammarListScreenState extends ConsumerState<GrammarListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grammarAsync = ref.watch(allGrammarProvider);

    return Scaffold(
      backgroundColor: OpenAITheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: OpenAITheme.bgPrimary,
        title: const Text('语法学习'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: OpenAITheme.openaiGreen,
          indicatorWeight: 2,
          labelColor: OpenAITheme.openaiGreen,
          unselectedLabelColor: OpenAITheme.textTertiary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: const [
            Tab(text: '入门 A1'),
            Tab(text: '基础 A2'),
            Tab(text: '全部'),
          ],
        ),
      ),
      body: grammarAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: OpenAITheme.openaiGreen),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: OpenAITheme.textTertiary),
              const SizedBox(height: 16),
              const Text(
                '加载失败',
                style: TextStyle(
                  fontSize: 16,
                  color: OpenAITheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => ref.invalidate(allGrammarProvider),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: OpenAITheme.borderLight),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '重试',
                      style: TextStyle(
                        color: OpenAITheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        data: (grammarPoints) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildGrammarList(grammarPoints.where((p) => p.level == 'A1').toList()),
              _buildGrammarList(grammarPoints.where((p) => p.level == 'A2').toList()),
              _buildGrammarList(grammarPoints),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGrammarList(List<GrammarPoint> grammarPoints) {
    if (grammarPoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.school_outlined, size: 48, color: OpenAITheme.textTertiary),
            SizedBox(height: 12),
            Text(
              '暂无语法课程',
              style: TextStyle(
                fontSize: 16,
                color: OpenAITheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grammarPoints.length,
      itemBuilder: (context, index) {
        final grammarPoint = grammarPoints[index];
        return _GrammarCard(
          grammarPoint: grammarPoint,
          index: index + 1,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GrammarDetailScreen(grammarPoint: grammarPoint),
              ),
            );
          },
        );
      },
    );
  }
}

class _GrammarCard extends ConsumerWidget {
  final GrammarPoint grammarPoint;
  final int index;
  final VoidCallback onTap;

  const _GrammarCard({
    required this.grammarPoint,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(grammarProgressProvider)[grammarPoint.id];
    final isCompleted = progress?.completed ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: OpenAITheme.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: OpenAITheme.borderLight),
            ),
            child: Row(
              children: [
                // 序号圆圈
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? OpenAITheme.openaiGreen.withValues(alpha: 0.1)
                        : OpenAITheme.bgSecondary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: OpenAITheme.openaiGreen,
                            size: 20,
                          )
                        : Text(
                            '$index',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: OpenAITheme.textSecondary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),

                // 内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      Text(
                        grammarPoint.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: OpenAITheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 描述
                      Text(
                        grammarPoint.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: OpenAITheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // 底部信息
                      Row(
                        children: [
                          // 等级标签
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getLevelColor(grammarPoint.level).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              grammarPoint.level,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getLevelColor(grammarPoint.level),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 规则数
                          const Icon(Icons.list, size: 14, color: OpenAITheme.textTertiary),
                          const SizedBox(width: 2),
                          Text(
                            '${grammarPoint.rules.length}规则',
                            style: const TextStyle(
                              fontSize: 12,
                              color: OpenAITheme.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 练习数
                          const Icon(Icons.edit_outlined, size: 14, color: OpenAITheme.textTertiary),
                          const SizedBox(width: 2),
                          Text(
                            '${grammarPoint.exercises.length}练习',
                            style: const TextStyle(
                              fontSize: 12,
                              color: OpenAITheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      // 练习进度条
                      if (progress != null && progress.exercisesTotal > 0) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: OpenAITheme.gray100,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: progress.exercisesCorrect / progress.exercisesTotal,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: OpenAITheme.openaiGreen,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${progress.exercisesCorrect}/${progress.exercisesTotal}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: OpenAITheme.openaiGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: OpenAITheme.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'A1':
        return const Color(0xFF22C55E); // green
      case 'A2':
        return const Color(0xFF3B82F6); // blue
      case 'B1':
        return const Color(0xFF8B5CF6); // purple
      case 'B2':
        return const Color(0xFFF59E0B); // amber
      default:
        return OpenAITheme.textSecondary;
    }
  }
}
