import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/openai_theme.dart';
import '../../core/config/api_config.dart';
import '../../shared/providers/onboarding_provider.dart';

/// 新手引导页面
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // API 密钥控制器
  final _deepSeekController = TextEditingController();
  final _ttsController = TextEditingController();
  bool _obscureDeepSeek = true;
  bool _obscureTts = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _deepSeekController.dispose();
    _ttsController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    setState(() => _isSaving = true);

    try {
      // 保存 API 密钥（如果有输入）
      final deepSeekKey = _deepSeekController.text.trim();
      final ttsKey = _ttsController.text.trim();

      if (deepSeekKey.isNotEmpty) {
        await ApiConfig.setDeepSeekApiKey(deepSeekKey);
      }
      if (ttsKey.isNotEmpty) {
        await ApiConfig.setTtsApiKey(ttsKey);
      }

      // 标记引导完成
      await markOnboardingCompleted();

      // 调用完成回调
      widget.onComplete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: OpenAITheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OpenAITheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // 进度指示器
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: List.generate(3, (index) {
                  final isActive = index <= _currentPage;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: isActive
                            ? OpenAITheme.openaiGreen
                            : OpenAITheme.gray100,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // 页面内容
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomePage(),
                  _buildFeaturesPage(),
                  _buildApiConfigPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 欢迎页
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Logo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [OpenAITheme.openaiGreen, const Color(0xFF009246)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.translate,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Benvenuto!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: OpenAITheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '欢迎使用 Ciao 意大利语学习',
            style: TextStyle(
              fontSize: 18,
              color: OpenAITheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '让我们完成一些初始设置，\n以获得最佳学习体验',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: OpenAITheme.textTertiary,
              height: 1.5,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: OpenAITheme.textPrimary,
                foregroundColor: OpenAITheme.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '开始设置',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 功能介绍页
  Widget _buildFeaturesPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '核心功能',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: OpenAITheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '应用提供以下学习功能，部分功能需要配置 API 密钥',
            style: TextStyle(
              fontSize: 15,
              color: OpenAITheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // 功能列表
          Expanded(
            child: ListView(
              children: [
                _buildFeatureItem(
                  icon: Icons.school,
                  title: '词汇学习',
                  description: '1469个词汇，智能复习算法',
                  requiresApi: false,
                ),
                _buildFeatureItem(
                  icon: Icons.menu_book,
                  title: '语法教学',
                  description: '14个语法点，140道练习题',
                  requiresApi: false,
                ),
                _buildFeatureItem(
                  icon: Icons.article,
                  title: '阅读理解',
                  description: '20篇文章，100道阅读题',
                  requiresApi: false,
                ),
                _buildFeatureItem(
                  icon: Icons.record_voice_over,
                  title: '语音播报',
                  description: '意大利语真人发音',
                  requiresApi: true,
                  apiType: 'TTS API',
                ),
                _buildFeatureItem(
                  icon: Icons.smart_toy,
                  title: 'AI 对话练习',
                  description: '与 AI 进行场景对话',
                  requiresApi: true,
                  apiType: 'DeepSeek API',
                ),
              ],
            ),
          ),

          // 按钮
          Row(
            children: [
              TextButton(
                onPressed: _previousPage,
                child: const Text('返回'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OpenAITheme.textPrimary,
                  foregroundColor: OpenAITheme.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('下一步'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required bool requiresApi,
    String? apiType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OpenAITheme.bgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: requiresApi
                  ? OpenAITheme.warning.withValues(alpha: 0.1)
                  : OpenAITheme.openaiGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: requiresApi
                  ? OpenAITheme.warning
                  : OpenAITheme.openaiGreen,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: OpenAITheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
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
          if (requiresApi && apiType != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: OpenAITheme.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '需要 $apiType',
                style: TextStyle(
                  fontSize: 11,
                  color: OpenAITheme.warning,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // API 配置页
  Widget _buildApiConfigPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'API 配置',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: OpenAITheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '配置 API 密钥以启用语音播报和 AI 对话功能（可稍后在设置中配置）',
            style: TextStyle(
              fontSize: 15,
              color: OpenAITheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // DeepSeek API 配置
          _buildApiInputSection(
            icon: Icons.smart_toy,
            iconColor: OpenAITheme.info,
            title: 'DeepSeek API',
            description: '用于 AI 对话练习功能',
            controller: _deepSeekController,
            hint: 'sk-...',
            obscure: _obscureDeepSeek,
            onToggleObscure: () =>
                setState(() => _obscureDeepSeek = !_obscureDeepSeek),
            helpUrl: 'https://platform.deepseek.com/api_keys',
          ),
          const SizedBox(height: 20),

          // TTS API 配置
          _buildApiInputSection(
            icon: Icons.record_voice_over,
            iconColor: OpenAITheme.openaiGreen,
            title: 'TTS API',
            description: '用于语音播报功能',
            controller: _ttsController,
            hint: 'sk-...',
            obscure: _obscureTts,
            onToggleObscure: () =>
                setState(() => _obscureTts = !_obscureTts),
            helpUrl: null,
          ),
          const SizedBox(height: 32),

          // 提示信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: OpenAITheme.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: OpenAITheme.info,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '不配置 API 也可以使用词汇、语法、阅读等基础功能',
                    style: TextStyle(
                      fontSize: 13,
                      color: OpenAITheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 按钮
          Row(
            children: [
              TextButton(
                onPressed: _isSaving ? null : _previousPage,
                child: const Text('返回'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isSaving ? null : _finishOnboarding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OpenAITheme.openaiGreen,
                  foregroundColor: OpenAITheme.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('开始学习'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApiInputSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggleObscure,
    String? helpUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OpenAITheme.bgSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: OpenAITheme.textPrimary,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: OpenAITheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (helpUrl != null)
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
                    '获取密钥',
                    style: TextStyle(
                      fontSize: 12,
                      color: OpenAITheme.openaiGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: OpenAITheme.textTertiary),
              filled: true,
              fillColor: OpenAITheme.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: OpenAITheme.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: OpenAITheme.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: OpenAITheme.openaiGreen,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
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
      ),
    );
  }
}
