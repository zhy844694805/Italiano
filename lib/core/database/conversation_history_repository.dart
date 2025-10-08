import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../shared/models/conversation.dart';
import 'database_service.dart';

class ConversationHistoryRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  // 保存消息
  Future<int> saveMessage(String scenarioId, ConversationMessage message) async {
    final db = await _dbService.database;

    return await db.insert('conversation_history', {
      'scenarioId': scenarioId,
      'content': message.content,
      'isUser': message.isUser ? 1 : 0,
      'timestamp': message.timestamp.toIso8601String(),
      'translation': message.translation,
      'grammarCorrections': message.corrections != null
          ? jsonEncode(message.corrections!.map((c) => c.toJson()).toList())
          : null,
    });
  }

  // 获取场景的所有消息
  Future<List<ConversationMessage>> getMessages(String scenarioId) async {
    final db = await _dbService.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'conversation_history',
      where: 'scenarioId = ?',
      whereArgs: [scenarioId],
      orderBy: 'timestamp ASC',
    );

    return maps.map((map) {
      List<GrammarCorrection>? corrections;
      if (map['grammarCorrections'] != null) {
        final List<dynamic> correctionsJson = jsonDecode(map['grammarCorrections']);
        corrections = correctionsJson.map((c) => GrammarCorrection.fromJson(c)).toList();
      }

      return ConversationMessage(
        id: map['id'].toString(),
        content: map['content'],
        isUser: map['isUser'] == 1,
        timestamp: DateTime.parse(map['timestamp']),
        translation: map['translation'],
        corrections: corrections,
      );
    }).toList();
  }

  // 删除场景的所有消息
  Future<int> deleteMessages(String scenarioId) async {
    final db = await _dbService.database;

    return await db.delete(
      'conversation_history',
      where: 'scenarioId = ?',
      whereArgs: [scenarioId],
    );
  }

  // 获取最近的N条消息（跨所有场景）
  Future<List<Map<String, dynamic>>> getRecentMessages(int limit) async {
    final db = await _dbService.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'conversation_history',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return maps;
  }

  // 统计场景的消息数量
  Future<int> getMessageCount(String scenarioId) async {
    final db = await _dbService.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM conversation_history WHERE scenarioId = ?',
      [scenarioId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 统计某天的会话消息总数（用于学习统计）
  Future<int> getMessageCountByDate(DateTime date) async {
    final db = await _dbService.database;

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM conversation_history WHERE timestamp >= ? AND timestamp <= ?',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 清空所有会话历史
  Future<int> deleteAll() async {
    final db = await _dbService.database;
    return await db.delete('conversation_history');
  }
}
