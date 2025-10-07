import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/deepseek_service.dart';
import '../models/conversation.dart';

/// Provider for DeepSeek service
final deepSeekServiceProvider = Provider<DeepSeekService>((ref) {
  return DeepSeekService(
    apiKey: 'REDACTED_DEEPSEEK_API_KEY',
    baseUrl: 'https://api.deepseek.com',
  );
});

/// Provider for conversation state
final conversationProvider =
    StateNotifierProvider.family<ConversationNotifier, ConversationState, ConversationScenario>(
  (ref, scenario) {
    final service = ref.watch(deepSeekServiceProvider);
    return ConversationNotifier(service, scenario);
  },
);

/// Conversation state
class ConversationState {
  final List<ConversationMessage> messages;
  final bool isLoading;
  final String? error;
  final ConversationScenario scenario;
  final AIRole role;
  final String userLevel; // A1-C2

  ConversationState({
    required this.messages,
    required this.isLoading,
    this.error,
    required this.scenario,
    required this.role,
    this.userLevel = 'A2', // Default level
  });

  ConversationState copyWith({
    List<ConversationMessage>? messages,
    bool? isLoading,
    String? error,
    ConversationScenario? scenario,
    AIRole? role,
    String? userLevel,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      scenario: scenario ?? this.scenario,
      role: role ?? this.role,
      userLevel: userLevel ?? this.userLevel,
    );
  }
}

/// Conversation state notifier
class ConversationNotifier extends StateNotifier<ConversationState> {
  final DeepSeekService _service;

  ConversationNotifier(this._service, ConversationScenario scenario)
      : super(ConversationState(
          messages: [],
          isLoading: false,
          scenario: scenario,
          role: AIRole.fromScenario(scenario),
        )) {
    _initConversation();
  }

  /// Initialize conversation with greeting from AI
  Future<void> _initConversation() async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _service.sendMessage(
        history: [],
        userMessage: 'Ciao! [Inizia la conversazione con un saluto appropriato per questa situazione]',
        role: state.role,
        userLevel: state.userLevel,
      );

      if (response.success) {
        final aiMessage = ConversationMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: response.message,
          isUser: false,
          timestamp: DateTime.now(),
          corrections: response.corrections,
        );

        state = state.copyWith(
          messages: [aiMessage],
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? '初始化对话失败',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '初始化对话时发生错误: $e',
      );
    }
  }

  /// Send user message and get AI response
  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    // Add user message
    final userMsg = ConversationMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_user',
      content: userMessage.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    try {
      final response = await _service.sendMessage(
        history: state.messages.where((m) => m != userMsg).toList(),
        userMessage: userMessage.trim(),
        role: state.role,
        userLevel: state.userLevel,
      );

      if (response.success) {
        final aiMessage = ConversationMessage(
          id: '${DateTime.now().millisecondsSinceEpoch}_ai',
          content: response.message,
          isUser: false,
          timestamp: DateTime.now(),
          corrections: response.corrections,
        );

        state = state.copyWith(
          messages: [...state.messages, aiMessage],
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? '发送消息失败',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '发送消息时发生错误: $e',
      );
    }
  }

  /// Change user level (A1-C2)
  void setUserLevel(String level) {
    state = state.copyWith(userLevel: level);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset conversation
  void reset() {
    state = ConversationState(
      messages: [],
      isLoading: false,
      scenario: state.scenario,
      role: state.role,
      userLevel: state.userLevel,
    );
    _initConversation();
  }
}
