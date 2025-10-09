/// 阅读理解数据模型
class ReadingPassage {
  final String id;
  final String title; // 文章标题
  final String titleChinese; // 中文标题
  final String level; // A1, A2, B1, etc.
  final String category; // 类别：日常生活、故事、实用文本等
  final String content; // 意大利语正文
  final int wordCount; // 字数
  final int estimatedMinutes; // 预计阅读时间（分钟）
  final List<ReadingQuestion> questions; // 理解题
  final String? audioUrl; // 音频URL（可选）
  final DateTime createdAt;

  ReadingPassage({
    required this.id,
    required this.title,
    required this.titleChinese,
    required this.level,
    required this.category,
    required this.content,
    required this.wordCount,
    required this.estimatedMinutes,
    required this.questions,
    this.audioUrl,
    required this.createdAt,
  });

  factory ReadingPassage.fromJson(Map<String, dynamic> json) {
    return ReadingPassage(
      id: json['id'] as String,
      title: json['title'] as String,
      titleChinese: json['titleChinese'] as String,
      level: json['level'] as String,
      category: json['category'] as String,
      content: json['content'] as String,
      wordCount: json['wordCount'] as int,
      estimatedMinutes: json['estimatedMinutes'] as int,
      questions: (json['questions'] as List)
          .map((q) => ReadingQuestion.fromJson(q))
          .toList(),
      audioUrl: json['audioUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleChinese': titleChinese,
      'level': level,
      'category': category,
      'content': content,
      'wordCount': wordCount,
      'estimatedMinutes': estimatedMinutes,
      'questions': questions.map((q) => q.toJson()).toList(),
      'audioUrl': audioUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// 阅读理解题
class ReadingQuestion {
  final String id;
  final String type; // choice, true_false, fill_blank
  final String question; // 题目（中文）
  final String questionItalian; // 题目（意大利语，可选）
  final List<String>? options; // 选项（多选题）
  final String answer; // 正确答案
  final String explanation; // 答案解释

  ReadingQuestion({
    required this.id,
    required this.type,
    required this.question,
    required this.questionItalian,
    this.options,
    required this.answer,
    required this.explanation,
  });

  factory ReadingQuestion.fromJson(Map<String, dynamic> json) {
    return ReadingQuestion(
      id: json['id'] as String,
      type: json['type'] as String,
      question: json['question'] as String,
      questionItalian: json['questionItalian'] as String,
      options: json['options'] != null
          ? (json['options'] as List).map((o) => o as String).toList()
          : null,
      answer: json['answer'] as String,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'question': question,
      'questionItalian': questionItalian,
      'options': options,
      'answer': answer,
      'explanation': explanation,
    };
  }
}

/// 阅读进度记录
class ReadingProgress {
  final String passageId;
  final DateTime completedAt;
  final int correctAnswers;
  final int totalQuestions;
  final Map<String, String> userAnswers; // questionId -> userAnswer
  final bool isFavorite;

  ReadingProgress({
    required this.passageId,
    required this.completedAt,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.userAnswers,
    this.isFavorite = false,
  });

  double get accuracy => totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      passageId: json['passageId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      correctAnswers: json['correctAnswers'] as int,
      totalQuestions: json['totalQuestions'] as int,
      userAnswers: Map<String, String>.from(json['userAnswers'] as Map),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passageId': passageId,
      'completedAt': completedAt.toIso8601String(),
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'userAnswers': userAnswers,
      'isFavorite': isFavorite,
    };
  }

  // 数据库字段转换
  Map<String, dynamic> toDatabase() {
    return {
      'passage_id': passageId,
      'completed_at': completedAt.toIso8601String(),
      'correct_answers': correctAnswers,
      'total_questions': totalQuestions,
      'user_answers': userAnswers.entries
          .map((e) => '${e.key}:${e.value}')
          .join(','), // 简单序列化
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  factory ReadingProgress.fromDatabase(Map<String, dynamic> map) {
    // 解析user_answers字符串 "q1:A,q2:B"
    final answersStr = map['user_answers'] as String? ?? '';
    final userAnswers = <String, String>{};
    if (answersStr.isNotEmpty) {
      for (var pair in answersStr.split(',')) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          userAnswers[parts[0]] = parts[1];
        }
      }
    }

    return ReadingProgress(
      passageId: map['passage_id'] as String,
      completedAt: DateTime.parse(map['completed_at'] as String),
      correctAnswers: map['correct_answers'] as int,
      totalQuestions: map['total_questions'] as int,
      userAnswers: userAnswers,
      isFavorite: (map['is_favorite'] as int) == 1,
    );
  }
}
