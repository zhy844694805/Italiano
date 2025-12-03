import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/openai_theme.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Ciao',
      debugShowCheckedModeBanner: false,
      // 使用 OpenAI 极简风格主题
      theme: OpenAITheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
