import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/voice_preference_provider.dart';
import '../../core/services/tts_service.dart';
import '../demo/ui_showcase_screen.dart';

/// Settings screen for app preferences
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedVoice = ref.watch(voicePreferenceProvider);
    final voiceNotifier = ref.read(voicePreferenceProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // TTS Settings Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '语音设置',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.record_voice_over),
            title: const Text('TTS 语音'),
            subtitle: Text(voiceNotifier.getVoiceName(selectedVoice)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showVoiceSelectionDialog(context, ref, selectedVoice);
            },
          ),
          const Divider(),

          // Test TTS Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                final ttsService = TTSService.instance;
                await ttsService.speak(
                  'Ciao! Sono la voce italiana.',
                  voice: selectedVoice,
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('试听当前语音'),
            ),
          ),

          const SizedBox(height: 16),

          // About Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '关于',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('应用版本'),
            subtitle: const Text('v1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('新UI预览'),
            subtitle: const Text('查看现代化界面组件'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UIShowcaseScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('使用说明'),
            subtitle: const Text('点击查看学习指南'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 打开使用说明页面
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('使用说明功能即将推出')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showVoiceSelectionDialog(BuildContext context, WidgetRef ref, String currentVoice) {
    final voiceNotifier = ref.read(voicePreferenceProvider.notifier);
    final ttsService = TTSService.instance;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语音'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Sara（女声）'),
              subtitle: const Text('温柔清晰的女性声音'),
              value: TTSService.voiceSara,
              groupValue: currentVoice,
              onChanged: (value) async {
                if (value != null) {
                  await voiceNotifier.setVoice(value);
                  // Play sample
                  await ttsService.speak('Ciao! Sono Sara.', voice: value);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Nicola（男声）'),
              subtitle: const Text('稳重有力的男性声音'),
              value: TTSService.voiceNicola,
              groupValue: currentVoice,
              onChanged: (value) async {
                if (value != null) {
                  await voiceNotifier.setVoice(value);
                  // Play sample
                  await ttsService.speak('Ciao! Sono Nicola.', voice: value);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
