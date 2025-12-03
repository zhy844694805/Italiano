import 'package:sqflite/sqflite.dart';
import '../../shared/models/grammar.dart';
import 'database_service.dart';

class GrammarProgressRepository {
  // 单例模式
  static final GrammarProgressRepository _instance = GrammarProgressRepository._internal();
  static GrammarProgressRepository get instance => _instance;

  GrammarProgressRepository._internal();

  // 保留旧的构造函数以保持向后兼容，但实际使用单例
  factory GrammarProgressRepository() => _instance;

  final DatabaseService _dbService = DatabaseService.instance;

  // 保存或更新语法进度
  Future<int> saveProgress(GrammarProgress progress) async {
    final db = await _dbService.database;

    final data = {
      'grammarId': progress.grammarId,
      'completedAt': progress.completed ? progress.lastStudied.toIso8601String() : null,
      'exerciseResults': '${progress.exercisesCorrect}/${progress.exercisesTotal}',
      'isFavorite': progress.isFavorite ? 1 : 0,
    };

    return await db.insert(
      'grammar_progress',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 获取单个语法点的进度
  Future<GrammarProgress?> getProgress(String grammarId) async {
    final db = await _dbService.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'grammar_progress',
      where: 'grammarId = ?',
      whereArgs: [grammarId],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    final exerciseResults = map['exerciseResults'] as String?;
    int correct = 0;
    int total = 0;
    if (exerciseResults != null && exerciseResults.contains('/')) {
      final parts = exerciseResults.split('/');
      correct = int.tryParse(parts[0]) ?? 0;
      total = int.tryParse(parts[1]) ?? 0;
    }

    return GrammarProgress(
      grammarId: map['grammarId'],
      lastStudied: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : DateTime.now(),
      completed: map['completedAt'] != null,
      exercisesCorrect: correct,
      exercisesTotal: total,
      isFavorite: map['isFavorite'] == 1,
    );
  }

  // 获取所有语法进度
  Future<Map<String, GrammarProgress>> getAllProgress() async {
    final db = await _dbService.database;

    final List<Map<String, dynamic>> maps = await db.query('grammar_progress');

    final Map<String, GrammarProgress> progressMap = {};

    for (var map in maps) {
      final exerciseResults = map['exerciseResults'] as String?;
      int correct = 0;
      int total = 0;
      if (exerciseResults != null && exerciseResults.contains('/')) {
        final parts = exerciseResults.split('/');
        correct = int.tryParse(parts[0]) ?? 0;
        total = int.tryParse(parts[1]) ?? 0;
      }

      final progress = GrammarProgress(
        grammarId: map['grammarId'],
        lastStudied: map['completedAt'] != null
            ? DateTime.parse(map['completedAt'])
            : DateTime.now(),
        completed: map['completedAt'] != null,
        exercisesCorrect: correct,
        exercisesTotal: total,
        isFavorite: map['isFavorite'] == 1,
      );
      progressMap[progress.grammarId] = progress;
    }

    return progressMap;
  }

  // 标记为已完成
  Future<int> markAsCompleted(String grammarId) async {
    final existing = await getProgress(grammarId);

    final updated = (existing ?? GrammarProgress(
      grammarId: grammarId,
      lastStudied: DateTime.now(),
    )).copyWith(
      completed: true,
      lastStudied: DateTime.now(),
    );

    return await saveProgress(updated);
  }

  // 切换收藏状态
  Future<int> toggleFavorite(String grammarId) async {
    final existing = await getProgress(grammarId);

    final updated = (existing ?? GrammarProgress(
      grammarId: grammarId,
      lastStudied: DateTime.now(),
    )).copyWith(
      isFavorite: !(existing?.isFavorite ?? false),
    );

    return await saveProgress(updated);
  }

  // 记录练习结果
  Future<int> recordExerciseResult(String grammarId, int correct, int total) async {
    final existing = await getProgress(grammarId);

    final updated = (existing ?? GrammarProgress(
      grammarId: grammarId,
      lastStudied: DateTime.now(),
    )).copyWith(
      exercisesCorrect: correct,
      exercisesTotal: total,
      lastStudied: DateTime.now(),
    );

    return await saveProgress(updated);
  }

  // 获取收藏的语法点数量
  Future<int> getFavoriteCount() async {
    final db = await _dbService.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM grammar_progress WHERE isFavorite = 1',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 获取已完成的语法点数量
  Future<int> getCompletedCount() async {
    final db = await _dbService.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM grammar_progress WHERE completedAt IS NOT NULL',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 统计某天学习的语法点数量
  Future<int> getStudiedCountByDate(DateTime date) async {
    final db = await _dbService.database;

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM grammar_progress WHERE completedAt >= ? AND completedAt <= ?',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 删除语法进度
  Future<int> deleteProgress(String grammarId) async {
    final db = await _dbService.database;

    return await db.delete(
      'grammar_progress',
      where: 'grammarId = ?',
      whereArgs: [grammarId],
    );
  }

  // 清空所有进度
  Future<int> deleteAll() async {
    final db = await _dbService.database;
    return await db.delete('grammar_progress');
  }
}
