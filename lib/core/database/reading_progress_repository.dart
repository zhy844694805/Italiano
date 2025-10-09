import 'package:sqflite/sqflite.dart';
import '../../shared/models/reading.dart';
import 'database_service.dart';

/// 阅读进度数据库仓储
class ReadingProgressRepository {
  final DatabaseService _databaseService;

  ReadingProgressRepository(this._databaseService);

  /// 保存阅读进度
  Future<void> saveProgress(ReadingProgress progress) async {
    final db = await _databaseService.database;
    await db.insert(
      'reading_progress',
      progress.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取指定文章的进度
  Future<ReadingProgress?> getProgress(String passageId) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reading_progress',
      where: 'passage_id = ?',
      whereArgs: [passageId],
    );

    if (maps.isEmpty) return null;
    return ReadingProgress.fromDatabase(maps.first);
  }

  /// 获取所有已完成的文章进度
  Future<List<ReadingProgress>> getAllProgress() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('reading_progress');
    return maps.map((map) => ReadingProgress.fromDatabase(map)).toList();
  }

  /// 切换收藏状态
  Future<void> toggleFavorite(String passageId) async {
    final db = await _databaseService.database;
    final progress = await getProgress(passageId);

    if (progress != null) {
      await db.update(
        'reading_progress',
        {'is_favorite': progress.isFavorite ? 0 : 1},
        where: 'passage_id = ?',
        whereArgs: [passageId],
      );
    }
  }

  /// 获取收藏的文章ID列表
  Future<List<String>> getFavoritePassageIds() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reading_progress',
      where: 'is_favorite = ?',
      whereArgs: [1],
    );
    return maps.map((map) => map['passage_id'] as String).toList();
  }

  /// 获取统计信息
  Future<Map<String, int>> getStatistics() async {
    final allProgress = await getAllProgress();

    int totalCompleted = allProgress.length;
    int totalCorrect = 0;
    int totalQuestions = 0;

    for (var progress in allProgress) {
      totalCorrect += progress.correctAnswers;
      totalQuestions += progress.totalQuestions;
    }

    return {
      'completed': totalCompleted,
      'correctAnswers': totalCorrect,
      'totalQuestions': totalQuestions,
    };
  }
}
