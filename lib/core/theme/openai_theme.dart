import 'package:flutter/material.dart';

/// OpenAI 官网风格主题
/// 设计理念: 极简、黑白、精致、专业
class OpenAITheme {
  // ═══════════════════════════════════════════════════════════════
  // 核心色彩 - OpenAI 极简色调
  // ═══════════════════════════════════════════════════════════════

  // OpenAI 绿色 - 品牌强调色
  static const Color openaiGreen = Color(0xFF10A37F);
  static const Color openaiGreenLight = Color(0xFF1ED9A4);
  static const Color openaiGreenDark = Color(0xFF0D8A6A);

  // 黑色系
  static const Color black = Color(0xFF000000);
  static const Color darkGray = Color(0xFF202123);
  static const Color charcoal = Color(0xFF343541);

  // 灰色系
  static const Color gray700 = Color(0xFF40414F);
  static const Color gray600 = Color(0xFF565869);
  static const Color gray500 = Color(0xFF6E6E80);
  static const Color gray400 = Color(0xFF8E8EA0);
  static const Color gray300 = Color(0xFFACACAC);
  static const Color gray200 = Color(0xFFD1D5DB);
  static const Color gray100 = Color(0xFFECECF1);
  static const Color gray50 = Color(0xFFF7F7F8);

