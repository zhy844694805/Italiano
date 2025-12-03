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
            top: BorderSide(color: OpenAITheme.borderLight, width: 1),
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
              icon: Icon(Icons.edit_outlined),
              selectedIcon: Icon(Icons.edit),
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

// 首页 - OpenAI 极简风格
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final wordsToReviewAsync = ref.watch(wordsToReviewProvider);
    final newWordsAsync = ref.watch(newWordsProvider);
    final statisticsAsync = ref.watch(statisticsProvider);
    final todayStatsAsync = ref.watch(todayStatisticsProvider);

    return Scaffold(
      backgroundColor: OpenAITheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: OpenAITheme.bgPrimary,
        title: const Text('学意大利语'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 学习进度卡片 - 简洁边框风格
              Container(
                padding: const EdgeInsets.all(20),
                decoration: OpenAITheme.floatingCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // 简洁图标
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: OpenAITheme.bgSecondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.local_fire_department,
                            color: OpenAITheme.openaiGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '连续学习',
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 2),
                              statisticsAsync.when(
                                data: (stats) => Text(
                                  '${stats.studyStreak} 天',
                                  style: theme.textTheme.headlineMedium,
                                ),
                                loading: () => Text(
                                  '0 天',
                                  style: theme.textTheme.headlineMedium,
                                ),
                                error: (_, __) => Text(
                                  '0 天',
                                  style: theme.textTheme.headlineMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: OpenAITheme.borderLight),
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
                                Text(
                                  '今日目标',
                                  style: theme.textTheme.titleSmall,
                                ),
                                Text(
                                  '$wordsLearned / $dailyGoal 词',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: OpenAITheme.openaiGreen,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // 简洁进度条
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: OpenAITheme.gray100,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: OpenAITheme.openaiGreen,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => _buildProgressPlaceholder(theme),
                      error: (_, __) => _buildProgressPlaceholder(theme),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 复习提醒
              wordsToReviewAsync.when(
                data: (wordsToReview) {
                  if (wordsToReview.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _buildReviewCard(context, wordsToReview.length),
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // 快速开始
              Text(
                '快速开始',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),

              // 功能卡片网格
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  newWordsAsync.when(
                    data: (newWords) => _ActionCard(
                      icon: Icons.auto_stories,
                      title: '学习新词',
                      subtitle: '${newWords.length} 词待学',
                      color: OpenAITheme.openaiGreen,
                      onTap: () => _navigateTo(context, const VocabularyLearningScreen(newWordsOnly: true)),
                    ),
                    loading: () => _ActionCard(
                      icon: Icons.auto_stories,
                      title: '学习新词',
                      color: OpenAITheme.openaiGreen,
                      onTap: () => _navigateTo(context, const VocabularyLearningScreen(newWordsOnly: true)),
                    ),
                    error: (_, __) => _ActionCard(
                      icon: Icons.auto_stories,
                      title: '学习新词',
                      color: OpenAITheme.openaiGreen,
                      onTap: () => _navigateTo(context, const VocabularyLearningScreen(newWordsOnly: true)),
                    ),
                  ),
                  _ActionCard(
                    icon: Icons.refresh,
                    title: '复习单词',
                    color: OpenAITheme.charcoal,
                    onTap: () => _navigateTo(context, const VocabularyReviewScreen()),
                  ),
                  _ActionCard(
                    icon: Icons.chat_bubble_outline,
                    title: 'AI 对话',
                    color: const Color(0xFF7C3AED),
                    onTap: () => _navigateTo(context, const ConversationScenarioScreen()),
                  ),
                  _ActionCard(
                    icon: Icons.record_voice_over,
                    title: '意大利语口语',
                    color: const Color(0xFFDC2626),
                    onTap: () => _navigateTo(context, const PhraseListScreen()),
                  ),
                  _ActionCard(
                    icon: Icons.forum_outlined,
                    title: '日常对话',
                    color: const Color(0xFF0891B2),
                    onTap: () => _navigateTo(context, const DailyConversationListScreen()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressPlaceholder(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('今日目标', style: theme.textTheme.titleSmall),
            Text(
              '0 / 20 词',
              style: theme.textTheme.titleSmall?.copyWith(
                color: OpenAITheme.openaiGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: OpenAITheme.gray100,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(BuildContext context, int count) {
    return GestureDetector(
      onTap: () => _navigateTo(context, const VocabularyReviewScreen()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: OpenAITheme.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: OpenAITheme.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: OpenAITheme.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_none,
                color: OpenAITheme.openaiGreen,
                size: 22,
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
                      color: OpenAITheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count 个单词等待复习',
                    style: const TextStyle(
                      fontSize: 13,
                      color: OpenAITheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: OpenAITheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

// 功能卡片 - OpenAI 极简风格
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 图标容器
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              // 文字内容
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: OpenAITheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: OpenAITheme.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
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
