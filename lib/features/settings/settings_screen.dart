import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/voice_preference_provider.dart';
import '../../core/services/tts_service.dart';
import '../../core/theme/openai_theme.dart';
import '../../core/config/api_config.dart';
import '../../core/utils/api_check_helper.dart';

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
                  await ApiCheckHelper.speakWithCheck(
                    context,
                    'Ciao! Sono la voce italiana.',
                    voice: selectedVoice,
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // API 配置
          const Text(
            'API 配置',
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
                icon: Icons.key,
                iconColor: OpenAITheme.warning,
                title: 'TTS API 密钥',
                subtitle: '配置语音合成服务',
                onTap: () => _showApiKeyDialog(context, 'TTS'),
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.smart_toy,
                iconColor: OpenAITheme.info,
                title: 'DeepSeek API 密钥',
                subtitle: '配置 AI 对话服务',
                onTap: () => _showApiKeyDialog(context, 'DeepSeek'),
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.help_outline,
                iconColor: OpenAITheme.textTertiary,
                title: '如何获取 API 密钥',
                subtitle: '查看详细指南',
                onTap: () => _showApiGuide(context),
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

    showModalBottomSheet(
      context: context,
      backgroundColor: OpenAITheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
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
                  await ApiCheckHelper.speakWithCheck(
                    sheetContext,
                    'Ciao! Sono Sara.',
                    voice: TTSService.voiceSara,
                  );
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
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
                  await ApiCheckHelper.speakWithCheck(
                    sheetContext,
                    'Ciao! Sono Nicola.',
                    voice: TTSService.voiceNicola,
                  );
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
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

  void _showApiKeyDialog(BuildContext context, String type) {
    final controller = TextEditingController();
    final isDeepSeek = type == 'DeepSeek';

    // 加载当前密钥
    Future<String> loadKey() async {
      if (isDeepSeek) {
        return await ApiConfig.getDeepSeekApiKey();
      } else {
        return await ApiConfig.getTtsApiKey();
      }
    }

    loadKey().then((currentKey) {
      if (!context.mounted) return;

      if (currentKey.isNotEmpty && currentKey.length >= 8) {
        // 显示部分密钥
        controller.text = '${currentKey.substring(0, 8)}...';
      }

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('配置 $type API 密钥'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isDeepSeek
                    ? '请输入您的 DeepSeek API 密钥，用于 AI 对话功能。'
                    : '请输入您的 TTS API 密钥，用于语音合成功能。',
                style: const TextStyle(
                  fontSize: 14,
                  color: OpenAITheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: isDeepSeek ? 'sk-...' : '输入 API 密钥',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => controller.clear(),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              Text(
                currentKey.isEmpty ? '当前状态：未配置' : '当前状态：已配置',
                style: TextStyle(
                  fontSize: 12,
                  color: currentKey.isEmpty ? OpenAITheme.error : OpenAITheme.openaiGreen,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                final newKey = controller.text.trim();
                // 忽略占位符文本
                if (newKey.isEmpty || newKey.contains('...')) {
                  Navigator.pop(dialogContext);
                  return;
                }

                if (isDeepSeek) {
                  await ApiConfig.setDeepSeekApiKey(newKey);
                } else {
                  await ApiConfig.setTtsApiKey(newKey);
                }

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$type API 密钥已保存'),
                      backgroundColor: OpenAITheme.openaiGreen,
                    ),
                  );
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      );
    });
  }

  void _showApiGuide(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ApiGuideScreen(),
      ),
    );
  }
}

/// API 获取指南页面 - OpenAI 极简风格
class ApiGuideScreen extends StatelessWidget {
  const ApiGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OpenAITheme.white,
      appBar: AppBar(
        backgroundColor: OpenAITheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: OpenAITheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'API 配置指南',
          style: TextStyle(
            color: OpenAITheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              const Text(
                '开始使用 AI 对话',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: OpenAITheme.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '配置 DeepSeek API 密钥，解锁智能对话练习功能。',
                style: TextStyle(
                  fontSize: 16,
                  color: OpenAITheme.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // 步骤
              _buildStep(
                number: '1',
                title: '访问 DeepSeek 平台',
                description: '打开浏览器，访问 platform.deepseek.com',
                action: 'platform.deepseek.com',
              ),

              _buildStep(
                number: '2',
                title: '注册或登录',
                description: '使用邮箱注册新账号，或登录已有账号。',
              ),

              _buildStep(
                number: '3',
                title: '创建 API 密钥',
                description: '进入「API Keys」页面，点击「Create new secret key」生成密钥。',
              ),

              _buildStep(
                number: '4',
                title: '复制密钥',
                description: '密钥仅显示一次，请立即复制并妥善保存。格式为 sk-xxx...',
                isLast: true,
              ),

              const SizedBox(height: 32),

              // 提示卡片
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: OpenAITheme.bgSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 20,
                          color: OpenAITheme.warning,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '提示',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: OpenAITheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• DeepSeek 提供免费额度，足够日常学习使用\n'
                      '• API 密钥是私密信息，请勿分享给他人\n'
                      '• 密钥存储在本地设备，不会上传到服务器',
                      style: TextStyle(
                        fontSize: 14,
                        color: OpenAITheme.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // TTS 说明
              const Text(
                '关于 TTS 语音',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: OpenAITheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'TTS（文字转语音）服务使用独立的 API 密钥。如需配置，请联系开发者获取密钥信息。',
                style: TextStyle(
                  fontSize: 15,
                  color: OpenAITheme.textSecondary,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 48),

              // 底部按钮
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OpenAITheme.textPrimary,
                    foregroundColor: OpenAITheme.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '我知道了',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
    String? action,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 步骤编号
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: OpenAITheme.textPrimary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: OpenAITheme.white,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 48,
                  color: OpenAITheme.borderLight,
                ),
            ],
          ),
          const SizedBox(width: 16),
          // 步骤内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: OpenAITheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: OpenAITheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: OpenAITheme.bgSecondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      action,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'monospace',
                        color: OpenAITheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
            content: 'Ciao 是一款专为零基础学习者设计的意大利语学习应用，'
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
