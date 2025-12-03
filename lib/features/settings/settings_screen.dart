import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/voice_preference_provider.dart';
import '../../core/services/tts_service.dart';
import '../../core/theme/openai_theme.dart';

/// Settings screen for app preferences
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // 应用版本号
  static const String appVersion = '1.0.3';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedVoice = ref.watch(voicePreferenceProvider);
    final voiceNotifier = ref.read(voicePreferenceProvider.notifier);

    return Scaffold(
      backgroundColor: OpenAITheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: OpenAITheme.bgPrimary,
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 语音设置
          const Text(
            '语音设置',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: OpenAITheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.record_voice_over,
                iconColor: OpenAITheme.openaiGreen,
                title: 'TTS 语音',
                subtitle: voiceNotifier.getVoiceName(selectedVoice),
                onTap: () => _showVoiceSelectionDialog(context, ref, selectedVoice),
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.play_circle_outline,
                iconColor: OpenAITheme.info,
                title: '试听语音',
                subtitle: '测试当前选择的语音效果',
                onTap: () async {
                  final ttsService = TTSService.instance;
                  await ttsService.speak(
                    'Ciao! Sono la voce italiana.',
                    voice: selectedVoice,
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 关于
          const Text(
            '关于',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: OpenAITheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                iconColor: OpenAITheme.textTertiary,
                title: '应用版本',
                subtitle: 'v$appVersion',
                showArrow: false,
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.help_outline,
                iconColor: OpenAITheme.warning,
                title: '使用说明',
                subtitle: '学习指南与使用技巧',
                onTap: () => _showUserGuide(context),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showVoiceSelectionDialog(BuildContext context, WidgetRef ref, String currentVoice) {
    final voiceNotifier = ref.read(voicePreferenceProvider.notifier);
    final ttsService = TTSService.instance;

    showModalBottomSheet(
      context: context,
      backgroundColor: OpenAITheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '选择语音',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: OpenAITheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // Sara 语音
              _VoiceOption(
                name: 'Sara（女声）',
                description: '温柔清晰的女性声音',
                isSelected: currentVoice == TTSService.voiceSara,
                onTap: () async {
                  await voiceNotifier.setVoice(TTSService.voiceSara);
                  await ttsService.speak('Ciao! Sono Sara.', voice: TTSService.voiceSara);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),

              // Nicola 语音
              _VoiceOption(
                name: 'Nicola（男声）',
                description: '稳重有力的男性声音',
                isSelected: currentVoice == TTSService.voiceNicola,
                onTap: () async {
                  await voiceNotifier.setVoice(TTSService.voiceNicola);
                  await ttsService.speak('Ciao! Sono Nicola.', voice: TTSService.voiceNicola);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserGuide(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserGuideScreen(),
      ),
    );
  }
}

// 设置卡片
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OpenAITheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OpenAITheme.borderLight),
      ),
      child: Column(children: children),
    );
  }
}

// 设置项
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool showArrow;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: OpenAITheme.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: OpenAITheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (showArrow && onTap != null)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: OpenAITheme.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// 语音选项
class _VoiceOption extends StatelessWidget {
  final String name;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _VoiceOption({
    required this.name,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? OpenAITheme.openaiGreen.withValues(alpha: 0.1)
                : OpenAITheme.bgSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? OpenAITheme.openaiGreen : OpenAITheme.borderLight,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? OpenAITheme.openaiGreen
                      : OpenAITheme.gray100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: isSelected ? Colors.white : OpenAITheme.textTertiary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? OpenAITheme.openaiGreen
                            : OpenAITheme.textPrimary,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: OpenAITheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: OpenAITheme.openaiGreen,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// 使用说明页面
class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OpenAITheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: OpenAITheme.bgPrimary,
        title: const Text('使用说明'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 概述
          _GuideSection(
            icon: Icons.school,
            title: '关于应用',
            content: '这是一款专为零基础学习者设计的意大利语学习应用，'
                '采用科学的间隔重复算法，帮助您高效记忆单词和语法。'
                '完成全部内容后，您将达到 CEFR A2 水平。',
          ),

          const SizedBox(height: 16),

          // 学习新词
          _GuideSection(
            icon: Icons.add_circle_outline,
            title: '学习新词',
            content: '点击首页的"学习新词"开始学习。\n\n'
                '• 点击卡片可以翻转查看释义\n'
                '• 向右滑动表示"认识"\n'
                '• 向左滑动表示"不认识"\n'
                '• 点击喇叭图标可以听发音',
          ),

          const SizedBox(height: 16),

          // 复习单词
          _GuideSection(
            icon: Icons.refresh,
            title: '复习单词',
            content: '系统会根据间隔重复算法自动安排复习。\n\n'
                '• 首页会显示待复习单词数量\n'
                '• 答对的单词会延长复习间隔\n'
                '• 答错的单词会在1小时后再次出现\n'
                '• 坚持复习是记忆的关键！',
          ),

          const SizedBox(height: 16),

          // 语法学习
          _GuideSection(
            icon: Icons.menu_book,
            title: '语法学习',
            content: '应用包含14个核心语法点，覆盖A1-A2全部内容。\n\n'
                '• 每个语法点包含规则讲解\n'
                '• 配有中意对照例句\n'
                '• 提供10道练习题巩固\n'
                '• 完成练习后标记为已学习',
          ),

          const SizedBox(height: 16),

          // AI对话
          _GuideSection(
            icon: Icons.chat_bubble_outline,
            title: 'AI 对话',
            content: '与AI进行意大利语对话练习。\n\n'
                '• 选择场景开始对话（餐厅、机场等）\n'
                '• AI会根据您的水平调整难度\n'
                '• 语法错误会被自动标出并解释\n'
                '• 需要配置 DeepSeek API 密钥',
          ),

          const SizedBox(height: 16),

          // 学习建议
          _GuideSection(
            icon: Icons.lightbulb_outline,
            title: '学习建议',
            content: '• 每天坚持学习30分钟效果最佳\n'
                '• 新词每天学习20-30个为宜\n'
                '• 一定要按时复习，不要堆积\n'
                '• 听发音跟读，训练口语\n'
                '• 学完语法后多做练习题\n'
                '• 预计9-18个月达到A2水平',
          ),

          const SizedBox(height: 16),

          // 快捷键说明
          _GuideSection(
            icon: Icons.touch_app,
            title: '手势操作',
            content: '• 卡片点击：翻转查看释义\n'
                '• 左滑：不认识/答错\n'
                '• 右滑：认识/答对\n'
                '• 下拉：刷新页面数据\n'
                '• 长按单词：查看详细信息',
          ),

          const SizedBox(height: 40),

          // 底部信息
          Center(
            child: Column(
              children: [
                const Text(
                  '祝您学习愉快！',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: OpenAITheme.openaiGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Buona fortuna! 🇮🇹',
                  style: TextStyle(
                    fontSize: 14,
                    color: OpenAITheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// 指南章节
class _GuideSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _GuideSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OpenAITheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OpenAITheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: OpenAITheme.openaiGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: OpenAITheme.openaiGreen,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: OpenAITheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: OpenAITheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
