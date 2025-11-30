/// 学习路径指导模型
class LearningGuide {
  final String id;
  final String title;
  final String chineseTitle;
  final String description;
  final String level; // A1, A2, B1, B2, C1, C2
  final int totalDays; // 总天数
  final int dailyMinutes; // 建议每日学习时长（分钟）
  final List<DailyTask> tasks; // 每日任务
  final List<LearningMilestone> milestones; // 学习里程碑
  final List<String> requirements; // 学习要求
  final List<String> materials; // 所需材料
  final bool isEssential; // 是否为核心路径
  final DateTime createdAt;

  const LearningGuide({
    required this.id,
    required this.title,
    required this.chineseTitle,
    required this.description,
    required this.level,
    required this.totalDays,
    required this.dailyMinutes,
    required this.tasks,
    required this.milestones,
    required this.requirements,
    required this.materials,
    this.isEssential = false,
    required this.createdAt,
  });

  factory LearningGuide.fromJson(Map<String, dynamic> json) {
    return LearningGuide(
      id: json['id'] as String,
      title: json['title'] as String,
      chineseTitle: json['chineseTitle'] as String,
      description: json['description'] as String,
      level: json['level'] as String,
      totalDays: json['totalDays'] as int,
      dailyMinutes: json['dailyMinutes'] as int,
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => DailyTask.fromJson(e as Map<String, dynamic>))
          .toList(),
      milestones: (json['milestones'] as List<dynamic>)
          .map((e) => LearningMilestone.fromJson(e as Map<String, dynamic>))
          .toList(),
      requirements: (json['requirements'] as List<dynamic>).cast<String>(),
      materials: (json['materials'] as List<dynamic>).cast<String>(),
      isEssential: json['isEssential'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'chineseTitle': chineseTitle,
      'description': description,
      'level': level,
      'totalDays': totalDays,
      'dailyMinutes': dailyMinutes,
      'tasks': tasks.map((e) => e.toJson()).toList(),
      'milestones': milestones.map((e) => e.toJson()).toList(),
      'requirements': requirements,
      'materials': materials,
      'isEssential': isEssential,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  LearningGuide copyWith({
    String? id,
    String? title,
    String? chineseTitle,
    String? description,
    String? level,
    int? totalDays,
    int? dailyMinutes,
    List<DailyTask>? tasks,
    List<LearningMilestone>? milestones,
    List<String>? requirements,
    List<String>? materials,
    bool? isEssential,
    DateTime? createdAt,
  }) {
    return LearningGuide(
      id: id ?? this.id,
      title: title ?? this.title,
      chineseTitle: chineseTitle ?? this.chineseTitle,
      description: description ?? this.description,
      level: level ?? this.level,
      totalDays: totalDays ?? this.totalDays,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      tasks: tasks ?? this.tasks,
      milestones: milestones ?? this.milestones,
      requirements: requirements ?? this.requirements,
      materials: materials ?? this.materials,
      isEssential: isEssential ?? this.isEssential,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LearningGuide && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LearningGuide(id: $id, title: $title, level: $level, days: $totalDays)';
  }
}

/// 每日任务
class DailyTask {
  final int day;
  final String title;
  final String chineseTitle;
  final String description;
  final TaskType type;
  final List<TaskItem> items;
  final int estimatedMinutes;
  final bool isOptional;
  final List<String> prerequisites; // 前置要求

  const DailyTask({
    required this.day,
    required this.title,
    required this.chineseTitle,
    required this.description,
    required this.type,
    required this.items,
    required this.estimatedMinutes,
    this.isOptional = false,
    this.prerequisites = const [],
  });

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      day: json['day'] as int,
      title: json['title'] as String,
      chineseTitle: json['chineseTitle'] as String,
      description: json['description'] as String,
      type: TaskType.values.firstWhere(
        (e) => e.toString() == 'TaskType.${json['type']}',
        orElse: () => TaskType.vocabulary,
      ),
      items: (json['items'] as List<dynamic>)
          .map((e) => TaskItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      estimatedMinutes: json['estimatedMinutes'] as int,
      isOptional: json['isOptional'] as bool? ?? false,
      prerequisites: (json['prerequisites'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'title': title,
      'chineseTitle': chineseTitle,
      'description': description,
      'type': type.toString().split('.').last,
      'items': items.map((e) => e.toJson()).toList(),
      'estimatedMinutes': estimatedMinutes,
      'isOptional': isOptional,
      'prerequisites': prerequisites,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyTask && other.day == day;
  }

  @override
  int get hashCode => day.hashCode;
}

/// 任务类型
enum TaskType {
  vocabulary,      // 词汇学习
  grammar,         // 语法学习
  listening,       // 听力练习
  speaking,        // 口语练习
  reading,         // 阅读理解
  conversation,    // AI对话
  review,          // 复习
  assessment,      // 测试
  practice,        // 综合练习
}

/// 任务项目
class TaskItem {
  final String id;
  final String title;
  final String chineseTitle;
  final String description;
  final String targetType; // 目标类型（单词、语法点等）
  final String targetId; // 目标ID
  final int count; // 数量要求
  final String unit; // 单位（个、分钟等）
  final bool isCompleted;

  const TaskItem({
    required this.id,
    required this.title,
    required this.chineseTitle,
    required this.description,
    required this.targetType,
    required this.targetId,
    required this.count,
    required this.unit,
    this.isCompleted = false,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String,
      chineseTitle: json['chineseTitle'] as String,
      description: json['description'] as String,
      targetType: json['targetType'] as String,
      targetId: json['targetId'] as String,
      count: json['count'] as int,
      unit: json['unit'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'chineseTitle': chineseTitle,
      'description': description,
      'targetType': targetType,
      'targetId': targetId,
      'count': count,
      'unit': unit,
      'isCompleted': isCompleted,
    };
  }

  TaskItem copyWith({
    String? id,
    String? title,
    String? chineseTitle,
    String? description,
    String? targetType,
    String? targetId,
    int? count,
    String? unit,
    bool? isCompleted,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      chineseTitle: chineseTitle ?? this.chineseTitle,
      description: description ?? this.description,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      count: count ?? this.count,
      unit: unit ?? this.unit,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 学习里程碑
class LearningMilestone {
  final int day;
  final String title;
  final String chineseTitle;
  final String description;
  final MilestoneType type;
  final List<String> requirements;
  final String reward;
  final bool isAchieved;

  const LearningMilestone({
    required this.day,
    required this.title,
    required this.chineseTitle,
    required this.description,
    required this.type,
    required this.requirements,
    required this.reward,
    this.isAchieved = false,
  });

  factory LearningMilestone.fromJson(Map<String, dynamic> json) {
    return LearningMilestone(
      day: json['day'] as int,
      title: json['title'] as String,
      chineseTitle: json['chineseTitle'] as String,
      description: json['description'] as String,
      type: MilestoneType.values.firstWhere(
        (e) => e.toString() == 'MilestoneType.${json['type']}',
        orElse: () => MilestoneType.vocabularyMilestone,
      ),
      requirements: (json['requirements'] as List<dynamic>).cast<String>(),
      reward: json['reward'] as String,
      isAchieved: json['isAchieved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'title': title,
      'chineseTitle': chineseTitle,
      'description': description,
      'type': type.toString().split('.').last,
      'requirements': requirements,
      'reward': reward,
      'isAchieved': isAchieved,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LearningMilestone && other.day == day;
  }

  @override
  int get hashCode => day.hashCode;
}

/// 里程碑类型
enum MilestoneType {
  vocabularyMilestone,    // 词汇里程碑
  grammarMilestone,       // 语法里程碑
  speakingMilestone,      // 口语里程碑
  listeningMilestone,     // 听力里程碑
  readingMilestone,       // 阅读里程碑
  comprehensiveMilestone,  // 综合里程碑
}

/// 学习路径进度
class LearningGuideProgress {
  final String guideId;
  final DateTime startedAt;
  final DateTime? lastActiveDate;
  final int currentDay;
  final List<String> completedDays;
  final List<String> completedTasks;
  final List<String> achievedMilestones;
  final int totalMinutesSpent;
  final bool isCompleted;
  final bool isFavorite;

  const LearningGuideProgress({
    required this.guideId,
    required this.startedAt,
    this.lastActiveDate,
    required this.currentDay,
    required this.completedDays,
    required this.completedTasks,
    required this.achievedMilestones,
    required this.totalMinutesSpent,
    required this.isCompleted,
    this.isFavorite = false,
  });

  factory LearningGuideProgress.fromJson(Map<String, dynamic> json) {
    return LearningGuideProgress(
      guideId: json['guideId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.parse(json['lastActiveDate'] as String)
          : null,
      currentDay: json['currentDay'] as int,
      completedDays: (json['completedDays'] as List<dynamic>).cast<String>(),
      completedTasks: (json['completedTasks'] as List<dynamic>).cast<String>(),
      achievedMilestones: (json['achievedMilestones'] as List<dynamic>).cast<String>(),
      totalMinutesSpent: json['totalMinutesSpent'] as int,
      isCompleted: json['isCompleted'] as int == 1,
      isFavorite: json['isFavorite'] as int == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guideId': guideId,
      'startedAt': startedAt.toIso8601String(),
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'currentDay': currentDay,
      'completedDays': completedDays,
      'completedTasks': completedTasks,
      'achievedMilestones': achievedMilestones,
      'totalMinutesSpent': totalMinutesSpent,
      'isCompleted': isCompleted ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  LearningGuideProgress copyWith({
    String? guideId,
    DateTime? startedAt,
    DateTime? lastActiveDate,
    int? currentDay,
    List<String>? completedDays,
    List<String>? completedTasks,
    List<String>? achievedMilestones,
    int? totalMinutesSpent,
    bool? isCompleted,
    bool? isFavorite,
  }) {
    return LearningGuideProgress(
      guideId: guideId ?? this.guideId,
      startedAt: startedAt ?? this.startedAt,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      currentDay: currentDay ?? this.currentDay,
      completedDays: completedDays ?? this.completedDays,
      completedTasks: completedTasks ?? this.completedTasks,
      achievedMilestones: achievedMilestones ?? this.achievedMilestones,
      totalMinutesSpent: totalMinutesSpent ?? this.totalMinutesSpent,
      isCompleted: isCompleted ?? this.isCompleted,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LearningGuideProgress && other.guideId == guideId;
  }

  @override
  int get hashCode => guideId.hashCode;

  /// 计算完成进度百分比
  double get progressPercentage {
    return completedDays.length.toDouble();
  }

  /// 计算连续学习天数
  int get consecutiveDays {
    if (completedDays.isEmpty) return 0;

    final sortedDays = completedDays.toList()..sort();
    var consecutive = 1;

    for (int i = 1; i < sortedDays.length; i++) {
      final current = int.parse(sortedDays[i]);
      final previous = int.parse(sortedDays[i - 1]);

      if (current == previous + 1) {
        consecutive++;
      } else {
        break;
      }
    }

    return consecutive;
  }
}