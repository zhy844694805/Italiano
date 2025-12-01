import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/tts_manager.dart';

/// Provider for voice preference (male/female)
final voicePreferenceProvider = StateNotifierProvider<VoicePreferenceNotifier, String>((ref) {
  return VoicePreferenceNotifier();
});

class VoicePreferenceNotifier extends StateNotifier<String> {
  static const String _key = 'tts_voice_preference';

  VoicePreferenceNotifier() : super(TTSService.voiceSara) {
    _loadPreference();
  }

  /// Load voice preference from SharedPreferences
  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVoice = prefs.getString(_key);
    if (savedVoice != null) {
      state = savedVoice;
    }
  }

  /// Set voice preference and save to SharedPreferences
  Future<void> setVoice(String voice) async {
    state = voice;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, voice);
  }

  /// Get display name for voice
  String getVoiceName(String voice) {
    switch (voice) {
      case TTSService.voiceNicola:
        return 'Nicola（男声）';
      case TTSService.voiceSara:
        return 'Sara（女声）';
      default:
        return voice;
    }
  }
}
