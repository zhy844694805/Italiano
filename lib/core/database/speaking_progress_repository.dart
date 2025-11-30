import 'package:sqflite/sqflite.dart';
import '../database/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/speaking.dart';

/// 口语练习进度数据库存储库
class SpeakingProgressRepository {
  Future<Database> get _database async => await DatabaseService.instance.database;

  /// 添加口语练习记录
  Future<void> addSpeakingRecord(SpeakingRecord record) async {
    final db = await _database;
    await db.insert(
      'speaking_progress',
      record.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取口语练习记录
  Future<SpeakingRecord?> getSpeakingRecord(String exerciseId) async {
    final db = await _database;
    final maps = await db.query(
      'speaking_progress',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return SpeakingRecord.fromJson(maps.first);
  }

  /// 获取所有口语练习记录
  Future<List<SpeakingRecord>> getAllSpeakingRecords() async {
    final db = await _database;
    final maps = await db.query(
      'speaking_progress',
      orderBy: 'practicedAt DESC',
    );
    return maps.map((map) => SpeakingRecord.fromJson(map)).toList();
  }

  /// 获取指定级别的口语练习记录
  Future<List<SpeakingRecord>> getSpeakingRecordsByLevel(String level) async {
    final db = await _database;
    final maps = await db.rawQuery('''
      SELECT sp.*
      FROM speaking_progress sp
      JOIN speaking_exercises se ON sp.exerciseId = se.id
      WHERE se.level = ?
      ORDER BY sp.practicedAt DESC
    ''', [level]);
    return maps.map((map) => SpeakingRecord.fromJson(map)).toList();
  }

  /// 获取指定类别的口语练习记录
  Future<List<SpeakingRecord>> getSpeakingRecordsByCategory(String category) async {
    final db = await _database;
    final maps = await db.rawQuery('''
      SELECT sp.*
      FROM speaking_progress sp
      JOIN speaking_exercises se ON sp.exerciseId = se.id
      WHERE se.category = ?
      ORDER BY sp.practicedAt DESC
    ''', [category]);
    return maps.map((map) => SpeakingRecord.fromJson(map)).toList();
  }

  /// 更新口语练习记录
  Future<void> updateSpeakingRecord(SpeakingRecord record) async {
    final db = await _database;
    await db.update(
      'speaking_progress',
      record.toJson(),
      where: 'exerciseId = ?',
      whereArgs: [record.exerciseId],
    );
  }

  /// 删除口语练习记录
  Future<void> deleteSpeakingRecord(String exerciseId) async {
    final db = await _database;
    await db.delete(
      'speaking_progress',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
    );
  }

  /// 切换收藏状态
  Future<void> toggleFavorite(String exerciseId) async {
    final db = await _database;
    final record = await getSpeakingRecord(exerciseId);
    if (record != null) {
      await db.update(
        'speaking_progress',
        {'isFavorite': record.isFavorite ? 0 : 1},
        where: 'exerciseId = ?',
        whereArgs: [exerciseId],
      );
    }
  }

  /// 获取所有收藏的口语练习
  Future<List<SpeakingRecord>> getFavoriteSpeakingRecords() async {
    final db = await _database;
    final maps = await db.query(
      'speaking_progress',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'practicedAt DESC',
    );
    return maps.map((map) => SpeakingRecord.fromJson(map)).toList();
  }

  /// 获取口语练习统计信息
  Future<Map<String, dynamic>> getSpeakingStatistics() async {
    final db = await _database;
    final maps = await db.rawQuery('''
      SELECT
        COUNT(*) as total_exercises,
        SUM(CASE WHEN isPassed = 1 THEN 1 ELSE 0 END) as passed_exercises,
        SUM(CASE WHEN isPassed = 0 THEN 1 ELSE 0 END) as failed_exercises,
        COUNT(DISTINCT DATE(practicedAt)) as practice_days,
        AVG(score) as avg_score,
        MAX(score) as max_score,
        MIN(score) as min_score,
        AVG(attempts) as avg_attempts,
        SUM(attempts) as total_attempts,
        AVG(recordingDuration) as avg_duration
      FROM speaking_progress
    ''');

    if (maps.isEmpty) return {};

    final stats = maps.first;
    final total = stats['total_exercises'] as int? ?? 0;
    final passed = stats['passed_exercises'] as int? ?? 0;

    return {
      'totalExercises': total,
      'passedExercises': passed,
      'failedExercises': total - passed,
      'accuracy': total > 0 ? (passed / total * 100).round() : 0,
      'practiceDays': stats['practice_days'] as int? ?? 0,
      'avgScore': ((stats['avg_score'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1),
      'maxScore': ((stats['max_score'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1),
      'minScore': ((stats['min_score'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1),
      'avgAttempts': ((stats['avg_attempts'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1),
      'totalAttempts': stats['total_attempts'] as int? ?? 0,
      'avgDuration': Duration(seconds: (stats['avg_duration'] as int?) ?? 0),
    };
  }

  /// 获取最近7天的口语练习记录
  Future<List<Map<String, dynamic>>> getRecentSpeakingStats(int days) async {
    final db = await _database;
    final maps = await db.rawQuery('''
      SELECT
        DATE(practicedAt) as date,
        COUNT(*) as exercises_practiced,
        SUM(CASE WHEN isPassed = 1 THEN 1 ELSE 0 END) as passed_exercises,
        AVG(score) as avg_score,
        SUM(attempts) as total_attempts,
        AVG(recordingDuration) as avg_duration
      FROM speaking_progress
      WHERE practicedAt >= datetime('now', '-$days days')
      GROUP BY DATE(practicedAt)
      ORDER BY date DESC
    ''');
    return maps;
  }

  /// 获取指定分数范围的练习记录
  Future<List<SpeakingRecord>> getRecordsByScoreRange(double minScore, double maxScore) async {
    final db = await _database;
    final maps = await db.query(
      'speaking_progress',
      where: 'score >= ? AND score <= ?',
      whereArgs: [minScore, maxScore],
      orderBy: 'score DESC',
    );
    return maps.map((map) => SpeakingRecord.fromJson(map)).toList();
  }

  /// 获取重复练习次数最多的练习
  Future<List<Map<String, dynamic>>> getMostPracticedExercises(int limit) async {
    final db = await _database;
    final maps = await db.rawQuery('''
      SELECT
        exerciseId,
        COUNT(*) as practice_count,
        AVG(score) as avg_score,
        MAX(score) as best_score,
        attempts
      FROM speaking_progress
      GROUP BY exerciseId
      ORDER BY practice_count DESC, avg_score DESC
      LIMIT ?
    ''', [limit]);
    return maps;
  }

  /// 获取未通过的练习
  Future<List<SpeakingRecord>> getFailedExercises() async {
    final db = await _database;
    final maps = await db.query(
      'speaking_progress',
      where: 'isPassed = ?',
      whereArgs: [0],
      orderBy: 'score ASC',
    );
    return maps.map((map) => SpeakingRecord.fromJson(map)).toList();
  }

  /// 获取已通过的练习
  Future<List<SpeakingRecord>> getPassedExercises() async {
    final db = await _database;
    final maps = await db.query(
      'speaking_progress',
      where: 'isPassed = ?',
      whereArgs: [1],
      orderBy: 'score DESC',
    );
    return maps.map((map) => SpeakingRecord.fromJson(map)).toList();
  }

  /// 清除所有口语练习进度
  Future<void> clearAllSpeakingRecords() async {
    final db = await _database;
    await db.delete('speaking_progress');
  }

  /// 获取口语练习的详细评估数据
  Future<Map<String, dynamic>> getDetailedEvaluation(String exerciseId) async {
    final db = await _database;
    final maps = await db.query(
      'speaking_progress',
      where: 'exerciseId = ?',
      whereArgs: [exerciseId],
      orderBy: 'practicedAt DESC',
      limit: 1,
    );

    if (maps.isEmpty) return {};

    final record = SpeakingRecord.fromJson(maps.first);
    return {
      'score': record.score,
      'detailedScore': record.detailedScore,
      'attempts': record.attempts,
      'feedback': record.feedback,
      'isPassed': record.isPassed,
      'recordingDuration': record.recordingDuration.inSeconds,
    };
  }
}

/// 口语练习进度数据库存储库Provider
final speakingProgressRepositoryProvider = Provider<SpeakingProgressRepository>((ref) {
  return SpeakingProgressRepository();
});