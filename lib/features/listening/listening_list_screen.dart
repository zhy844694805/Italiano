import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/listening_provider.dart';
import '../../shared/models/listening.dart';
import '../../shared/widgets/gradient_card.dart';
import 'listening_detail_screen.dart';

/// 听力练习列表界面
class ListeningListScreen extends ConsumerStatefulWidget {
  const ListeningListScreen({super.key});

  @override
  ConsumerState<ListeningListScreen> createState() => _ListeningListScreenState();
}

class _ListeningListScreenState extends ConsumerState<ListeningListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedLevel = '全部';
  String _selectedCategory = '全部';

  final List<String> _levels = ['全部', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allExercises = ref.watch(allListeningExercisesProvider);
    final categories = ref.watch(listeningCategoriesProvider);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('听力练习'),
              pinned: true,
              floating: true,
              expandedHeight: 140,
              backgroundColor: Theme.of(context).colorScheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  '听力练习',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF00B578),
                        Color(0xFF009246),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'A1必备'),
                  Tab(text: '数字听写'),
                  Tab(text: '单词识别'),
                  Tab(text: '短对话'),
                  Tab(text: '问题回答'),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: _buildFilters(allExercises.value ?? []),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildExerciseList(ref.watch(essentialListeningProvider)),
            _buildExerciseList(ref.watch(numberDictationProvider)),
            _buildExerciseList(ref.watch(wordRecognitionProvider)),
            _buildExerciseList(ref.watch(shortDialogueProvider)),
            _buildExerciseList(ref.watch(questionAnswerProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(List<ListeningExercise> exercises) {
    final categories = [
      '全部',
      '数字听写',
      '单词识别',
      '短对话',
      '问题回答',
    ];

    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '筛选：',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  '级别',
                  _selectedLevel,
                  _levels,
                  (value) {
                    setState(() {
                      _selectedLevel = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  '类别',
                  _selectedCategory,
                  categories,
                  (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          hint: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildExerciseList(List<ListeningExercise> exercises) {
    // 应用筛选
    var filteredExercises = exercises.where((exercise) {
      if (_selectedLevel != '全部' && exercise.level != _selectedLevel) {
        return false;
      }
      if (_selectedCategory != '全部' && exercise.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    if (filteredExercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.headphones,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无听力练习',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请调整筛选条件或稍后再试',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = filteredExercises[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ListeningExerciseCard(
            exercise: exercise,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListeningDetailScreen(exercise: exercise),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选选项'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('级别：'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _levels.map((level) {
                final isSelected = _selectedLevel == level;
                return FilterChip(
                  label: Text(level),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedLevel = selected ? level : '全部';
                    });
                    Navigator.pop(context);
                  },
                  backgroundColor: isSelected ? null : Colors.grey[200],
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? Theme.of(context).primaryColor : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// 听力练习卡片组件
class _ListeningExerciseCard extends ConsumerWidget {
  final ListeningExercise exercise;
  final VoidCallback onTap;

  const _ListeningExerciseCard({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(listeningProgressProvider);
    final isCompleted = progress.when(
      data: (progressList) => progressList.any((p) => p.exerciseId == exercise.id),
      loading: () => false,
      error: (_, __) => false,
    );

    final isFavorite = progress.when(
      data: (progressList) {
        final item = progressList.firstWhere(
          (p) => p.exerciseId == exercise.id,
          orElse: () => ListeningProgress(
            exerciseId: exercise.id,
            completedAt: DateTime.now(),
            isCorrect: false,
            selectedAnswer: '',
            attempts: 0,
            completionTime: Duration.zero,
            isFavorite: false,
          ),
        );
        return item.isFavorite;
      },
      loading: () => false,
      error: (_, __) => false,
    );

    Color categoryColor;
    IconData categoryIcon;

    switch (exercise.category) {
      case '数字听写':
        categoryColor = Colors.blue;
        categoryIcon = Icons.tag;
        break;
      case '单词识别':
        categoryColor = Colors.green;
        categoryIcon = Icons.translate;
        break;
      case '短对话':
        categoryColor = Colors.orange;
        categoryIcon = Icons.chat;
        break;
      case '问题回答':
        categoryColor = Colors.purple;
        categoryIcon = Icons.question_answer;
        break;
      default:
        categoryColor = Colors.grey;
        categoryIcon = Icons.headphones;
    }

    return GradientCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  categoryIcon,
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.chineseTitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getLevelColor(exercise.level).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      exercise.level,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getLevelColor(exercise.level),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isCompleted)
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        )
                      else
                        Icon(
                          Icons.radio_button_unchecked,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      if (isFavorite) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                '${exercise.duration.inSeconds}秒',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.repeat,
                size: 16,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                '${exercise.playCount}次',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              if (exercise.isEssential)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: const Text(
                    '必备',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            exercise.description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
      case 'C1':
        return Colors.purple;
      case 'C2':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}