import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import '../config/api_config.dart';

/// KOKORO TTS 服务
/// API兼容OpenAI格式，使用意大利语语音
class TTSService {
  static final TTSService instance = TTSService._init();
  TTSService._init();

  Dio? _dio;
  bool _initialized = false;

  /// 初始化 Dio 客户端（延迟加载 API 密钥）
  Future<Dio> _getDio() async {
    if (_dio == null || !_initialized) {
      final apiKey = await ApiConfig.getTtsApiKey();
      _dio = Dio(BaseOptions(
        baseUrl: ApiConfig.ttsBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ));
      _initialized = true;
    }
    return _dio!;
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  StreamSubscription<void>? _playerCompleteSubscription;
  File? _currentTempFile;

  /// 初始化播放完成监听器
  void _initPlayerCompleteListener() {
    _playerCompleteSubscription?.cancel();
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      // 删除临时文件
      _currentTempFile?.delete().catchError((_) => _currentTempFile!);
      _currentTempFile = null;
    });
  }

  /// 可用的意大利语语音
  static const String voiceNicola = 'im_nicola'; // 男声
  static const String voiceSara = 'if_sara';     // 女声

  /// 文本转语音并播放
  /// [text] 要朗读的意大利语文本
  /// [voice] 语音类型，默认使用 Sara（女声）
  Future<bool> speak(String text, {String voice = voiceSara}) async {
    if (text.isEmpty) return false;
    if (_isPlaying) {
      await stop();
    }

    try {
      // 调用 KOKORO TTS API
      final dio = await _getDio();
      final response = await dio.post(
        '/audio/speech',
        data: {
          'model': 'kokoro',
          'voice': voice,
          'input': text,
          'response_format': 'mp3',
        },
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        // 保存音频到临时文件
        final tempDir = await getTemporaryDirectory();
        final audioFile = File('${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3');
        await audioFile.writeAsBytes(response.data);

        // 初始化监听器并播放音频
        _initPlayerCompleteListener();
        _currentTempFile = audioFile;
        _isPlaying = true;
        await _audioPlayer.play(DeviceFileSource(audioFile.path));

        return true;
      }
      return false;
    } catch (e) {
      _isPlaying = false;
      return false;
    }
  }

  /// 停止播放
  Future<void> stop() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      _isPlaying = false;
    }
  }

  /// 暂停播放
  Future<void> pause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    }
  }

  /// 恢复播放
  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  /// 是否正在播放
  bool get isPlaying => _isPlaying;

  /// 释放资源
  Future<void> dispose() async {
    _playerCompleteSubscription?.cancel();
    _playerCompleteSubscription = null;
    await _audioPlayer.dispose();
  }

  /// 预加载音频（用于缓存）
  /// 下载音频但不播放，返回文件路径
  Future<String?> preloadAudio(String text, {String voice = voiceSara}) async {
    if (text.isEmpty) return null;

    try {
      final dio = await _getDio();
      final response = await dio.post(
        '/audio/speech',
        data: {
          'model': 'kokoro',
          'voice': voice,
          'input': text,
          'response_format': 'mp3',
        },
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        // 保存到应用文档目录（持久化缓存）
        final appDir = await getApplicationDocumentsDirectory();
        final cacheDir = Directory('${appDir.path}/tts_cache');
        if (!await cacheDir.exists()) {
          await cacheDir.create(recursive: true);
        }

        // 使用文本哈希作为文件名
        final fileName = '${text.hashCode}_$voice.mp3';
        final audioFile = File('${cacheDir.path}/$fileName');
        await audioFile.writeAsBytes(response.data);

        return audioFile.path;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 从缓存播放音频
  Future<bool> playFromCache(String text, {String voice = voiceSara}) async {
    if (_isPlaying) {
      await stop();
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${text.hashCode}_$voice.mp3';
      final audioFile = File('${appDir.path}/tts_cache/$fileName');

      if (await audioFile.exists()) {
        _initPlayerCompleteListener();
        _currentTempFile = null; // 缓存文件不删除
        _isPlaying = true;
        await _audioPlayer.play(DeviceFileSource(audioFile.path));

        return true;
      }
      return false;
    } catch (e) {
      _isPlaying = false;
      return false;
    }
  }

  /// 清除TTS缓存
  Future<void> clearCache() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/tts_cache');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      // Ignore errors
    }
  }
}
