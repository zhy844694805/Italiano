import 'dart:convert';
import 'package:flutter/services.dart';
import '../../shared/models/reading.dart';

/// 阅读文章加载服务
class ReadingService {
  Future<List<ReadingPassage>> loadReadingPassages() async {
    try {
      final String response = await rootBundle.loadString('assets/data/reading_passages.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => ReadingPassage.fromJson(json)).toList();
    } catch (e) {
      // Error loading reading passages
      return [];
    }
  }

  /// 按级别筛选文章
  List<ReadingPassage> filterByLevel(List<ReadingPassage> passages, String level) {
    return passages.where((p) => p.level == level).toList();
  }

  /// 按分类筛选文章
  List<ReadingPassage> filterByCategory(List<ReadingPassage> passages, String category) {
    return passages.where((p) => p.category == category).toList();
  }

  /// 获取所有分类
  List<String> getAllCategories(List<ReadingPassage> passages) {
    return passages.map((p) => p.category).toSet().toList()..sort();
  }
}
