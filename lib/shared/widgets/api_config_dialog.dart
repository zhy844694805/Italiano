import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/openai_theme.dart';
import '../../core/config/api_config.dart';

/// API 配置类型
enum ApiConfigType {
  deepSeek,
  tts,
  both,
}

/// API 配置弹窗
/// 用于在 API 未配置时提示用户输入
class ApiConfigDialog extends StatefulWidget {
  final ApiConfigType configType;
  final String? title;
  final String? description;

  const ApiConfigDialog({
    super.key,
    required this.configType,
    this.title,
    this.description,
  });

  /// 显示 API 配置弹窗
  /// 返回 true 表示配置成功
  static Future<bool> show(
    BuildContext context, {
    required ApiConfigType configType,
    String? title,
    String? description,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ApiConfigDialog(
        configType: configType,
        title: title,
        description: description,
      ),
    );
    return result ?? false;
  }

  /// 检查并提示配置 TTS API
  /// 如果已配置返回 true，否则显示配置弹窗
  static Future<bool> checkAndConfigureTts(BuildContext context) async {
    final isConfigured = await ApiConfig.isTtsConfigured();
    if (isConfigured) return true;

    if (!context.mounted) return false;
    return await show(
      context,
      configType: ApiConfigType.tts,
      title: '语音播报需要配置',
      description: '请配置 TTS API 密钥以使用语音播报功能',
    );
  }

  /// 检查并提示配置 DeepSeek API
  /// 如果已配置返回 true，否则显示配置弹窗
  static Future<bool> checkAndConfigureDeepSeek(BuildContext context) async {
    final isConfigured = await ApiConfig.isDeepSeekConfigured();
    if (isConfigured) return true;

    if (!context.mounted) return false;
    return await show(
      context,
      configType: ApiConfigType.deepSeek,
      title: 'AI 对话需要配置',
      description: '请配置 DeepSeek API 密钥以使用 AI 对话功能',
    );
  }

  @override
  State<ApiConfigDialog> createState() => _ApiConfigDialogState();
}

class _ApiConfigDialogState extends State<ApiConfigDialog> {
  final _deepSeekController = TextEditingController();
  final _ttsController = TextEditingController();
  bool _isLoading = false;
  bool _obscureDeepSeek = true;
  bool _obscureTts = true;

  bool get _needsDeepSeek =>
      widget.configType == ApiConfigType.deepSeek ||
      widget.configType == ApiConfigType.both;

  bool get _needsTts =>
      widget.configType == ApiConfigType.tts ||
      widget.configType == ApiConfigType.both;

  @override
  void initState() {
    super.initState();
    _loadExistingKeys();
  }

  Future<void> _loadExistingKeys() async {
    if (_needsDeepSeek) {
      final key = await ApiConfig.getDeepSeekApiKey();
      if (key.isNotEmpty) {
        _deepSeekController.text = key;
      }
    }
    if (_needsTts) {
      final key = await ApiConfig.getTtsApiKey();
      if (key.isNotEmpty) {
        _ttsController.text = key;
      }
    }
  }

  @override
  void dispose() {
    _deepSeekController.dispose();
    _ttsController.dispose();
    super.dispose();
  }

  String get _defaultTitle {
    switch (widget.configType) {
      case ApiConfigType.deepSeek:
        return '配置 DeepSeek API';
      case ApiConfigType.tts:
        return '配置语音 API';
      case ApiConfigType.both:
        return '配置 API 密钥';
    }
  }

  String get _defaultDescription {
    switch (widget.configType) {
      case ApiConfigType.deepSeek:
        return '请输入 DeepSeek API 密钥以使用 AI 对话功能';
      case ApiConfigType.tts:
        return '请输入 TTS API 密钥以使用语音播报功能';
      case ApiConfigType.both:
        return '请配置以下 API 密钥以启用完整功能';
    }
  }

  Future<void> _saveAndClose() async {
    // 验证输入
    if (_needsDeepSeek && _deepSeekController.text.trim().isEmpty) {
      _showError('请输入 DeepSeek API 密钥');
      return;
    }
    if (_needsTts && _ttsController.text.trim().isEmpty) {
      _showError('请输入 TTS API 密钥');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_needsDeepSeek) {
        await ApiConfig.setDeepSeekApiKey(_deepSeekController.text.trim());
      }
      if (_needsTts) {
        await ApiConfig.setTtsApiKey(_ttsController.text.trim());
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showError('保存失败: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: OpenAITheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: OpenAITheme.openaiGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.key,
                    color: OpenAITheme.openaiGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.title ?? _defaultTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: OpenAITheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 描述
            Text(
              widget.description ?? _defaultDescription,
              style: const TextStyle(
                fontSize: 14,
                color: OpenAITheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // DeepSeek API 输入
            if (_needsDeepSeek) ...[
              _buildApiInput(
                label: 'DeepSeek API 密钥',
                hint: 'sk-...',
                controller: _deepSeekController,
                obscure: _obscureDeepSeek,
                onToggleObscure: () =>
                    setState(() => _obscureDeepSeek = !_obscureDeepSeek),
                helpUrl: 'https://platform.deepseek.com/api_keys',
              ),
              const SizedBox(height: 16),
            ],

            // TTS API 输入
            if (_needsTts) ...[
              _buildApiInput(
                label: 'TTS API 密钥',
                hint: 'sk-...',
                controller: _ttsController,
                obscure: _obscureTts,
                onToggleObscure: () =>
                    setState(() => _obscureTts = !_obscureTts),
                helpUrl: null,
              ),
              const SizedBox(height: 24),
            ],

            // 按钮
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('稍后配置'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAndClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OpenAITheme.openaiGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('保存'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggleObscure,
    String? helpUrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: OpenAITheme.textPrimary,
              ),
            ),
            if (helpUrl != null) ...[
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: helpUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('获取地址已复制到剪贴板'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(
                  '如何获取？',
                  style: TextStyle(
                    fontSize: 12,
                    color: OpenAITheme.openaiGreen,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: OpenAITheme.textTertiary),
            filled: true,
            fillColor: OpenAITheme.bgSecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: OpenAITheme.openaiGreen,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: OpenAITheme.textTertiary,
                size: 20,
              ),
              onPressed: onToggleObscure,
            ),
          ),
        ),
      ],
    );
  }
}
