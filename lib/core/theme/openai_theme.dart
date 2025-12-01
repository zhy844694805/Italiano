import 'package:flutter/material.dart';

/// OpenAI 风格主题
/// 特点: 极简、黑白为主、细腻的灰度层次、优雅的排版、微妙的动效
class OpenAITheme {
  // ========== 颜色系统 ==========
  // 主色调 - 纯净黑白
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // 灰度层次 (OpenAI 的核心)
  static const Color gray50 = Color(0xFFFAFAFA);   // 最浅背景
  static const Color gray100 = Color(0xFFF4F4F5);  // 卡片背景
  static const Color gray200 = Color(0xFFE4E4E7);  // 边框、分割线
  static const Color gray300 = Color(0xFFD4D4D8);  // 禁用状态
  static const Color gray400 = Color(0xFFA1A1AA);  // 占位文字
  static const Color gray500 = Color(0xFF71717A);  // 次要文字
  static const Color gray600 = Color(0xFF52525B);  // 正文
  static const Color gray700 = Color(0xFF3F3F46);  // 重要文字
  static const Color gray800 = Color(0xFF27272A);  // 标题
  static const Color gray900 = Color(0xFF18181B);  // 最深文字

  // 功能色 - 极其克制
  static const Color green = Color(0xFF10A37F);    // OpenAI 标志绿
  static const Color greenLight = Color(0xFFD1FAE5);
  static const Color red = Color(0xFFEF4444);      // 错误
  static const Color redLight = Color(0xFFFEE2E2);
  static const Color blue = Color(0xFF3B82F6);     // 链接
  static const Color blueLight = Color(0xFFDBEAFE);

  // ========== 主题配置 ==========
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'SF Pro Display', // iOS 默认会 fallback 到系统字体

    colorScheme: const ColorScheme.light(
      primary: black,
      onPrimary: white,
      secondary: green,
      onSecondary: white,
      surface: white,
      onSurface: gray900,
      surfaceContainerHighest: gray50,
      error: red,
      onError: white,
      outline: gray200,
    ),

    scaffoldBackgroundColor: white,

    // AppBar - 极简风格
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: gray900,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: gray700, size: 22),
    ),

    // 卡片 - 细微边框 + 超浅阴影
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: gray200, width: 1),
      ),
      color: white,
      margin: EdgeInsets.zero,
    ),

    // 文本主题 - 清晰的层次
    textTheme: const TextTheme(
      // 大标题
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w600,
        color: gray900,
        letterSpacing: -1.5,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: gray900,
        letterSpacing: -1,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: gray900,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      // 标题
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: gray900,
        letterSpacing: -0.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: gray900,
        letterSpacing: -0.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: gray900,
      ),
      // 正文
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: gray800,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: gray700,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: gray600,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: gray700,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: gray600,
        height: 1.6,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: gray500,
        height: 1.5,
      ),
      // 标签
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: gray700,
        letterSpacing: 0,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: gray500,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: gray400,
        letterSpacing: 0.3,
      ),
    ),

    // 按钮 - 简洁有力
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gray900,
        foregroundColor: white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: gray900,
        side: const BorderSide(color: gray300, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: gray700,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // 输入框 - 简洁边框
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: gray50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: gray200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: gray900, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: gray400, fontSize: 14),
    ),

    // 底部导航 - 极简
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      elevation: 0,
      backgroundColor: white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: gray100,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: gray900,
          );
        }
        return const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: gray500,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: gray900, size: 22);
        }
        return const IconThemeData(color: gray500, size: 22);
      }),
    ),

    // 分割线
    dividerTheme: const DividerThemeData(
      color: gray200,
      thickness: 1,
      space: 1,
    ),

    // 对话框
    dialogTheme: DialogThemeData(
      backgroundColor: white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: gray900,
      ),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: gray100,
      selectedColor: gray900,
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: gray700,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      side: BorderSide.none,
    ),

    // 进度指示器
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: gray900,
      linearTrackColor: gray200,
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: gray900,
      contentTextStyle: const TextStyle(
        color: white,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // 列表项
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      titleTextStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: gray800,
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 13,
        color: gray500,
      ),
    ),
  );

  // ========== 深色主题 ==========
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'SF Pro Display',

    colorScheme: const ColorScheme.dark(
      primary: white,
      onPrimary: gray900,
      secondary: green,
      onSecondary: white,
      surface: Color(0xFF1A1A1A),
      onSurface: gray100,
      surfaceContainerHighest: Color(0xFF0D0D0D),
      error: Color(0xFFFF6B6B),
    ),

    scaffoldBackgroundColor: const Color(0xFF0D0D0D),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0D0D0D),
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: gray300, size: 22),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: gray800.withValues(alpha: 0.5), width: 1),
      ),
      color: const Color(0xFF1A1A1A),
    ),
  );
}
