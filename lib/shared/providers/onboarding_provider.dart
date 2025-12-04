import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 首次启动检测 Provider
/// 用于判断是否需要显示新手引导
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_completed') ?? false;
});

/// 标记新手引导已完成
Future<void> markOnboardingCompleted() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_completed', true);
}

/// 重置新手引导状态（用于测试）
Future<void> resetOnboardingStatus() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('onboarding_completed');
}
