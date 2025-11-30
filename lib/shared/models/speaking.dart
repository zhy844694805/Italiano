/// 口语练习模型
class SpeakingExercise {
  final String id;
  final String title;
  final String chineseTitle;
  final String description;
  final String audioUrl; // 标准发音音频
  final String level; // A1, A2, B1, B2, C1, C2
  final String category; // 单词跟读, 句子重复, 日常对话
  final SpeakingType type;
  final String text; // 需要跟读的文本
  final String phonetic; // 音标或发音指南
  final String meaning; // 含义解释
  final List<String> keyPoints; // 发音要点
  final List<SpeakingTip> tips; // 发音技巧
  final Duration duration; // 音频时长
  final bool isEssential; // 是否为A1必备
  final DateTime createdAt;

  const SpeakingExercise({
    required this.id,
    required this.title,
    required this.chineseTitle,
    required this.description,
    required this.audioUrl,
    required this.level,
    required this.category,
    required this.type,
    required this.text,
    required this.phonetic,
    required this.meaning,
    required this.keyPoints,
    required this.tips,
    required this.duration,
    this.isEssential = false,
    required this.createdAt,
  });

  factory SpeakingExercise.fromJson(Map<String, dynamic> json) {
    return SpeakingExercise(
      id: json['id'] as String,
      title: json['title'] as String,
      chineseTitle: json['chineseTitle'] as String,
      description: json['description'] as String,
      audioUrl: json['audioUrl'] as String,
      level: json['level'] as String,
      category: json['category'] as String,
      type: SpeakingType.values.firstWhere(
        (e) => e.toString() == 'SpeakingType.${json['type']}',
        orElse: () => SpeakingType.wordRepetition,
      ),
      text: json['text'] as String,
      phonetic: json['phonetic'] as String,
      meaning: json['meaning'] as String,
      keyPoints: (json['keyPoints'] as List<dynamic>).cast<String>(),
      tips: (json['tips'] as List<dynamic>)
          .map((e) => SpeakingTip.fromJson(e as Map<String, dynamic>))
          .toList(),
      duration: Duration(seconds: json['duration'] as int? ?? 5),
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
      'text': text,
      'phonetic': phonetic,
      'meaning': meaning,
      'keyPoints': keyPoints,
      'tips': tips.map((e) => e.toJson()).toList(),
      'duration': duration.inSeconds,
      'isEssential': isEssential,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  SpeakingExercise copyWith({
    String? id,
    String? title,
    String? chineseTitle,
    String? description,
    String? audioUrl,
    String? level,
    String? category,
    SpeakingType? type,
    String? text,
    String? phonetic,
    String? meaning,
    List<String>? keyPoints,
    List<SpeakingTip>? tips,
    Duration? duration,
    bool? isEssential,
    DateTime? createdAt,
  }) {
    return SpeakingExercise(
      id: id ?? this.id,
      title: title ?? this.title,
      chineseTitle: chineseTitle ?? this.chineseTitle,
      description: description ?? this.description,
      audioUrl: audioUrl ?? this.audioUrl,
      level: level ?? this.level,
      category: category ?? this.category,
      type: type ?? this.type,
      text: text ?? this.text,
      phonetic: phonetic ?? this.phonetic,
      meaning: meaning ?? this.meaning,
      keyPoints: keyPoints ?? this.keyPoints,
      tips: tips ?? this.tips,
      duration: duration ?? this.duration,
      isEssential: isEssential ?? this.isEssential,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpeakingExercise && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SpeakingExercise(id: $id, title: $title, level: $level, category: $category)';
  }
}

/// 口语练习类型
enum SpeakingType {
  wordRepetition,    // 单词跟读
  sentenceRepetition, // 句子重复
  dailyDialogue,      // 日常对话
  pronunciation,     // 发音练习
  rhythm,             // 节奏练习
}

/// 发音技巧
class SpeakingTip {
  final String title;
  final String description;
  final String example;
  final TipType type;

  const SpeakingTip({
    required this.title,
    required this.description,
    required this.example,
    required this.type,
  });

  factory SpeakingTip.fromJson(Map<String, dynamic> json) {
    return SpeakingTip(
      title: json['title'] as String,
      description: json['description'] as String,
      example: json['example'] as String,
      type: TipType.values.firstWhere(
        (e) => e.toString() == 'TipType.${json['type']}',
        orElse: () => TipType.vowel,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'example': example,
      'type': type.toString().split('.').last,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpeakingTip && other.title == title;
  }

  @override
  int get hashCode => title.hashCode;
}

/// 技巧类型
enum TipType {
  vowel,       // 元音
  consonant,   // 辅音
  rhythm,      // 节奏
  intonation,  // 语调
  stress,      // 重音
  linking,      // 连音
}

/// 口语练习记录
class SpeakingRecord {
  final String exerciseId;
  final DateTime practicedAt;
  final Duration recordingDuration; // 录音时长
  final String? recordingPath; // 录音文件路径
  final double score; // 发音评分 0-100
  final Map<String, double> detailedScore; // 详细评分
  final bool isPassed; // 是否达标
  final int attempts; // 练习次数
  final String feedback; // 反馈意见
  final bool isFavorite;

  const SpeakingRecord({
    required this.exerciseId,
    required this.practicedAt,
    required this.recordingDuration,
    this.recordingPath,
    required this.score,
    required this.detailedScore,
    required this.isPassed,
    required this.attempts,
    required this.feedback,
    this.isFavorite = false,
  });

  factory SpeakingRecord.fromJson(Map<String, dynamic> json) {
    return SpeakingRecord(
      exerciseId: json['exerciseId'] as String,
      practicedAt: DateTime.parse(json['practicedAt'] as String),
      recordingDuration: Duration(seconds: json['recordingDuration'] as int),
      recordingPath: json['recordingPath'] as String?,
      score: (json['score'] as num).toDouble(),
      detailedScore: Map<String, double>.from(
        (json['detailedScore'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      isPassed: json['isPassed'] as int == 1,
      attempts: json['attempts'] as int,
      feedback: json['feedback'] as String,
      isFavorite: json['isFavorite'] as int == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'practicedAt': practicedAt.toIso8601String(),
      'recordingDuration': recordingDuration.inSeconds,
      'recordingPath': recordingPath,
      'score': score,
      'detailedScore': detailedScore,
      'isPassed': isPassed ? 1 : 0,
      'attempts': attempts,
      'feedback': feedback,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  SpeakingRecord copyWith({
    String? exerciseId,
    DateTime? practicedAt,
    Duration? recordingDuration,
    String? recordingPath,
    double? score,
    Map<String, double>? detailedScore,
    bool? isPassed,
    int? attempts,
    String? feedback,
    bool? isFavorite,
  }) {
    return SpeakingRecord(
      exerciseId: exerciseId ?? this.exerciseId,
      practicedAt: practicedAt ?? this.practicedAt,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      recordingPath: recordingPath ?? this.recordingPath,
      score: score ?? this.score,
      detailedScore: detailedScore ?? this.detailedScore,
      isPassed: isPassed ?? this.isPassed,
      attempts: attempts ?? this.attempts,
      feedback: feedback ?? this.feedback,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpeakingRecord && other.exerciseId == exerciseId;
  }

  @override
  int get hashCode => exerciseId.hashCode;
}

/// 发音评估标准
class PronunciationCriteria {
  final String aspect;
  final double weight; // 权重
  final String description;
  final double score; // 得分
  final String feedback;

  const PronunciationCriteria({
    required this.aspect,
    required this.weight,
    required this.description,
    required this.score,
    required this.feedback,
  });

  factory PronunciationCriteria.fromJson(Map<String, dynamic> json) {
    return PronunciationCriteria(
      aspect: json['aspect'] as String,
      weight: (json['weight'] as num).toDouble(),
      description: json['description'] as String,
      score: (json['score'] as num).toDouble(),
      feedback: json['feedback'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aspect': aspect,
      'weight': weight,
      'description': description,
      'score': score,
      'feedback': feedback,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PronunciationCriteria && other.aspect == aspect;
  }

  @override
  int get hashCode => aspect.hashCode;
}