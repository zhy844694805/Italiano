import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/vocabulary_provider.dart';
import '../../shared/models/word.dart';

class PersistenceTestScreen extends ConsumerWidget {
  const PersistenceTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressNotifier = ref.watch(learningProgressProvider.notifier);
    final progress = ref.watch(learningProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('数据持久化测试'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // 强制刷新
              ref.invalidate(learningProgressProvider);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '测试说明：',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. 点击"添加测试数据"按钮\n'
              '2. 查看已保存的学习记录\n'
              '3. 完全退出应用(Command+Q)\n'
              '4. 重新启动应用\n'
              '5. 返回此页面，数据应该仍然存在',
              style: TextStyle(fontSize: 14),
            ),
            const Divider(height: 32),

            // 统计信息
            FutureBuilder<Map<String, dynamic>>(
              future: progressNotifier.getStatistics(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final stats = snapshot.data!;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('已学习单词数: ${stats['totalWords']}'),
                        Text('收藏单词数: ${stats['favoriteWords']}'),
                        Text('待复习单词数: ${stats['wordsToReview']}'),
                        Text('平均掌握度: ${(stats['averageMastery'] * 100).toStringAsFixed(1)}%'),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // 学习记录列表
            Expanded(
              child: progress.isEmpty
                  ? const Center(child: Text('暂无学习记录'))
                  : ListView.builder(
                      itemCount: progress.length,
                      itemBuilder: (context, index) {
                        final entry = progress.entries.elementAt(index);
                        final record = entry.value;

                        return ListTile(
                          title: Text('单词ID: ${record.wordId}'),
                          subtitle: Text(
                            '复习次数: ${record.reviewCount} | '
                            '正确次数: ${record.correctCount} | '
                            '掌握度: ${(record.mastery * 100).toStringAsFixed(0)}%',
                          ),
                          trailing: record.isFavorite
                              ? const Icon(Icons.favorite, color: Colors.red)
                              : null,
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // 添加一些测试数据
                      final testWord1 = Word(
                        id: 'test_1',
                        italian: 'ciao',
                        chinese: '你好',
                        category: '测试',
                        level: 'A1',
                      );

                      final testWord2 = Word(
                        id: 'test_2',
                        italian: 'grazie',
                        chinese: '谢谢',
                        category: '测试',
                        level: 'A1',
                      );

                      await progressNotifier.recordWordStudied(testWord1, true);
                      await progressNotifier.recordWordStudied(testWord2, false);
                      await progressNotifier.toggleFavorite('test_1');

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('测试数据已添加并保存到数据库')),
                        );
                      }
                    },
                    child: const Text('添加测试数据'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      await progressNotifier.clearAllProgress();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('所有数据已清空')),
                        );
                      }
                    },
                    child: const Text('清空所有数据'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
