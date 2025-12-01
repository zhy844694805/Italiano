import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/openai_theme.dart';
import 'features/home/home_screen.dart';
import 'features/setup/tts_setup_screen.dart';
import 'features/setup/api_key_setup_screen.dart';
import 'shared/providers/api_key_provider.dart';

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
      title: 'Italiano',
      debugShowCheckedModeBanner: false,
      theme: OpenAITheme.lightTheme,
      darkTheme: OpenAITheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const AppLauncher(),
    );
  }
}

/// 设置流程阶段
enum SetupPhase {
  loading,
  ttsSetup,
  apiKeySetup,
  completed,
}

/// 应用启动器，处理首次启动设置流程
class AppLauncher extends ConsumerStatefulWidget {
  const AppLauncher({super.key});

  @override
  ConsumerState<AppLauncher> createState() => _AppLauncherState();
}

class _AppLauncherState extends ConsumerState<AppLauncher> {
  SetupPhase _phase = SetupPhase.loading;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    // 检查 TTS 设置
    final ttsSetupCompleted = await ref.read(ttsSetupCompletedProvider.future);

    if (!ttsSetupCompleted) {
      if (mounted) {
        setState(() {
          _phase = SetupPhase.ttsSetup;
        });
      }
      return;
    }

    // 检查 API Key 设置
    final apiKeyConfigured = await ref.read(apiKeyConfiguredProvider.future);

    if (!apiKeyConfigured) {
      if (mounted) {
        setState(() {
          _phase = SetupPhase.apiKeySetup;
        });
      }
      return;
    }

    // 全部完成
    if (mounted) {
      setState(() {
        _phase = SetupPhase.completed;
      });
    }
  }

  void _onTtsSetupComplete() {
    ref.invalidate(ttsSetupCompletedProvider);
    // 继续检查 API Key
    _checkApiKeySetup();
  }

  Future<void> _checkApiKeySetup() async {
    final apiKeyConfigured = await ref.read(apiKeyConfiguredProvider.future);

    if (!apiKeyConfigured) {
      setState(() {
        _phase = SetupPhase.apiKeySetup;
      });
    } else {
      setState(() {
        _phase = SetupPhase.completed;
      });
    }
  }

  void _onApiKeySetupComplete() {
    ref.invalidate(apiKeyConfiguredProvider);
    setState(() {
      _phase = SetupPhase.completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case SetupPhase.loading:
        return Scaffold(
          backgroundColor: OpenAITheme.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: OpenAITheme.gray100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 32,
                    color: OpenAITheme.gray700,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Italiano',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: OpenAITheme.gray900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        );

      case SetupPhase.ttsSetup:
        return TTSSetupScreen(onComplete: _onTtsSetupComplete);

      case SetupPhase.apiKeySetup:
        return ApiKeySetupScreen(
          onComplete: _onApiKeySetupComplete,
          isInitialSetup: true,
        );

      case SetupPhase.completed:
        return const HomeScreen();
    }
  }
}
