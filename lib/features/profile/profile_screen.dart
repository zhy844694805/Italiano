import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../shared/providers/statistics_provider.dart';
import '../../core/database/learning_statistics_repository.dart';
import '../settings/settings_screen.dart';
import '../../core/theme/modern_theme.dart';
import '../../shared/widgets/gradient_card.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final statisticsAsync = ref.watch(statisticsProvider);
    final vocabularyStatsAsync = ref.watch(vocabularyStatsProvider);
    final grammarStatsAsync = ref.watch(grammarStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(statisticsProvider);
          ref.invalidate(vocabularyStatsProvider);
          ref.invalidate(grammarStatsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户信息卡片
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '意大利语学习者',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            statisticsAsync.when(
                              data: (stats) => Row(
                                children: [
                                  Icon(
                                    Icons.local_fire_department,
                                    size: 20,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '连续学习 ${stats.studyStreak} 天',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              loading: () => const SizedBox(),
                              error: (_, __) => const SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 学习统计总览
              statisticsAsync.when(
                data: (stats) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '学习统计',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 统计数据网格 - 使用现代化 StatCard
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: [
                        StatCard(
                          icon: Icons.local_fire_department,
                          label: '总学习天数',
                          value: '${stats.totalStudyDays}天',
                          gradient: ModernTheme.accentGradient,
                        ),
                        StatCard(
                          icon: Icons.schedule,
                          label: '总学习时长',
                          value: '${(stats.totalStudyTimeMinutes / 60).toStringAsFixed(1)}h',
                          gradient: ModernTheme.secondaryGradient,
                        ),
                        StatCard(
                          icon: Icons.translate,
                          label: '学习单词',
                          value: '${stats.totalWordsLearned}',
                          gradient: ModernTheme.primaryGradient,
                        ),
                        StatCard(
                          icon: Icons.school,
                          label: '语法点',
                          value: '${stats.totalGrammarStudied}',
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFF8A65), Color(0xFFFF6F00)],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 最近7天学习趋势图
                    Text(
                      '最近7天学习趋势',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FloatingCard(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 200,
                        child: _LearningChart(recentStats: stats.recentStats),
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('加载统计数据失败: $error'),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 词汇统计
              vocabularyStatsAsync.when(
                data: (vocabStats) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '词汇掌握情况',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FloatingCard(
                      child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _VocabStatItem(
                                  label: '已学习',
                                  value: vocabStats['totalWords'],
                                  color: colorScheme.primary,
                                ),
                                _VocabStatItem(
                                  label: '已掌握',
                                  value: vocabStats['masteredWords'],
                                  color: Colors.green,
                                ),
                                _VocabStatItem(
                                  label: '复习中',
                                  value: vocabStats['reviewingWords'],
                                  color: Colors.orange,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '平均掌握度',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const Spacer(),
                                Text(
                                  '${(vocabStats['averageMastery'] * 100).toStringAsFixed(1)}%',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: vocabStats['averageMastery'],
                                minHeight: 10,
                                backgroundColor: colorScheme.surfaceContainerHighest,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                    ),
                  ],
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),

              const SizedBox(height: 24),

              // 语法统计
              grammarStatsAsync.when(
                data: (grammarStats) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '语法学习进度',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FloatingCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _GrammarStatItem(
                            icon: Icons.check_circle,
                            label: '已完成',
                            value: grammarStats['completedCount'],
                            color: Colors.green,
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: colorScheme.outlineVariant,
                          ),
                          _GrammarStatItem(
                            icon: Icons.favorite,
                            label: '已收藏',
                            value: grammarStats['favoriteCount'],
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),

              const SizedBox(height: 24),

              // 功能入口
              Text(
                '更多功能',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              FloatingCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: ModernTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.star, color: Colors.white, size: 20),
                      ),
                      title: const Text('我的收藏'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: 导航到收藏页面
                      },
                    ),
                    Divider(height: 1, indent: 56),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: ModernTheme.accentGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.emoji_events, color: Colors.white, size: 20),
                      ),
                      title: const Text('学习成就'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: 导航到成就页面
                      },
                    ),
                    Divider(height: 1, indent: 56),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: ModernTheme.secondaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.notifications, color: Colors.white, size: 20),
                      ),
                      title: const Text('学习提醒'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: 导航到提醒设置页面
                      },
                    ),
                    Divider(height: 1, indent: 56),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
                      ),
                      title: const Text('关于应用'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showAboutDialog(context);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80), // 底部留白
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于意大利语学习'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('版本: 1.0.0'),
            SizedBox(height: 8),
            Text('一个现代化的意大利语学习应用'),
            SizedBox(height: 8),
            Text('使用科学的间隔重复算法帮助你高效学习意大利语'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

// 词汇统计项
class _VocabStatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _VocabStatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// 语法统计项
class _GrammarStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _GrammarStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// 学习趋势图表
class _LearningChart extends StatelessWidget {
  final List<DailyStatistics> recentStats;

  const _LearningChart({required this.recentStats});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 如果没有数据,显示空状态
    if (recentStats.isEmpty) {
      return Center(
        child: Text(
          '暂无学习数据',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // 准备图表数据
    final spots = <FlSpot>[];
    final dates = <String>[];

    for (int i = 0; i < recentStats.length; i++) {
      final stat = recentStats[i];
      final totalActivity = stat.wordsLearned + stat.wordsReviewed +
                           stat.grammarPointsStudied + stat.conversationMessages;
      spots.add(FlSpot(i.toDouble(), totalActivity.toDouble()));
      dates.add(DateFormat('MM/dd').format(stat.date));
    }

    // 计算Y轴最大值
    final maxY = spots.isEmpty ? 10.0 : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final yInterval = maxY > 0 ? (maxY / 5).ceilToDouble() : 5.0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval.toDouble(),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < dates.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      dates[index],
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: yInterval.toDouble(),
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: colorScheme.outlineVariant),
            left: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        minX: 0,
        maxX: (recentStats.length - 1).toDouble(),
        minY: 0,
        maxY: maxY + yInterval,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
