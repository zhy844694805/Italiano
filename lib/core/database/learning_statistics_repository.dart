import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

/// 学习统计数据模型
class DailyStatistics {
  final DateTime date;
  final int wordsLearned;
  final int wordsReviewed;
  final int grammarPointsStudied;
  final int conversationMessages;
  final int studyTimeMinutes;

  DailyStatistics({
    required this.date,
    this.wordsLearned = 0,
    this.wordsReviewed = 0,
    this.grammarPointsStudied = 0,
    this.conversationMessages = 0,
    this.studyTimeMinutes = 0,
  });

  factory DailyStatistics.fromMap(Map<String, dynamic> map) {
    return DailyStatistics(
      date: DateTime.parse(map['date']),
      wordsLearned: map['wordsLearned'] as int,
      wordsReviewed: map['wordsReviewed'] as int,
      grammarPointsStudied: map['grammarPointsStudied'] as int,
      conversationMessages: map['conversationMessages'] as int,
      studyTimeMinutes: map['studyTimeMinutes'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': _dateKey(date),
      'wordsLearned': wordsLearned,
      'wordsReviewed': wordsReviewed,
      'grammarPointsStudied': grammarPointsStudied,
      'conversationMessages': conversationMessages,
      'studyTimeMinutes': studyTimeMinutes,
    };
  }

  static String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class LearningStatisticsRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  // 保存或更新每日统计
  Future<int> saveStatistics(DailyStatistics stats) async {
    final db = await _dbService.database;

    return await db.insert(
      'learning_statistics',
      stats.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 获取某天的统计
  Future<DailyStatistics?> getStatistics(DateTime date) async {
    final db = await _dbService.database;

    final dateKey = DailyStatistics._dateKey(date);
    final List<Map<String, dynamic>> maps = await db.query(
      'learning_statistics',
      where: 'date = ?',
      whereArgs: [dateKey],
    );

    if (maps.isEmpty) return null;

    return DailyStatistics.fromMap(maps.first);
  }

  // 增加单词学习数量
  Future<void> incrementWordsLearned(DateTime date, int count) async {
    await _incrementField(date, 'wordsLearned', count);
  }

  // 增加单词复习数量
  Future<void> incrementWordsReviewed(DateTime date, int count) async {
    await _incrementField(date, 'wordsReviewed', count);
  }

  // 增加语法点学习数量
  Future<void> incrementGrammarStudied(DateTime date, int count) async {
    await _incrementField(date, 'grammarPointsStudied', count);
  }

  // 增加会话消息数量
  Future<void> incrementConversationMessages(DateTime date, int count) async {
    await _incrementField(date, 'conversationMessages', count);
  }

  // 增加学习时长
  Future<void> addStudyTime(DateTime date, int minutes) async {
    await _incrementField(date, 'studyTimeMinutes', minutes);
  }

  // 通用增量更新方法
  Future<void> _incrementField(DateTime date, String field, int increment) async {
    final db = await _dbService.database;
    final dateKey = DailyStatistics._dateKey(date);

    final existing = await getStatistics(date);

    if (existing == null) {
      // 创建新记录
      await db.insert('learning_statistics', {
        'date': dateKey,
        'wordsLearned': field == 'wordsLearned' ? increment : 0,
        'wordsReviewed': field == 'wordsReviewed' ? increment : 0,
        'grammarPointsStudied': field == 'grammarPointsStudied' ? increment : 0,
        'conversationMessages': field == 'conversationMessages' ? increment : 0,
        'studyTimeMinutes': field == 'studyTimeMinutes' ? increment : 0,
      });
    } else {
      // 更新现有记录
      await db.rawUpdate(
        'UPDATE learning_statistics SET $field = $field + ? WHERE date = ?',
        [increment, dateKey],
      );
    }
  }

  // 获取一段时间的统计
  Future<List<DailyStatistics>> getStatisticsRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbService.database;

    final startKey = DailyStatistics._dateKey(startDate);
    final endKey = DailyStatistics._dateKey(endDate);

    final List<Map<String, dynamic>> maps = await db.query(
      'learning_statistics',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startKey, endKey],
      orderBy: 'date ASC',
    );

    return maps.map((m) => DailyStatistics.fromMap(m)).toList();
  }

  // 获取最近N天的统计
  Future<List<DailyStatistics>> getRecentStatistics(int days) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days - 1));

    return await getStatisticsRange(startDate, endDate);
  }

  // 计算连续学习天数
  Future<int> getStudyStreak() async {
    final db = await _dbService.database;

    // 获取所有有学习记录的日期，按日期降序排列
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT date FROM learning_statistics
      WHERE wordsLearned > 0 OR wordsReviewed > 0 OR grammarPointsStudied > 0 OR conversationMessages > 0
      ORDER BY date DESC
      ''',
    );

    if (maps.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    for (var map in maps) {
      final date = DateTime.parse(map['date']);

      if (lastDate == null) {
        // 第一天
        final today = DateTime.now();
        final todayKey = DailyStatistics._dateKey(today);
        final recordKey = DailyStatistics._dateKey(date);

        // 如果最近一次学习不是今天或昨天，连续天数为0
        if (recordKey != todayKey &&
            recordKey != DailyStatistics._dateKey(today.subtract(const Duration(days: 1)))) {
          return 0;
        }

        streak = 1;
        lastDate = date;
      } else {
        // 检查是否连续
        final diff = lastDate.difference(date).inDays;
        if (diff == 1) {
          streak++;
          lastDate = date;
        } else {
          break; // 不连续，停止计数
        }
      }
    }

    return streak;
  }

  // 获取总学习天数
  Future<int> getTotalStudyDays() async {
    final db = await _dbService.database;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count FROM learning_statistics
      WHERE wordsLearned > 0 OR wordsReviewed > 0 OR grammarPointsStudied > 0 OR conversationMessages > 0
      ''',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 获取总学习时长（分钟）
  Future<int> getTotalStudyTime() async {
    final db = await _dbService.database;

    final result = await db.rawQuery(
      'SELECT SUM(studyTimeMinutes) as total FROM learning_statistics',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 删除所有统计数据
  Future<int> deleteAll() async {
    final db = await _dbService.database;
    return await db.delete('learning_statistics');
  }
}
