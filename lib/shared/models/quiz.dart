/// 测验题目类型
enum QuizType {
  vocabulary,    // 词汇题
  grammar,       // 语法题
  translation,   // 翻译题
  listening,     // 听力题(未来实现)
}

/// 测验模式
enum QuizMode {
  comprehensive, // 综合测验
  daily,         // 每日挑战
  wrongQuestions, // 错题集
  custom,        // 自定义
}

/// 测验难度
enum QuizDifficulty {
  easy,    // 简单(A1-A2)
  medium,  // 中等(B1-B2)
  hard,    // 困难(C1-C2)
  mixed,   // 混合
}

/// 测验题目
class QuizQuestion {
  final String id;
  final QuizType type;
  final String question;           // 题目文本
  final List<String> options;      // 选项
  final String correctAnswer;      // 正确答案
  final String? explanation;       // 解析
  final String? hint;              // 提示
  final String level;              // CEFR级别
  final String? relatedWordId;     // 关联的单词ID
  final String? relatedGrammarId;  // 关联的语法点ID

  QuizQuestion({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.hint,
    required this.level,
    this.relatedWordId,
    this.relatedGrammarId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'hint': hint,
      'level': level,
      'relatedWordId': relatedWordId,
      'relatedGrammarId': relatedGrammarId,
    };
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id']?.toString() ?? '',
      type: QuizType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => QuizType.vocabulary,
      ),
      question: json['question']?.toString() ?? '',
      options: json['options'] != null && json['options'] is List
          ? (json['options'] as List).map((e) => e.toString()).toList()
          : [],
      correctAnswer: json['correctAnswer']?.toString() ?? '',
      explanation: json['explanation']?.toString(),
      hint: json['hint']?.toString(),
      level: json['level']?.toString() ?? 'A1',
      relatedWordId: json['relatedWordId']?.toString(),
      relatedGrammarId: json['relatedGrammarId']?.toString(),
    );
  }
}

/// 测验结果
class QuizResult {
  final String questionId;
  final String userAnswer;
  final bool isCorrect;
  final DateTime answeredAt;
  final int timeSpentSeconds;

  QuizResult({
    required this.questionId,
    required this.userAnswer,
    required this.isCorrect,
    required this.answeredAt,
    this.timeSpentSeconds = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect ? 1 : 0,
      'answeredAt': answeredAt.toIso8601String(),
      'timeSpentSeconds': timeSpentSeconds,
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      questionId: map['questionId'] as String,
      userAnswer: map['userAnswer'] as String,
      isCorrect: (map['isCorrect'] as int) == 1,
      answeredAt: DateTime.parse(map['answeredAt'] as String),
      timeSpentSeconds: map['timeSpentSeconds'] as int,
    );
  }
}

/// 测验会话
class QuizSession {
  final String id;
  final QuizMode mode;
  final QuizDifficulty difficulty;
  final List<QuizQuestion> questions;
  final List<QuizResult> results;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int totalQuestions;
  final int correctCount;
  final int score; // 分数(0-100)

  QuizSession({
    required this.id,
    required this.mode,
    required this.difficulty,
    required this.questions,
    this.results = const [],
    required this.startedAt,
    this.completedAt,
  })  : totalQuestions = questions.length,
        correctCount = results.where((r) => r.isCorrect).length,
        score = results.isEmpty
            ? 0
            : ((results.where((r) => r.isCorrect).length / results.length) * 100)
                .round();

  bool get isCompleted => results.length == questions.length;
  double get accuracy => results.isEmpty ? 0.0 : correctCount / results.length;
  int get remainingQuestions => totalQuestions - results.length;

  QuizSession copyWith({
    String? id,
    QuizMode? mode,
    QuizDifficulty? difficulty,
    List<QuizQuestion>? questions,
    List<QuizResult>? results,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return QuizSession(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      difficulty: difficulty ?? this.difficulty,
      questions: questions ?? this.questions,
      results: results ?? this.results,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mode': mode.toString(),
      'difficulty': difficulty.toString(),
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'totalQuestions': totalQuestions,
      'correctCount': correctCount,
      'score': score,
    };
  }
}

/// 错题记录
class WrongQuestionRecord {
  final String questionId;
  final int wrongCount;
  final DateTime lastWrongAt;
  final bool mastered; // 是否已掌握(连续答对3次)

  WrongQuestionRecord({
    required this.questionId,
    required this.wrongCount,
    required this.lastWrongAt,
    this.mastered = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'wrongCount': wrongCount,
      'lastWrongAt': lastWrongAt.toIso8601String(),
      'mastered': mastered ? 1 : 0,
    };
  }

  factory WrongQuestionRecord.fromMap(Map<String, dynamic> map) {
    return WrongQuestionRecord(
      questionId: map['questionId'] as String,
      wrongCount: map['wrongCount'] as int,
      lastWrongAt: DateTime.parse(map['lastWrongAt'] as String),
      mastered: (map['mastered'] as int) == 1,
    );
  }

  WrongQuestionRecord copyWith({
    String? questionId,
    int? wrongCount,
    DateTime? lastWrongAt,
    bool? mastered,
  }) {
    return WrongQuestionRecord(
      questionId: questionId ?? this.questionId,
      wrongCount: wrongCount ?? this.wrongCount,
      lastWrongAt: lastWrongAt ?? this.lastWrongAt,
      mastered: mastered ?? this.mastered,
    );
  }
}

/// 每日挑战状态
class DailyChallenge {
  final DateTime date;
  final bool completed;
  final int score;
  final int streak; // 连续完成天数

  DailyChallenge({
    required this.date,
    this.completed = false,
    this.score = 0,
    this.streak = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'completed': completed ? 1 : 0,
      'score': score,
      'streak': streak,
    };
  }

  factory DailyChallenge.fromMap(Map<String, dynamic> map) {
    return DailyChallenge(
      date: DateTime.parse(map['date'] as String),
      completed: (map['completed'] as int) == 1,
      score: map['score'] as int,
      streak: map['streak'] as int,
    );
  }
}
