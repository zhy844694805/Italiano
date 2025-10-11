import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../vocabulary/vocabulary_learning_screen.dart';
import '../vocabulary/vocabulary_list_screen.dart';
import '../vocabulary/vocabulary_review_screen.dart';
import '../grammar/grammar_list_screen.dart';
import '../conversation/conversation_scenario_screen.dart';
import '../reading/reading_list_screen.dart';
import '../practice/practice_screen.dart';
import '../profile/profile_screen.dart';
import '../../shared/providers/vocabulary_provider.dart';
import '../../shared/providers/statistics_provider.dart';
import '../../core/theme/modern_theme.dart';
import '../../shared/widgets/gradient_card.dart';

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
      bottomNavigationBar: NavigationBar(
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
    );
  }
}

// 首页
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final wordsToReviewAsync = ref.watch(wordsToReviewProvider);
    final newWordsAsync = ref.watch(newWordsProvider);
    final statisticsAsync = ref.watch(statisticsProvider);
    final todayStatsAsync = ref.watch(todayStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ciao! 👋'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 学习进度卡片 - 现代化设计
              FloatingCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // 渐变图标背景
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: ModernTheme.accentGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: ModernTheme.accentColor.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '连续学习',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: ModernTheme.textLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              statisticsAsync.when(
                                data: (stats) => Text(
                                  '${stats.studyStreak} 天',
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                loading: () => Text(
                                  '0 天',
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                error: (_, __) => Text(
                                  '0 天',
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    todayStatsAsync.when(
                      data: (todayStats) {
                        final dailyGoal = 20;
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
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '$wordsLearned / $dailyGoal 词',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: ModernTheme.textLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // 使用渐变进度条
                            GradientProgressBar(
                              progress: progress,
                              height: 12,
                              gradient: ModernTheme.primaryGradient,
                            ),
                          ],
                        );
                      },
                      loading: () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '今日目标',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '0 / 20 词',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: ModernTheme.textLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const GradientProgressBar(
                            progress: 0,
                            height: 12,
                            gradient: ModernTheme.primaryGradient,
                          ),
                        ],
                      ),
                      error: (_, __) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '今日目标',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '0 / 20 词',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: ModernTheme.textLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const GradientProgressBar(
                            progress: 0,
                            height: 12,
                            gradient: ModernTheme.primaryGradient,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 复习提醒卡片
              wordsToReviewAsync.when(
                data: (wordsToReview) {
                  if (wordsToReview.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        color: colorScheme.secondaryContainer,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VocabularyReviewScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.alarm,
                                    color: colorScheme.onSecondary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '复习提醒',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSecondaryContainer,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${wordsToReview.length} 个单词等待复习',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSecondaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: colorScheme.onSecondaryContainer,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  newWordsAsync.when(
                    data: (newWords) => _QuickActionCardWithBadge(
                      icon: Icons.book,
                      title: '学习新词',
                      color: colorScheme.primary,
                      badge: newWords.isNotEmpty ? '${newWords.length}' : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VocabularyLearningScreen(
                              newWordsOnly: true,
                            ),
                          ),
                        );
                      },
                    ),
                    loading: () => _QuickActionCard(
                      icon: Icons.book,
                      title: '学习新词',
                      color: colorScheme.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VocabularyLearningScreen(
                              newWordsOnly: true,
                            ),
                          ),
                        );
                      },
                    ),
                    error: (_, __) => _QuickActionCard(
                      icon: Icons.book,
                      title: '学习新词',
                      color: colorScheme.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VocabularyLearningScreen(
                              newWordsOnly: true,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _QuickActionCard(
                    icon: Icons.repeat,
                    title: '复习单词',
                    color: colorScheme.secondary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VocabularyReviewScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.chat_bubble_outline,
                    title: 'AI 对话',
                    color: Colors.deepPurple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConversationScenarioScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.article,
                    title: '阅读理解',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReadingListScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  Gradient _getGradient() {
    // 根据颜色返回对应的渐变
    if (color == ModernTheme.primaryColor || color == Colors.green) {
      return ModernTheme.primaryGradient;
    } else if (color == ModernTheme.secondaryColor || color == Colors.blue) {
      return ModernTheme.secondaryGradient;
    } else if (color == Colors.deepPurple) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
      );
    } else if (color == Colors.orange) {
      return ModernTheme.accentGradient;
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color, color.withValues(alpha: 0.8)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      gradient: _getGradient(),
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// 带徽章的快捷操作卡片
class _QuickActionCardWithBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const _QuickActionCardWithBadge({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.badge,
  });

  Gradient _getGradient() {
    // 根据颜色返回对应的渐变
    if (color == ModernTheme.primaryColor || color == Colors.green) {
      return ModernTheme.primaryGradient;
    } else if (color == ModernTheme.secondaryColor || color == Colors.blue) {
      return ModernTheme.secondaryGradient;
    } else if (color == Colors.deepPurple) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
      );
    } else if (color == Colors.orange) {
      return ModernTheme.accentGradient;
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color, color.withValues(alpha: 0.8)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox.expand(
          child: GradientCard(
            gradient: _getGradient(),
            onTap: onTap,
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        // 徽章
        if (badge != null)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ModernTheme.redGradient.colors.first,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// 词汇页面 - 使用词汇列表
class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const VocabularyListScreen();
  }
}

// 语法页面 - 使用语法列表
class GrammarPage extends StatelessWidget {
  const GrammarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GrammarListScreen();
  }
}

// 练习页面 - 使用阅读理解列表
class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PracticeScreen();
  }
}

// 个人页面 - 使用个人中心页面
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}
