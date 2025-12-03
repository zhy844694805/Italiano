import 'package:dio/dio.dart';
import '../../shared/models/conversation.dart';

/// Service for interacting with DeepSeek API
class DeepSeekService {
  final Dio _dio;

  DeepSeekService({
    required String apiKey,
    String baseUrl = 'https://api.deepseek.com',
  }) : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ));

  /// Send a chat completion request to DeepSeek
  Future<ChatResponse> sendMessage({
    required List<ConversationMessage> history,
    required String userMessage,
    required AIRole role,
    required String userLevel, // A1-C2
  }) async {
    try {
      // Build messages for API
      final messages = [
        {
          'role': 'system',
          'content': _buildSystemPrompt(role, userLevel),
        },
        // Add conversation history
        ...history.map((msg) => {
              'role': msg.isUser ? 'user' : 'assistant',
              'content': msg.content,
            }),
        // Add new user message
        {
          'role': 'user',
          'content': userMessage,
        },
      ];

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'deepseek-chat',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 500,
          'stream': false,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final aiMessage = data['choices'][0]['message']['content'] as String;

        // Parse corrections if included in response
        final corrections = _parseCorrections(aiMessage);
        // Parse translation if included in response
        final translation = _parseTranslation(aiMessage);

        return ChatResponse(
          message: _cleanMessage(aiMessage),
          translation: translation,
          corrections: corrections,
          success: true,
        );
      } else {
        throw Exception('API request failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return ChatResponse(
        message: '',
        corrections: null,
        success: false,
        error: _handleDioError(e),
      );
    } catch (e) {
      return ChatResponse(
        message: '',
        corrections: null,
        success: false,
        error: '发生未知错误: $e',
      );
    }
  }

  /// Build system prompt with role and level adaptation
  String _buildSystemPrompt(AIRole role, String userLevel) {
    final levelGuidance = _getLevelGuidance(userLevel);

    return '''${role.systemPrompt}

IMPORTANTE - Livello dello studente: $userLevel
$levelGuidance

Linee guida per la conversazione:
1. Rispondi in modo naturale e coinvolgente
2. Se lo studente fa errori di grammatica, correggili gentilmente alla fine della tua risposta usando il formato: [CORREZIONE: "errore" → "corretto" - spiegazione]
3. Usa vocabolario appropriato per il livello dello studente
4. Fai domande per mantenere viva la conversazione
5. Incoraggia lo studente a usare frasi complete
6. Se necessario, fornisci suggerimenti di vocabolario utile per la situazione
7. IMPORTANTE: Alla fine di ogni tua risposta, aggiungi sempre una traduzione in cinese usando il formato: [TRADUZIONE: 翻译内容]

Esempio di risposta completa:
"Ottima scelta! Quale tipo di pasta preferisci? Abbiamo carbonara, amatriciana, e aglio e olio.
[CORREZIONE: "Io voglio" → "Vorrei" - In italiano formale al ristorante si usa il condizionale]
[TRADUZIONE: 很好的选择！你喜欢哪种意大利面？我们有培根蛋面、番茄培根面和蒜香油面。]"''';
  }

  String _getLevelGuidance(String level) {
    switch (level) {
      case 'A1':
        return '''- Usa frasi semplici e corte
- Vocabolario base (circa 500 parole)
- Tempo presente principalmente
- Ripeti e parafrasa se necessario''';
      case 'A2':
        return '''- Frasi di media complessità
- Vocabolario quotidiano (circa 1000 parole)
- Presente, passato prossimo e futuro semplice
- Puoi introdurre nuove espressioni con spiegazioni''';
      case 'B1':
        return '''- Frasi articolate con subordinate semplici
- Vocabolario più ampio e specifico
- Vari tempi verbali incluso imperfetto e condizionale
- Puoi usare modi di dire comuni''';
      case 'B2':
        return '''- Linguaggio naturale e fluido
- Vocabolario specifico e tecnico
- Tutti i tempi verbali incluso congiuntivo
- Espressioni idiomatiche e culturali''';
      case 'C1':
      case 'C2':
        return '''- Linguaggio sofisticato e sfumato
- Vocabolario avanzato e specializzato
- Tutti i modi e tempi, incluso congiuntivo imperfetto
- Riferimenti culturali e letterari''';
      default:
        return '- Adatta il linguaggio al contesto';
    }
  }

  /// Parse grammar corrections from AI response
  List<GrammarCorrection>? _parseCorrections(String message) {
    final corrections = <GrammarCorrection>[];
    final correctionRegex = RegExp(
      r'\[CORREZIONE:\s*"([^"]+)"\s*→\s*"([^"]+)"\s*-\s*([^\]]+)\]',
      multiLine: true,
    );

    final matches = correctionRegex.allMatches(message);
    for (final match in matches) {
      corrections.add(GrammarCorrection(
        originalText: match.group(1)!.trim(),
        correctedText: match.group(2)!.trim(),
        explanation: match.group(3)!.trim(),
        type: 'grammar',
      ));
    }

    return corrections.isEmpty ? null : corrections;
  }

  /// Parse Chinese translation from AI response
  String? _parseTranslation(String message) {
    final translationRegex = RegExp(
      r'\[TRADUZIONE:\s*(.+?)\]',
      multiLine: true,
      dotAll: true,
    );

    final match = translationRegex.firstMatch(message);
    if (match != null) {
      return match.group(1)?.trim();
    }
    return null;
  }

  /// Remove correction and translation markers from message
  String _cleanMessage(String message) {
    return message
        .replaceAll(RegExp(r'\[CORREZIONE:.*?\]', multiLine: true), '')
        .replaceAll(RegExp(r'\[TRADUZIONE:.*?\]', multiLine: true, dotAll: true), '')
        .trim();
  }

  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return '连接超时，请检查网络';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return '响应超时，请稍后重试';
    } else if (e.response != null) {
      final statusCode = e.response!.statusCode;
      if (statusCode == 401) {
        return 'API密钥无效';
      } else if (statusCode == 429) {
        return '请求过于频繁，请稍后再试';
      } else if (statusCode == 500) {
        return '服务器错误，请稍后重试';
      }
      return 'API错误: $statusCode';
    } else {
      return '网络错误: ${e.message}';
    }
  }

  void dispose() {
    _dio.close();
  }
}

/// Response from chat completion API
class ChatResponse {
  final String message;
  final String? translation;
  final List<GrammarCorrection>? corrections;
  final bool success;
  final String? error;

  ChatResponse({
    required this.message,
    this.translation,
    required this.corrections,
    required this.success,
    this.error,
  });
}
