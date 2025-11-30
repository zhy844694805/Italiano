import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/phrase.dart';

part 'phrase_provider.g.dart';

@riverpod
class PhraseNotifier extends _$PhraseNotifier {
  List<ItalianPhrase> _allPhrases = [];

  @override
  Future<List<ItalianPhrase>> build() async {
    await _loadPhrases();
    return _allPhrases;
  }

  Future<void> _loadPhrases() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/italian_phrases.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      _allPhrases = (data['phrases'] as List<dynamic>)
          .map((json) => ItalianPhrase.fromJson(json as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(_allPhrases);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  List<ItalianPhrase> getPhrasesByCategory(String category) {
    return _allPhrases.where((phrase) => phrase.category == category).toList();
  }

  List<ItalianPhrase> getPopularPhrases() {
    return _allPhrases.where((phrase) => phrase.isPopular).toList();
  }

  List<ItalianPhrase> getPhrasesByLevel(String level) {
    return _allPhrases.where((phrase) => phrase.level == level).toList();
  }

  List<ItalianPhrase> getComplimentPhrases() => getPhrasesByCategory('compliment');
  List<ItalianPhrase> getInsultPhrases() => getPhrasesByCategory('insult');
  List<ItalianPhrase> getCasualPhrases() => getPhrasesByCategory('casual');
}

@riverpod
List<ItalianPhrase> popularPhrases(PopularPhrasesRef ref) {
  final phraseAsync = ref.watch(phraseNotifierProvider);
  return phraseAsync.when(
    data: (phrases) => phrases.where((phrase) => phrase.isPopular).take(6).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

@riverpod
List<ItalianPhrase> complimentPhrases(ComplimentPhrasesRef ref) {
  final phraseAsync = ref.watch(phraseNotifierProvider);
  return phraseAsync.when(
    data: (phrases) => phrases.where((phrase) => phrase.category == 'compliment').toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

@riverpod
List<ItalianPhrase> insultPhrases(InsultPhrasesRef ref) {
  final phraseAsync = ref.watch(phraseNotifierProvider);
  return phraseAsync.when(
    data: (phrases) => phrases.where((phrase) => phrase.category == 'insult').toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

@riverpod
List<ItalianPhrase> casualPhrases(CasualPhrasesRef ref) {
  final phraseAsync = ref.watch(phraseNotifierProvider);
  return phraseAsync.when(
    data: (phrases) => phrases.where((phrase) => phrase.category == 'casual').toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}