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
      version: 1,
      onCreate: _createDB,
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
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // 清空所有数据（用于测试或重置）
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('learning_records');
  }
}
