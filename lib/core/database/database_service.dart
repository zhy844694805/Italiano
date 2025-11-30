import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  // 数据库字段类型常量
  static const String idType = 'TEXT PRIMARY KEY';
  static const String textType = 'TEXT NOT NULL';
  static const String intType = 'INTEGER NOT NULL';
  static const String realType = 'REAL NOT NULL';
  static const String boolType = 'INTEGER NOT NULL'; // SQLite 使用 INTEGER 表示布尔值

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('italiano_learning.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final dbFilePath = path.join(dbPath, filePath);

    return await openDatabase(
      dbFilePath,
      version: 6,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {

    // 创建学习记录表
    await db.execute('''
      CREATE TABLE learning_records (
        wordId $idType,
        lastReviewed $textType,
        reviewCount $intType,
        correctCount $intType,
        mastery $realType,
        nextReviewDate $textType,
        isFavorite $boolType
      )
    ''');

    // 创建索引以提高查询性能
    await db.execute('''
      CREATE INDEX idx_next_review ON learning_records(nextReviewDate)
    ''');

    await db.execute('''
      CREATE INDEX idx_favorite ON learning_records(isFavorite)
    ''');

    // 创建会话历史表
    await db.execute('''
      CREATE TABLE conversation_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        scenarioId $textType,
        content $textType,
        isUser $boolType,
        timestamp $textType,
        translation TEXT,
        grammarCorrections TEXT
      )
    ''');

    // 创建索引以提高查询性能
    await db.execute('''
      CREATE INDEX idx_scenario ON conversation_history(scenarioId)
    ''');

    await db.execute('''
      CREATE INDEX idx_timestamp ON conversation_history(timestamp)
    ''');

    // 创建语法学习进度表
    await db.execute('''
      CREATE TABLE grammar_progress (
        grammarId $idType,
        completedAt TEXT,
        exerciseResults TEXT,
        isFavorite $boolType
      )
    ''');

    // 创建学习统计表（记录每日学习数据）
    await db.execute('''
      CREATE TABLE learning_statistics (
        date $idType,
        wordsLearned $intType,
        wordsReviewed $intType,
        grammarPointsStudied $intType,
        conversationMessages $intType,
        listeningExercises $intType,
        speakingExercises $intType,
        studyTimeMinutes $intType
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_date ON learning_statistics(date)
    ''');

    // 创建阅读进度表
    await db.execute('''
      CREATE TABLE reading_progress (
        passage_id $idType,
        completed_at $textType,
        correct_answers $intType,
        total_questions $intType,
        user_answers $textType,
        is_favorite $boolType
      )
    ''');

    // 创建听力练习进度表
    await db.execute('''
      CREATE TABLE listening_progress (
        exerciseId $idType,
        completedAt $textType,
        isCorrect $boolType,
        selectedAnswer $textType,
        attempts $intType,
        completionTime $intType,
        isFavorite $boolType
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_listening_exercise ON listening_progress(exerciseId)
    ''');

    await db.execute('''
      CREATE INDEX idx_listening_completed ON listening_progress(completedAt)
    ''');

    // 创建口语练习进度表
    await db.execute('''
      CREATE TABLE speaking_progress (
        exerciseId $idType,
        practicedAt $textType,
        recordingDuration $intType,
        recordingPath TEXT,
        score REAL,
        detailedScore TEXT,
        isPassed $boolType,
        attempts $intType,
        feedback TEXT,
        isFavorite $boolType
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_speaking_exercise ON speaking_progress(exerciseId)
    ''');

    await db.execute('''
      CREATE INDEX idx_speaking_practiced ON speaking_progress(practicedAt)
    ''');

    // 创建学习路径进度表
    await db.execute('''
      CREATE TABLE learning_guide_progress (
        guideId $idType,
        startedAt $textType,
        lastActiveDate TEXT,
        currentDay $intType,
        completedDays TEXT,
        completedTasks TEXT,
        achievedMilestones TEXT,
        totalMinutesSpent $intType,
        isCompleted $boolType,
        isFavorite $boolType
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_learning_guide ON learning_guide_progress(guideId)
    ''');

    await db.execute('''
      CREATE INDEX idx_learning_guide_active ON learning_guide_progress(lastActiveDate)
    ''');

    await db.execute('''
      CREATE INDEX idx_learning_guide_completed ON learning_guide_progress(isCompleted)
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {

      // 创建会话历史表
      await db.execute('''
        CREATE TABLE conversation_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          scenarioId $textType,
          content $textType,
          isUser $boolType,
          timestamp $textType,
          translation TEXT,
          grammarCorrections TEXT
        )
      ''');

      await db.execute('''
        CREATE INDEX idx_scenario ON conversation_history(scenarioId)
      ''');

      await db.execute('''
        CREATE INDEX idx_timestamp ON conversation_history(timestamp)
      ''');

      // 创建语法学习进度表
      await db.execute('''
        CREATE TABLE grammar_progress (
          grammarId TEXT PRIMARY KEY,
          completedAt TEXT,
          exerciseResults TEXT,
          isFavorite $boolType
        )
      ''');

      // 创建学习统计表
      await db.execute('''
        CREATE TABLE learning_statistics (
          date TEXT PRIMARY KEY,
          wordsLearned $intType,
          wordsReviewed $intType,
          grammarPointsStudied $intType,
          conversationMessages $intType,
          studyTimeMinutes $intType
        )
      ''');

      await db.execute('''
        CREATE INDEX idx_date ON learning_statistics(date)
      ''');

      // 添加听力和口语练习字段
      await db.execute('''
        ALTER TABLE learning_statistics ADD COLUMN listeningExercises $intType NOT NULL DEFAULT 0
      ''');
      await db.execute('''
        ALTER TABLE learning_statistics ADD COLUMN speakingExercises $intType NOT NULL DEFAULT 0
      ''');
    }

    if (oldVersion < 3) {
      const idType = 'TEXT PRIMARY KEY';
      const textType = 'TEXT NOT NULL';
      const intType = 'INTEGER NOT NULL';
      const boolType = 'INTEGER NOT NULL';

      // 创建阅读进度表
      await db.execute('''
        CREATE TABLE reading_progress (
          passage_id $idType,
          completed_at $textType,
          correct_answers $intType,
          total_questions $intType,
          user_answers $textType,
          is_favorite $boolType
        )
      ''');
    }

    if (oldVersion < 4) {
      const idType = 'TEXT PRIMARY KEY';
      const textType = 'TEXT NOT NULL';
      const intType = 'INTEGER NOT NULL';
      const boolType = 'INTEGER NOT NULL';

      // 创建听力练习进度表
      await db.execute('''
        CREATE TABLE listening_progress (
          exerciseId $idType,
          completedAt $textType,
          isCorrect $boolType,
          selectedAnswer $textType,
          attempts $intType,
          completionTime $intType,
          isFavorite $boolType
        )
      ''');

      await db.execute('''
        CREATE INDEX idx_listening_exercise ON listening_progress(exerciseId)
      ''');

      await db.execute('''
        CREATE INDEX idx_listening_completed ON listening_progress(completedAt)
      ''');
    }

    if (oldVersion < 5) {
      // 创建口语练习进度表
      await db.execute('''
        CREATE TABLE speaking_progress (
          exerciseId $idType,
          practicedAt $textType,
          recordingDuration $intType,
          recordingPath TEXT,
          score REAL,
          detailedScore TEXT,
          isPassed $boolType,
          attempts $intType,
          feedback TEXT,
          isFavorite $boolType
        )
      ''');

      await db.execute('''
        CREATE INDEX idx_speaking_exercise ON speaking_progress(exerciseId)
      ''');

      await db.execute('''
        CREATE INDEX idx_speaking_practiced ON speaking_progress(practicedAt)
      ''');
    }

    if (oldVersion < 6) {
      // 创建学习路径进度表
      await db.execute('''
        CREATE TABLE learning_guide_progress (
          guideId $idType,
          startedAt $textType,
          lastActiveDate TEXT,
          currentDay $intType,
          completedDays TEXT,
          completedTasks TEXT,
          achievedMilestones TEXT,
          totalMinutesSpent $intType,
          isCompleted $boolType,
          isFavorite $boolType
        )
      ''');

      await db.execute('''
        CREATE INDEX idx_learning_guide ON learning_guide_progress(guideId)
      ''');

      await db.execute('''
        CREATE INDEX idx_learning_guide_active ON learning_guide_progress(lastActiveDate)
      ''');

      await db.execute('''
        CREATE INDEX idx_learning_guide_completed ON learning_guide_progress(isCompleted)
      ''');
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // 清空所有数据（用于测试或重置）
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('learning_records');
    await db.delete('conversation_history');
    await db.delete('grammar_progress');
    await db.delete('learning_statistics');
    await db.delete('reading_progress');
    await db.delete('listening_progress');
    await db.delete('speaking_progress');
    await db.delete('learning_guide_progress');
  }
}
