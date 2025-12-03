import 'package:flutter/material.dart';
import '../providers/achievement_provider.dart';
import '../../core/theme/openai_theme.dart';

class AchievementUnlockDialog extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;

  const AchievementUnlockDialog({
    super.key,
    required this.achievement,
    this.onDismiss,
  });

  /// 显示成就解锁弹窗
  static Future<void> show(BuildContext context, Achievement achievement) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Achievement',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AchievementUnlockDialog(achievement: achievement);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<AchievementUnlockDialog> createState() => _AchievementUnlockDialogState();
}

class _AchievementUnlockDialogState extends State<AchievementUnlockDialog>
    with SingleTickerProviderStateMixin {
  AnimationController? _iconController;
  Animation<double>? _iconScale;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController!, curve: Curves.elasticOut),
    );

    // 延迟启动图标动画
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _iconController?.forward();
    });
  }

  @override
  void dispose() {
    _iconController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: OpenAITheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: OpenAITheme.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部成就图标区域
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: const BoxDecoration(
                  color: OpenAITheme.bgSecondary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    // 成就图标
                    AnimatedBuilder(
                      animation: _iconController ?? const AlwaysStoppedAnimation(1.0),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _iconScale?.value ?? 1.0,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: OpenAITheme.openaiGreen.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: OpenAITheme.openaiGreen.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              widget.achievement.icon,
                              size: 36,
                              color: OpenAITheme.openaiGreen,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // 解锁标签
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: OpenAITheme.openaiGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '成就解锁',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 成就信息
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // 成就标题
                    Text(
                      widget.achievement.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: OpenAITheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 成就描述
                    Text(
                      widget.achievement.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: OpenAITheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // 鼓励语
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: OpenAITheme.bgSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: OpenAITheme.borderLight),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: OpenAITheme.textTertiary,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '继续保持，你做得很棒！',
                            style: TextStyle(
                              fontSize: 13,
                              color: OpenAITheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 确定按钮
                    SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            widget.onDismiss?.call();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: OpenAITheme.charcoal,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '继续学习',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 辅助方法：检查并显示成就弹窗
Future<void> checkAndShowAchievement(BuildContext context, Achievement? achievement) async {
  if (achievement != null && context.mounted) {
    await AchievementUnlockDialog.show(context, achievement);
  }
}
