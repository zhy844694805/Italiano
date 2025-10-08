/// 语法点模型
class GrammarPoint {
  final String id;
  final String title;              // 标题，如 "现在时 (Presente)"
  final String category;           // 分类：时态、冠词、代词、介词、形容词、动词变位等
  final String level;              // CEFR等级
  final String description;        // 详细说明
  final List<GrammarRule> rules;   // 规则列表
  final List<GrammarExample> examples; // 例句
  final List<GrammarExercise> exercises; // 练习题
  final String? imageUrl;          // 配图
  final DateTime createdAt;

  GrammarPoint({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.description,
    required this.rules,
    required this.examples,
    this.exercises = const [],
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory GrammarPoint.fromJson(Map<String, dynamic> json) {
    return GrammarPoint(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      level: json['level']?.toString() ?? 'A1',
      description: json['description']?.toString() ?? '',
      rules: json['rules'] != null && json['rules'] is List
          ? (json['rules'] as List<dynamic>)
              .map((r) => GrammarRule.fromJson(r as Map<String, dynamic>))
              .toList()
          : [],
      examples: json['examples'] != null && json['examples'] is List
          ? (json['examples'] as List<dynamic>)
              .map((e) => GrammarExample.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      exercises: json['exercises'] != null && json['exercises'] is List
          ? (json['exercises'] as List<dynamic>)
              .map((e) => GrammarExercise.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      imageUrl: json['imageUrl']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'level': level,
      'description': description,
      'rules': rules.map((r) => r.toJson()).toList(),
      'examples': examples.map((e) => e.toJson()).toList(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// 语法规则
class GrammarRule {
  final String title;       // 规则标题
  final String content;     // 规则内容
  final List<String>? points; // 要点列表

  GrammarRule({
    required this.title,
    required this.content,
    this.points,
  });

  factory GrammarRule.fromJson(Map<String, dynamic> json) {
    return GrammarRule(
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      points: json['points'] != null && json['points'] is List
          ? (json['points'] as List<dynamic>).map((p) => p.toString()).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      if (points != null) 'points': points,
    };
  }
}

/// 语法例句
class GrammarExample {
  final String italian;
  final String chinese;
  final String? english;
  final String? highlight; // 高亮的语法点

  GrammarExample({
    required this.italian,
    required this.chinese,
    this.english,
    this.highlight,
  });

  factory GrammarExample.fromJson(Map<String, dynamic> json) {
    return GrammarExample(
      italian: json['italian']?.toString() ?? '',
      chinese: json['chinese']?.toString() ?? '',
      english: json['english']?.toString(),
      highlight: json['highlight']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'italian': italian,
      'chinese': chinese,
      if (english != null) 'english': english,
      if (highlight != null) 'highlight': highlight,
    };
  }
}

/// 语法练习题
class GrammarExercise {
  final String id;
  final String type;        // 题型: fill_blank, choice, translation
  final String question;    // 题目
  final List<String>? options; // 选项（选择题）
  final String answer;      // 答案
  final String? explanation; // 解析

  GrammarExercise({
    required this.id,
    required this.type,
    required this.question,
    this.options,
    required this.answer,
    this.explanation,
  });

  factory GrammarExercise.fromJson(Map<String, dynamic> json) {
    return GrammarExercise(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      options: json['options'] != null && json['options'] is List
          ? (json['options'] as List<dynamic>).map((o) => o.toString()).toList()
          : null,
      answer: json['answer']?.toString() ?? '',
      explanation: json['explanation']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'question': question,
      if (options != null) 'options': options,
      'answer': answer,
      if (explanation != null) 'explanation': explanation,
    };
  }
}

/// 语法学习记录
class GrammarProgress {
  final String grammarId;
  final DateTime lastStudied;
  final bool completed;
  final int exercisesCorrect;
  final int exercisesTotal;
  final bool isFavorite;

  GrammarProgress({
    required this.grammarId,
    required this.lastStudied,
    this.completed = false,
    this.exercisesCorrect = 0,
    this.exercisesTotal = 0,
    this.isFavorite = false,
  });

  GrammarProgress copyWith({
    DateTime? lastStudied,
    bool? completed,
    int? exercisesCorrect,
    int? exercisesTotal,
    bool? isFavorite,
  }) {
    return GrammarProgress(
      grammarId: grammarId,
      lastStudied: lastStudied ?? this.lastStudied,
      completed: completed ?? this.completed,
      exercisesCorrect: exercisesCorrect ?? this.exercisesCorrect,
      exercisesTotal: exercisesTotal ?? this.exercisesTotal,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'grammarId': grammarId,
      'lastStudied': lastStudied.toIso8601String(),
      'completed': completed ? 1 : 0,
      'exercisesCorrect': exercisesCorrect,
      'exercisesTotal': exercisesTotal,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory GrammarProgress.fromMap(Map<String, dynamic> map) {
    return GrammarProgress(
      grammarId: map['grammarId'] as String,
      lastStudied: DateTime.parse(map['lastStudied'] as String),
      completed: (map['completed'] as int) == 1,
      exercisesCorrect: map['exercisesCorrect'] as int,
      exercisesTotal: map['exercisesTotal'] as int,
      isFavorite: (map['isFavorite'] as int) == 1,
    );
  }
}
