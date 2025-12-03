import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/vocabulary_provider.dart';
import '../../shared/providers/grammar_provider.dart';
import '../../shared/providers/tts_provider.dart';
import '../../shared/models/word.dart';
import '../../shared/models/grammar.dart';
import '../../core/theme/openai_theme.dart';
import '../grammar/grammar_detail_screen.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OpenAITheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: OpenAITheme.bgPrimary,
        title: const Text('我的收藏'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: OpenAITheme.openaiGreen,
          indicatorWeight: 2,
          labelColor: OpenAITheme.openaiGreen,
          unselectedLabelColor: OpenAITheme.textTertiary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: const [
            Tab(text: '单词'),
            Tab(text: '语法'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FavoriteWordsTab(),
          _FavoriteGrammarTab(),
        ],
      ),
    );
  }
}

// 收藏的单词标签页
class _FavoriteWordsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allWordsAsync = ref.watch(allWordsProvider);
    final learningProgress = ref.watch(learningProgressProvider);
    final ttsService = ref.watch(ttsServiceProvider);

    return allWordsAsync.when(
      data: (allWords) {
        // 过滤出收藏的单词
        final favoriteWordIds = learningProgress.entries
            .where((e) => e.value.isFavorite)
            .map((e) => e.key)
            .toSet();

        final favoriteWords = allWords
            .where((word) => favoriteWordIds.contains(word.id))
            .toList();

        if (favoriteWords.isEmpty) {
          return _EmptyState(
            icon: Icons.star_outline,
            title: '暂无收藏单词',
            description: '在学习单词时点击星标收藏',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favoriteWords.length,
          itemBuilder: (context, index) {
            final word = favoriteWords[index];
            final record = learningProgress[word.id];

            return _FavoriteWordCard(
              word: word,
              mastery: record?.mastery ?? 0.0,
              ttsService: ttsService,
              onUnfavorite: () {
                ref.read(learningProgressProvider.notifier).toggleFavorite(word.id);
              },
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: OpenAITheme.openaiGreen),
      ),
      error: (_, __) => _EmptyState(
        icon: Icons.error_outline,
        title: '加载失败',
        description: '请稍后重试',
      ),
    );
  }
}

// 收藏的语法标签页
class _FavoriteGrammarTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allGrammarAsync = ref.watch(allGrammarProvider);
    final grammarProgress = ref.watch(grammarProgressProvider);

    return allGrammarAsync.when(
      data: (allGrammar) {
        // 过滤出收藏的语法
        final favoriteGrammarIds = grammarProgress.entries
            .where((e) => e.value.isFavorite)
            .map((e) => e.key)
            .toSet();

        final favoriteGrammar = allGrammar
            .where((grammar) => favoriteGrammarIds.contains(grammar.id))
            .toList();

        if (favoriteGrammar.isEmpty) {
          return _EmptyState(
            icon: Icons.star_outline,
            title: '暂无收藏语法',
            description: '在学习语法时点击星标收藏',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favoriteGrammar.length,
          itemBuilder: (context, index) {
            final grammar = favoriteGrammar[index];
            final progress = grammarProgress[grammar.id];

            return _FavoriteGrammarCard(
              grammar: grammar,
              isCompleted: progress?.completed ?? false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GrammarDetailScreen(grammarPoint: grammar),
                  ),
                );
              },
              onUnfavorite: () {
                ref.read(grammarProgressProvider.notifier).toggleFavorite(grammar.id);
              },
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: OpenAITheme.openaiGreen),
      ),
      error: (_, __) => _EmptyState(
        icon: Icons.error_outline,
        title: '加载失败',
        description: '请稍后重试',
      ),
    );
  }
}

// 空状态组件
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: OpenAITheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: OpenAITheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: OpenAITheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// 收藏单词卡片
class _FavoriteWordCard extends StatelessWidget {
  final Word word;
  final double mastery;
  final dynamic ttsService;
  final VoidCallback onUnfavorite;

  const _FavoriteWordCard({
    required this.word,
    required this.mastery,
    required this.ttsService,
    required this.onUnfavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: OpenAITheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OpenAITheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部行
            Row(
              children: [
                // 级别标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getLevelColor(word.level).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    word.level,
                    style: TextStyle(
                      color: _getLevelColor(word.level),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                // 播放按钮
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 20),
                  color: OpenAITheme.textSecondary,
                  onPressed: () {
                    try {
                      ttsService.speak(word.italian);
                    } catch (e) {
                      debugPrint('TTS error: $e');
                    }
                  },
                ),
                // 取消收藏按钮
                IconButton(
                  icon: const Icon(Icons.star, size: 20),
                  color: OpenAITheme.warning,
                  onPressed: onUnfavorite,
                ),
              ],
            ),

            // 单词
            Text(
              word.italian,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: OpenAITheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // 音标
            if (word.pronunciation != null)
              Text(
                word.pronunciation!,
                style: const TextStyle(
                  fontSize: 13,
                  color: OpenAITheme.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 8),

            // 翻译
            Text(
              word.chinese,
              style: const TextStyle(
                fontSize: 15,
                color: OpenAITheme.textSecondary,
              ),
            ),

            // 掌握度
            if (mastery > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    '掌握度',
                    style: TextStyle(
                      fontSize: 12,
                      color: OpenAITheme.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: OpenAITheme.gray100,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: mastery.clamp(0.0, 1.0),
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
                    '${(mastery * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
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
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'A1':
        return OpenAITheme.openaiGreen;
      case 'A2':
        return OpenAITheme.info;
      case 'B1':
        return const Color(0xFF8B5CF6);
      case 'B2':
        return OpenAITheme.warning;
      default:
        return OpenAITheme.textSecondary;
    }
  }
}

// 收藏语法卡片
class _FavoriteGrammarCard extends StatelessWidget {
  final GrammarPoint grammar;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback onUnfavorite;

  const _FavoriteGrammarCard({
    required this.grammar,
    required this.isCompleted,
    required this.onTap,
    required this.onUnfavorite,
  });

  @override
  Widget build(BuildContext context) {
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
                // 完成状态图标
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? OpenAITheme.openaiGreen.withValues(alpha: 0.1)
                        : OpenAITheme.bgSecondary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : Icons.school_outlined,
                    size: 20,
                    color: isCompleted ? OpenAITheme.openaiGreen : OpenAITheme.textTertiary,
                  ),
                ),
                const SizedBox(width: 14),

                // 内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        grammar.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: OpenAITheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getLevelColor(grammar.level).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              grammar.level,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getLevelColor(grammar.level),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${grammar.rules.length}规则 · ${grammar.exercises.length}练习',
                            style: const TextStyle(
                              fontSize: 12,
                              color: OpenAITheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 取消收藏按钮
                IconButton(
                  icon: const Icon(Icons.star, size: 20),
                  color: OpenAITheme.warning,
                  onPressed: onUnfavorite,
                ),

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
        return OpenAITheme.openaiGreen;
      case 'A2':
        return OpenAITheme.info;
      default:
        return OpenAITheme.textSecondary;
    }
  }
}
