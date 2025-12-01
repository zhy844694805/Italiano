import 'dart:io';
import 'dart:typed_data';
import 'package:kokoro_tts_flutter/kokoro_tts_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

/// 本地 KOKORO TTS 服务
/// 使用本地模型进行离线文本转语音
class KokoroLocalTTSService {
  static final KokoroLocalTTSService instance = KokoroLocalTTSService._init();
  KokoroLocalTTSService._init();

  Kokoro? _kokoro;
  Tokenizer? _tokenizer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isInitialized = false;
  String? _initError;

  /// 可用的意大利语语音
  /// Kokoro 本地模型支持的意大利语语音
  static const String voiceNicola = 'im_nicola'; // 男声
  static const String voiceSara = 'if_sara';     // 女声

  /// 初始化状态
  bool get isInitialized => _isInitialized;
  String? get initError => _initError;
  bool get isPlaying => _isPlaying;

  /// 初始化本地TTS引擎
  /// 需要模型文件位于应用文档目录的 kokoro_models/ 下
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      print('[TTS] 开始初始化...');

      // 获取应用文档目录
      final appDir = await getApplicationDocumentsDirectory();
      final modelDir = Directory('${appDir.path}/kokoro_models');
      print('[TTS] 模型目录: ${modelDir.path}');

      // 检查模型文件是否存在
      final modelFile = File('${modelDir.path}/kokoro-v1.0.onnx');
      final voicesFile = File('${modelDir.path}/voices-v1.0.bin');

      final modelExists = await modelFile.exists();
      final voicesExists = await voicesFile.exists();
      print('[TTS] 模型文件存在: $modelExists, voices文件存在: $voicesExists');

      if (!modelExists || !voicesExists) {
        _initError = '模型文件未找到，请先下载模型文件';
        print('[TTS] 错误: $_initError');
        return false;
      }

      // 检查文件大小
      final modelSize = await modelFile.length();
      final voicesSize = await voicesFile.length();
      print('[TTS] 模型大小: ${(modelSize / 1024 / 1024).toStringAsFixed(2)} MB');
      print('[TTS] Voices大小: ${(voicesSize / 1024 / 1024).toStringAsFixed(2)} MB');

      // 创建配置
      print('[TTS] 创建Kokoro配置...');
      final config = KokoroConfig(
        modelPath: modelFile.path,
        voicesPath: voicesFile.path,
      );

      // 初始化 Kokoro 引擎
      print('[TTS] 初始化Kokoro引擎...');
      _kokoro = Kokoro(config);
      await _kokoro!.initialize();
      print('[TTS] Kokoro引擎初始化成功');

      // 初始化 Tokenizer
      print('[TTS] 初始化Tokenizer...');
      _tokenizer = Tokenizer();
      await _tokenizer!.ensureInitialized();
      print('[TTS] Tokenizer初始化成功');

