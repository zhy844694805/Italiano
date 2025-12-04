import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/openai_theme.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'shared/providers/onboarding_provider.dart';

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
      home: const _AppHome(),
    );
  }
}

/// 应用首页 - 根据引导完成状态决定显示内容
class _AppHome extends ConsumerStatefulWidget {
  const _AppHome();

  @override
  ConsumerState<_AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends ConsumerState<_AppHome> {
  bool _showOnboarding = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final onboardingCompleted = await ref.read(onboardingCompletedProvider.future);
    if (mounted) {
      setState(() {
        _showOnboarding = !onboardingCompleted;
        _isLoading = false;
      });
    }
  }

  void _onOnboardingComplete() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: OpenAITheme.white,
        body: Center(
          child: CircularProgressIndicator(
            color: OpenAITheme.openaiGreen,
          ),
        ),
      );
    }

    if (_showOnboarding) {
      return OnboardingScreen(onComplete: _onOnboardingComplete);
    }

    return const HomeScreen();
  }
}
