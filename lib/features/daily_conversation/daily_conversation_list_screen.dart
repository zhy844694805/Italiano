import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/daily_conversation.dart';
import '../../shared/providers/daily_conversation_provider.dart';
import '../../shared/providers/tts_provider.dart';
import '../../core/theme/openai_theme.dart';
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
    final ttsService = ref.watch(ttsServiceProvider);

    return Scaffold(
      backgroundColor: OpenAITheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: OpenAITheme.bgPrimary,
        title: const Text('日常对话'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: OpenAITheme.openaiGreen,
          indicatorWeight: 2,
          labelColor: OpenAITheme.openaiGreen,
          unselectedLabelColor: OpenAITheme.textTertiary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(text: '热门'),
            Tab(text: '餐厅'),
            Tab(text: '购物'),
            Tab(text: '家庭'),
            Tab(text: '阅读'),
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

  Widget _buildConversationList(dynamic ttsService, {bool? isPopular, String? category}) {
    final conversationsAsync = ref.watch(dailyConversationProvider);

    if (conversationsAsync is AsyncLoading) {
      return const Center(
        child: CircularProgressIndicator(color: OpenAITheme.openaiGreen),
      );
    }

    if (conversationsAsync is AsyncError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: OpenAITheme.textTertiary,
            ),
            const SizedBox(height: 12),
            const Text(
              '加载对话失败',
              style: TextStyle(
                fontSize: 16,
                color: OpenAITheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ref.read(dailyConversationProvider.notifier).reloadConversations();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: OpenAITheme.borderLight),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '重试',
                    style: TextStyle(
                      color: OpenAITheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
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
          children: const [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: OpenAITheme.textTertiary,
            ),
            SizedBox(height: 12),
            Text(
              '暂无对话',
              style: TextStyle(
                fontSize: 16,
                color: OpenAITheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // OpenAI 风格搜索栏
        Container(
          margin: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索对话...',
              hintStyle: const TextStyle(color: OpenAITheme.textTertiary),
              prefixIcon: const Icon(Icons.search, color: OpenAITheme.textTertiary),
              filled: true,
              fillColor: OpenAITheme.bgSecondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: OpenAITheme.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: OpenAITheme.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: OpenAITheme.openaiGreen),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部标签栏 - OpenAI 风格
                Row(
                  children: [
                    // 级别标签
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: OpenAITheme.bgSecondary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        conversation.level.toUpperCase(),
                        style: const TextStyle(
                          color: OpenAITheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (conversation.isPopular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: OpenAITheme.openaiGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '热门',
                          style: TextStyle(
                            color: OpenAITheme.openaiGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      conversation.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // 标题
                Text(
                  conversation.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: OpenAITheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                // 描述
                Text(
                  conversation.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: OpenAITheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 12),

                // 场景描述 - OpenAI 风格
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: OpenAITheme.bgSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: OpenAITheme.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          conversation.scenario,
                          style: const TextStyle(
                            fontSize: 13,
                            color: OpenAITheme.textSecondary,
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
                    const Icon(
                      Icons.chat_outlined,
                      size: 15,
                      color: OpenAITheme.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${conversation.messages.length} 句对话',
                      style: const TextStyle(
                        fontSize: 13,
                        color: OpenAITheme.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.bookmark_outline,
                      size: 15,
                      color: OpenAITheme.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${conversation.vocabulary.length} 个词汇',
                      style: const TextStyle(
                        fontSize: 13,
                        color: OpenAITheme.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: OpenAITheme.textTertiary,
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
}