  // 白色系
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAFAFA);

  // 功能色
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10A37F);
  static const Color info = Color(0xFF3B82F6);

  // 文字颜色
  static const Color textPrimary = Color(0xFF202123);
  static const Color textSecondary = Color(0xFF6E6E80);
  static const Color textTertiary = Color(0xFFACACAC);
  static const Color textInverse = Color(0xFFFFFFFF);

  // 背景色
  static const Color bgPrimary = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFF7F7F8);
  static const Color bgTertiary = Color(0xFFECECF1);

  // 边框色
  static const Color borderLight = Color(0xFFE5E5E5);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderDark = Color(0xFFACACAC);

  // ═══════════════════════════════════════════════════════════════
  // 主题数据
  // ═══════════════════════════════════════════════════════════════

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // 色彩方案
    colorScheme: const ColorScheme.light(
      primary: openaiGreen,
      onPrimary: white,
      primaryContainer: Color(0xFFD1FAE5),
      onPrimaryContainer: openaiGreenDark,
      secondary: charcoal,
      onSecondary: white,
      secondaryContainer: gray100,
      onSecondaryContainer: darkGray,
      tertiary: gray500,
      surface: white,
      onSurface: textPrimary,
      surfaceContainerHighest: bgSecondary,
      error: error,
      onError: white,
      outline: borderLight,
      outlineVariant: borderMedium,
    ),

    scaffoldBackgroundColor: bgPrimary,

    // ═══════════════════════════════════════════════════════════════
    // AppBar - 简洁透明
    // ═══════════════════════════════════════════════════════════════
    appBarTheme: const AppBarTheme(
      backgroundColor: bgPrimary,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: textPrimary, size: 22),
    ),

    // ═══════════════════════════════════════════════════════════════
    // 卡片 - 精致边框
    // ═══════════════════════════════════════════════════════════════
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderLight, width: 1),
      ),
      color: white,
      margin: const EdgeInsets.symmetric(vertical: 6),
    ),

    // ═══════════════════════════════════════════════════════════════
    // 文字样式 - 清晰层级
    // ═══════════════════════════════════════════════════════════════
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.3,
        height: 1.25,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.2,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.35,
      ),
      headlineSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textTertiary,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: white,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textTertiary,
        letterSpacing: 0.2,
      ),
    ),

    // ═══════════════════════════════════════════════════════════════
    // 按钮样式 - OpenAI 风格
    // ═══════════════════════════════════════════════════════════════
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: openaiGreen,
        foregroundColor: white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: darkGray,
        foregroundColor: white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: const BorderSide(color: borderMedium, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    ),

    // ═══════════════════════════════════════════════════════════════
    // 输入框 - 简洁边框
    // ═══════════════════════════════════════════════════════════════
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderMedium),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: openaiGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: const TextStyle(color: textTertiary, fontSize: 14),
    ),

    // ═══════════════════════════════════════════════════════════════
    // 底部导航栏 - 简洁
    // ═══════════════════════════════════════════════════════════════
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      elevation: 0,
      backgroundColor: white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: openaiGreen.withValues(alpha: 0.1),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: openaiGreen,
          );
        }
        return const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: openaiGreen, size: 24);
        }
        return const IconThemeData(color: textSecondary, size: 22);
      }),
    ),

    // ═══════════════════════════════════════════════════════════════
    // 浮动按钮
    // ═══════════════════════════════════════════════════════════════
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkGray,
      foregroundColor: white,
      elevation: 2,
      focusElevation: 4,
      hoverElevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // ═══════════════════════════════════════════════════════════════
    // 对话框
    // ═══════════════════════════════════════════════════════════════
    dialogTheme: DialogThemeData(
      backgroundColor: white,
      elevation: 8,
      shadowColor: black.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),

    // ═══════════════════════════════════════════════════════════════
    // Chip 标签
    // ═══════════════════════════════════════════════════════════════
    chipTheme: ChipThemeData(
      backgroundColor: bgSecondary,
      selectedColor: openaiGreen.withValues(alpha: 0.15),
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      side: BorderSide.none,
    ),

    // ═══════════════════════════════════════════════════════════════
    // 进度指示器
    // ═══════════════════════════════════════════════════════════════
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: openaiGreen,
      linearTrackColor: gray100,
      circularTrackColor: gray100,
    ),

    // ═══════════════════════════════════════════════════════════════
    // Slider
    // ═══════════════════════════════════════════════════════════════
    sliderTheme: SliderThemeData(
      activeTrackColor: openaiGreen,
      inactiveTrackColor: gray200,
      thumbColor: openaiGreen,
      overlayColor: openaiGreen.withValues(alpha: 0.12),
    ),

    // ═══════════════════════════════════════════════════════════════
    // Switch 开关
    // ═══════════════════════════════════════════════════════════════
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return white;
        }
        return gray400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return openaiGreen;
        }
        return gray200;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        return Colors.transparent;
      }),
    ),

    // ═══════════════════════════════════════════════════════════════
    // Divider 分割线
    // ═══════════════════════════════════════════════════════════════
    dividerTheme: const DividerThemeData(
      color: borderLight,
      thickness: 1,
      space: 1,
    ),

    // ═══════════════════════════════════════════════════════════════
    // BottomSheet
    // ═══════════════════════════════════════════════════════════════
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: white,
      modalBackgroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      dragHandleColor: gray300,
      dragHandleSize: Size(36, 4),
    ),

    // ═══════════════════════════════════════════════════════════════
    // Snackbar
    // ═══════════════════════════════════════════════════════════════
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkGray,
      contentTextStyle: const TextStyle(
        color: white,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // Tab 标签
    tabBarTheme: const TabBarThemeData(
      labelColor: textPrimary,
      unselectedLabelColor: textSecondary,
      indicatorColor: openaiGreen,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),

    // ListTile
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      minLeadingWidth: 24,
      horizontalTitleGap: 12,
    ),
  );

  // ═══════════════════════════════════════════════════════════════
  // 辅助装饰方法
  // ═══════════════════════════════════════════════════════════════

  /// 卡片装饰 - 带边框
  static BoxDecoration cardDecoration({
    Color? color,
    double radius = 12,
    bool selected = false,
  }) {
    return BoxDecoration(
      color: color ?? white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: selected ? openaiGreen : borderLight,
        width: selected ? 2 : 1,
      ),
    );
  }

  /// 浮动卡片装饰 - 微妙阴影
  static BoxDecoration floatingCardDecoration({
    Color? color,
    double radius = 12,
  }) {
    return BoxDecoration(
      color: color ?? white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderLight, width: 1),
      boxShadow: [
        BoxShadow(
          color: black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// 强调卡片装饰
  static BoxDecoration accentCardDecoration({
    double radius = 12,
  }) {
    return BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: openaiGreen, width: 2),
      boxShadow: [
        BoxShadow(
          color: openaiGreen.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// 深色卡片装饰
  static BoxDecoration darkCardDecoration({
    double radius = 12,
  }) {
    return BoxDecoration(
      color: darkGray,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// 渐变按钮装饰 (保留给需要渐变的场景)
  static BoxDecoration gradientButtonDecoration({
    double radius = 8,
  }) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [openaiGreen, openaiGreenDark],
      ),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// 玻璃态装饰
  static BoxDecoration glassDecoration({
    Color? color,
    double radius = 12,
  }) {
    return BoxDecoration(
      color: (color ?? white).withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderLight,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
