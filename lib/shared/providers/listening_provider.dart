import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/listening.dart';
import '../../core/services/audio_player_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/database/listening_progress_repository.dart';
import '../../core/database/learning_statistics_repository.dart';

/// 听力练习服务
class ListeningService {
  static ListeningService? _instance;
  static ListeningService get instance => _instance ??= ListeningService._();

  ListeningService._();

  List<ListeningExercise>? _exercises;
  bool _isLoading = false;
  String? _error;

  List<ListeningExercise>? get exercises => _exercises;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 加载听力练习数据
  Future<void> loadExercises() async {
    if (_exercises != null && _exercises!.isNotEmpty) return;

    _isLoading = true;
    _error = null;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/listening_exercises.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _exercises = jsonList.map((json) => ListeningExercise.fromJson(json)).toList();
    } catch (e) {
      _error = '加载听力练习失败: $e';
    } finally {
      _isLoading = false;
    }
  }

  /// 根据级别获取听力练习
  List<ListeningExercise> getExercisesByLevel(String level) {
    if (_exercises == null) return [];
    return _exercises!.where((exercise) => exercise.level == level).toList();
  }

  /// 根据类别获取听力练习
  List<ListeningExercise> getExercisesByCategory(String category) {
    if (_exercises == null) return [];
    return _exercises!.where((exercise) => exercise.category == category).toList();
  }

  /// 根据类型获取听力练习
  List<ListeningExercise> getExercisesByType(ListeningType type) {
    if (_exercises == null) return [];
    return _exercises!.where((exercise) => exercise.type == type).toList();
  }

  /// 获取A1必备听力练习
  List<ListeningExercise> getEssentialExercises() {
    if (_exercises == null) return [];
    return _exercises!.where((exercise) => exercise.isEssential).toList();
  }

  /// 根据ID获取听力练习
  ListeningExercise? getExerciseById(String id) {
    if (_exercises == null) return null;
    try {
      return _exercises!.firstWhere((exercise) => exercise.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取所有听力练习类别
  List<String> getCategories() {
    if (_exercises == null) return [];
    final categories = _exercises!.map((e) => e.category).toSet().toList();
    categories.sort();
    return categories;
  }
}

/// 听力练习服务Provider
final listeningServiceProvider = Provider<ListeningService>((ref) {
  return ListeningService.instance;
});

/// 所有听力练习Provider
final allListeningExercisesProvider = FutureProvider<List<ListeningExercise>>((ref) async {
  final service = ref.watch(listeningServiceProvider);
  await service.loadExercises();
  return service.exercises ?? [];
});

/// A1级别听力练习Provider
final a1ListeningExercisesProvider = Provider<List<ListeningExercise>>((ref) {
  final service = ref.watch(listeningServiceProvider);
  return service.getExercisesByLevel('A1');
});

/// A2级别听力练习Provider
final a2ListeningExercisesProvider = Provider<List<ListeningExercise>>((ref) {
  final service = ref.watch(listeningServiceProvider);
  return service.getExercisesByLevel('A2');
});

/// 数字听写练习Provider
final numberDictationProvider = Provider<List<ListeningExercise>>((ref) {
  final service = ref.watch(listeningServiceProvider);
  return service.getExercisesByCategory('数字听写');
});

/// 单词识别练习Provider
final wordRecognitionProvider = Provider<List<ListeningExercise>>((ref) {
  final service = ref.watch(listeningServiceProvider);
  return service.getExercisesByCategory('单词识别');
});

/// 短对话练习Provider
final shortDialogueProvider = Provider<List<ListeningExercise>>((ref) {
  final service = ref.watch(listeningServiceProvider);
  return service.getExercisesByCategory('短对话');
});

/// 问题回答练习Provider
final questionAnswerProvider = Provider<List<ListeningExercise>>((ref) {
  final service = ref.watch(listeningServiceProvider);
  return service.getExercisesByCategory('问题回答');
});

/// A1必备听力练习Provider
final essentialListeningProvider = Provider<List<ListeningExercise>>((ref) {
  final service = ref.watch(listeningServiceProvider);
  return service.getEssentialExercises();
});

/// 听力练习类别Provider
final listeningCategoriesProvider = Provider<List<String>>((ref) {
  final service = ref.watch(listeningServiceProvider);
  return service.getCategories();
});

/// 听力练习进度Notifier
class ListeningProgressNotifier extends StateNotifier<List<ListeningProgress>> {
  final ListeningProgressRepository _repository;
  final LearningStatisticsRepository _statsRepository;

  ListeningProgressNotifier(this._repository, this._statsRepository)
    : super([]) {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final progress = await _repository.getAllListeningProgress();
      state = progress;
    } catch (e) {
      // 错误处理
    }
  }

  /// 添加听力练习进度
  Future<void> addProgress(ListeningProgress progress) async {
    try {
      await _repository.addListeningProgress(progress);

      // 更新学习统计
      final today = DateTime.now();
      await _statsRepository.incrementListeningExercises(today, 1);

      // 重新加载进度
      await _loadProgress();
    } catch (e) {
      // 错误处理
    }
  }

  /// 更新听力练习进度
  Future<void> updateProgress(ListeningProgress progress) async {
    try {
      await _repository.updateListeningProgress(progress);
      await _loadProgress();
    } catch (e) {
      // 错误处理
    }
  }

  /// 切换收藏状态
  Future<void> toggleFavorite(String exerciseId) async {
    try {
      await _repository.toggleFavorite(exerciseId);
      await _loadProgress();
    } catch (e) {
      // 错误处理
    }
  }

  /// 删除听力练习进度
  Future<void> deleteProgress(String exerciseId) async {
    try {
      await _repository.deleteListeningProgress(exerciseId);
      await _loadProgress();
    } catch (e) {
      // 错误处理
    }
  }

  /// 清除所有进度
  Future<void> clearAllProgress() async {
    try {
      await _repository.clearAllListeningProgress();
      state = [];
    } catch (e) {
      // 错误处理
    }
  }

  /// 获取指定练习的进度
  ListeningProgress? getProgress(String exerciseId) {
    try {
      return state.firstWhere((p) => p.exerciseId == exerciseId);
    } catch (e) {
      return null;
    }
  }

  /// 检查练习是否已完成
  bool isCompleted(String exerciseId) {
    return getProgress(exerciseId) != null;
  }

  /// 检查练习是否收藏
  bool isFavorite(String exerciseId) {
    final progress = getProgress(exerciseId);
    return progress?.isFavorite ?? false;
  }

  /// 获取指定级别的进度
  List<ListeningProgress> getProgressByLevel(String level) {
    // 这里需要在数据库中添加与听力练习表的连接
    // 现在返回空列表，实际使用时需要完善
    return [];
  }

  /// 获取指定类别的进度
  List<ListeningProgress> getProgressByCategory(String category) {
    // 这里需要在数据库中添加与听力练习表的连接
    // 现在返回空列表，实际使用时需要完善
    return [];
  }

  /// 获取收藏的练习
  List<ListeningProgress> getFavoriteProgress() {
    return state.where((p) => p.isFavorite).toList();
  }

  /// 获取统计信息
  Map<String, dynamic> getStatistics() {
    if (state.isEmpty) return {};

    final total = state.length;
    final correct = state.where((p) => p.isCorrect).length;
    final accuracy = total > 0 ? (correct / total * 100).round() : 0;

    final avgAttempts = state.isEmpty ? 0 :
      state.map((p) => p.attempts).reduce((a, b) => a + b) / state.length;

    final avgCompletionTime = state.isEmpty ? Duration.zero :
      Duration(seconds: (state.map((p) => p.completionTime.inSeconds).reduce((a, b) => a + b) / state.length).round());

    return {
      'totalExercises': total,
      'correctExercises': correct,
      'incorrectExercises': total - correct,
      'accuracy': accuracy,
      'avgAttempts': avgAttempts.toStringAsFixed(1),
      'avgCompletionTime': '${avgCompletionTime.inMinutes}:${(avgCompletionTime.inSeconds % 60).toString().padLeft(2, '0')}',
    };
  }
}

/// 听力练习进度Provider
final listeningProgressProvider = StateNotifierProvider<ListeningProgressNotifier, List<ListeningProgress>>((ref) {
  final repository = ref.read(listeningProgressRepositoryProvider);
  final statsRepository = ref.read(learningStatisticsRepositoryProvider);
  return ListeningProgressNotifier(repository, statsRepository);
});

/// 听力练习统计Provider
final listeningStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(listeningProgressRepositoryProvider);
  return await repository.getListeningStatistics();
});

