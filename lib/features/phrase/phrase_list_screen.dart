import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/phrase.dart';
import '../../shared/providers/phrase_provider.dart';
import '../../core/theme/openai_theme.dart';
import '../../core/utils/api_check_helper.dart';

class PhraseListScreen extends ConsumerStatefulWidget {
  const PhraseListScreen({super.key});

  @override
  ConsumerState<PhraseListScreen> createState() => _PhraseListScreenState();
}

class _PhraseListScreenState extends ConsumerState<PhraseListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final complimentPhrases = ref.watch(complimentPhrasesProvider);
    final insultPhrases = ref.watch(insultPhrasesProvider);
    final casualPhrases = ref.watch(casualPhrasesProvider);

    return Scaffold(
      backgroundColor: OpenAITheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: OpenAITheme.bgPrimary,
        title: const Text('意大利语口语'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: OpenAITheme.openaiGreen,
          indicatorWeight: 2,
          labelColor: OpenAITheme.openaiGreen,
          unselectedLabelColor: OpenAITheme.textTertiary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(text: '夸人'),
            Tab(text: '骂人'),
            Tab(text: '日常'),
            Tab(text: '热门'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPhraseList(complimentPhrases, '夸人用语', Icons.favorite_outline),
          _buildPhraseList(insultPhrases, '骂人用语', Icons.sentiment_dissatisfied_outlined),
          _buildPhraseList(casualPhrases, '日常用语', Icons.chat_bubble_outline),
          _buildPhraseList(
            complimentPhrases + insultPhrases + casualPhrases,
            '热门用语',
            Icons.local_fire_department_outlined,
            isPopular: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPhraseList(
    List<ItalianPhrase> phrases,
    String title,
    IconData icon, {
    bool isPopular = false,
  }) {
    final displayPhrases = isPopular
        ? phrases.where((p) => p.isPopular).toList()
        : phrases;

    if (displayPhrases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 48,
              color: OpenAITheme.textTertiary,
            ),
            const SizedBox(height: 12),
            const Text(
              '正在加载...',
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
        // OpenAI 风格统计信息卡片
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: OpenAITheme.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: OpenAITheme.borderLight),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: OpenAITheme.openaiGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: OpenAITheme.openaiGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: OpenAITheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${displayPhrases.length} 条实用表达',
                      style: const TextStyle(
                        fontSize: 13,
                        color: OpenAITheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 短语列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayPhrases.length,
            itemBuilder: (context, index) {
              final phrase = displayPhrases[index];
              return _PhraseCard(phrase: phrase);
            },
          ),
        ),
      ],
    );
  }
}

class _PhraseCard extends StatelessWidget {
  final ItalianPhrase phrase;

  const _PhraseCard({
    required this.phrase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  phrase.level.toUpperCase(),
                  style: const TextStyle(
                    color: OpenAITheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (phrase.isPopular) ...[
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
              // TTS 播放按钮 - OpenAI 风格
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await ApiCheckHelper.speakWithCheck(context, phrase.italian);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: OpenAITheme.borderLight),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.volume_up,
                      color: OpenAITheme.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 意大利语和 emoji
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  phrase.italian,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: OpenAITheme.textPrimary,
                  ),
                ),
              ),
              if (phrase.emoji != null) ...[
                const SizedBox(width: 8),
                Text(
                  phrase.emoji!,
                  style: const TextStyle(fontSize: 22),
                ),
              ],
            ],
          ),

          const SizedBox(height: 4),

          // 音标标注
          Text(
            phrase.phonetic,
            style: const TextStyle(
              fontSize: 13,
              color: OpenAITheme.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 12),

          // 中文翻译 - OpenAI 风格
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: OpenAITheme.bgSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              phrase.chinese,
              style: const TextStyle(
                fontSize: 15,
                color: OpenAITheme.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 使用场景
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: OpenAITheme.textTertiary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  phrase.context,
                  style: const TextStyle(
                    fontSize: 13,
                    color: OpenAITheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
