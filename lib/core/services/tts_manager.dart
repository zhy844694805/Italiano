import 'kokoro_local_tts_service.dart';

/// 统一的 TTS 管理器
/// 使用本地 KOKORO 模型进行离线语音合成
class TTSService {
  static final TTSService instance = TTSService._init();
  TTSService._init();

  final KokoroLocalTTSService _localService = KokoroLocalTTSService.instance;

  /// 可用的意大利语语音
  static const String voiceNicola = 'im_nicola'; // 男声
  static const String voiceSara = 'if_sara';     // 女声

  /// 是否正在播放
  bool get isPlaying => _localService.isPlaying;

  /// 是否已初始化
  bool get isInitialized => _localService.isInitialized;

  /// 初始化错误信息
  String? get initError => _localService.initError;

  /// 初始化 TTS 引擎
  Future<bool> initialize() async {
    return _localService.initialize();
  }

  /// 文本转语音并播放
  Future<bool> speak(String text, {String voice = voiceSara}) async {
    return _localService.speak(text, voice: voice);
  }

  /// 停止播放
  Future<void> stop() async {
    await _localService.stop();
  }

  /// 暂停播放
  Future<void> pause() async {
    await _localService.pause();
  }

  /// 恢复播放
  Future<void> resume() async {
    await _localService.resume();
  }

  /// 预加载音频
  Future<String?> preloadAudio(String text, {String voice = voiceSara}) async {
    return _localService.preloadAudio(text, voice: voice);
  }

  /// 从缓存播放音频
  Future<bool> playFromCache(String text, {String voice = voiceSara}) async {
    return _localService.playFromCache(text, voice: voice);
  }

  /// 清除缓存
  Future<void> clearCache() async {
    await _localService.clearCache();
  }

  /// 释放资源
  Future<void> dispose() async {
    await _localService.dispose();
  }

  /// 检查本地模型是否已安装
  static Future<bool> isModelInstalled() async {
    return KokoroLocalTTSService.isModelInstalled();
  }

  /// 获取本地模型目录路径
  static Future<String> getModelPath() async {
    return KokoroLocalTTSService.getModelDirectoryPath();
  }

  /// 获取本地模型信息
  static Map<String, String> getModelInfo() {
    return KokoroLocalTTSService.getModelInfo();
  }
}