/// 当前听力播放状态Provider
class CurrentListeningNotifier extends StateNotifier<ListeningState> {
  final AudioPlayerService _audioPlayer;

  CurrentListeningNotifier(this._audioPlayer) : super(const ListeningState());

  /// 播放听力音频
  Future<void> playAudio(String audioUrl) async {
    state = state.copyWith(isPlaying: true, isLoading: true);

    try {
      await _audioPlayer.playFromUrl(audioUrl);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isPlaying: false,
        isLoading: false,
        error: '播放失败: $e'
      );
    }
  }

  /// 停止播放
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    state = state.copyWith(isPlaying: false, error: null);
  }

  /// 暂停播放
  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    state = state.copyWith(isPlaying: false);
  }

  /// 继续播放
  Future<void> resumeAudio() async {
    await _audioPlayer.resume();
    state = state.copyWith(isPlaying: true);
  }

  /// 设置播放次数
  void setPlayCount(int count) {
    state = state.copyWith(playCount: count, remainingPlays: count);
  }

  /// 减少剩余播放次数
  void decrementRemainingPlays() {
    final remaining = (state.remainingPlays ?? 1) - 1;
    state = state.copyWith(remainingPlays: remaining > 0 ? remaining : 0);
  }

  /// 重置状态
  void reset() {
    state = const ListeningState();
  }

  /// 设置错误状态
  void setError(String error) {
    state = state.copyWith(error: error);
  }
}

/// 当前听力播放状态Provider
final currentListeningProvider = StateNotifierProvider<CurrentListeningNotifier, ListeningState>((ref) {
  final audioPlayer = ref.watch(audioPlayerServiceProvider);
  return CurrentListeningNotifier(audioPlayer);
});

/// 听力播放状态模型
class ListeningState {
  final bool isPlaying;
  final bool isLoading;
  final String? error;
  final int? playCount;
  final int? remainingPlays;

  const ListeningState({
    this.isPlaying = false,
    this.isLoading = false,
    this.error,
    this.playCount = 2,
    this.remainingPlays = 2,
  });

  ListeningState copyWith({
    bool? isPlaying,
    bool? isLoading,
    String? error,
    int? playCount,
    int? remainingPlays,
  }) {
    return ListeningState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      playCount: playCount ?? this.playCount,
      remainingPlays: remainingPlays ?? this.remainingPlays,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListeningState &&
      other.isPlaying == isPlaying &&
      other.isLoading == isLoading &&
      other.error == error &&
      other.playCount == playCount &&
      other.remainingPlays == remainingPlays;
  }

  @override
  int get hashCode {
    return isPlaying.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      playCount.hashCode ^
      remainingPlays.hashCode;
  }
}