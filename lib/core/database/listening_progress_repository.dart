import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../database/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/listening.dart';

/// 听力练习进度数据库存储库
class ListeningProgressRepository {
  Database get _database => DatabaseService.instance;

  /// 添加听力练习进度
  Future<void> addListeningProgress(ListeningProgress progress) async {
    final db = _database;
    await db.insert(
      'listening_progress',
      progress.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取听力练习进度
  Future<ListeningProgress?> getListeningProgress(String exerciseId) async {
    final db = _database;
    final maps = await db.query(
      'listening_progress',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return ListeningProgress.fromJson(maps.first);
  }

  /// 获取所有听力练习进度
  Future<List<ListeningProgress>> getAllListeningProgress() async {
    final db = _database;
    final maps = await db.query(
      'listening_progress',
      orderBy: 'completedAt DESC',
    );
    return maps.map((map) => ListeningProgress.fromJson(map)).toList();
  }

  /// 获取指定级别的听力练习进度
  Future<List<ListeningProgress>> getListeningProgressByLevel(String level) async {
    final db = _database;
    final maps = await db.rawQuery('''
      SELECT lp.*
      FROM listening_progress lp
      JOIN listening_exercises le ON lp.exerciseId = le.id
      WHERE le.level = ?
      ORDER BY lp.completedAt DESC
    ''', [level]);
    return maps.map((map) => ListeningProgress.fromJson(map)).toList();
  }

  /// 获取指定类别的听力练习进度
  Future<List<ListeningProgress>> getListeningProgressByCategory(String category) async {
    final db = _database;
    final maps = await db.rawQuery('''
      SELECT lp.*
      FROM listening_progress lp
      JOIN listening_exercises le ON lp.exerciseId = le.id
      WHERE le.category = ?
      ORDER BY lp.completedAt DESC
    ''', [category]);
    return maps.map((map) => ListeningProgress.fromJson(map)).toList();
  }

  /// 更新听力练习进度
  Future<void> updateListeningProgress(ListeningProgress progress) async {
    final db = _database;
    await db.update(
      'listening_progress',
      progress.toJson(),
      where: 'exerciseId = ?',
      whereArgs: [progress.exerciseId],
    );
  }

  /// 删除听力练习进度
  Future<void> deleteListeningProgress(String exerciseId) async {
    final db = _database;
    await db.delete(
      'listening_progress',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
  }

  /// 切换收藏状态
  Future<void> toggleFavorite(String exerciseId) async {
    final db = _database;
    final progress = await getListeningProgress(exerciseId);
    if (progress != null) {
      await db.update(
        'listening_progress',
        {'isFavorite': progress.isFavorite ? 0 : 1},
        where: 'exerciseId = ?',
        whereArgs: [exerciseId],
      );
    }
  }

  /// 获取所有收藏的听力练习
  Future<List<ListeningProgress>> getFavoriteListeningProgress() async {
    final db = _database;
    final maps = await db.query(
      'listening_progress',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'completedAt DESC',
    );
    return maps.map((map) => ListeningProgress.fromJson(map)).toList();
  }

  /// 获取听力练习统计信息
  Future<Map<String, dynamic>> getListeningStatistics() async {
    final db = _database;
    final maps = await db.rawQuery('''
      SELECT
        COUNT(*) as total_exercises,
        SUM(CASE WHEN isCorrect = 1 THEN 1 ELSE 0 END) as correct_exercises,
        SUM(CASE WHEN isCorrect = 0 THEN 1 ELSE 0 END) as incorrect_exercises,
        COUNT(DISTINCT DATE(completedAt)) as practice_days,
        MAX(completionTime) as max_completion_time,
        MIN(completionTime) as min_completion_time,
        AVG(completionTime) as avg_completion_time
      FROM listening_progress
    ''');

    if (maps.isEmpty) return {};

    final stats = maps.first;
    final total = stats['total_exercises'] as int? ?? 0;
    final correct = stats['correct_exercises'] as int? ?? 0;

    return {
      'totalExercises': total,
      'correctExercises': correct,
      'incorrectExercises': total - correct,
      'accuracy': total > 0 ? (correct / total * 100).round() : 0,
      'practiceDays': stats['practice_days'] as int? ?? 0,
      'maxCompletionTime': Duration(seconds: stats['max_completion_time'] as int? ?? 0),
      'minCompletionTime': Duration(seconds: stats['min_completion_time'] as int? ?? 0),
      'avgCompletionTime': Duration(seconds: (stats['avg_completion_time'] as num?)?.round() ?? 0),
    };
  }

  /// 获取最近7天的听力练习记录
  Future<List<Map<String, dynamic>>> getRecentListeningStats(int days) async {
    final db = _database;
    final maps = await db.rawQuery('''
      SELECT
        DATE(completedAt) as date,
        COUNT(*) as exercises_completed,
        SUM(CASE WHEN isCorrect = 1 THEN 1 ELSE 0 END) as correct_exercises
      FROM listening_progress
      WHERE completedAt >= datetime('now', '-$days days')
      GROUP BY DATE(completedAt)
      ORDER BY date DESC
    ''');
    return maps;
  }

  /// 清除所有听力练习进度
  Future<void> clearAllListeningProgress() async {
    final db = _database;
    await db.delete('listening_progress');
  }
}

/// 听力练习进度数据库存储库Provider
final listeningProgressRepositoryProvider = Provider<ListeningProgressRepository>((ref) {
  return ListeningProgressRepository();
});