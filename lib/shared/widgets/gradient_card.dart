import 'package:flutter/material.dart';
import '../../core/theme/modern_theme.dart';

/// 渐变卡片组件 - 现代风格
class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double? width;
  final double? height;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient,
    this.onTap,
    this.padding,
    this.borderRadius = 24,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? ModernTheme.primaryGradient;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: effectiveGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
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
    this.borderRadius = 24,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ModernTheme.glassDecoration(color: backgroundColor),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 浮动卡片组件（带阴影）
class FloatingCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;

  const FloatingCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius = 24,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ModernTheme.floatingCardDecoration(color: backgroundColor),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 带图标的渐变按钮
class GradientButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const GradientButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.gradient,
    this.borderRadius = 20,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? ModernTheme.primaryGradient;

    return Container(
      decoration: BoxDecoration(
        gradient: effectiveGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: ModernTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
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

/// 统计数字卡片（带渐变边框）
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Gradient? gradient;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveGradient = gradient ?? ModernTheme.secondaryGradient;

    return Container(
      decoration: ModernTheme.floatingCardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 渐变图标
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: effectiveGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          // 数值
          Text(
            value,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // 标签
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ModernTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// 进度条（渐变）
class GradientProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final double height;
  final Gradient? gradient;
  final Color? backgroundColor;

  const GradientProgressBar({
    super.key,
    required this.progress,
    this.height = 12,
    this.gradient,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? ModernTheme.primaryGradient;
    final effectiveBackground = backgroundColor ?? ModernTheme.backgroundColor;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: effectiveBackground,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: effectiveGradient,
            ),
          ),
        ),
      ),
    );
  }
}
