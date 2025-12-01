import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/voice_preference_provider.dart';
import '../../shared/providers/tts_provider.dart';
import '../../shared/providers/api_key_provider.dart';
import '../../core/services/tts_manager.dart';
import '../../core/services/model_download_service.dart';
import '../../core/theme/openai_theme.dart';
import '../../shared/widgets/openai_widgets.dart';
import '../setup/api_key_setup_screen.dart';

/// Settings screen for app preferences
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  DownloadProgress _downloadProgress = const DownloadProgress();
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final selectedVoice = ref.watch(voicePreferenceProvider);
    final voiceNotifier = ref.read(voicePreferenceProvider.notifier);
    final localModelInstalledAsync = ref.watch(localModelInstalledProvider);
    final ttsService = ref.watch(ttsServiceProvider);

    return Scaffold(
      backgroundColor: OpenAITheme.white,
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: OpenAITheme.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // TTS 模型状态
          const OSectionHeader(title: '语音引擎'),
          localModelInstalledAsync.when(
            data: (isInstalled) => OCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isInstalled ? OpenAITheme.greenLight : OpenAITheme.gray100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isInstalled ? Icons.check_circle : Icons.warning_amber_rounded,
                          color: isInstalled ? OpenAITheme.green : OpenAITheme.gray500,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isInstalled ? '本地模型已安装' : '本地模型未安装',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isInstalled ? OpenAITheme.gray900 : OpenAITheme.gray600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isInstalled ? '无需网络即可播放语音' : '需要下载模型才能使用语音功能',
                              style: const TextStyle(
                                fontSize: 13,
                                color: OpenAITheme.gray500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 下载进度
                  if (_isDownloading) ...[
                    const SizedBox(height: 16),
                    const ODivider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: OpenAITheme.gray900,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '正在下载 ${_downloadProgress.currentFile ?? ''}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: OpenAITheme.gray700,
                                ),
                              ),
                              Text(
                                _downloadProgress.progressText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: OpenAITheme.gray500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _cancelDownload,
                          child: const Text(
                            '取消',
                            style: TextStyle(
                              fontSize: 13,
                              color: OpenAITheme.gray500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OProgressBar(
                      progress: _downloadProgress.progress,
                      height: 4,
                    ),
                  ],

                  // 下载失败
                  if (_downloadProgress.status == DownloadStatus.failed) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: OpenAITheme.redLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: OpenAITheme.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _downloadProgress.error ?? '下载失败',
                              style: TextStyle(
                                fontSize: 13,
                                color: OpenAITheme.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 下载/重新下载按钮
                  if (!_isDownloading) ...[
                    const SizedBox(height: 16),
                    if (!isInstalled || _downloadProgress.status == DownloadStatus.failed)
                      OButton(
                        text: isInstalled ? '重新下载模型' : '下载语音模型',
                        icon: Icons.download,
                        onPressed: _startDownload,
                        fullWidth: true,
                      )
                    else ...[
                      const ODivider(),
                      const SizedBox(height: 12),
                      const _InfoRow(label: '模型文件', value: 'kokoro-v1.0.onnx'),
                      const SizedBox(height: 8),
                      const _InfoRow(label: '模型大小', value: '~330MB'),
                    ],
                  ],
                ],
              ),
            ),
            loading: () => OCard(
              padding: const EdgeInsets.all(20),
              child: const Center(
                child: CircularProgressIndicator(color: OpenAITheme.gray900),
              ),
            ),
            error: (_, __) => OCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.error_outline, color: OpenAITheme.gray500),
                      SizedBox(width: 12),
                      Text(
                        '检查模型状态失败',
                        style: TextStyle(color: OpenAITheme.gray500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OButton(
                    text: '下载语音模型',
                    icon: Icons.download,
                    onPressed: _startDownload,
                    fullWidth: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 语音选择
          const OSectionHeader(title: '语音选择'),
          OCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _VoiceOption(
                  title: 'Sara（女声）',
                  subtitle: '温柔清晰的女性声音',
                  isSelected: selectedVoice == TTSService.voiceSara,
                  onTap: () async {
                    await voiceNotifier.setVoice(TTSService.voiceSara);
                  },
                ),
                const ODivider(indent: 16),
                _VoiceOption(
                  title: 'Nicola（男声）',
                  subtitle: '稳重有力的男性声音',
                  isSelected: selectedVoice == TTSService.voiceNicola,
                  onTap: () async {
                    await voiceNotifier.setVoice(TTSService.voiceNicola);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 试听按钮
          localModelInstalledAsync.when(
            data: (isInstalled) => OButton(
              text: '试听当前语音',
              icon: Icons.play_arrow,
              onPressed: isInstalled
                  ? () async {
                      final success = await ttsService.speak(
                        'Ciao! Sono la voce italiana.',
                        voice: selectedVoice,
                      );
                      if (!success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ttsService.initError ?? '播放失败'),
                            backgroundColor: OpenAITheme.gray900,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        );
                      }
                    }
                  : null,
            ),
            loading: () => const OButton(
              text: '试听当前语音',
              icon: Icons.play_arrow,
              onPressed: null,
            ),
            error: (_, __) => const OButton(
              text: '试听当前语音',
              icon: Icons.play_arrow,
              onPressed: null,
            ),
          ),

          const SizedBox(height: 24),

          // 缓存管理
          const OSectionHeader(title: '缓存管理'),
          OCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                OListTile(
                  leading: Icons.cleaning_services_outlined,
                  title: '清除语音缓存',
                  subtitle: '删除已缓存的语音文件',
                  onTap: () async {
                    await ttsService.clearCache();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('缓存已清除'),
                          backgroundColor: OpenAITheme.gray900,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    }
                  },
                ),
                const ODivider(indent: 50),
                OListTile(
                  leading: Icons.delete_outline,
                  title: '删除语音模型',
                  subtitle: '删除已下载的模型文件',
                  onTap: () => _showDeleteModelDialog(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // AI 对话设置
          const OSectionHeader(title: 'AI 对话'),
          _buildApiKeySection(),

          const SizedBox(height: 24),

          // 关于
          const OSectionHeader(title: '关于'),
          OCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                const OListTile(
                  leading: Icons.info_outline,
                  title: '应用版本',
                  subtitle: 'v1.0.0',
                ),
                const ODivider(indent: 50),
                OListTile(
                  leading: Icons.description_outlined,
                  title: '使用说明',
                  subtitle: '点击查看学习指南',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('使用说明功能即将推出'),
                        backgroundColor: OpenAITheme.gray900,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = const DownloadProgress(status: DownloadStatus.downloading);
    });

    await ModelDownloadService.instance.downloadModels(
      onProgress: (progress) {
        setState(() {
          _downloadProgress = progress;
        });

        if (progress.status == DownloadStatus.completed) {
          _onDownloadComplete();
        } else if (progress.status == DownloadStatus.failed) {
          setState(() {
            _isDownloading = false;
          });
        }
      },
    );
  }

  void _cancelDownload() {
    ModelDownloadService.instance.cancelDownload();
    setState(() {
      _isDownloading = false;
      _downloadProgress = const DownloadProgress();
    });
  }

  Future<void> _onDownloadComplete() async {
    setState(() {
      _isDownloading = false;
    });

    // 初始化 TTS
    await TTSService.instance.initialize();

    // 刷新状态
    ref.invalidate(localModelInstalledProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('语音模型下载完成！'),
          backgroundColor: OpenAITheme.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showDeleteModelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: OpenAITheme.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '删除语音模型',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: OpenAITheme.gray900,
          ),
        ),
        content: const Text(
          '删除后将无法使用语音功能，确定要删除吗？',
          style: TextStyle(
            fontSize: 14,
            color: OpenAITheme.gray600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '取消',
              style: TextStyle(color: OpenAITheme.gray500),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ModelDownloadService.instance.deleteModels();
              ref.invalidate(localModelInstalledProvider);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('语音模型已删除'),
                    backgroundColor: OpenAITheme.gray900,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              }
            },
            child: Text(
              '删除',
              style: TextStyle(
                color: OpenAITheme.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeySection() {
    final apiKey = ref.watch(apiKeyProvider);
    final isConfigured = apiKey != null && apiKey.isNotEmpty;

    return OCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isConfigured ? OpenAITheme.greenLight : OpenAITheme.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isConfigured ? Icons.check_circle : Icons.key,
                  color: isConfigured ? OpenAITheme.green : OpenAITheme.gray500,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DeepSeek API Key',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isConfigured ? OpenAITheme.gray900 : OpenAITheme.gray600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isConfigured
                          ? 'sk-****${apiKey!.substring(apiKey.length - 4)}'
                          : '未配置，AI 对话功能不可用',
                      style: const TextStyle(
                        fontSize: 13,
                        color: OpenAITheme.gray500,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OButton(
                  text: isConfigured ? '修改 API Key' : '配置 API Key',
                  icon: isConfigured ? Icons.edit : Icons.add,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ApiKeySetupScreen(
                          onComplete: () => Navigator.pop(context),
                          isInitialSetup: false,
                        ),
                      ),
                    );
                  },
                  fullWidth: true,
                ),
              ),
              if (isConfigured) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _showDeleteApiKeyDialog(),
                  icon: Icon(Icons.delete_outline, color: OpenAITheme.red),
                  style: IconButton.styleFrom(
                    backgroundColor: OpenAITheme.redLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteApiKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: OpenAITheme.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '删除 API Key',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: OpenAITheme.gray900,
          ),
        ),
        content: const Text(
          '删除后 AI 对话功能将不可用，确定要删除吗？',
          style: TextStyle(
            fontSize: 14,
            color: OpenAITheme.gray600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '取消',
              style: TextStyle(color: OpenAITheme.gray500),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(apiKeyProvider.notifier).clearApiKey();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('API Key 已删除'),
                    backgroundColor: OpenAITheme.gray900,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              }
            },
            child: Text(
              '删除',
              style: TextStyle(
                color: OpenAITheme.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _VoiceOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? OpenAITheme.gray900 : OpenAITheme.gray300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: OpenAITheme.gray900,
                        ),
                      ),
                    )
                  : null,
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
                      color: OpenAITheme.gray900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: OpenAITheme.gray500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: OpenAITheme.gray500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: OpenAITheme.gray700,
          ),
        ),
      ],
    );
  }
}
