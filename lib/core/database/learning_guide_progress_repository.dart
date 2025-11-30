import 'package:sqflite/sqflite.dart';
import '../database/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/learning_guide.dart';

/// 学习路径进度数据库存储库
class LearningGuideProgressRepository {
  Future<Database> get _database async => await DatabaseService.instance.database;

  /// 添加学习路径进度
  Future<void> addGuideProgress(LearningGuideProgress progress) async {
    final db = await _database;
    await db.insert(
      'learning_guide_progress',
      progress.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取学习路径进度
  Future<LearningGuideProgress?> getGuideProgress(String guideId) async {
    final db = await _database;
    final maps = await db.query(
      'learning_guide_progress',
      where: 'guideId = ?',
      whereArgs: [guideId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return LearningGuideProgress.fromJson(maps.first);
  }

  /// 获取所有学习路径进度
  Future<List<LearningGuideProgress>> getAllGuideProgress() async {
    final db = await _database;
    final maps = await db.query(
      'learning_guide_progress',
      orderBy: 'lastActiveDate DESC',
    );
    return maps.map((map) => LearningGuideProgress.fromJson(map)).toList();
  }

  /// 获取指定级别的学习路径进度
  Future<List<LearningGuideProgress>> getGuideProgressByLevel(String level) async {
    final db = await _database;
    final maps = await db.rawQuery('''
      SELECT lgp.*
      FROM learning_guide_progress lgp
      JOIN learning_guides lg ON lgp.guideId = lg.id
      WHERE lg.level = ?
      ORDER BY lgp.lastActiveDate DESC
    ''', [level]);
    return maps.map((map) => LearningGuideProgress.fromJson(map)).toList();
  }

  /// 更新学习路径进度
  Future<void> updateGuideProgress(LearningGuideProgress progress) async {
    final db = await _database;
    await db.update(
      'learning_guide_progress',
      progress.toJson(),
      where: 'guideId = ?',
      whereArgs: [progress.guideId],
    );
  }

  /// 删除学习路径进度
  Future<void> deleteGuideProgress(String guideId) async {
    final db = await _database;
    await db.delete(
      'learning_guide_progress',
      where: 'guideId = ?',
      whereArgs: [guideId],
    );
  }

  /// 切换收藏状态
  Future<void> toggleFavorite(String guideId) async {
    final db = await _database;
    final progress = await getGuideProgress(guideId);
    if (progress != null) {
      await db.update(
        'learning_guide_progress',
        {'isFavorite': progress.isFavorite ? 0 : 1},
        where: 'guideId = ?',
        whereArgs: [guideId],
      );
    }
  }

  /// 获取所有收藏的学习路径
  Future<List<LearningGuideProgress>> getFavoriteGuideProgress() async {
    final db = await _database;
    final maps = await db.query(
      'learning_guide_progress',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'lastActiveDate DESC',
    );
    return maps.map((map) => LearningGuideProgress.fromJson(map)).toList();
  }

  /// 获取已完成的学习路径
  Future<List<LearningGuideProgress>> getCompletedGuideProgress() async {
    final db = await _database;
    final maps = await db.query(
      'learning_guide_progress',
      where: 'isCompleted = ?',
      whereArgs: [1],
      orderBy: 'completedAt DESC',
    );
    return maps.map((map) => LearningGuideProgress.fromJson(map)).toList();
  }

  /// 获取活跃的学习路径（未完成但最近活跃）
  Future<List<LearningGuideProgress>> getActiveGuideProgress() async {
    final db = await _database;
    final maps = await db.query(
      'learning_guide_progress',
      where: 'isCompleted = ?',
      whereArgs: [0],
      orderBy: 'lastActiveDate DESC',
      limit: 5,
    );
    return maps.map((map) => LearningGuideProgress.fromJson(map)).toList();
  }

  /// 获取学习路径统计信息
  Future<Map<String, dynamic>> getGuideStatistics() async {
    final db = await _database;
    final maps = await db.rawQuery('''
      SELECT
        COUNT(*) as total_guides,
        SUM(CASE WHEN isCompleted = 1 THEN 1 ELSE 0 END) as completed_guides,
        SUM(CASE WHEN isFavorite = 1 THEN 1 ELSE 0 END) as favorite_guides,
        AVG(currentDay) as avg_current_day,
        MAX(currentDay) as max_current_day,
        SUM(totalMinutesSpent) as total_minutes_spent,
        AVG(totalMinutesSpent) as avg_minutes_spent,
        COUNT(DISTINCT DATE(startedAt)) as distinct_start_days
      FROM learning_guide_progress
    ''');

    if (maps.isEmpty) return {};

    final stats = maps.first;
    return {
      'totalGuides': stats['total_guides'] as int? ?? 0,
      'completedGuides': stats['completed_guides'] as int? ?? 0,
      'favoriteGuides': stats['favorite_guides'] as int? ?? 0,
      'avgCurrentDay': ((stats['avg_current_day'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1),
      'maxCurrentDay': ((stats['max_current_day'] as int?) ?? 0),
      'totalMinutesSpent': stats['total_minutes_spent'] as int? ?? 0,
      'avgMinutesSpent': ((stats['avg_minutes_spent'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1),
      'distinctStartDays': stats['distinct_start_days'] as int? ?? 0,
    };
  }

  /// 获取最近的学习活动
  Future<List<Map<String, dynamic>>> getRecentGuideActivity(int days) async {
    final db = await _database;
    final maps = await db.rawQuery('''
      SELECT
        guideId,
        DATE(lastActiveDate) as date,
        currentDay,
        totalMinutesSpent,
        isCompleted
      FROM learning_guide_progress
      WHERE lastActiveDate >= datetime('now', '-$days days')
      GROUP BY guideId, DATE(lastActiveDate)
      ORDER BY date DESC
    ''');
    return maps;
  }

  /// 获取学习进度趋势
  Future<List<Map<String, dynamic>>> getProgressTrend(String guideId) async {
    final db = await _database;
    final maps = await db.rawQuery('''
      SELECT
        DATE(lastActiveDate) as date,
        currentDay,
        SUM(totalMinutesSpent) as daily_minutes
      FROM learning_guide_progress
      WHERE guideId = ?
      GROUP BY DATE(lastActiveDate)
      ORDER BY date ASC
    ''', [guideId]);
    return maps;
  }

  /// 清除所有学习路径进度
  Future<void> clearAllGuideProgress() async {
    final db = await _database;
    await db.delete('learning_guide_progress');
  }

  /// 获取学习热力图（最活跃的学习路径）
  Future<List<Map<String, dynamic>>> getLearningHeatmap() async {
    final db = await _database;
    final maps = await db.rawQuery('''
      SELECT
        guideId,
        DATE(lastActiveDate) as date,
        COUNT(*) as activity_count
      FROM learning_guide_progress
      WHERE lastActiveDate >= datetime('now', '-90 days')
      GROUP BY guideId, DATE(lastActiveDate)
      ORDER BY date ASC
    ''');
    return maps;
  }

  /// 更新每日学习时间
  Future<void> updateDailyStudyTime(String guideId, DateTime date, int minutes) async {
    final db = await _database;
    await db.rawUpdate('''
      UPDATE learning_guide_progress
      SET totalMinutesSpent = totalMinutesSpent + ?,
          lastActiveDate = ?
      WHERE guideId = ? AND DATE(lastActiveDate) = ?
    ''', [minutes, date.toIso8601String(), guideId, date.toIso8601String()]);
  }

  /// 获取连续学习天数
  Future<int> getConsecutiveStudyDays(String guideId) async {
    final db = await _database;
    final maps = await db.rawQuery('''
      SELECT completedDays
      FROM learning_guide_progress
      WHERE guideId = ?
    ''', [guideId]);

    if (maps.isEmpty) return 0;

    final completedDaysJson = maps.first['completedDays'] as String;
    final completedDays = completedDaysJson.split(',').map((s) => s.trim()).toList();

    if (completedDays.isEmpty) return 0;

    completedDays.sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    int consecutive = 1;
    for (int i = 1; i < completedDays.length; i++) {
      final current = int.parse(completedDays[i]);
      final previous = int.parse(completedDays[i - 1]);

      if (current == previous + 1) {
        consecutive++;
      } else {
        break;
      }
    }

    return consecutive;
  }

  /// 获取学习成就徽章
  Future<List<Map<String, dynamic>>> getAchievementBadges(String guideId) async {
    final progress = await getGuideProgress(guideId);
    if (progress == null) return [];

    final badges = <Map<String, dynamic>>[];

    // 连续学习徽章
    if (progress.consecutiveDays >= 7) {
      badges.add({
        'id': 'week_streak',
        'title': '连续一周',
        'description': '连续学习7天',
        'icon': '🔥',
        'achievedAt': DateTime.now().toIso8601String(),
      });
    }

    if (progress.consecutiveDays >= 14) {
      badges.add({
        'id': 'two_weeks',
        'title': '连续两周',
        'description': '连续学习14天',
        'icon': '💪',
        'achievedAt': DateTime.now().toIso8601String(),
      });
    }

    if (progress.consecutiveDays >= 30) {
      badges.add({
        'id': 'month_streak',
        'title': '连续一月',
        'description': '连续学习30天',
        'icon': '🌟',
        'achievedAt': DateTime.now().toIso8601String(),
      });
    }

    // 进度徽章
    if (progress.progressPercentage >= 0.5) {
      badges.add({
        'id': 'halfway',
        'title': '半程英雄',
        'description': '完成学习路径50%',
        'icon': '🏃‍♂️',
        'achievedAt': DateTime.now().toIso8601String(),
      });
    }

    if (progress.isCompleted) {
      badges.add({
        'id': 'completion',
        'title': '毕业勋章',
        'description': '完成整个学习路径',
        'icon': '🎓',
        'achievedAt': DateTime.now().toIso8601String(),
      });
    }

    return badges;
  }
}

/// 学习路径进度数据库存储库Provider
final learningGuideProgressRepositoryProvider = Provider<LearningGuideProgressRepository>((ref) {
  return LearningGuideProgressRepository();
});