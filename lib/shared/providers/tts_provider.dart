import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/tts_service.dart';

/// TTS服务提供者
final ttsServiceProvider = Provider<TTSService>((ref) {
  return TTSService.instance;
});

/// TTS播放状态提供者
final ttsPlayingStateProvider = StateProvider<bool>((ref) {
  return false;
});
