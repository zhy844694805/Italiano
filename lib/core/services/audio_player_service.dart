import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  bool get isPlaying => _isPlaying;

  // 初始化监听器（仅调用一次）
  void _initListener() {
    _playerStateSubscription?.cancel();
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
      }
    });
  }

  // 播放本地音频文件
  Future<void> playLocalAudio(String assetPath) async {
    try {
      if (_isPlaying) {
        await stop();
      }

      _initListener();
      await _audioPlayer.setAsset(assetPath);
      _isPlaying = true;
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
      _isPlaying = false;
    }
  }

  // 播放网络音频（如果将来需要）
  Future<void> playNetworkAudio(String url) async {
    try {
      if (_isPlaying) {
        await stop();
      }

      _initListener();
      await _audioPlayer.setUrl(url);
      _isPlaying = true;
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing network audio: $e');
      _isPlaying = false;
    }
  }

  // 播放单词发音（根据单词ID查找音频文件）
  Future<void> playWordPronunciation(String wordId) async {
    // 音频文件命名规则：assets/audio/words/{wordId}.mp3
    final audioPath = 'assets/audio/words/$wordId.mp3';
    await playLocalAudio(audioPath);
  }

  // TTS 播放（使用系统 TTS 或在线服务，暂时使用占位符）
  Future<void> playTextToSpeech(String text, {String language = 'it'}) async {
    // TODO: 集成 TTS 服务
    // 可以使用 flutter_tts 包或者调用在线 TTS API
    debugPrint('TTS播放: $text (语言: $language)');
  }

  // 停止播放
  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  // 暂停
  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
  }

  // 继续播放
  Future<void> resume() async {
    await _audioPlayer.play();
    _isPlaying = true;
  }

  // 设置音量 (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  // 设置播放速度
  Future<void> setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed);
  }

  // 释放资源
  void dispose() {
    _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
    _audioPlayer.dispose();
  }
}

// Provider
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();

  // 当 Provider 被销毁时释放资源
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
