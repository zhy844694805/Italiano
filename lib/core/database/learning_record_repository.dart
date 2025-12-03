import 'package:sqflite/sqflite.dart';
import '../../shared/models/word.dart';
import 'database_service.dart';

class LearningRecordRepository {
  // 单例模式
  static final LearningRecordRepository _instance = LearningRecordRepository._internal();
  static LearningRecordRepository get instance => _instance;

  LearningRecordRepository._internal();

  // 保留旧的构造函数以保持向后兼容，但实际使用单例
  factory LearningRecordRepository() => _instance;

  final DatabaseService _dbService = DatabaseService.instance;

  // 保存或更新学习记录
  Future<void> saveLearningRecord(LearningRecord record) async {
    final db = await _dbService.database;

    await db.insert(
      'learning_records',
      _toMap(record),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 批量保存学习记录
  Future<void> saveBatch(List<LearningRecord> records) async {
    final db = await _dbService.database;
    final batch = db.batch();

    for (final record in records) {
      batch.insert(
        'learning_records',
        _toMap(record),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // 获取单个学习记录
  Future<LearningRecord?> getLearningRecord(String wordId) async {
    final db = await _dbService.database;

    final maps = await db.query(
      'learning_records',
      where: 'wordId = ?',
      whereArgs: [wordId],
    );

    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  // 获取所有学习记录
  Future<Map<String, LearningRecord>> getAllLearningRecords() async {
    final db = await _dbService.database;
    final maps = await db.query('learning_records');

    final records = <String, LearningRecord>{};
    for (final map in maps) {
      final record = _fromMap(map);
      records[record.wordId] = record;
    }

    return records;
  }

  // 获取需要复习的单词ID列表
  Future<List<String>> getWordsToReview() async {
    final db = await _dbService.database;
    final now = DateTime.now().toIso8601String();

    final maps = await db.query(
      'learning_records',
      columns: ['wordId'],
      where: 'nextReviewDate <= ?',
      whereArgs: [now],
      orderBy: 'nextReviewDate ASC',
    );

    return maps.map((map) => map['wordId'] as String).toList();
  }

  // 获取收藏的单词ID列表
  Future<List<String>> getFavoriteWordIds() async {
    final db = await _dbService.database;

    final maps = await db.query(
      'learning_records',
      columns: ['wordId'],
      where: 'isFavorite = ?',
      whereArgs: [1],
    );

    return maps.map((map) => map['wordId'] as String).toList();
  }

  // 获取已学习的单词ID列表
  Future<List<String>> getStudiedWordIds() async {
    final db = await _dbService.database;

    final maps = await db.query(
      'learning_records',
      columns: ['wordId'],
    );

    return maps.map((map) => map['wordId'] as String).toList();
  }

  // 删除学习记录
  Future<void> deleteLearningRecord(String wordId) async {
    final db = await _dbService.database;

    await db.delete(
      'learning_records',
      where: 'wordId = ?',
      whereArgs: [wordId],
    );
  }

  // 获取学习统计
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await _dbService.database;

    // 总学习单词数
    final totalCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM learning_records'),
    ) ?? 0;

    // 收藏单词数
    final favoriteCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM learning_records WHERE isFavorite = 1'),
    ) ?? 0;

    // 需要复习的单词数
    final now = DateTime.now().toIso8601String();
    final reviewCount = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM learning_records WHERE nextReviewDate <= ?',
        [now],
      ),
    ) ?? 0;

    // 平均掌握度
    final avgMastery = await db.rawQuery(
      'SELECT AVG(mastery) as avgMastery FROM learning_records',
    );
    final averageMastery = (avgMastery.first['avgMastery'] as double?) ?? 0.0;

    return {
      'totalWords': totalCount,
      'favoriteWords': favoriteCount,
      'wordsToReview': reviewCount,
      'averageMastery': averageMastery,
    };
  }

  // 清空所有学习记录
  Future<void> clearAll() async {
    final db = await _dbService.database;
    await db.delete('learning_records');
  }

  // 将 LearningRecord 转换为 Map
  Map<String, dynamic> _toMap(LearningRecord record) {
    return {
      'wordId': record.wordId,
      'lastReviewed': record.lastReviewed.toIso8601String(),
      'reviewCount': record.reviewCount,
      'correctCount': record.correctCount,
      'mastery': record.mastery,
      'nextReviewDate': record.nextReviewDate?.toIso8601String(),
      'isFavorite': record.isFavorite ? 1 : 0,
    };
  }

  // 将 Map 转换为 LearningRecord
  LearningRecord _fromMap(Map<String, dynamic> map) {
    return LearningRecord(
      wordId: map['wordId'] as String,
      lastReviewed: DateTime.parse(map['lastReviewed'] as String),
      reviewCount: map['reviewCount'] as int,
      correctCount: map['correctCount'] as int,
      mastery: map['mastery'] as double,
      nextReviewDate: map['nextReviewDate'] != null
          ? DateTime.parse(map['nextReviewDate'] as String)
          : null,
      isFavorite: (map['isFavorite'] as int) == 1,
    );
  }
}
