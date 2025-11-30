/// 意大利语口语表达数据模型
class ItalianPhrase {
  final String id;
  final String italian;
  final String chinese;
  final String phonetic; // IPA音标或拼音标注
  final String category; // compliment, insult, casual, formal等
  final String context; // 使用场景说明
  final String level; // A1, A2, B1等难度级别
  final List<String> examples; // 例句
  final String? emoji; // 表情符号增加趣味性
  final bool isPopular; // 是否为常用表达

  ItalianPhrase({
    required this.id,
    required this.italian,
    required this.chinese,
    required this.phonetic,
    required this.category,
    required this.context,
    required this.level,
    required this.examples,
    this.emoji,
    this.isPopular = false,
  });

  factory ItalianPhrase.fromJson(Map<String, dynamic> json) {
    return ItalianPhrase(
      id: json['id'] as String,
      italian: json['italian'] as String,
      chinese: json['chinese'] as String,
      phonetic: json['phonetic'] as String,
      category: json['category'] as String,
      context: json['context'] as String,
      level: json['level'] as String,
      examples: (json['examples'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      emoji: json['emoji'] as String?,
      isPopular: json['isPopular'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'italian': italian,
      'chinese': chinese,
      'phonetic': phonetic,
      'category': category,
      'context': context,
      'level': level,
      'examples': examples,
      'emoji': emoji,
      'isPopular': isPopular,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItalianPhrase && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}