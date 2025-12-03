import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// API 配置管理器
/// 安全存储和管理 API 密钥
class ApiConfig {
  static const String _deepSeekKeyKey = 'deepseek_api_key';
  static const String _ttsKeyKey = 'tts_api_key';

  // 默认 API 配置（可通过设置页面修改）
  static const String _defaultDeepSeekKey = 'REDACTED_DEEPSEEK_API_KEY';
  static const String _defaultTtsKey = 'REDACTED_TTS_API_KEY';

  static const String deepSeekBaseUrl = 'https://api.deepseek.com';
  static const String ttsBaseUrl = 'https://newapi.maiduoduo.it/v1';

  /// 获取 DeepSeek API 密钥
  static Future<String> getDeepSeekApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_deepSeekKeyKey) ?? _defaultDeepSeekKey;
    } catch (e) {
      debugPrint('Error loading DeepSeek API key: $e');
      return _defaultDeepSeekKey;
    }
  }

  /// 设置 DeepSeek API 密钥
  static Future<void> setDeepSeekApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deepSeekKeyKey, key);
  }

  /// 获取 TTS API 密钥
  static Future<String> getTtsApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_ttsKeyKey) ?? _defaultTtsKey;
    } catch (e) {
      debugPrint('Error loading TTS API key: $e');
      return _defaultTtsKey;
    }
  }

  /// 设置 TTS API 密钥
  static Future<void> setTtsApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ttsKeyKey, key);
  }

  /// 检查 API 密钥是否已配置
  static Future<bool> isConfigured() async {
    final deepSeekKey = await getDeepSeekApiKey();
    final ttsKey = await getTtsApiKey();
    return deepSeekKey.isNotEmpty && ttsKey.isNotEmpty;
  }

  /// 重置为默认配置
  static Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deepSeekKeyKey);
    await prefs.remove(_ttsKeyKey);
  }
}
