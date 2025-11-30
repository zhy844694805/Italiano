import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/phrase.dart';
import '../../shared/providers/phrase_provider.dart';
import '../../shared/providers/tts_provider.dart';
import '../../core/theme/modern_theme.dart';
import '../../shared/widgets/gradient_card.dart';

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
    final ttsService = ref.watch(ttsServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '意大利语口语 🇮🇹',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ModernTheme.primaryColor,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ModernTheme.primaryColor,
          labelColor: ModernTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(
              icon: Icon(Icons.star, color: Colors.orange),
              text: '夸人',
            ),
            Tab(
              icon: Icon(Icons.warning, color: Colors.red),
              text: '骂人',
            ),
            Tab(
              icon: Icon(Icons.chat, color: Colors.blue),
              text: '日常',
            ),
            Tab(
              icon: Icon(Icons.local_fire_department, color: Colors.purple),
              text: '热门',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPhraseList(complimentPhrases, '夸人用语', ttsService),
          _buildPhraseList(insultPhrases, '骂人用语', ttsService),
          _buildPhraseList(casualPhrases, '日常用语', ttsService),
          _buildPhraseList(
            complimentPhrases +
            insultPhrases +
            casualPhrases,
            '热门用语',
            ttsService,
            isPopular: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPhraseList(List<ItalianPhrase> phrases, String title, ttsService, {bool isPopular = false}) {
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
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '正在加载...',
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
        // 统计信息卡片
        Container(
          margin: const EdgeInsets.all(16),
          child: FloatingCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: isPopular ? ModernTheme.primaryGradient :
                        title.contains('夸人') ? ModernTheme.accentGradient :
                        title.contains('骂人') ? ModernTheme.redGradient :
                        ModernTheme.secondaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      title.contains('夸人') ? Icons.favorite :
                      title.contains('骂人') ? Icons.warning :
                      title.contains('日常') ? Icons.chat :
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${displayPhrases.length} 条实用表达',
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
            ),
          ),
        ),

        // 短语列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayPhrases.length,
            itemBuilder: (context, index) {
              final phrase = displayPhrases[index];
              return _PhraseCard(phrase: phrase, ttsService: ttsService);
            },
          ),
        ),
      ],
    );
  }
}

class _PhraseCard extends StatelessWidget {
  final ItalianPhrase phrase;
  final dynamic ttsService;

  const _PhraseCard({
    required this.phrase,
    required this.ttsService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: FloatingCard(
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
                      color: _getCategoryColor(phrase.category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getCategoryColor(phrase.category),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getCategoryName(phrase.category),
                      style: TextStyle(
                        color: _getCategoryColor(phrase.category),
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
                      phrase.level.toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (phrase.isPopular) ...[
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
                  // TTS播放按钮
                  GestureDetector(
                    onTap: () async {
                      try {
                        await ttsService.speak(phrase.italian);
                      } catch (e) {
                        print('TTS播放失败: $e');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ModernTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.volume_up,
                        color: ModernTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 意大利语和emoji
              Row(
                children: [
                  Expanded(
                    child: Text(
                      phrase.italian,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ModernTheme.textDark,
                      ),
                    ),
                  ),
                  if (phrase.emoji != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      phrase.emoji!,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 4),

              // 音标标注
              Text(
                phrase.phonetic,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 8),

              // 中文翻译
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  phrase.chinese,
                  style: const TextStyle(
                    fontSize: 16,
                    color: ModernTheme.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 使用场景
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      phrase.context,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'compliment':
        return Colors.orange;
      case 'insult':
        return Colors.red;
      case 'casual':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'compliment':
        return '夸人';
      case 'insult':
        return '骂人';
      case 'casual':
        return '日常';
      default:
        return '其他';
    }
  }
}