      _isInitialized = true;
      _initError = null;
      print('[TTS] 初始化完成!');
      return true;
    } catch (e, stackTrace) {
      _initError = '初始化失败: $e';
      _isInitialized = false;
      print('[TTS] 初始化失败: $e');
      print('[TTS] 堆栈: $stackTrace');
      return false;
    }
  }

  /// 文本转语音并播放
  /// [text] 要朗读的意大利语文本
  /// [voice] 语音类型，默认使用 Sara（女声）
  Future<bool> speak(String text, {String voice = voiceSara}) async {
    print('[TTS] speak() 被调用, 文本: "$text", 语音: $voice');

    if (text.isEmpty) {
      print('[TTS] 文本为空，跳过');
      return false;
    }

    if (!_isInitialized) {
      print('[TTS] 未初始化，尝试初始化...');
      final initialized = await initialize();
      if (!initialized) {
        print('[TTS] 初始化失败，无法播放');
        return false;
      }
    }

    if (_isPlaying) {
      print('[TTS] 正在播放，先停止');
      await stop();
    }

    try {
      // 将文本转换为音素（意大利语）
      print('[TTS] 转换文本为音素...');
      final phonemes = await _tokenizer!.phonemize(text, lang: 'it');
      print('[TTS] 音素: $phonemes');

      // 使用 Kokoro 生成音频
      print('[TTS] 生成音频...');
      final ttsResult = await _kokoro!.createTTS(
        text: phonemes,
        voice: voice,
        isPhonemes: true,
      );

      final audioData = ttsResult.audio;
      print('[TTS] 音频数据长度: ${audioData.length}');

      if (audioData.isEmpty) {
        print('[TTS] 音频数据为空');
        return false;
      }

      // 保存音频到临时文件
      final tempDir = await getTemporaryDirectory();
      final audioFile = File('${tempDir.path}/tts_local_${DateTime.now().millisecondsSinceEpoch}.wav');
      print('[TTS] 保存音频到: ${audioFile.path}');
      await audioFile.writeAsBytes(_convertToWav(audioData.cast<double>()));

      final fileSize = await audioFile.length();
      print('[TTS] 音频文件大小: $fileSize 字节');

      // 播放音频
      print('[TTS] 开始播放...');
      _isPlaying = true;
      await _audioPlayer.play(DeviceFileSource(audioFile.path));
      print('[TTS] 播放已启动');

      // 监听播放完成
      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlaying = false;
        print('[TTS] 播放完成');
        // 删除临时文件
        audioFile.delete().catchError((_) => audioFile);
      });

      return true;
    } catch (e, stackTrace) {
      _isPlaying = false;
      print('[TTS] speak() 错误: $e');
      print('[TTS] 堆栈: $stackTrace');
      return false;
    }
  }

  /// 将浮点音频数据转换为 WAV 格式
  Uint8List _convertToWav(List<double> audioData) {
    // 采样率和位深度
    const sampleRate = 24000;
    const bitsPerSample = 16;
    const numChannels = 1;

    // 将浮点数据转换为16位整数
    final int16Data = Int16List(audioData.length);
    for (var i = 0; i < audioData.length; i++) {
      final sample = (audioData[i] * 32767).clamp(-32768, 32767).toInt();
      int16Data[i] = sample;
    }

    // 创建 WAV 文件头
    final byteData = ByteData(44 + int16Data.length * 2);

    // RIFF header
    byteData.setUint8(0, 0x52); // R
    byteData.setUint8(1, 0x49); // I
    byteData.setUint8(2, 0x46); // F
    byteData.setUint8(3, 0x46); // F
    byteData.setUint32(4, 36 + int16Data.length * 2, Endian.little); // File size - 8
    byteData.setUint8(8, 0x57);  // W
    byteData.setUint8(9, 0x41);  // A
    byteData.setUint8(10, 0x56); // V
    byteData.setUint8(11, 0x45); // E

    // fmt chunk
    byteData.setUint8(12, 0x66); // f
    byteData.setUint8(13, 0x6D); // m
    byteData.setUint8(14, 0x74); // t
    byteData.setUint8(15, 0x20); // (space)
    byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    byteData.setUint16(20, 1, Endian.little);  // AudioFormat (1 for PCM)
    byteData.setUint16(22, numChannels, Endian.little); // NumChannels
    byteData.setUint32(24, sampleRate, Endian.little);  // SampleRate
    byteData.setUint32(28, sampleRate * numChannels * bitsPerSample ~/ 8, Endian.little); // ByteRate
    byteData.setUint16(32, numChannels * bitsPerSample ~/ 8, Endian.little); // BlockAlign
    byteData.setUint16(34, bitsPerSample, Endian.little); // BitsPerSample

    // data chunk
    byteData.setUint8(36, 0x64); // d
    byteData.setUint8(37, 0x61); // a
    byteData.setUint8(38, 0x74); // t
    byteData.setUint8(39, 0x61); // a
    byteData.setUint32(40, int16Data.length * 2, Endian.little); // Subchunk2Size

    // Audio data
    for (var i = 0; i < int16Data.length; i++) {
      byteData.setInt16(44 + i * 2, int16Data[i], Endian.little);
    }

    return byteData.buffer.asUint8List();
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

  /// 释放资源
  Future<void> dispose() async {
    await _audioPlayer.dispose();
    _kokoro?.dispose();
    _isInitialized = false;
  }

  /// 预加载音频（用于缓存）
  /// 生成音频但不播放，返回文件路径
  Future<String?> preloadAudio(String text, {String voice = voiceSara}) async {
    if (text.isEmpty) return null;

    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return null;
    }

    try {
      // 将文本转换为音素（意大利语）
      final phonemes = await _tokenizer!.phonemize(text, lang: 'it');

      final ttsResult = await _kokoro!.createTTS(
        text: phonemes,
        voice: voice,
        isPhonemes: true,
      );

      final audioData = ttsResult.audio;
      if (audioData.isEmpty) {
        return null;
      }

      // 保存到应用文档目录（持久化缓存）
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDir.path}/tts_local_cache');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      // 使用文本哈希作为文件名
      final fileName = '${text.hashCode}_$voice.wav';
      final audioFile = File('${cacheDir.path}/$fileName');
      await audioFile.writeAsBytes(_convertToWav(audioData.cast<double>()));

      return audioFile.path;
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
      final fileName = '${text.hashCode}_$voice.wav';
      final audioFile = File('${appDir.path}/tts_local_cache/$fileName');

      if (await audioFile.exists()) {
        _isPlaying = true;
        await _audioPlayer.play(DeviceFileSource(audioFile.path));

        _audioPlayer.onPlayerComplete.listen((_) {
          _isPlaying = false;
        });

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
      final cacheDir = Directory('${appDir.path}/tts_local_cache');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// 获取模型目录路径（用于下载模型）
  static Future<String> getModelDirectoryPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/kokoro_models';
  }

  /// 检查模型是否已安装
  static Future<bool> isModelInstalled() async {
    final modelDir = await getModelDirectoryPath();
    final modelFile = File('$modelDir/kokoro-v1.0.onnx');
    final voicesFile = File('$modelDir/voices-v1.0.bin');
    return await modelFile.exists() && await voicesFile.exists();
  }

  /// 获取模型大小信息
  static Map<String, String> getModelInfo() {
    return {
      'modelFile': 'kokoro-v1.0.onnx',
      'voicesFile': 'voices-v1.0.bin',
      'modelSize': '~330MB',
      'downloadUrl': 'https://github.com/thewh1teagle/kokoro-onnx/releases',
    };
  }
}
