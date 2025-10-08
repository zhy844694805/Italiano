import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/grammar_progress_repository.dart';
import '../../core/database/learning_statistics_repository.dart';
import '../models/grammar.dart';

// 语法服务
class GrammarService {
  Future<List<GrammarPoint>> loadGrammarPoints() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/sample_grammar.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData.map((json) => GrammarPoint.fromJson(json)).toList();
    } catch (e) {
      print('Error loading grammar points: $e');
      return [];
    }
  }

  Future<List<GrammarPoint>> getGrammarByCategory(String category) async {
    final grammarPoints = await loadGrammarPoints();
    return grammarPoints.where((point) => point.category == category).toList();
  }

  Future<List<GrammarPoint>> getGrammarByLevel(String level) async {
    final grammarPoints = await loadGrammarPoints();
    return grammarPoints.where((point) => point.level == level).toList();
  }
}

// Provider for grammar service
final grammarServiceProvider = Provider<GrammarService>((ref) {
  return GrammarService();
});

// Provider for all grammar points
final allGrammarProvider = FutureProvider<List<GrammarPoint>>((ref) async {
  final service = ref.watch(grammarServiceProvider);
  return service.loadGrammarPoints();
});

// Provider for grammar by category
final grammarByCategoryProvider = FutureProvider.family<List<GrammarPoint>, String>((ref, category) async {
  final service = ref.watch(grammarServiceProvider);
  return service.getGrammarByCategory(category);
});

// Provider for grammar by level
final grammarByLevelProvider = FutureProvider.family<List<GrammarPoint>, String>((ref, level) async {
  final service = ref.watch(grammarServiceProvider);
  return service.getGrammarByLevel(level);
});

// Grammar progress provider
class GrammarProgressNotifier extends StateNotifier<Map<String, GrammarProgress>> {
  final GrammarProgressRepository _repository = GrammarProgressRepository();
  final LearningStatisticsRepository _statsRepo = LearningStatisticsRepository();

  GrammarProgressNotifier() : super({}) {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await _repository.getAllProgress();
    state = progress;
  }

  Future<void> markAsStudied(String grammarId) async {
    final existingProgress = state[grammarId];
    final newProgress = existingProgress?.copyWith(
      lastStudied: DateTime.now(),
    ) ?? GrammarProgress(
      grammarId: grammarId,
      lastStudied: DateTime.now(),
    );

    await _repository.saveProgress(newProgress);
    state = {...state, grammarId: newProgress};
  }

  Future<void> markAsCompleted(String grammarId) async {
    final existingProgress = state[grammarId];
    final newProgress = existingProgress?.copyWith(
      completed: true,
      lastStudied: DateTime.now(),
    ) ?? GrammarProgress(
      grammarId: grammarId,
      lastStudied: DateTime.now(),
      completed: true,
    );

    await _repository.saveProgress(newProgress);
    await _statsRepo.incrementGrammarStudied(DateTime.now(), 1);

    state = {...state, grammarId: newProgress};
  }

  Future<void> recordExerciseResult(String grammarId, bool correct) async {
    final existingProgress = state[grammarId];
    final newProgress = existingProgress?.copyWith(
      exercisesCorrect: existingProgress.exercisesCorrect + (correct ? 1 : 0),
      exercisesTotal: existingProgress.exercisesTotal + 1,
      lastStudied: DateTime.now(),
    ) ?? GrammarProgress(
      grammarId: grammarId,
      lastStudied: DateTime.now(),
      exercisesCorrect: correct ? 1 : 0,
      exercisesTotal: 1,
    );

    await _repository.saveProgress(newProgress);
    state = {...state, grammarId: newProgress};
  }

  Future<void> toggleFavorite(String grammarId) async {
    final existingProgress = state[grammarId];
    final newProgress = existingProgress?.copyWith(
      isFavorite: !existingProgress.isFavorite,
    ) ?? GrammarProgress(
      grammarId: grammarId,
      lastStudied: DateTime.now(),
      isFavorite: true,
    );

    await _repository.saveProgress(newProgress);
    state = {...state, grammarId: newProgress};
  }

  GrammarProgress? getProgress(String grammarId) {
    return state[grammarId];
  }

  List<String> getCompletedGrammarIds() {
    return state.entries
        .where((entry) => entry.value.completed)
        .map((entry) => entry.key)
        .toList();
  }

  List<String> getFavoriteGrammarIds() {
    return state.entries
        .where((entry) => entry.value.isFavorite)
        .map((entry) => entry.key)
        .toList();
  }

  Map<String, dynamic> getStatistics() {
    final totalStudied = state.length;
    final totalCompleted = state.values.where((p) => p.completed).length;
    final totalFavorites = state.values.where((p) => p.isFavorite).length;

    int totalExercises = 0;
    int totalCorrect = 0;
    for (var progress in state.values) {
      totalExercises += progress.exercisesTotal;
      totalCorrect += progress.exercisesCorrect;
    }

    final accuracy = totalExercises > 0 ? totalCorrect / totalExercises : 0.0;

    return {
      'totalStudied': totalStudied,
      'totalCompleted': totalCompleted,
      'totalFavorites': totalFavorites,
      'totalExercises': totalExercises,
      'totalCorrect': totalCorrect,
      'accuracy': accuracy,
    };
  }
}

final grammarProgressProvider = StateNotifierProvider<GrammarProgressNotifier, Map<String, GrammarProgress>>((ref) {
  return GrammarProgressNotifier();
});

// Provider for grammar categories
final grammarCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final grammarPoints = await ref.watch(allGrammarProvider.future);
  final categories = grammarPoints.map((p) => p.category).toSet().toList();
  categories.sort();
  return categories;
});
