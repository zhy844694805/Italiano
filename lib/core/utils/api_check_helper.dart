import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../services/tts_service.dart';
import '../../shared/widgets/api_config_dialog.dart';

/// API 检查帮助类
/// 提供统一的 API 配置检查和提示功能
class ApiCheckHelper {
  /// 播放 TTS 语音（带 API 检查）
  /// 如果 API 未配置，会弹出配置对话框
  /// 返回是否成功播放
  static Future<bool> speakWithCheck(
    BuildContext context,
    String text, {
    String voice = TTSService.voiceSara,
  }) async {
    // 检查 API 是否配置
    final isConfigured = await ApiConfig.isTtsConfigured();

    if (!isConfigured) {
      if (!context.mounted) return false;

      // 显示配置对话框
      final configured = await ApiConfigDialog.show(
        context,
        configType: ApiConfigType.tts,
        title: '语音播报需要配置',
        description: '请配置 TTS API 密钥以使用语音播报功能',
      );

      if (!configured) return false;
    }

    // 播放语音
    return await TTSService.instance.speak(text, voice: voice);
  }

  /// 检查 DeepSeek API 是否已配置
  /// 如果未配置，会弹出配置对话框
  /// 返回是否已配置
  static Future<bool> checkDeepSeekApi(BuildContext context) async {
    final isConfigured = await ApiConfig.isDeepSeekConfigured();

    if (!isConfigured) {
      if (!context.mounted) return false;

      return await ApiConfigDialog.show(
        context,
        configType: ApiConfigType.deepSeek,
        title: 'AI 对话需要配置',
        description: '请配置 DeepSeek API 密钥以使用 AI 对话功能',
      );
    }

    return true;
  }

  /// 检查 TTS API 是否已配置
  /// 如果未配置，会弹出配置对话框
  /// 返回是否已配置
  static Future<bool> checkTtsApi(BuildContext context) async {
    final isConfigured = await ApiConfig.isTtsConfigured();

    if (!isConfigured) {
      if (!context.mounted) return false;

      return await ApiConfigDialog.show(
        context,
        configType: ApiConfigType.tts,
        title: '语音播报需要配置',
        description: '请配置 TTS API 密钥以使用语音播报功能',
      );
    }

    return true;
  }
}
