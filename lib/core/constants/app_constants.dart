class AppConstants {
  // App 基础信息
  static const String appName = 'Italiano';
  static const String appVersion = '1.0.0';

  // CEFR 等级
  static const List<String> cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  // 学习目标（每日单词数）
  static const int defaultDailyGoal = 20;
  static const int minDailyGoal = 5;
  static const int maxDailyGoal = 100;

  // 间隔重复算法参数
  static const List<int> spacedRepetitionIntervals = [
    1, // 1天后
    3, // 3天后
    7, // 1周后
    14, // 2周后
    30, // 1月后
    90, // 3月后
  ];

  // 词汇分类
  static const List<String> vocabularyCategories = [
    '日常用语',
    '食物餐饮',
    '旅游出行',
    '购物消费',
    '工作学习',
    '家庭生活',
    '健康医疗',
    '娱乐运动',
    '文化艺术',
    '商务交流',
  ];

  // 动画时长
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // 成就系统
  static const Map<String, int> achievements = {
    'first_word': 1,
    'streak_7': 7,
    'streak_30': 30,
    'streak_100': 100,
    'words_100': 100,
    'words_500': 500,
    'words_1000': 1000,
    'perfect_week': 7,
  };
}
