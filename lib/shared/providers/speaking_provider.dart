import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/speaking.dart';
import '../../core/services/audio_player_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/database/speaking_progress_repository.dart';
import '../../core/database/learning_statistics_repository.dart';

/// 口语练习服务
class SpeakingService {
  static SpeakingService? _instance;
  static SpeakingService get instance => _instance ??= SpeakingService._();

  SpeakingService._();

  List<SpeakingExercise>? _exercises;
  bool _isLoading = false;
  String? _error;

  List<SpeakingExercise>? get exercises => _exercises;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 加载口语练习数据
  Future<void> loadExercises() async {
    if (_exercises != null && _exercises!.isNotEmpty) return;

    _isLoading = true;
    _error = null;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/speaking_exercises.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _exercises = jsonList.map((json) => SpeakingExercise.fromJson(json)).toList();
    } catch (e) {
      _error = '加载口语练习失败: $e';
    } finally {
      _isLoading = false;
    }
  }

  /// 根据级别获取口语练习
  List<SpeakingExercise> getExercisesByLevel(String level) {
    if (_exercises == null) return [];
    return _exercises!.where((exercise) => exercise.level == level).toList();
  }

  /// 根据类别获取口语练习
  List<SpeakingExercise> getExercisesByCategory(String category) {
    if (_exercises == null) return [];
    return _exercises!.where((exercise) => exercise.category == category).toList();
  }

  /// 根据类型获取口语练习
  List<SpeakingExercise> getExercisesByType(SpeakingType type) {
    if (_exercises == null) return [];
    return _exercises!.where((exercise) => exercise.type == type).toList();
  }

  /// 获取A1必备口语练习
  List<SpeakingExercise> getEssentialExercises() {
    if (_exercises == null) return [];
    return _exercises!.where((exercise) => exercise.isEssential).toList();
  }

  /// 根据ID获取口语练习
  SpeakingExercise? getExerciseById(String id) {
    if (_exercises == null) return null;
    try {
      return _exercises!.firstWhere((exercise) => exercise.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取所有口语练习类别
  List<String> getCategories() {
    if (_exercises == null) return [];
    final categories = _exercises!.map((e) => e.category).toSet().toList();
    categories.sort();
    return categories;
  }

  /// 生成发音评估（模拟）
  Future<Map<String, double>> evaluatePronunciation(
    String userRecording,
    String targetText,
  ) async {
    // 模拟发音评估
    await Future.delayed(const Duration(seconds: 2));

    // 简单的评分逻辑（实际应该使用语音识别API）
    final score = Map<String, double>();

    // 模拟各项评分
    score['accuracy'] = 70 + (DateTime.now().millisecond % 20).toDouble(); // 准确度
    score['fluency'] = 65 + (DateTime.now().millisecond % 25).toDouble(); // 流利度
    score['rhythm'] = 75 + (DateTime.now().millisecond % 15).toDouble(); // 节奏
    score['intonation'] = 60 + (DateTime.now().millisecond % 30).toDouble(); // 语调

    // 计算总分
    score['overall'] = (score['accuracy']! * 0.4 +
                       score['fluency']! * 0.2 +
                       score['rhythm']! * 0.2 +
                       score['intonation']! * 0.2);

    return score;
  }

  /// 生成反馈意见
  String generateFeedback(double overallScore, Map<String, double> detailedScore) {
    if (overallScore >= 90) {
      return '发音优秀！继续保持，你很有语言天赋。';
    } else if (overallScore >= 80) {
      return '发音很好！注意一些细节会更完美。';
    } else if (overallScore >= 70) {
      return '发音不错，需要多练习重音和语调。';
    } else if (overallScore >= 60) {
      return '发音基本正确，建议多听多练。';
    } else {
      return '需要加强基础发音练习，建议从简单词汇开始。';
    }
  }
}

/// 口语练习服务Provider
final speakingServiceProvider = Provider<SpeakingService>((ref) {
  return SpeakingService.instance;
});

/// 所有口语练习Provider
final allSpeakingExercisesProvider = FutureProvider<List<SpeakingExercise>>((ref) async {
  final service = ref.watch(speakingServiceProvider);
  await service.loadExercises();
  return service.exercises ?? [];
});

/// A1级别口语练习Provider
final a1SpeakingExercisesProvider = Provider<List<SpeakingExercise>>((ref) {
  final service = ref.watch(speakingServiceProvider);
  return service.getExercisesByLevel('A1');
});

/// A2级别口语练习Provider
final a2SpeakingExercisesProvider = Provider<List<SpeakingExercise>>((ref) {
  final service = ref.watch(speakingServiceProvider);
  return service.getExercisesByLevel('A2');
});

/// 单词跟读练习Provider
final wordRepetitionProvider = Provider<List<SpeakingExercise>>((ref) {
  final service = ref.watch(speakingServiceProvider);
  return service.getExercisesByCategory('单词跟读');
});

/// 句子重复练习Provider
final sentenceRepetitionProvider = Provider<List<SpeakingExercise>>((ref) {
  final service = ref.watch(speakingServiceProvider);
  return service.getExercisesByCategory('句子重复');
});

/// 日常对话Provider
final dailyDialogueProvider = Provider<List<SpeakingExercise>>((ref) {
  final service = ref.watch(speakingServiceProvider);
  return service.getExercisesByCategory('日常对话');
});

/// A1必备口语练习Provider
final essentialSpeakingProvider = Provider<List<SpeakingExercise>>((ref) {
  final service = ref.watch(speakingServiceProvider);
  return service.getEssentialExercises();
});

/// 口语练习类别Provider
final speakingCategoriesProvider = Provider<List<String>>((ref) {
  final service = ref.watch(speakingServiceProvider);
  return service.getCategories();
});

/// 当前口语练习状态
class SpeakingState {
  final bool isRecording;
  final bool isPlaying;
  final bool isEvaluating;
  final Duration recordingDuration;
  final Map<String, double>? evaluationResult;
  final String? feedback;
  final String? error;

  const SpeakingState({
    this.isRecording = false,
    this.isPlaying = false,
    this.isEvaluating = false,
    this.recordingDuration = Duration.zero,
    this.evaluationResult,
    this.feedback,
    this.error,
  });

  SpeakingState copyWith({
    bool? isRecording,
    bool? isPlaying,
    bool? isEvaluating,
    Duration? recordingDuration,
    Map<String, double>? evaluationResult,
    String? feedback,
    String? error,
  }) {
    return SpeakingState(
      isRecording: isRecording ?? this.isRecording,
      isPlaying: isPlaying ?? this.isPlaying,
      isEvaluating: isEvaluating ?? this.isEvaluating,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      evaluationResult: evaluationResult ?? this.evaluationResult,
      feedback: feedback ?? this.feedback,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpeakingState &&
      other.isRecording == isRecording &&
      other.isPlaying == isPlaying &&
      other.isEvaluating == isEvaluating &&
      other.recordingDuration == recordingDuration &&
      other.evaluationResult == evaluationResult &&
      other.feedback == feedback &&
      other.error == error;
  }

  @override
  int get hashCode {
    return isRecording.hashCode ^
      isPlaying.hashCode ^
      isEvaluating.hashCode ^
      recordingDuration.hashCode ^
      evaluationResult.hashCode ^
      feedback.hashCode ^
      error.hashCode;
  }
}

/// 当前口语练习状态Notifier
class CurrentSpeakingNotifier extends StateNotifier<SpeakingState> {
  final AudioPlayerService _audioPlayer;
  final SpeakingService _speakingService;

  CurrentSpeakingNotifier(this._audioPlayer, this._speakingService)
    : super(const SpeakingState());

  /// 播放标准音频
  Future<void> playStandardAudio(String audioUrl) async {
    state = state.copyWith(isPlaying: true, error: null);

    try {
      await _audioPlayer.playFromUrl(audioUrl);
    } catch (e) {
      state = state.copyWith(
        isPlaying: false,
        error: '播放失败: $e'
      );
    }
  }

  /// 停止播放
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    state = state.copyWith(isPlaying: false);
  }

  /// 开始录音
  Future<void> startRecording() async {
    // 这里应该调用录音功能
    state = state.copyWith(
      isRecording: true,
      recordingDuration: Duration.zero,
      error: null,
    );

    // 模拟录音计时
    await Future.delayed(const Duration(seconds: 1));
    if (state.isRecording) {
      _updateRecordingDuration();
    }
  }

  /// 更新录音时长
  void _updateRecordingDuration() {
    if (!state.isRecording) return;

    final newDuration = state.recordingDuration + const Duration(seconds: 1);
    state = state.copyWith(recordingDuration: newDuration);

    // 继续更新
    Future.delayed(const Duration(seconds: 1), _updateRecordingDuration);
  }

  /// 停止录音
  Future<void> stopRecording() async {
    state = state.copyWith(isRecording: false);

    // 这里应该停止录音并保存文件
    // 暂时模拟
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// 评估发音
  Future<void> evaluatePronunciation(String userText, String targetText) async {
    if (state.isEvaluating) return;

    state = state.copyWith(isEvaluating: true, error: null);

    try {
      final result = await _speakingService.evaluatePronunciation(userText, targetText);
      final feedback = _speakingService.generateFeedback(result['overall']!, result);

      state = state.copyWith(
        isEvaluating: false,
        evaluationResult: result,
        feedback: feedback,
      );
    } catch (e) {
      state = state.copyWith(
        isEvaluating: false,
        error: '评估失败: $e'
      );
    }
  }

  /// 重置状态
  void reset() {
    state = const SpeakingState();
  }

  /// 设置错误状态
  void setError(String error) {
    state = state.copyWith(error: error);
  }
}

/// 当前口语练习状态Provider
final currentSpeakingProvider = StateNotifierProvider<CurrentSpeakingNotifier, SpeakingState>((ref) {
  final audioPlayer = ref.watch(audioPlayerServiceProvider);
  final speakingService = ref.watch(speakingServiceProvider);
  return CurrentSpeakingNotifier(audioPlayer, speakingService);
});

/// 口语练习进度Notifier
class SpeakingProgressNotifier extends StateNotifier<List<SpeakingRecord>> {
  final SpeakingProgressRepository _repository;
  final LearningStatisticsRepository _statsRepository;

  SpeakingProgressNotifier(this._repository, this._statsRepository)
    : super([]) {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final progress = await _repository.getAllSpeakingRecords();
      state = progress;
    } catch (e) {
      // 错误处理
    }
  }

  /// 添加口语练习记录
  Future<void> addRecord(SpeakingRecord record) async {
    try {
      await _repository.addSpeakingRecord(record);

      // 更新学习统计
      final today = DateTime.now();
      await _statsRepository.incrementSpeakingExercises(today, 1);

      // 重新加载进度
      await _loadProgress();
    } catch (e) {
      // 错误处理
    }
  }

  /// 更新口语练习记录
  Future<void> updateRecord(SpeakingRecord record) async {
    try {
      await _repository.updateSpeakingRecord(record);
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

  /// 删除口语练习记录
  Future<void> deleteRecord(String exerciseId) async {
    try {
      await _repository.deleteSpeakingRecord(exerciseId);
      await _loadProgress();
    } catch (e) {
      // 错误处理
    }
  }

  /// 获取指定练习的记录
  SpeakingRecord? getRecord(String exerciseId) {
    try {
      return state.firstWhere((r) => r.exerciseId == exerciseId);
    } catch (e) {
      return null;
    }
  }

  /// 检查练习是否已完成
  bool isCompleted(String exerciseId) {
    return getRecord(exerciseId) != null;
  }

  /// 检查练习是否收藏
  bool isFavorite(String exerciseId) {
    final record = getRecord(exerciseId);
    return record?.isFavorite ?? false;
  }

  /// 清除所有进度
  Future<void> clearAllProgress() async {
    try {
      await _repository.clearAllSpeakingRecords();
      state = [];
    } catch (e) {
      // 错误处理
    }
  }

  /// 获取统计信息
  Map<String, dynamic> getStatistics() {
    if (state.isEmpty) return {};

    final total = state.length;
    final passed = state.where((r) => r.isPassed).length;
    final accuracy = total > 0 ? (passed / total * 100).round() : 0;

    final avgScore = state.isEmpty ? 0 :
      state.map((r) => r.score).reduce((a, b) => a + b) / total;

    final avgAttempts = state.isEmpty ? 0 :
      state.map((r) => r.attempts).reduce((a, b) => a + b) / total;

    return {
      'totalExercises': total,
      'passedExercises': passed,
      'failedExercises': total - passed,
      'accuracy': accuracy,
      'avgScore': avgScore.round(),
      'avgAttempts': avgAttempts.toStringAsFixed(1),
    };
  }
}

/// 口语练习进度Provider
final speakingProgressProvider = StateNotifierProvider<SpeakingProgressNotifier, List<SpeakingRecord>>((ref) {
  final repository = ref.read(speakingProgressRepositoryProvider);
  final statsRepository = ref.read(learningStatisticsRepositoryProvider);
  return SpeakingProgressNotifier(repository, statsRepository);
});

/// 口语练习统计Provider
final speakingStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(speakingProgressRepositoryProvider);
  return await repository.getSpeakingStatistics();
});