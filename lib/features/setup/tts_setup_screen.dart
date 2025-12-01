import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/model_download_service.dart';
import '../../core/services/tts_manager.dart';
import '../../core/theme/openai_theme.dart';
import '../../shared/widgets/openai_widgets.dart';

/// TTS 设置完成状态 Provider
final ttsSetupCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  // 如果模型已安装，则视为设置完成
  final isInstalled = await TTSService.isModelInstalled();
  if (isInstalled) {
    await prefs.setBool('tts_setup_completed', true);
    return true;
  }
  return prefs.getBool('tts_setup_completed') ?? false;
});

/// TTS 首次设置页面
class TTSSetupScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const TTSSetupScreen({
    super.key,
    required this.onComplete,
  });

  @override
  ConsumerState<TTSSetupScreen> createState() => _TTSSetupScreenState();
}

class _TTSSetupScreenState extends ConsumerState<TTSSetupScreen> {
  DownloadProgress _progress = const DownloadProgress();
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OpenAITheme.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48, // 减去padding
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),

                    // 图标
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: OpenAITheme.gray100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.record_voice_over,
                        size: 40,
                        color: OpenAITheme.gray700,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 标题
                    const Text(
                      '语音功能设置',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: OpenAITheme.gray900,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 描述
                    const Text(
                      '下载离线语音模型，让你随时随地\n听取意大利语发音，无需网络连接',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: OpenAITheme.gray500,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 下载信息卡片
                    OCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.storage,
                            label: '模型大小',
                            value: ModelDownloadService.modelSizeText,
                          ),
                          const SizedBox(height: 12),
                          const _InfoRow(
                            icon: Icons.wifi_off,
                            label: '离线可用',
                            value: '下载后无需网络',
                          ),
                          const SizedBox(height: 12),
                          const _InfoRow(
                            icon: Icons.translate,
                            label: '支持语言',
                            value: '意大利语',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 下载进度
                    if (_isDownloading || _progress.status == DownloadStatus.downloading) ...[
                      OCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
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
                                        '正在下载 ${_progress.currentFile ?? ''}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: OpenAITheme.gray900,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _progress.progressText,
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
                                    style: TextStyle(color: OpenAITheme.gray500),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            OProgressBar(
                              progress: _progress.progress,
                              height: 6,
                            ),
                          ],
                        ),
                      ),
                    ],

                    // 下载失败提示
                    if (_progress.status == DownloadStatus.failed) ...[
                      OCard(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: OpenAITheme.redLight,
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: OpenAITheme.red, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _progress.error ?? '下载失败',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: OpenAITheme.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 32),

                    // 按钮
                    if (!_isDownloading && _progress.status != DownloadStatus.downloading) ...[
                      OButton(
                        text: _progress.status == DownloadStatus.failed ? '重新下载' : '下载语音模型',
                        icon: Icons.download,
                        onPressed: _startDownload,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 12),
                      OButtonOutlined(
                        text: '稍后设置',
                        onPressed: _skipSetup,
                        fullWidth: true,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // 提示
                    const Text(
                      '你可以随时在设置中下载语音模型',
                      style: TextStyle(
                        fontSize: 12,
                        color: OpenAITheme.gray400,
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _progress = const DownloadProgress(status: DownloadStatus.downloading);
    });

    await ModelDownloadService.instance.downloadModels(
      onProgress: (progress) {
        setState(() {
          _progress = progress;
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
      _progress = const DownloadProgress();
    });
  }

  Future<void> _onDownloadComplete() async {
    setState(() {
      _isDownloading = false;
    });

    // 标记设置完成
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tts_setup_completed', true);

    // 初始化 TTS
    await TTSService.instance.initialize();

    if (mounted) {
      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('语音模型下载完成！'),
          backgroundColor: OpenAITheme.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      widget.onComplete();
    }
  }

  Future<void> _skipSetup() async {
    // 标记设置已跳过（但未完成）
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tts_setup_completed', true);
    await prefs.setBool('tts_setup_skipped', true);

    widget.onComplete();
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: OpenAITheme.gray500),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: OpenAITheme.gray500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: OpenAITheme.gray900,
          ),
        ),
      ],
    );
  }
}
