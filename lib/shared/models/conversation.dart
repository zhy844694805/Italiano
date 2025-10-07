/// Models for AI conversation feature
class ConversationScenario {
  final String id;
  final String nameIt;
  final String nameZh;
  final String description;
  final String level; // A1, A2, B1, B2, C1, C2
  final String icon;

  const ConversationScenario({
    required this.id,
    required this.nameIt,
    required this.nameZh,
    required this.description,
    required this.level,
    required this.icon,
  });

  static const restaurant = ConversationScenario(
    id: 'restaurant',
    nameIt: 'Al ristorante',
    nameZh: '在餐厅',
    description: '练习点餐、询问菜单、结账等场景',
    level: 'A1',
    icon: '🍽️',
  );

  static const shopping = ConversationScenario(
    id: 'shopping',
    nameIt: 'Fare shopping',
    nameZh: '购物',
    description: '练习询价、试穿、付款等场景',
    level: 'A1',
    icon: '🛍️',
  );

  static const airport = ConversationScenario(
    id: 'airport',
    nameIt: "All'aeroporto",
    nameZh: '在机场',
    description: '练习办理登机、过安检、找登机口等',
    level: 'A2',
    icon: '✈️',
  );

  static const doctor = ConversationScenario(
    id: 'doctor',
    nameIt: 'Dal dottore',
    nameZh: '看医生',
    description: '描述症状、听取建议、取药等',
    level: 'B1',
    icon: '🏥',
  );

  static const interview = ConversationScenario(
    id: 'interview',
    nameIt: 'Colloquio di lavoro',
    nameZh: '工作面试',
    description: '自我介绍、回答专业问题、询问公司',
    level: 'B2',
    icon: '💼',
  );

  static const friend = ConversationScenario(
    id: 'friend',
    nameIt: 'Con un amico',
    nameZh: '和朋友聊天',
    description: '日常闲聊、分享生活、讨论话题',
    level: 'A2',
    icon: '👥',
  );

  static List<ConversationScenario> get all => [
        restaurant,
        shopping,
        airport,
        doctor,
        interview,
        friend,
      ];
}

class AIRole {
  final String id;
  final String nameIt;
  final String nameZh;
  final String systemPrompt;

  const AIRole({
    required this.id,
    required this.nameIt,
    required this.nameZh,
    required this.systemPrompt,
  });

  factory AIRole.fromScenario(ConversationScenario scenario) {
    switch (scenario.id) {
      case 'restaurant':
        return const AIRole(
          id: 'waiter',
          nameIt: 'Cameriere',
          nameZh: '服务员',
          systemPrompt:
              'Sei un cameriere cordiale in un ristorante italiano. Aiuta il cliente a ordinare, suggerisci piatti e rispondi alle domande sul menu. Usa un linguaggio educato e professionale.',
        );
      case 'shopping':
        return const AIRole(
          id: 'salesperson',
          nameIt: 'Commesso',
          nameZh: '店员',
          systemPrompt:
              'Sei un commesso in un negozio di abbigliamento italiano. Aiuta i clienti a trovare quello che cercano, suggerisci taglie e colori, e rispondi alle domande sui prezzi.',
        );
      case 'airport':
        return const AIRole(
          id: 'staff',
          nameIt: 'Personale aeroportuale',
          nameZh: '机场工作人员',
          systemPrompt:
              "Sei un membro del personale dell'aeroporto. Aiuta i passeggeri con il check-in, fornisci informazioni sui voli e indica le direzioni.",
        );
      case 'doctor':
        return const AIRole(
          id: 'doctor',
          nameIt: 'Dottore',
          nameZh: '医生',
          systemPrompt:
              'Sei un medico empatico. Ascolta i sintomi del paziente, fai domande per capire meglio il problema e dai consigli medici generali.',
        );
      case 'interview':
        return const AIRole(
          id: 'interviewer',
          nameIt: 'Intervistatore',
          nameZh: '面试官',
          systemPrompt:
              "Sei un responsabile delle risorse umane che conduce un colloquio di lavoro. Fai domande sull'esperienza del candidato, le sue competenze e motivazioni.",
        );
      case 'friend':
        return const AIRole(
          id: 'friend',
          nameIt: 'Amico',
          nameZh: '朋友',
          systemPrompt:
              'Sei un amico italiano amichevole. Chiacchiera naturalmente, condividi esperienze, fai domande e mostra interesse per la vita del tuo amico.',
        );
      default:
        return const AIRole(
          id: 'generic',
          nameIt: 'Assistente',
          nameZh: '助手',
          systemPrompt: 'Sei un assistente che parla italiano.',
        );
    }
  }
}

class ConversationMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? translation; // Optional Chinese translation
  final List<GrammarCorrection>? corrections; // Grammar corrections from AI

  ConversationMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.translation,
    this.corrections,
  });

  ConversationMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    String? translation,
    List<GrammarCorrection>? corrections,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      translation: translation ?? this.translation,
      corrections: corrections ?? this.corrections,
    );
  }
}

class GrammarCorrection {
  final String originalText;
  final String correctedText;
  final String explanation;
  final String type; // grammar, vocabulary, etc.

  GrammarCorrection({
    required this.originalText,
    required this.correctedText,
    required this.explanation,
    required this.type,
  });

  factory GrammarCorrection.fromJson(Map<String, dynamic> json) {
    return GrammarCorrection(
      originalText: json['original'] as String,
      correctedText: json['corrected'] as String,
      explanation: json['explanation'] as String,
      type: json['type'] as String? ?? 'grammar',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original': originalText,
      'corrected': correctedText,
      'explanation': explanation,
      'type': type,
    };
  }
}
