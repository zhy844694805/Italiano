import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/deepseek_service.dart';
import '../../core/database/conversation_history_repository.dart';
import '../../core/database/learning_statistics_repository.dart';
import '../../core/config/api_config.dart';
import '../models/conversation.dart';

/// Provider for DeepSeek service (异步初始化)
/// 如果 API 密钥未配置，返回 null
final deepSeekServiceProvider = FutureProvider<DeepSeekService?>((ref) async {
  final apiKey = await ApiConfig.getDeepSeekApiKey();
  if (apiKey.isEmpty) {
    return null; // API 密钥未配置
  }
  return DeepSeekService(
    apiKey: apiKey,
    baseUrl: ApiConfig.deepSeekBaseUrl,
  );
});

/// Provider for conversation state
final conversationProvider =
    StateNotifierProvider.family<ConversationNotifier, ConversationState, ConversationScenario>(
  (ref, scenario) {
    final serviceAsync = ref.watch(deepSeekServiceProvider);
    // 使用 maybeWhen 处理异步加载状态
    final service = serviceAsync.maybeWhen(
      data: (s) => s,
      orElse: () => null,
    );
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
  final DeepSeekService? _service;
  final ConversationHistoryRepository _historyRepo = ConversationHistoryRepository();
  final LearningStatisticsRepository _statsRepo = LearningStatisticsRepository();

  ConversationNotifier(this._service, ConversationScenario scenario)
      : super(ConversationState(
          messages: [],
          isLoading: false,
          scenario: scenario,
          role: AIRole.fromScenario(scenario),
        )) {
    if (_service != null) {
      _loadHistory();
    }
  }

  /// 检查服务是否可用
  bool get isServiceAvailable => _service != null;

  /// Load conversation history from database
  Future<void> _loadHistory() async {
    try {
      final messages = await _historyRepo.getMessages(state.scenario.id);

      if (messages.isEmpty) {
        // No history, initialize with AI greeting
        await _initConversation();
      } else {
        // Load existing history
        state = state.copyWith(messages: messages);
      }
    } catch (e) {
      // If loading fails, initialize new conversation
      await _initConversation();
    }
  }

  /// Initialize conversation with greeting from AI
  Future<void> _initConversation() async {
    if (_service == null) {
      state = state.copyWith(error: 'AI 服务未初始化，请稍后重试');
      return;
    }
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
          translation: response.translation,
          corrections: response.corrections,
        );

        // Save to database
        await _historyRepo.saveMessage(state.scenario.id, aiMessage);

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
    if (_service == null) {
      state = state.copyWith(error: 'AI 服务未初始化，请稍后重试');
      return;
    }

    // Add user message
    final userMsg = ConversationMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_user',
      content: userMessage.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Save user message to database
    await _historyRepo.saveMessage(state.scenario.id, userMsg);

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
          translation: response.translation,
          corrections: response.corrections,
        );

        // Save AI message to database
        await _historyRepo.saveMessage(state.scenario.id, aiMessage);

        // Update statistics - increment conversation messages
        await _statsRepo.incrementConversationMessages(DateTime.now(), 2); // user + AI

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
  Future<void> reset() async {
    // Delete history from database
    await _historyRepo.deleteMessages(state.scenario.id);

    state = ConversationState(
      messages: [],
      isLoading: false,
      scenario: state.scenario,
      role: state.role,
      userLevel: state.userLevel,
    );
    await _initConversation();
  }
}
