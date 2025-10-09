import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/reading.dart';
import '../../shared/providers/reading_provider.dart';
import 'reading_detail_screen.dart';

class ReadingListScreen extends ConsumerStatefulWidget {
  const ReadingListScreen({super.key});

  @override
  ConsumerState<ReadingListScreen> createState() => _ReadingListScreenState();
}

class _ReadingListScreenState extends ConsumerState<ReadingListScreen> {
  String _selectedLevel = 'All';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final passagesAsync = ref.watch(allReadingPassagesProvider);
    final progressMap = ref.watch(readingProgressProvider);
    final categories = ref.watch(readingCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('阅读理解'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: passagesAsync.when(
        data: (passages) {
          // 筛选文章
          var filteredPassages = passages;
          if (_selectedLevel != 'All') {
            filteredPassages = filteredPassages.where((p) => p.level == _selectedLevel).toList();
          }
          if (_selectedCategory != 'All') {
            filteredPassages = filteredPassages.where((p) => p.category == _selectedCategory).toList();
          }

          return Column(
            children: [
              // 筛选器
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildLevelFilter(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCategoryFilter(categories),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStatistics(passages, progressMap),
                  ],
                ),
              ),

              // 文章列表
              Expanded(
                child: filteredPassages.isEmpty
                    ? const Center(child: Text('暂无文章'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredPassages.length,
                        itemBuilder: (context, index) {
                          final passage = filteredPassages[index];
                          final progress = progressMap[passage.id];
                          return _buildPassageCard(context, passage, progress);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('加载失败: $error')),
      ),
    );
  }

  Widget _buildLevelFilter() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedLevel,
      decoration: const InputDecoration(
        labelText: '级别',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: ['All', 'A1', 'A2', 'B1', 'B2']
          .map((level) => DropdownMenuItem(
                value: level,
                child: Text(level),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedLevel = value);
        }
      },
    );
  }

  Widget _buildCategoryFilter(List<String> categories) {
    final allCategories = ['All', ...categories];
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: const InputDecoration(
        labelText: '分类',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: allCategories
          .map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedCategory = value);
        }
      },
    );
  }

  Widget _buildStatistics(List<ReadingPassage> allPassages, Map<String, ReadingProgress> progressMap) {
    final completed = progressMap.length;
    final total = allPassages.length;
    final percentage = total > 0 ? (completed / total * 100).toStringAsFixed(0) : '0';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.library_books, '总文章', '$total'),
          _buildStatItem(Icons.check_circle, '已完成', '$completed'),
          _buildStatItem(Icons.trending_up, '完成率', '$percentage%'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildPassageCard(BuildContext context, ReadingPassage passage, ReadingProgress? progress) {
    final isCompleted = progress != null;
    final accuracy = progress?.accuracy ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReadingDetailScreen(passage: passage),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 级别标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getLevelColor(passage.level),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      passage.level,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 分类标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      passage.category,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  // 完成状态
                  if (isCompleted)
                    Icon(Icons.check_circle, color: Colors.green[600], size: 24),
                ],
              ),
              const SizedBox(height: 12),
              // 标题
              Text(
                passage.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                passage.titleChinese,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              // 文章信息
              Row(
                children: [
                  Icon(Icons.article, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${passage.wordCount} 词', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('约 ${passage.estimatedMinutes} 分钟', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(width: 16),
                  Icon(Icons.quiz, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${passage.questions.length} 题', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              // 进度信息
              if (isCompleted) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: accuracy,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          accuracy >= 0.8 ? Colors.green : (accuracy >= 0.6 ? Colors.orange : Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(accuracy * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
        return Colors.blue;
      case 'B1':
        return Colors.orange;
      case 'B2':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
