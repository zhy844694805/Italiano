import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/openai_theme.dart';
import '../../shared/widgets/openai_widgets.dart';
import '../../shared/providers/api_key_provider.dart';

/// API Key 设置页面
class ApiKeySetupScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final bool isInitialSetup; // 是否首次设置

  const ApiKeySetupScreen({
    super.key,
    required this.onComplete,
    this.isInitialSetup = true,
  });

  @override
  ConsumerState<ApiKeySetupScreen> createState() => _ApiKeySetupScreenState();
}

class _ApiKeySetupScreenState extends ConsumerState<ApiKeySetupScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  bool _obscureText = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 如果已有 API key，加载到输入框
    final currentKey = ref.read(apiKeyProvider);
    if (currentKey != null) {
      _controller.text = currentKey;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    final apiKey = _controller.text.trim();

    // 验证格式
    if (apiKey.isEmpty) {
      setState(() {
        _errorMessage = '请输入 API Key';
      });
      return;
    }

    if (!ApiKeyNotifier.isValidFormat(apiKey)) {
      setState(() {
        _errorMessage = 'API Key 格式不正确，应以 sk- 开头';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await ref.read(apiKeyProvider.notifier).setApiKey(apiKey);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('API Key 保存成功'),
              backgroundColor: OpenAITheme.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
          widget.onComplete();
        }
      } else {
        setState(() {
          _errorMessage = '保存失败，请重试';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '保存失败: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _openDeepSeekPlatform() async {
    final uri = Uri.parse('https://platform.deepseek.com/api_keys');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('无法打开链接，请手动访问 platform.deepseek.com'),
            backgroundColor: OpenAITheme.gray900,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OpenAITheme.white,
      appBar: widget.isInitialSetup
          ? null
          : AppBar(
              title: const Text('配置 API Key'),
              backgroundColor: OpenAITheme.white,
              surfaceTintColor: Colors.transparent,
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isInitialSetup) ...[
                const SizedBox(height: 20),

                // 图标
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: OpenAITheme.gray100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      size: 40,
                      color: OpenAITheme.gray700,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 标题
                const Center(
                  child: Text(
                    'AI 对话功能设置',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: OpenAITheme.gray900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 描述
                const Center(
                  child: Text(
                    '配置 DeepSeek API Key\n开启智能对话练习功能',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: OpenAITheme.gray500,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],

              // 获取指引卡片
              OCard(
                padding: const EdgeInsets.all(16),
                backgroundColor: OpenAITheme.gray50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 20, color: OpenAITheme.gray700),
                        SizedBox(width: 8),
                        Text(
                          '如何获取 API Key',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: OpenAITheme.gray900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _StepItem(
                      number: '1',
                      text: '访问 DeepSeek 开放平台',
                    ),
                    const _StepItem(
                      number: '2',
                      text: '注册或登录账号',
                    ),
                    const _StepItem(
                      number: '3',
                      text: '进入 API Keys 页面',
                    ),
                    const _StepItem(
                      number: '4',
                      text: '点击「创建 API Key」并复制',
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _openDeepSeekPlatform,
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('打开 DeepSeek 平台'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: OpenAITheme.gray900,
                          side: const BorderSide(color: OpenAITheme.gray300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // API Key 输入
              const Text(
                'API Key',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: OpenAITheme.gray700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                obscureText: _obscureText,
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  hintText: 'sk-xxxxxxxxxxxxxxxx',
                  hintStyle: const TextStyle(
                    color: OpenAITheme.gray400,
                    fontFamily: 'monospace',
                  ),
                  filled: true,
                  fillColor: OpenAITheme.gray50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: OpenAITheme.gray900, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: OpenAITheme.red, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: OpenAITheme.gray500,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.paste, color: OpenAITheme.gray500),
                        onPressed: () async {
                          final data = await Clipboard.getData('text/plain');
                          if (data?.text != null) {
                            _controller.text = data!.text!;
                          }
                        },
                      ),
                    ],
                  ),
                ),
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                },
              ),

              // 错误信息
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    fontSize: 13,
                    color: OpenAITheme.red,
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // 安全提示
              Row(
                children: [
                  Icon(Icons.lock_outline, size: 14, color: OpenAITheme.gray400),
                  const SizedBox(width: 6),
                  Text(
                    'API Key 仅存储在本地设备，不会上传',
                    style: TextStyle(
                      fontSize: 12,
                      color: OpenAITheme.gray400,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 保存按钮
              OButton(
                text: _isLoading ? '保存中...' : '保存并继续',
                onPressed: _isLoading ? null : _saveApiKey,
                fullWidth: true,
              ),

              // 跳过按钮 (仅首次设置显示)
              if (widget.isInitialSetup) ...[
                const SizedBox(height: 12),
                OButtonOutlined(
                  text: '稍后设置',
                  onPressed: widget.onComplete,
                  fullWidth: true,
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    '你可以随时在设置中配置 API Key',
                    style: TextStyle(
                      fontSize: 12,
                      color: OpenAITheme.gray400,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // 费用说明
              OCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: OpenAITheme.gray500),
                        SizedBox(width: 8),
                        Text(
                          '关于 DeepSeek API',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: OpenAITheme.gray700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem('价格实惠', '约 0.001 元/次对话'),
                    _buildInfoItem('新用户福利', '注册即送免费额度'),
                    _buildInfoItem('按量计费', '用多少付多少'),
                    _buildInfoItem('响应快速', '中国服务器，低延迟'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: OpenAITheme.gray500)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: OpenAITheme.gray600),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(text: content),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String text;

  const _StepItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: OpenAITheme.gray200,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: OpenAITheme.gray700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: OpenAITheme.gray600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
