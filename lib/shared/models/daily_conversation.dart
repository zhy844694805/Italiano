import 'package:flutter/foundation.dart';

@immutable
class ConversationWord {
  final String text;
  final String translation;
  final String? phonetic;
  final WordType type;
  final bool isPunctuation;

  const ConversationWord({
    required this.text,
    required this.translation,
    this.phonetic,
    required this.type,
    this.isPunctuation = false,
  });

  factory ConversationWord.fromJson(Map<String, dynamic> json) {
    return ConversationWord(
      text: json['text'] as String,
      translation: json['translation'] as String,
      phonetic: json['phonetic'] as String?,
      type: _parseWordType(json['type'] as String),
      isPunctuation: json['isPunctuation'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'translation': translation,
      'phonetic': phonetic,
      'type': type.name,
      'isPunctuation': isPunctuation,
    };
  }

  static WordType _parseWordType(String type) {
    switch (type.toLowerCase()) {
      case 'noun':
        return WordType.noun;
      case 'verb':
        return WordType.verb;
      case 'adjective':
        return WordType.adjective;
      case 'adverb':
        return WordType.adverb;
      case 'preposition':
        return WordType.preposition;
      case 'conjunction':
        return WordType.conjunction;
      case 'pronoun':
        return WordType.pronoun;
      case 'article':
        return WordType.article;
      case 'interjection':
        return WordType.interjection;
      default:
        return WordType.other;
    }
  }
}

enum WordType {
  noun,        // 名词
  verb,        // 动词
  adjective,   // 形容词
  adverb,      // 副词
  preposition, // 介词
  conjunction, // 连词
  pronoun,     // 代词
  article,     // 冠词
  interjection,// 感叹词
  other,       // 其他
}

@immutable
class ConversationMessage {
  final String id;
  final String speaker;
  final String italian;
  final List<ConversationWord> words;
  final String chinese;
  final String context;
  final String? audioUrl;

  const ConversationMessage({
    required this.id,
    required this.speaker,
    required this.italian,
    required this.words,
    required this.chinese,
    required this.context,
    this.audioUrl,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      id: json['id'] as String,
      speaker: json['speaker'] as String,
      italian: json['italian'] as String,
      words: (json['words'] as List<dynamic>)
          .map((wordJson) => ConversationWord.fromJson(wordJson))
          .toList(),
      chinese: json['chinese'] as String,
      context: json['context'] as String,
      audioUrl: json['audioUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'speaker': speaker,
      'italian': italian,
      'words': words.map((word) => word.toJson()).toList(),
      'chinese': chinese,
      'context': context,
      'audioUrl': audioUrl,
    };
  }
}

@immutable
class DailyConversation {
  final String id;
  final String title;
  final String description;
  final String category;
  final String level;
  final String scenario;
  final List<ConversationMessage> messages;
  final List<String> vocabulary;
  final String? culturalNote;
  final bool isPopular;
  final String emoji;

  const DailyConversation({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.scenario,
    required this.messages,
    required this.vocabulary,
    this.culturalNote,
    required this.isPopular,
    required this.emoji,
  });

  factory DailyConversation.fromJson(Map<String, dynamic> json) {
    return DailyConversation(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      level: json['level'] as String,
      scenario: json['scenario'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((messageJson) => ConversationMessage.fromJson(messageJson))
          .toList(),
      vocabulary: (json['vocabulary'] as List<dynamic>)
          .map((vocab) => vocab as String)
          .toList(),
      culturalNote: json['culturalNote'] as String?,
      isPopular: json['isPopular'] as bool? ?? false,
      emoji: json['emoji'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'level': level,
      'scenario': scenario,
      'messages': messages.map((message) => message.toJson()).toList(),
      'vocabulary': vocabulary,
      'culturalNote': culturalNote,
      'isPopular': isPopular,
      'emoji': emoji,
    };
  }

  DailyConversation copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? level,
    String? scenario,
    List<ConversationMessage>? messages,
    List<String>? vocabulary,
    String? culturalNote,
    bool? isPopular,
    String? emoji,
  }) {
    return DailyConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      level: level ?? this.level,
      scenario: scenario ?? this.scenario,
      messages: messages ?? this.messages,
      vocabulary: vocabulary ?? this.vocabulary,
      culturalNote: culturalNote ?? this.culturalNote,
      isPopular: isPopular ?? this.isPopular,
      emoji: emoji ?? this.emoji,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyConversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DailyConversation(id: $id, title: $title, category: $category, level: $level)';
  }
}