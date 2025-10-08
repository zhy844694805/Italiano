import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../../shared/models/quiz.dart';

class QuizRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  // 初始化表(如果数据库升级需要)
  Future<void> _ensureTables() async {
    final db = await _dbService.database;

    // 创建错题记录表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS wrong_questions (
        questionId TEXT PRIMARY KEY,
        wrongCount INTEGER NOT NULL,
        lastWrongAt TEXT NOT NULL,
        mastered INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 创建每日挑战表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_challenges (
        date TEXT PRIMARY KEY,
        completed INTEGER NOT NULL DEFAULT 0,
        score INTEGER NOT NULL DEFAULT 0,
        streak INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 创建测验历史表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS quiz_history (
        id TEXT PRIMARY KEY,
        mode TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        startedAt TEXT NOT NULL,
        completedAt TEXT,
        totalQuestions INTEGER NOT NULL,
        correctCount INTEGER NOT NULL,
        score INTEGER NOT NULL
      )
    ''');

    // 创建测验结果详情表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS quiz_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessionId TEXT NOT NULL,
        questionId TEXT NOT NULL,
        userAnswer TEXT NOT NULL,
        isCorrect INTEGER NOT NULL,
        answeredAt TEXT NOT NULL,
        timeSpentSeconds INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (sessionId) REFERENCES quiz_history (id)
      )
    ''');
  }

  // ============ 错题集管理 ============

  /// 保存或更新错题记录
  Future<void> saveWrongQuestion(WrongQuestionRecord record) async {
    await _ensureTables();
    final db = await _dbService.database;

    await db.insert(
      'wrong_questions',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取所有错题记录(未掌握的)
  Future<List<WrongQuestionRecord>> getWrongQuestions() async {
    await _ensureTables();
    final db = await _dbService.database;

    final maps = await db.query(
      'wrong_questions',
      where: 'mastered = ?',
      whereArgs: [0],
      orderBy: 'lastWrongAt DESC',
    );

    return maps.map((m) => WrongQuestionRecord.fromMap(m)).toList();
  }

  /// 标记题目为已掌握
  Future<void> markQuestionAsMastered(String questionId) async {
    await _ensureTables();
    final db = await _dbService.database;

    await db.update(
      'wrong_questions',
      {'mastered': 1},
      where: 'questionId = ?',
      whereArgs: [questionId],
    );
  }

  /// 增加错题次数
  Future<void> incrementWrongCount(String questionId) async {
    await _ensureTables();
    final db = await _dbService.database;

    final existing = await db.query(
      'wrong_questions',
      where: 'questionId = ?',
      whereArgs: [questionId],
    );

    if (existing.isEmpty) {
      await saveWrongQuestion(WrongQuestionRecord(
        questionId: questionId,
        wrongCount: 1,
        lastWrongAt: DateTime.now(),
      ));
    } else {
      final record = WrongQuestionRecord.fromMap(existing.first);
      await saveWrongQuestion(record.copyWith(
        wrongCount: record.wrongCount + 1,
        lastWrongAt: DateTime.now(),
        mastered: false, // 重置掌握状态
      ));
    }
  }

  /// 获取错题数量
  Future<int> getWrongQuestionsCount() async {
    await _ensureTables();
    final db = await _dbService.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM wrong_questions WHERE mastered = 0',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ============ 每日挑战管理 ============

  /// 获取今日挑战状态
  Future<DailyChallenge?> getTodayChallenge() async {
    await _ensureTables();
    final db = await _dbService.database;
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final maps = await db.query(
      'daily_challenges',
      where: 'date = ?',
      whereArgs: [dateKey],
    );

    if (maps.isEmpty) return null;
    return DailyChallenge.fromMap(maps.first);
  }

  /// 保存每日挑战结果
  Future<void> saveDailyChallenge(DailyChallenge challenge) async {
    await _ensureTables();
    final db = await _dbService.database;

    await db.insert(
      'daily_challenges',
      challenge.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 计算挑战连续天数
  Future<int> calculateChallengeStreak() async {
    await _ensureTables();
    final db = await _dbService.database;

    final maps = await db.query(
      'daily_challenges',
      where: 'completed = 1',
      orderBy: 'date DESC',
    );

    if (maps.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    for (var map in maps) {
      final date = DateTime.parse(map['date'] as String);

      if (lastDate == null) {
        // 检查是否是今天或昨天
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final todayKey =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        final yesterdayKey =
            '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

        if (dateKey != todayKey && dateKey != yesterdayKey) {
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
          break;
        }
      }
    }

    return streak;
  }

  // ============ 测验历史管理 ============

  /// 保存测验会话
  Future<void> saveQuizSession(QuizSession session) async {
    await _ensureTables();
    final db = await _dbService.database;

    // 保存会话基本信息
    await db.insert(
      'quiz_history',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 保存结果详情
    for (var result in session.results) {
      await db.insert('quiz_results', {
        'sessionId': session.id,
        ...result.toMap(),
      });
    }
  }

  /// 获取测验历史
  Future<List<QuizSession>> getQuizHistory({int limit = 20}) async {
    await _ensureTables();
    final db = await _dbService.database;

    final maps = await db.query(
      'quiz_history',
      orderBy: 'startedAt DESC',
      limit: limit,
    );

    final sessions = <QuizSession>[];
    for (var map in maps) {
      // 获取该会话的所有结果
      final resultMaps = await db.query(
        'quiz_results',
        where: 'sessionId = ?',
        whereArgs: [map['id']],
        orderBy: 'answeredAt ASC',
      );

      final results =
          resultMaps.map((r) => QuizResult.fromMap(r)).toList();

      sessions.add(QuizSession(
        id: map['id'] as String,
        mode: QuizMode.values.firstWhere(
          (e) => e.toString() == map['mode'],
          orElse: () => QuizMode.comprehensive,
        ),
        difficulty: QuizDifficulty.values.firstWhere(
          (e) => e.toString() == map['difficulty'],
          orElse: () => QuizDifficulty.mixed,
        ),
        questions: [], // 历史记录不需要完整题目
        results: results,
        startedAt: DateTime.parse(map['startedAt'] as String),
        completedAt: map['completedAt'] != null
            ? DateTime.parse(map['completedAt'] as String)
            : null,
      ));
    }

    return sessions;
  }

  /// 获取测验统计
  Future<Map<String, dynamic>> getQuizStatistics() async {
    await _ensureTables();
    final db = await _dbService.database;

    // 总测验次数
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM quiz_history WHERE completedAt IS NOT NULL',
    );
    final totalQuizzes = Sqflite.firstIntValue(totalResult) ?? 0;

    // 平均分数
    final avgResult = await db.rawQuery(
      'SELECT AVG(score) as avgScore FROM quiz_history WHERE completedAt IS NOT NULL',
    );
    final avgScore = (avgResult.first['avgScore'] as num?)?.toDouble() ?? 0.0;

    // 最高分
    final maxResult = await db.rawQuery(
      'SELECT MAX(score) as maxScore FROM quiz_history',
    );
    final maxScore = Sqflite.firstIntValue(maxResult) ?? 0;

    // 总答题数
    final answeredResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM quiz_results',
    );
    final totalAnswered = Sqflite.firstIntValue(answeredResult) ?? 0;

    // 总正确数
    final correctResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM quiz_results WHERE isCorrect = 1',
    );
    final totalCorrect = Sqflite.firstIntValue(correctResult) ?? 0;

    return {
      'totalQuizzes': totalQuizzes,
      'avgScore': avgScore,
      'maxScore': maxScore,
      'totalAnswered': totalAnswered,
      'totalCorrect': totalCorrect,
      'accuracy': totalAnswered > 0 ? totalCorrect / totalAnswered : 0.0,
    };
  }

  /// 清除所有测验数据
  Future<void> clearAllData() async {
    await _ensureTables();
    final db = await _dbService.database;

    await db.delete('wrong_questions');
    await db.delete('daily_challenges');
    await db.delete('quiz_results');
    await db.delete('quiz_history');
  }
}
