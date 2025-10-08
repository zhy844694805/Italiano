import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/quiz.dart';
import '../../core/database/quiz_repository.dart';
import '../../core/services/quiz_generator_service.dart';
import 'vocabulary_provider.dart';
import 'grammar_provider.dart';

// Quiz服务providers
final quizRepositoryProvider = Provider((ref) => QuizRepository());
final quizGeneratorProvider = Provider((ref) => QuizGeneratorService());

// 当前测验会话provider
final currentQuizSessionProvider =
    StateNotifierProvider<QuizSessionNotifier, QuizSession?>((ref) {
  return QuizSessionNotifier(
    ref.watch(quizRepositoryProvider),
  );
});

// 测验会话状态管理
class QuizSessionNotifier extends StateNotifier<QuizSession?> {
  final QuizRepository _repository;

  QuizSessionNotifier(this._repository) : super(null);

  /// 开始新测验
  Future<void> startQuiz({
    required QuizMode mode,
    required QuizDifficulty difficulty,
    required List<QuizQuestion> questions,
  }) async {
    if (questions.isEmpty) return;

    state = QuizSession(
      id: const Uuid().v4(),
      mode: mode,
      difficulty: difficulty,
      questions: questions,
      startedAt: DateTime.now(),
    );
  }

  /// 提交答案
  Future<void> submitAnswer(String questionId, String answer) async {
    if (state == null) return;

    final currentIndex = state!.results.length;
    if (currentIndex >= state!.questions.length) return;

    final question = state!.questions[currentIndex];
    final isCorrect = question.correctAnswer == answer;

    final result = QuizResult(
      questionId: questionId,
      userAnswer: answer,
      isCorrect: isCorrect,
      answeredAt: DateTime.now(),
    );

    final updatedResults = [...state!.results, result];
    state = state!.copyWith(results: updatedResults);

    // 如果答错,记录到错题集
    if (!isCorrect) {
      await _repository.incrementWrongCount(questionId);
    }

    // 如果测验完成,保存到数据库
    if (updatedResults.length == state!.questions.length) {
      final completedSession = state!.copyWith(
        completedAt: DateTime.now(),
      );
      state = completedSession;
      await _repository.saveQuizSession(completedSession);

      // 如果是每日挑战,更新挑战状态
      if (completedSession.mode == QuizMode.daily) {
        final streak = await _repository.calculateChallengeStreak();
        await _repository.saveDailyChallenge(DailyChallenge(
          date: DateTime.now(),
          completed: true,
          score: completedSession.score,
          streak: streak + 1,
        ));
      }
    }
  }

  /// 重置当前测验
  void reset() {
    state = null;
  }

  /// 获取当前题目
  QuizQuestion? getCurrentQuestion() {
    if (state == null) return null;
    final currentIndex = state!.results.length;
    if (currentIndex >= state!.questions.length) return null;
    return state!.questions[currentIndex];
  }
}

// 生成综合测验provider
final comprehensiveQuizProvider =
    FutureProvider.family<List<QuizQuestion>, QuizDifficulty>(
  (ref, difficulty) async {
    final generator = ref.watch(quizGeneratorProvider);
    final wordsAsync = await ref.watch(allWordsProvider.future);
    final grammarAsync = await ref.watch(allGrammarProvider.future);

    return generator.generateComprehensiveQuiz(
      wordsAsync,
      grammarAsync,
      count: 20,
      difficulty: difficulty,
    );
  },
);

// 生成每日挑战provider
final dailyChallengeQuestionsProvider =
    FutureProvider<List<QuizQuestion>>((ref) async {
  final generator = ref.watch(quizGeneratorProvider);
  final wordsAsync = await ref.watch(allWordsProvider.future);
  final grammarAsync = await ref.watch(allGrammarProvider.future);

  // 每日挑战固定10题,混合难度
  return generator.generateComprehensiveQuiz(
    wordsAsync,
    grammarAsync,
    count: 10,
    difficulty: QuizDifficulty.mixed,
  );
});

// 今日挑战状态provider
final todaysChallengeProvider = FutureProvider<DailyChallenge?>((ref) async {
  final repository = ref.watch(quizRepositoryProvider);
  return await repository.getTodayChallenge();
});

// 错题集provider
final wrongQuestionsProvider =
    FutureProvider<List<WrongQuestionRecord>>((ref) async {
  final repository = ref.watch(quizRepositoryProvider);
  return await repository.getWrongQuestions();
});

// 错题数量provider
final wrongQuestionsCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(quizRepositoryProvider);
  return await repository.getWrongQuestionsCount();
});

// 根据错题生成复习测验
final wrongQuestionsQuizProvider =
    FutureProvider<List<QuizQuestion>>((ref) async {
  final wrongRecords = await ref.watch(wrongQuestionsProvider.future);
  if (wrongRecords.isEmpty) return [];

  final generator = ref.watch(quizGeneratorProvider);
  final wordsAsync = await ref.watch(allWordsProvider.future);
  final grammarAsync = await ref.watch(allGrammarProvider.future);

  // 从错题中提取相关的单词和语法ID
  final wrongWordIds = wrongRecords
      .where((r) => r.questionId.startsWith('v_'))
      .map((r) {
        final parts = r.questionId.split('_');
        return parts.length > 2 ? parts[2] : null;
      })
      .where((id) => id != null)
      .toSet();

  final wrongGrammarIds = wrongRecords
      .where((r) => r.questionId.startsWith('g_'))
      .map((r) {
        final parts = r.questionId.split('_');
        return parts.length > 1 ? parts[1] : null;
      })
      .where((id) => id != null)
      .toSet();

  // 筛选相关的单词和语法
  final wrongWords = wordsAsync
      .where((w) => wrongWordIds.contains(w.id))
      .toList();
  final wrongGrammar = grammarAsync
      .where((g) => wrongGrammarIds.contains(g.id))
      .toList();

  // 生成题目
  final vocabQuestions = generator.generateVocabularyQuestions(
    wrongWords,
    count: wrongWords.length.clamp(0, 10),
  );
  final grammarQuestions = generator.generateGrammarQuestions(
    wrongGrammar,
    count: wrongGrammar.length.clamp(0, 10),
  );

  final allQuestions = [...vocabQuestions, ...grammarQuestions];
  allQuestions.shuffle();

  return allQuestions.take(15).toList();
});

// 测验历史provider
final quizHistoryProvider = FutureProvider<List<QuizSession>>((ref) async {
  final repository = ref.watch(quizRepositoryProvider);
  return await repository.getQuizHistory();
});

// 测验统计provider
final quizStatisticsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(quizRepositoryProvider);
  return await repository.getQuizStatistics();
});

// 挑战连续天数provider
final challengeStreakProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(quizRepositoryProvider);
  return await repository.calculateChallengeStreak();
});
