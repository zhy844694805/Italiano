import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/tts_manager.dart';

/// TTS服务提供者
final ttsServiceProvider = Provider<TTSService>((ref) {
  return TTSService.instance;
});

/// TTS播放状态提供者
final ttsPlayingStateProvider = StateProvider<bool>((ref) {
  return false;
});

/// 本地模型安装状态提供者
final localModelInstalledProvider = FutureProvider<bool>((ref) async {
  return TTSService.isModelInstalled();
});

/// 本地模型路径提供者
final localModelPathProvider = FutureProvider<String>((ref) async {
  return TTSService.getModelPath();
});
