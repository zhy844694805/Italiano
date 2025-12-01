import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for DeepSeek API key
final apiKeyProvider = StateNotifierProvider<ApiKeyNotifier, String?>((ref) {
  return ApiKeyNotifier();
});

/// Provider to check if API key is configured
final apiKeyConfiguredProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final apiKey = prefs.getString('deepseek_api_key');
  return apiKey != null && apiKey.isNotEmpty;
});

class ApiKeyNotifier extends StateNotifier<String?> {
  static const String _key = 'deepseek_api_key';

  ApiKeyNotifier() : super(null) {
    _loadApiKey();
  }

  /// Load API key from SharedPreferences
  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key);
  }

  /// Save API key to SharedPreferences
  Future<bool> setApiKey(String apiKey) async {
    if (apiKey.trim().isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, apiKey.trim());
    state = apiKey.trim();
    return true;
  }

  /// Clear API key
  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = null;
  }

  /// Validate API key format (basic check)
  static bool isValidFormat(String apiKey) {
    // DeepSeek API keys typically start with 'sk-'
    return apiKey.trim().startsWith('sk-') && apiKey.trim().length > 10;
  }
}
