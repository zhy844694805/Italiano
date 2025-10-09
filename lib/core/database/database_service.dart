import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

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
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const boolType = 'INTEGER NOT NULL'; // SQLite 使用 INTEGER 表示布尔值

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
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      const textType = 'TEXT NOT NULL';
      const intType = 'INTEGER NOT NULL';
      const boolType = 'INTEGER NOT NULL';

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
  }
}
