import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../shared/providers/statistics_provider.dart';
import '../../core/database/learning_statistics_repository.dart';
import '../settings/settings_screen.dart';
import '../../core/theme/openai_theme.dart';
import '../../shared/widgets/openai_widgets.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(statisticsProvider);
    final vocabularyStatsAsync = ref.watch(vocabularyStatsProvider);
    final grammarStatsAsync = ref.watch(grammarStatsProvider);

    return Scaffold(
      backgroundColor: OpenAITheme.white,
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: OpenAITheme.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: OpenAITheme.gray600),
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
        color: OpenAITheme.gray900,
        onRefresh: () async {
          ref.invalidate(statisticsProvider);
          ref.invalidate(vocabularyStatsProvider);
          ref.invalidate(grammarStatsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户信息卡片
              OCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: OpenAITheme.gray100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 32,
                        color: OpenAITheme.gray500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '意大利语学习者',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: OpenAITheme.gray900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          statisticsAsync.when(
                            data: (stats) => Row(
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  size: 16,
                                  color: OpenAITheme.gray500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '连续学习 ${stats.studyStreak} 天',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: OpenAITheme.gray500,
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

              const SizedBox(height: 24),

              // 学习统计总览
              statisticsAsync.when(
                data: (stats) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OSectionHeader(title: '学习统计'),

                    // 统计数据网格
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _StatCard(
                          icon: Icons.local_fire_department,
                          label: '学习天数',
                          value: '${stats.totalStudyDays}',
                        ),
                        _StatCard(
                          icon: Icons.schedule,
                          label: '学习时长',
                          value: '${(stats.totalStudyTimeMinutes / 60).toStringAsFixed(1)}h',
                        ),
                        _StatCard(
                          icon: Icons.translate,
                          label: '学习单词',
                          value: '${stats.totalWordsLearned}',
                        ),
                        _StatCard(
                          icon: Icons.school,
                          label: '语法点',
                          value: '${stats.totalGrammarStudied}',
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 学习趋势图
                    const OSectionHeader(title: '最近7天'),
                    OCard(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 180,
                        child: _LearningChart(recentStats: stats.recentStats),
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: OpenAITheme.gray900),
                  ),
                ),
                error: (error, stack) => OEmptyState(
                  icon: Icons.error_outline,
                  title: '加载失败',
                  subtitle: error.toString(),
                ),
              ),

              const SizedBox(height: 24),

              // 词汇统计
              vocabularyStatsAsync.when(
                data: (vocabStats) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OSectionHeader(title: '词汇掌握'),
                    OCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _VocabStat(
                                label: '已学习',
                                value: vocabStats['totalWords'],
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color: OpenAITheme.gray200,
                              ),
                              _VocabStat(
                                label: '已掌握',
                                value: vocabStats['masteredWords'],
                                color: OpenAITheme.green,
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color: OpenAITheme.gray200,
                              ),
                              _VocabStat(
                                label: '复习中',
                                value: vocabStats['reviewingWords'],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Text(
                                '平均掌握度',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: OpenAITheme.gray500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${(vocabStats['averageMastery'] * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: OpenAITheme.gray900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          OProgressBar(
                            progress: vocabStats['averageMastery'],
                            height: 6,
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
                    const OSectionHeader(title: '语法进度'),
                    OCard(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _GrammarStat(
                            icon: Icons.check_circle_outline,
                            label: '已完成',
                            value: grammarStats['completedCount'],
                          ),
                          Container(
                            height: 50,
                            width: 1,
                            color: OpenAITheme.gray200,
                          ),
                          _GrammarStat(
                            icon: Icons.favorite_outline,
                            label: '已收藏',
                            value: grammarStats['favoriteCount'],
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

              // 更多功能
              const OSectionHeader(title: '更多'),
              OCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    OListTile(
                      leading: Icons.star_outline,
                      title: '我的收藏',
                      onTap: () {},
                    ),
                    const ODivider(indent: 50),
                    OListTile(
                      leading: Icons.emoji_events_outlined,
                      title: '学习成就',
                      onTap: () {},
                    ),
                    const ODivider(indent: 50),
                    OListTile(
                      leading: Icons.notifications_outlined,
                      title: '学习提醒',
                      onTap: () {},
                    ),
                    const ODivider(indent: 50),
                    OListTile(
                      leading: Icons.info_outline,
                      title: '关于应用',
                      onTap: () => _showAboutDialog(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
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
        backgroundColor: OpenAITheme.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '关于',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: OpenAITheme.gray900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '意大利语学习 v1.0.0',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: OpenAITheme.gray800,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '使用科学的间隔重复算法，帮助你高效学习意大利语。',
              style: TextStyle(
                fontSize: 14,
                color: OpenAITheme.gray500,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '确定',
              style: TextStyle(
                color: OpenAITheme.gray900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return OCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: OpenAITheme.gray500),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: OpenAITheme.gray900,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: OpenAITheme.gray500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VocabStat extends StatelessWidget {
  final String label;
  final int value;
  final Color? color;

  const _VocabStat({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: color ?? OpenAITheme.gray900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: OpenAITheme.gray500,
          ),
        ),
      ],
    );
  }
}

class _GrammarStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;

  const _GrammarStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: OpenAITheme.gray500),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: OpenAITheme.gray900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: OpenAITheme.gray500,
          ),
        ),
      ],
    );
  }
}

class _LearningChart extends StatelessWidget {
  final List<DailyStatistics> recentStats;

  const _LearningChart({required this.recentStats});

  @override
  Widget build(BuildContext context) {
    if (recentStats.isEmpty) {
      return const Center(
        child: Text(
          '暂无学习数据',
          style: TextStyle(color: OpenAITheme.gray500),
        ),
      );
    }

    final spots = <FlSpot>[];
    final dates = <String>[];

    for (int i = 0; i < recentStats.length; i++) {
      final stat = recentStats[i];
      final totalActivity = stat.wordsLearned + stat.wordsReviewed +
                           stat.grammarPointsStudied + stat.conversationMessages;
      spots.add(FlSpot(i.toDouble(), totalActivity.toDouble()));
      dates.add(DateFormat('MM/dd').format(stat.date));
    }

    final maxY = spots.isEmpty ? 10.0 : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final yInterval = maxY > 0 ? (maxY / 4).ceilToDouble() : 5.0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval.toDouble(),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: OpenAITheme.gray200,
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
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < dates.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      dates[index],
                      style: const TextStyle(
                        color: OpenAITheme.gray400,
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
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: OpenAITheme.gray400,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (recentStats.length - 1).toDouble(),
        minY: 0,
        maxY: maxY + yInterval,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: OpenAITheme.gray900,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: OpenAITheme.gray900,
                  strokeWidth: 0,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: OpenAITheme.gray100,
            ),
          ),
        ],
      ),
    );
  }
}
