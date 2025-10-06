class Word {
  final String id;
  final String italian;
  final String chinese;
  final String? english;
  final String? pronunciation; // IPA 发音
  final String? audioUrl;
  final String category;
  final String level; // A1, A2, B1, B2, C1, C2
  final List<String> examples; // 例句
  final String? imageUrl;
  final DateTime createdAt;

  Word({
    required this.id,
    required this.italian,
    required this.chinese,
    this.english,
    this.pronunciation,
    this.audioUrl,
    required this.category,
    required this.level,
    this.examples = const [],
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'italian': italian,
      'chinese': chinese,
      'english': english,
      'pronunciation': pronunciation,
      'audioUrl': audioUrl,
      'category': category,
      'level': level,
      'examples': examples,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'],
      italian: json['italian'],
      chinese: json['chinese'],
      english: json['english'],
      pronunciation: json['pronunciation'],
      audioUrl: json['audioUrl'],
      category: json['category'],
      level: json['level'],
      examples: List<String>.from(json['examples'] ?? []),
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Word copyWith({
    String? id,
    String? italian,
    String? chinese,
    String? english,
    String? pronunciation,
    String? audioUrl,
    String? category,
    String? level,
    List<String>? examples,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Word(
      id: id ?? this.id,
      italian: italian ?? this.italian,
      chinese: chinese ?? this.chinese,
      english: english ?? this.english,
      pronunciation: pronunciation ?? this.pronunciation,
      audioUrl: audioUrl ?? this.audioUrl,
      category: category ?? this.category,
      level: level ?? this.level,
      examples: examples ?? this.examples,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// 学习记录
class LearningRecord {
  final String wordId;
  final DateTime lastReviewed;
  final int reviewCount;
  final int correctCount;
  final double mastery; // 0-1 掌握程度
  final DateTime? nextReviewDate;
  final bool isFavorite;

  LearningRecord({
    required this.wordId,
    required this.lastReviewed,
    this.reviewCount = 0,
    this.correctCount = 0,
    this.mastery = 0.0,
    this.nextReviewDate,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'wordId': wordId,
      'lastReviewed': lastReviewed.toIso8601String(),
      'reviewCount': reviewCount,
      'correctCount': correctCount,
      'mastery': mastery,
      'nextReviewDate': nextReviewDate?.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory LearningRecord.fromJson(Map<String, dynamic> json) {
    return LearningRecord(
      wordId: json['wordId'],
      lastReviewed: DateTime.parse(json['lastReviewed']),
      reviewCount: json['reviewCount'],
      correctCount: json['correctCount'],
      mastery: json['mastery'],
      nextReviewDate: json['nextReviewDate'] != null
          ? DateTime.parse(json['nextReviewDate'])
          : null,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  LearningRecord copyWith({
    String? wordId,
    DateTime? lastReviewed,
    int? reviewCount,
    int? correctCount,
    double? mastery,
    DateTime? nextReviewDate,
    bool? isFavorite,
  }) {
    return LearningRecord(
      wordId: wordId ?? this.wordId,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      reviewCount: reviewCount ?? this.reviewCount,
      correctCount: correctCount ?? this.correctCount,
      mastery: mastery ?? this.mastery,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
