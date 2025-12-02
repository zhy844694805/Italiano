import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/daily_conversation.dart';
import '../../shared/providers/daily_conversation_provider.dart';
import '../../shared/providers/tts_provider.dart';
import '../../core/theme/openai_theme.dart';
import '../../shared/widgets/gradient_card.dart';
import 'daily_conversation_detail_screen.dart';

class DailyConversationListScreen extends ConsumerStatefulWidget {
  const DailyConversationListScreen({super.key});

  @override
  ConsumerState<DailyConversationListScreen> createState() => _DailyConversationListScreenState();
}

class _DailyConversationListScreenState extends ConsumerState<DailyConversationListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(dailyConversationProvider);
    final ttsService = ref.watch(ttsServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '日常对话 🗣️',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: OpenAITheme.openaiGreen,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: OpenAITheme.openaiGreen,
          labelColor: OpenAITheme.openaiGreen,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(
              icon: Icon(Icons.star, color: Colors.orange),
              text: '热门',
            ),
            Tab(
              icon: Icon(Icons.restaurant, color: Colors.red),
              text: '餐厅',
            ),
            Tab(
              icon: Icon(Icons.shopping_bag, color: Colors.blue),
              text: '购物',
            ),
            Tab(
              icon: Icon(Icons.family_restroom, color: Colors.green),
              text: '家庭',
            ),
            Tab(
              icon: Icon(Icons.article, color: Colors.orange),
              text: '阅读',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConversationList(ttsService, isPopular: true),
          _buildConversationList(ttsService, category: 'restaurant'),
          _buildConversationList(ttsService, category: 'shopping'),
          _buildConversationList(ttsService, category: 'family'),
          _buildConversationList(ttsService, category: 'reading'),
        ],
      ),
    );
  }

  Widget _buildConversationList(ttsService, {bool? isPopular, String? category}) {
    final conversationsAsync = ref.watch(dailyConversationProvider);

    if (conversationsAsync is AsyncLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (conversationsAsync is AsyncError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '加载对话失败',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                conversationsAsync.error.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(dailyConversationProvider.notifier).reloadConversations();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    List<DailyConversation> filteredConversations = conversationsAsync.value!;

    if (isPopular == true) {
      filteredConversations = filteredConversations.where((c) => c.isPopular).toList();
    }

    if (category != null) {
      filteredConversations = filteredConversations.where((c) => c.category == category).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filteredConversations = filteredConversations.where((conversation) {
        return conversation.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               conversation.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               conversation.scenario.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (filteredConversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无对话',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 搜索栏
        Container(
          margin: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索对话...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // 对话列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredConversations.length,
            itemBuilder: (context, index) {
              final conversation = filteredConversations[index];
              return _ConversationCard(
                conversation: conversation,
                ttsService: ttsService,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DailyConversationDetailScreen(
                        conversation: conversation,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final DailyConversation conversation;
  final dynamic ttsService;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.conversation,
    required this.ttsService,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: FloatingCard(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部标签栏
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(conversation.category).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getCategoryColor(conversation.category),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getCategoryName(conversation.category),
                        style: TextStyle(
                          color: _getCategoryColor(conversation.category),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        conversation.level.toUpperCase(),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (conversation.isPopular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange, width: 1),
                        ),
                        child: const Text(
                          '🔥 热门',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      conversation.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 标题和描述
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conversation.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: OpenAITheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            conversation.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 场景描述
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          conversation.scenario,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 底部信息
                Row(
                  children: [
                    Icon(
                      Icons.chat_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${conversation.messages.length} 句对话',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.bookmark_outline,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${conversation.vocabulary.length} 个词汇',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'restaurant':
        return Colors.red;
      case 'shopping':
        return Colors.blue;
      case 'family':
        return Colors.green;
      case 'travel':
        return Colors.purple;
      case 'reading':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'restaurant':
        return '餐厅';
      case 'shopping':
        return '购物';
      case 'family':
        return '家庭';
      case 'travel':
        return '旅行';
      case 'reading':
        return '阅读';
      default:
        return '其他';
    }
  }
}