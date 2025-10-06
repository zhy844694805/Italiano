import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/vocabulary/vocabulary_screen.dart';
import '../../features/grammar/grammar_screen.dart';
import '../../features/practice/practice_screen.dart';
import '../../features/profile/profile_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String vocabulary = '/vocabulary';
  static const String grammar = '/grammar';
  static const String practice = '/practice';
  static const String profile = '/profile';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: vocabulary,
        builder: (context, state) => const VocabularyScreen(),
      ),
      GoRoute(
        path: grammar,
        builder: (context, state) => const GrammarScreen(),
      ),
      GoRoute(
        path: practice,
        builder: (context, state) => const PracticeScreen(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('页面不存在: ${state.matchedLocation}'),
      ),
    ),
  );
}
