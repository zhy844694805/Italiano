import 'package:flutter/material.dart';
import '../../core/theme/openai_theme.dart';

/// 卡片组件 - OpenAI 极简风格
/// 支持纯色和渐变两种模式
class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final Color? color;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double? width;
  final double? height;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient,
    this.color,
    this.onTap,
    this.padding,
    this.borderRadius = 12,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? (color ?? OpenAITheme.darkGray) : null,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 玻璃态卡片组件
class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius = 12,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: OpenAITheme.glassDecoration(
        color: backgroundColor,
        radius: borderRadius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 浮动卡片组件（带边框和微妙阴影）
class FloatingCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final bool selected;

  const FloatingCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius = 12,
    this.backgroundColor,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: selected
          ? OpenAITheme.accentCardDecoration(radius: borderRadius)
          : OpenAITheme.floatingCardDecoration(
              color: backgroundColor,
              radius: borderRadius,
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 带图标的按钮 - OpenAI 风格
class GradientButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final Color? color;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool outlined;

  const GradientButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.gradient,
    this.color,
    this.borderRadius = 8,
    this.padding,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(text),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? (color ?? OpenAITheme.openaiGreen) : null,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 统计数字卡片 - OpenAI 风格
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Gradient? gradient;
  final Color? iconColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.gradient,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: OpenAITheme.floatingCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: OpenAITheme.bgSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor ?? OpenAITheme.openaiGreen,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          // 数值
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // 标签
          Text(
            label,
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// 进度条 - OpenAI 风格
class GradientProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final double height;
  final Gradient? gradient;
  final Color? color;
  final Color? backgroundColor;

  const GradientProgressBar({
    super.key,
    required this.progress,
    this.height = 6,
    this.gradient,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? OpenAITheme.gray100,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              color: gradient == null ? (color ?? OpenAITheme.openaiGreen) : null,
            ),
          ),
        ),
      ),
    );
  }
}
