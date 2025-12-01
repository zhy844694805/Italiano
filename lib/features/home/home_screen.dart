import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../vocabulary/vocabulary_learning_screen.dart';
import '../vocabulary/vocabulary_list_screen.dart';
import '../vocabulary/vocabulary_review_screen.dart';
import '../grammar/grammar_list_screen.dart';
import '../conversation/conversation_scenario_screen.dart';
import '../practice/practice_screen.dart';
import '../profile/profile_screen.dart';
import '../phrase/phrase_list_screen.dart';
import '../daily_conversation/daily_conversation_list_screen.dart';
import '../../shared/providers/vocabulary_provider.dart';
import '../../shared/providers/statistics_provider.dart';
import '../../core/theme/openai_theme.dart';
import '../../shared/widgets/openai_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const VocabularyPage(),
    const GrammarPage(),
    const PracticePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: OpenAITheme.gray200, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: '首页',
            ),
            NavigationDestination(
              icon: Icon(Icons.book_outlined),
              selectedIcon: Icon(Icons.book),
              label: '词汇',
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school),
              label: '语法',
            ),
            NavigationDestination(
              icon: Icon(Icons.edit_note_outlined),
              selectedIcon: Icon(Icons.edit_note),
              label: '练习',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}

// 首页
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsToReviewAsync = ref.watch(wordsToReviewProvider);
    final newWordsAsync = ref.watch(newWordsProvider);
    final statisticsAsync = ref.watch(statisticsProvider);
    final todayStatsAsync = ref.watch(todayStatisticsProvider);

    return Scaffold(
      backgroundColor: OpenAITheme.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部问候
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ciao!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: OpenAITheme.gray900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '继续你的意大利语学习之旅',
                      style: TextStyle(
                        fontSize: 15,
                        color: OpenAITheme.gray500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 学习统计卡片
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: OCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: OpenAITheme.gray100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.local_fire_department,
                              color: OpenAITheme.gray700,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '连续学习',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: OpenAITheme.gray500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                statisticsAsync.when(
                                  data: (stats) => Text(
                                    '${stats.studyStreak} 天',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: OpenAITheme.gray900,
                                    ),
                                  ),
                                  loading: () => const Text(
                                    '0 天',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: OpenAITheme.gray900,
                                    ),
                                  ),
                                  error: (_, __) => const Text(
                                    '0 天',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: OpenAITheme.gray900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      todayStatsAsync.when(
                        data: (todayStats) {
                          const dailyGoal = 20;
                          final wordsLearned = todayStats?.wordsLearned ?? 0;
                          final progress = (wordsLearned / dailyGoal).clamp(0.0, 1.0);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '今日目标',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: OpenAITheme.gray700,
                                    ),
                                  ),
                                  Text(
                                    '$wordsLearned / $dailyGoal 词',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: OpenAITheme.gray500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              OProgressBar(
                                progress: progress,
                                height: 6,
                              ),
                            ],
                          );
                        },
                        loading: () => _buildProgressPlaceholder(),
                        error: (_, __) => _buildProgressPlaceholder(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 复习提醒
            SliverToBoxAdapter(
              child: wordsToReviewAsync.when(
                data: (wordsToReview) {
                  if (wordsToReview.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: OCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VocabularyReviewScreen(),
                          ),
                        );
                      },
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: OpenAITheme.greenLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.notifications_outlined,
                              color: OpenAITheme.green,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '复习提醒',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: OpenAITheme.gray800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${wordsToReview.length} 个单词等待复习',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: OpenAITheme.gray500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: OpenAITheme.gray400,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // 快速开始标题
            const SliverToBoxAdapter(
              child: OSectionHeader(title: '快速开始'),
            ),

            // 功能入口网格
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                delegate: SliverChildListDelegate([
                  newWordsAsync.when(
                    data: (newWords) => _ActionCard(
                      icon: Icons.add_circle_outline,
                      title: '学习新词',
                      badge: newWords.isNotEmpty ? '${newWords.length}' : null,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VocabularyLearningScreen(
                            newWordsOnly: true,
                          ),
                        ),
                      ),
                    ),
                    loading: () => _ActionCard(
                      icon: Icons.add_circle_outline,
                      title: '学习新词',
                      onTap: () {},
                    ),
                    error: (_, __) => _ActionCard(
                      icon: Icons.add_circle_outline,
                      title: '学习新词',
                      onTap: () {},
                    ),
                  ),
                  _ActionCard(
                    icon: Icons.refresh,
                    title: '复习单词',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VocabularyReviewScreen(),
                      ),
                    ),
                  ),
                  _ActionCard(
                    icon: Icons.chat_bubble_outline,
                    title: 'AI 对话',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConversationScenarioScreen(),
                      ),
                    ),
                  ),
                  _ActionCard(
                    icon: Icons.record_voice_over_outlined,
                    title: '常用短语',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PhraseListScreen(),
                      ),
                    ),
                  ),
                ]),
              ),
            ),

            // 更多功能标题
            const SliverToBoxAdapter(
              child: OSectionHeader(title: '更多'),
            ),

            // 更多功能列表
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      OListTile(
                        leading: Icons.forum_outlined,
                        title: '日常对话',
                        subtitle: '场景化对话练习',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DailyConversationListScreen(),
                          ),
                        ),
                      ),
                      const ODivider(indent: 50),
                      OListTile(
                        leading: Icons.menu_book_outlined,
                        title: '阅读理解',
                        subtitle: '提升阅读能力',
                        onTap: () {
                          // 切换到练习页面
                          final state = context.findAncestorStateOfType<_HomeScreenState>();
                          if (state != null) {
                            // ignore: invalid_use_of_protected_member
                            state.setState(() {
                              state._selectedIndex = 3;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              '今日目标',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: OpenAITheme.gray700,
              ),
            ),
            Text(
              '0 / 20 词',
              style: TextStyle(
                fontSize: 13,
                color: OpenAITheme.gray500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const OProgressBar(progress: 0, height: 6),
      ],
    );
  }
}

// 功能卡片
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? badge;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: OpenAITheme.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 22, color: OpenAITheme.gray700),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: OpenAITheme.gray800,
                ),
              ),
            ],
          ),
          if (badge != null)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: OpenAITheme.gray900,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: OpenAITheme.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 词汇页面
class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const VocabularyListScreen();
  }
}

// 语法页面
class GrammarPage extends StatelessWidget {
  const GrammarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GrammarListScreen();
  }
}

// 练习页面
class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PracticeScreen();
  }
}

// 个人页面
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}
