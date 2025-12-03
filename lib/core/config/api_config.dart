import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// API 配置管理器
/// 安全存储和管理 API 密钥
///
/// 重要：API 密钥必须由用户自行配置，不要在代码中硬编码
class ApiConfig {
  static const String _deepSeekKeyKey = 'deepseek_api_key';
  static const String _ttsKeyKey = 'tts_api_key';

  static const String deepSeekBaseUrl = 'https://api.deepseek.com';
  static const String ttsBaseUrl = 'https://newapi.maiduoduo.it/v1';

  /// 获取 DeepSeek API 密钥
  /// 如果未配置，返回空字符串
  static Future<String> getDeepSeekApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_deepSeekKeyKey) ?? '';
    } catch (e) {
      debugPrint('Error loading DeepSeek API key: $e');
      return '';
    }
  }

  /// 设置 DeepSeek API 密钥
  static Future<void> setDeepSeekApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deepSeekKeyKey, key);
  }

  /// 获取 TTS API 密钥
  /// 如果未配置，返回空字符串
  static Future<String> getTtsApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_ttsKeyKey) ?? '';
    } catch (e) {
      debugPrint('Error loading TTS API key: $e');
      return '';
    }
  }

  /// 设置 TTS API 密钥
  static Future<void> setTtsApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ttsKeyKey, key);
  }

  /// 检查 DeepSeek API 密钥是否已配置
  static Future<bool> isDeepSeekConfigured() async {
    final key = await getDeepSeekApiKey();
    return key.isNotEmpty;
  }

  /// 检查 TTS API 密钥是否已配置
  static Future<bool> isTtsConfigured() async {
    final key = await getTtsApiKey();
    return key.isNotEmpty;
  }

  /// 检查所有 API 密钥是否已配置
  static Future<bool> isConfigured() async {
    final deepSeekKey = await getDeepSeekApiKey();
    final ttsKey = await getTtsApiKey();
    return deepSeekKey.isNotEmpty && ttsKey.isNotEmpty;
  }

  /// 清除所有 API 配置
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deepSeekKeyKey);
    await prefs.remove(_ttsKeyKey);
  }
}
