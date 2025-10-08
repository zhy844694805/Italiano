import 'dart:math';
import '../../shared/models/word.dart';
import '../../shared/models/grammar.dart';
import '../../shared/models/quiz.dart';

/// 测验题目生成服务
class QuizGeneratorService {
  final Random _random = Random();

  /// 从单词生成词汇题
  List<QuizQuestion> generateVocabularyQuestions(
    List<Word> words, {
    int count = 10,
    QuizDifficulty difficulty = QuizDifficulty.mixed,
  }) {
    final filteredWords = _filterByDifficulty(words, difficulty);
    if (filteredWords.isEmpty) return [];

    final selectedWords = _selectRandom(filteredWords, count);
    final questions = <QuizQuestion>[];

    for (var word in selectedWords) {
      // 随机选择题型
      final questionType = _random.nextInt(3);

      if (questionType == 0) {
        // 意大利语 -> 中文
        questions.add(_generateItalianToChineseQuestion(word, filteredWords));
      } else if (questionType == 1) {
        // 中文 -> 意大利语
        questions.add(_generateChineseToItalianQuestion(word, filteredWords));
      } else {
        // 例句填空
        questions.add(_generateFillBlankQuestion(word, filteredWords));
      }
    }

    return questions;
  }

  /// 从语法点生成语法题
  List<QuizQuestion> generateGrammarQuestions(
    List<GrammarPoint> grammarPoints, {
    int count = 10,
    QuizDifficulty difficulty = QuizDifficulty.mixed,
  }) {
    final filteredGrammar = _filterGrammarByDifficulty(grammarPoints, difficulty);
    if (filteredGrammar.isEmpty) return [];

    final questions = <QuizQuestion>[];

    for (var grammar in filteredGrammar) {
      // 从每个语法点的练习中选择题目
      if (grammar.exercises.isNotEmpty) {
        final exercise =
            grammar.exercises[_random.nextInt(grammar.exercises.length)];

        questions.add(QuizQuestion(
          id: 'g_${grammar.id}_${exercise.id}',
          type: QuizType.grammar,
          question: exercise.question,
          options: exercise.options ?? [],
          correctAnswer: exercise.answer,
          explanation: exercise.explanation,
          level: grammar.level,
          relatedGrammarId: grammar.id,
        ));

        if (questions.length >= count) break;
      }
    }

    return questions;
  }

  /// 生成综合测验(词汇+语法)
  List<QuizQuestion> generateComprehensiveQuiz(
    List<Word> words,
    List<GrammarPoint> grammarPoints, {
    int count = 20,
    QuizDifficulty difficulty = QuizDifficulty.mixed,
  }) {
    final vocabCount = (count * 0.6).round(); // 60%词汇
    final grammarCount = count - vocabCount; // 40%语法

    final vocabQuestions =
        generateVocabularyQuestions(words, count: vocabCount, difficulty: difficulty);
    final grammarQuestions = generateGrammarQuestions(
      grammarPoints,
      count: grammarCount,
      difficulty: difficulty,
    );

    final allQuestions = [...vocabQuestions, ...grammarQuestions];
    allQuestions.shuffle();

    return allQuestions;
  }

  /// 意大利语 -> 中文题
  QuizQuestion _generateItalianToChineseQuestion(
    Word word,
    List<Word> allWords,
  ) {
    final wrongOptions = _selectRandom(
      allWords.where((w) => w.id != word.id).toList(),
      3,
    ).map((w) => w.chinese).toList();

    final options = [word.chinese, ...wrongOptions];
    options.shuffle();

    return QuizQuestion(
      id: 'v_itc_${word.id}',
      type: QuizType.vocabulary,
      question: '${word.italian} 的中文意思是?',
      options: options,
      correctAnswer: word.chinese,
      explanation: word.pronunciation != null
          ? '发音: ${word.pronunciation}\n${word.examples.isNotEmpty ? word.examples.first : ""}' : word.examples.isNotEmpty ? word.examples.first : null,
      level: word.level,
      relatedWordId: word.id,
    );
  }

  /// 中文 -> 意大利语题
  QuizQuestion _generateChineseToItalianQuestion(
    Word word,
    List<Word> allWords,
  ) {
    final wrongOptions = _selectRandom(
      allWords.where((w) => w.id != word.id).toList(),
      3,
    ).map((w) => w.italian).toList();

    final options = [word.italian, ...wrongOptions];
    options.shuffle();

    return QuizQuestion(
      id: 'v_cit_${word.id}',
      type: QuizType.vocabulary,
      question: '"${word.chinese}" 用意大利语怎么说?',
      options: options,
      correctAnswer: word.italian,
      explanation: word.pronunciation != null
          ? '发音: ${word.pronunciation}\n${word.examples.isNotEmpty ? word.examples.first : ""}' : word.examples.isNotEmpty ? word.examples.first : null,
      level: word.level,
      relatedWordId: word.id,
    );
  }

  /// 例句填空题
  QuizQuestion _generateFillBlankQuestion(
    Word word,
    List<Word> allWords,
  ) {
    if (word.examples.isEmpty) {
      // 如果没有例句,回退到意大利语->中文题
      return _generateItalianToChineseQuestion(word, allWords);
    }

    final example = word.examples[_random.nextInt(word.examples.length)];
    final questionText = example.replaceAll(word.italian, '______');

    final wrongOptions = _selectRandom(
      allWords.where((w) => w.id != word.id && w.level == word.level).toList(),
      3,
    ).map((w) => w.italian).toList();

    final options = [word.italian, ...wrongOptions];
    options.shuffle();

    return QuizQuestion(
      id: 'v_fill_${word.id}',
      type: QuizType.vocabulary,
      question: '请选择正确的单词填入空白处:\n\n$questionText',
      options: options,
      correctAnswer: word.italian,
      explanation: '完整句子: $example',
      level: word.level,
      relatedWordId: word.id,
    );
  }

  /// 根据难度筛选单词
  List<Word> _filterByDifficulty(List<Word> words, QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return words.where((w) => w.level == 'A1' || w.level == 'A2').toList();
      case QuizDifficulty.medium:
        return words.where((w) => w.level == 'B1' || w.level == 'B2').toList();
      case QuizDifficulty.hard:
        return words.where((w) => w.level == 'C1' || w.level == 'C2').toList();
      case QuizDifficulty.mixed:
        return words;
    }
  }

  /// 根据难度筛选语法
  List<GrammarPoint> _filterGrammarByDifficulty(
    List<GrammarPoint> grammar,
    QuizDifficulty difficulty,
  ) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return grammar.where((g) => g.level == 'A1' || g.level == 'A2').toList();
      case QuizDifficulty.medium:
        return grammar.where((g) => g.level == 'B1' || g.level == 'B2').toList();
      case QuizDifficulty.hard:
        return grammar.where((g) => g.level == 'C1' || g.level == 'C2').toList();
      case QuizDifficulty.mixed:
        return grammar;
    }
  }

  /// 随机选择N个元素
  List<T> _selectRandom<T>(List<T> list, int count) {
    if (list.length <= count) return list;

    final shuffled = List<T>.from(list);
    shuffled.shuffle(_random);
    return shuffled.take(count).toList();
  }
}
