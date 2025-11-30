import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_conversation.dart';

/// Provider for the daily conversation service
final dailyConversationServiceProvider = Provider<DailyConversationService>((ref) {
  return DailyConversationService();
});

/// Notifier for managing daily conversations state
final dailyConversationProvider = AsyncNotifierProvider<DailyConversationNotifier, List<DailyConversation>>(
  () => DailyConversationNotifier(),
);

/// Provider for popular conversations
final popularConversationsProvider = Provider<List<DailyConversation>>((ref) {
  final conversations = ref.watch(dailyConversationProvider);
  return conversations.when(
    data: (list) => list.where((conversation) => conversation.isPopular).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for conversations by category
final conversationsByCategoryProvider = Provider.family<List<DailyConversation>, String>((ref, category) {
  final conversations = ref.watch(dailyConversationProvider);
  return conversations.when(
    data: (list) => list.where((conversation) => conversation.category == category).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for conversations by level
final conversationsByLevelProvider = Provider.family<List<DailyConversation>, String>((ref, level) {
  final conversations = ref.watch(dailyConversationProvider);
  return conversations.when(
    data: (list) => list.where((conversation) => conversation.level == level).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Service for loading daily conversation data
class DailyConversationService {
  List<DailyConversation> _conversations = [];

  Future<List<DailyConversation>> loadConversations() async {
    if (_conversations.isNotEmpty) {
      return _conversations;
    }

    try {
      print('Loading daily conversations from assets...');
      final String jsonString = await rootBundle.loadString('assets/data/daily_conversations.json');
      print('JSON file loaded successfully, parsing...');

      final Map<String, dynamic> data = json.decode(jsonString);
      print('JSON decoded successfully, extracting conversations...');

      if (!data.containsKey('conversations')) {
        throw Exception('JSON file missing "conversations" key');
      }

      final conversationsList = data['conversations'] as List<dynamic>;
      print('Found ${conversationsList.length} conversations');

      _conversations = conversationsList
          .map((json) {
            try {
              return DailyConversation.fromJson(json);
            } catch (e) {
              print('Error parsing conversation: $e');
              print('Conversation data: $json');
              rethrow;
            }
          })
          .toList();

      print('Successfully parsed ${_conversations.length} daily conversations');
      return _conversations;
    } catch (e) {
      print('Error loading daily conversations: $e');
      throw Exception('Failed to load daily conversations: $e');
    }
  }

  /// Get conversation by ID
  DailyConversation? getConversationById(String id) {
    try {
      return _conversations.firstWhere((conversation) => conversation.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all available categories
  List<String> getAvailableCategories() {
    return _conversations.map((conversation) => conversation.category).toSet().toList();
  }

  /// Get all available levels
  List<String> getAvailableLevels() {
    return _conversations.map((conversation) => conversation.level).toSet().toList();
  }
}

/// Notifier for managing daily conversations state
class DailyConversationNotifier extends AsyncNotifier<List<DailyConversation>> {
  late DailyConversationService _service;

  @override
  Future<List<DailyConversation>> build() async {
    _service = ref.read(dailyConversationServiceProvider);
    return _service.loadConversations();
  }

  /// Reload conversations from data source
  Future<void> reloadConversations() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _service.loadConversations();
    });
  }

  /// Get conversation by ID
  DailyConversation? getConversationById(String id) {
    return _service.getConversationById(id);
  }

  /// Search conversations by text
  List<DailyConversation> searchConversations(String query) {
    if (state.value == null) return [];

    final lowercaseQuery = query.toLowerCase();
    return state.value!.where((conversation) {
      return conversation.title.toLowerCase().contains(lowercaseQuery) ||
             conversation.description.toLowerCase().contains(lowercaseQuery) ||
             conversation.scenario.toLowerCase().contains(lowercaseQuery) ||
             conversation.vocabulary.any((vocab) => vocab.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }
}