/// 听力练习模型
class ListeningExercise {
  final String id;
  final String title;
  final String chineseTitle;
  final String description;
  final String audioUrl;
  final String level; // A1, A2, B1, B2, C1, C2
  final String category; // 数字听写, 单词识别, 短对话, 问题回答
  final ListeningType type;
  final String transcript; // 音频文本
  final String question;
  final List<ListeningOption> options;
  final String correctAnswer;
  final String explanation;
  final Duration duration; // 音频时长
  final int playCount; // 建议播放次数
  final bool isEssential; // 是否为A1必备
  final DateTime createdAt;

  const ListeningExercise({
    required this.id,
    required this.title,
    required this.chineseTitle,
    required this.description,
    required this.audioUrl,
    required this.level,
    required this.category,
    required this.type,
    required this.transcript,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.duration,
    this.playCount = 2,
    this.isEssential = false,
    required this.createdAt,
  });

  factory ListeningExercise.fromJson(Map<String, dynamic> json) {
    return ListeningExercise(
      id: json['id'] as String,
      title: json['title'] as String,
      chineseTitle: json['chineseTitle'] as String,
      description: json['description'] as String,
      audioUrl: json['audioUrl'] as String,
      level: json['level'] as String,
      category: json['category'] as String,
      type: ListeningType.values.firstWhere(
        (e) => e.toString() == 'ListeningType.${json['type']}',
        orElse: () => ListeningType.wordRecognition,
      ),
      transcript: json['transcript'] as String,
      question: json['question'] as String,
      options: (json['options'] as List)
          .map((e) => ListeningOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String,
      duration: Duration(seconds: json['duration'] as int? ?? 10),
      playCount: json['playCount'] as int? ?? 2,
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
      'audioUrl': audioUrl,
      'level': level,
      'category': category,
      'type': type.toString().split('.').last,
      'transcript': transcript,
      'question': question,
      'options': options.map((e) => e.toJson()).toList(),
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'duration': duration.inSeconds,
      'playCount': playCount,
      'isEssential': isEssential,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ListeningExercise copyWith({
    String? id,
    String? title,
    String? chineseTitle,
    String? description,
    String? audioUrl,
    String? level,
    String? category,
    ListeningType? type,
    String? transcript,
    String? question,
    List<ListeningOption>? options,
    String? correctAnswer,
    String? explanation,
    Duration? duration,
    int? playCount,
    bool? isEssential,
    DateTime? createdAt,
  }) {
    return ListeningExercise(
      id: id ?? this.id,
      title: title ?? this.title,
      chineseTitle: chineseTitle ?? this.chineseTitle,
      description: description ?? this.description,
      audioUrl: audioUrl ?? this.audioUrl,
      level: level ?? this.level,
      category: category ?? this.category,
      type: type ?? this.type,
      transcript: transcript ?? this.transcript,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      duration: duration ?? this.duration,
      playCount: playCount ?? this.playCount,
      isEssential: isEssential ?? this.isEssential,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListeningExercise && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ListeningExercise(id: $id, title: $title, level: $level, category: $category)';
  }
}

/// 听力练习类型
enum ListeningType {
  numberDictation,      // 数字听写
  wordRecognition,      // 单词识别
  shortDialogue,         // 短对话
  questionAnswer,        // 问题回答
  sentenceCompletion,    // 句子填空
  pictureDescription,    // 图片描述
}

/// 听力选项
class ListeningOption {
  final String id;
  final String text;
  final String chineseText;

  const ListeningOption({
    required this.id,
    required this.text,
    required this.chineseText,
  });

  factory ListeningOption.fromJson(Map<String, dynamic> json) {
    return ListeningOption(
      id: json['id'] as String,
      text: json['text'] as String,
      chineseText: json['chineseText'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'chineseText': chineseText,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListeningOption && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 听力练习进度
class ListeningProgress {
  final String exerciseId;
  final DateTime completedAt;
  final bool isCorrect;
  final String selectedAnswer;
  final int attempts;
  final Duration completionTime;
  final bool isFavorite;

  const ListeningProgress({
    required this.exerciseId,
    required this.completedAt,
    required this.isCorrect,
    required this.selectedAnswer,
    required this.attempts,
    required this.completionTime,
    this.isFavorite = false,
  });

  factory ListeningProgress.fromJson(Map<String, dynamic> json) {
    return ListeningProgress(
      exerciseId: json['exerciseId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      isCorrect: json['isCorrect'] as int == 1,
      selectedAnswer: json['selectedAnswer'] as String,
      attempts: json['attempts'] as int,
      completionTime: Duration(seconds: json['completionTime'] as int),
      isFavorite: json['isFavorite'] as int == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'completedAt': completedAt.toIso8601String(),
      'isCorrect': isCorrect ? 1 : 0,
      'selectedAnswer': selectedAnswer,
      'attempts': attempts,
      'completionTime': completionTime.inSeconds,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  ListeningProgress copyWith({
    String? exerciseId,
    DateTime? completedAt,
    bool? isCorrect,
    String? selectedAnswer,
    int? attempts,
    Duration? completionTime,
    bool? isFavorite,
  }) {
    return ListeningProgress(
      exerciseId: exerciseId ?? this.exerciseId,
      completedAt: completedAt ?? this.completedAt,
      isCorrect: isCorrect ?? this.isCorrect,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      attempts: attempts ?? this.attempts,
      completionTime: completionTime ?? this.completionTime,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListeningProgress && other.exerciseId == exerciseId;
  }

  @override
  int get hashCode => exerciseId.hashCode;
}