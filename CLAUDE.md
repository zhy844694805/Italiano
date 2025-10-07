# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Italian language learning Flutter application (意大利语学习应用) with comprehensive features for vocabulary and grammar learning. The app uses a scientifically-proven spaced repetition algorithm to optimize long-term retention and stores all progress in a local SQLite database.

### Key Features
1. **Learn New Words** - Smart filtering shows only unstudied words (163 total available)
   - Badge on home screen shows count of new words
   - Interactive flashcard interface with swipe gestures
   - Automatic progress tracking

2. **Review System** - Intelligent spaced repetition based on learning history
   - Shows words due for review based on algorithm
   - Review reminders appear on home screen
   - Tracks accuracy and updates review schedule

3. **Vocabulary Browser** - Complete word list with powerful filtering
   - Search by Italian, Chinese, or English
   - Filter by level (A1-C2) and category
   - Sort by mastery level or recent study
   - Detailed word information sheets

4. **Grammar Lessons** - Interactive grammar teaching with exercises
   - 6 grammar points covering fundamentals
   - Rules, examples, and practice exercises
   - Immediate feedback on exercise answers
   - Progress tracking per grammar point

5. **Progress Tracking** - Comprehensive statistics and analytics
   - Mastery calculation for each word
   - Study streaks and daily goals
   - Favorite words bookmarking
   - All data persisted locally with SQLite

## Commands

### Development
- `flutter run` - Run the app on a connected device/simulator
- `flutter run -d macos` - Run on macOS
- `flutter run -d chrome` - Run in Chrome browser
- `flutter run -d <device-id>` - Run on specific device

### Code Generation
- `dart run build_runner build` - Generate code for Riverpod providers and JSON serialization
- `dart run build_runner build --delete-conflicting-outputs` - Force regenerate all generated files
- `dart run build_runner watch` - Watch mode for continuous code generation

### Testing
- `flutter test` - Run all tests
- `flutter test test/widget_test.dart` - Run a specific test file

### Build
- `flutter build ios` - Build for iOS
- `flutter build macos` - Build for macOS
- `flutter build apk` - Build Android APK
- `flutter build web` - Build for web

### Maintenance
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies
- `flutter clean` - Clean build artifacts
- `flutter doctor` - Check Flutter environment setup

## Architecture

### State Management
Uses **Riverpod** (`flutter_riverpod`) as the state management solution:

**Vocabulary Providers** (`lib/shared/providers/vocabulary_provider.dart`):
- `allWordsProvider` - Loads all words from JSON
- `newWordsProvider` - Filters unstudied words (no learning record)
- `wordsToReviewProvider` - Words due for review based on `nextReviewDate`
- `wordsByLevelProvider` - Filter by CEFR level
- `wordsByCategoryProvider` - Filter by category
- `learningProgressProvider` - StateNotifier managing learning records with auto-save to database
- `vocabularyServiceProvider` - Service for loading vocabulary data

**Grammar Providers** (`lib/shared/providers/grammar_provider.dart`):
- `allGrammarProvider` - Loads all grammar points from JSON
- `grammarByCategoryProvider` - Filter by category
- `grammarByLevelProvider` - Filter by level
- `grammarProgressProvider` - StateNotifier tracking study progress and exercise results
- `grammarCategoriesProvider` - Auto-extracts unique categories
- `grammarServiceProvider` - Service for loading grammar data

Use `ConsumerWidget` or `ConsumerStatefulWidget` for widgets that need to watch providers

### Data Persistence
SQLite database managed through:
- `DatabaseService` (`lib/core/database/database_service.dart`) - Database initialization and schema
- `LearningRecordRepository` (`lib/core/database/learning_record_repository.dart`) - CRUD operations for learning records
- Database file: `italiano_learning.db` with `learning_records` table
- All learning progress automatically persists across app restarts
- Provider integration: `LearningProgressNotifier` loads from database on initialization and saves after each update

### Routing
- Routes defined in `lib/core/router/app_router.dart` (GoRouter configured but not integrated)
- Currently uses basic MaterialApp navigation with `Navigator.push`
- Main entry: `HomeScreen` with bottom navigation bar
- Learning flow: `HomeScreen` → `VocabularyLearningScreen`

### Data Models
Located in `lib/shared/models/word.dart`:
- `Word` - Vocabulary word with:
  - Multilingual support: Italian, Chinese, English
  - IPA pronunciation notation
  - CEFR level (A1-C2) and category tags
  - Examples array with bilingual sentences
  - Audio URL field (for future TTS integration)

- `LearningRecord` - Learning progress tracking:
  - Review history (count, last reviewed date)
  - Accuracy tracking (correct/total reviews)
  - Mastery level (0.0-1.0 calculated score)
  - Next review date (spaced repetition)
  - Favorite flag

### Spaced Repetition Algorithm
Implemented in `vocabulary_provider.dart:_calculateNextReviewDate()`:
- **Wrong answer** → Review in 1 hour
- **Correct answers** follow increasing intervals:
  1. 4 hours
  2. 1 day
  3. 3 days
  4. 7 days (1 week)
  5. 14 days (2 weeks)
  6. 30 days (1 month)
  7. 90 days (3 months)
- **Mastery calculation**: `(accuracy × 0.7) + (reviewFactor × 0.3)`
  - `accuracy = correctCount / reviewCount`
  - `reviewFactor = min(reviewCount / 10, 1.0)`

### Vocabulary Learning System
Complete card-based learning flow with three modes:

1. **FlipCard** (`lib/shared/widgets/flip_card.dart`)
   - 3D Y-axis rotation animation
   - Controlled flip via `FlipCardState` key reference
   - Configurable duration and tap behavior

2. **SwipeableWordCard** (`lib/shared/widgets/swipeable_word_card.dart`)
   - Gesture detection: swipe left (don't know) / right (know)
   - Drag threshold: 30% of screen width
   - Visual feedback: color overlay (green/red) + icon
   - Front side: Italian word, IPA, audio button, level tags
   - Back side: Chinese/English translations, example sentences
   - Integrates FlipCard for tap-to-flip functionality

3. **VocabularyLearningScreen** (`lib/features/vocabulary/vocabulary_learning_screen.dart`)
   - **Two modes**:
     - `newWordsOnly: true` - Only unstudied words (filtered by `newWordsProvider`)
     - `newWordsOnly: false` - All words
   - Card stack with visual depth (scaled background card)
   - Real-time progress bar and statistics
   - Swipe callbacks trigger `recordWordStudied()` → auto-saves to database
   - Completion screen with learning summary
   - SnackBar feedback for each action
   - Empty state: Shows celebration when all new words learned

4. **VocabularyReviewScreen** (`lib/features/vocabulary/vocabulary_review_screen.dart`)
   - Smart review system based on spaced repetition
   - Loads words due for review via `wordsToReviewProvider`
   - Real-time statistics: correct/incorrect count, accuracy percentage
   - Same card interface as learning screen
   - Updates `nextReviewDate` after each review
   - Empty state: Congratulations when no words need review

5. **VocabularyListScreen** (`lib/features/vocabulary/vocabulary_list_screen.dart`)
   - Comprehensive word browser with search, filter, and sort
   - **Search**: Real-time filtering by Italian, Chinese, or English text
   - **Filters**: Level (A1-C2), Category, Favorites toggle
   - **Sort**: Default order, Mastery (low to high), Recently studied
   - Word cards display mastery progress bar and learning statistics
   - Tap word for detailed modal sheet with full info and examples
   - Accessible via bottom navigation "词汇" tab
   - **Null Safety Note**: Use Builder pattern when accessing nullable LearningRecord properties to avoid type promotion issues

6. **AudioPlayerService** (`lib/core/services/audio_player_service.dart`)
   - Based on `just_audio` package
   - Plays local assets: `assets/audio/words/{wordId}.mp3`
   - Supports network URLs and playback controls
   - TTS integration placeholder for future

### Grammar Learning System
Comprehensive grammar teaching with interactive exercises:

1. **Grammar Data Models** (`lib/shared/models/grammar.dart`)
   - `GrammarPoint` - Main grammar lesson with title, category, level, description
   - `GrammarRule` - Individual grammar rules with title, content, and bullet points
   - `GrammarExample` - Example sentences in Italian/Chinese/English with highlights
   - `GrammarExercise` - Practice exercises (fill_blank, choice, translation)
   - `GrammarProgress` - Tracks completion, exercise results, favorites

2. **GrammarListScreen** (`lib/features/grammar/grammar_list_screen.dart`)
   - Category tabs: 时态, 冠词, 代词, 名词, 介词
   - Level filtering (A1-C2)
   - Grammar cards show: level badge, category, completion status, favorite button
   - Progress indicator for exercises completed
   - Click to open detail screen

3. **GrammarDetailScreen** (`lib/features/grammar/grammar_detail_screen.dart`)
   - Three tabs: Rules, Examples, Exercises
   - **Rules Tab**: Numbered rules with bullet points, color-coded presentation
   - **Examples Tab**: Bilingual examples with grammar highlights
   - **Exercises Tab**: Interactive practice with immediate feedback
     - Fill-in-the-blank questions
     - Multiple choice questions
     - Shows correct/incorrect with explanations
     - Progress tracking per grammar point
   - Mark as completed functionality
   - Favorite toggle

4. **Grammar Providers** (`lib/shared/providers/grammar_provider.dart`)
   - `allGrammarProvider` - Loads all grammar points from JSON
   - `grammarByCategoryProvider` - Filter by category
   - `grammarByLevelProvider` - Filter by CEFR level
   - `grammarProgressProvider` - Tracks study progress and exercise results
   - `grammarCategoriesProvider` - Auto-extracts unique categories

5. **Grammar Data** (`assets/data/sample_grammar.json`)
   - 6 grammar points covering A1-A2 fundamentals
   - Topics: Present tense, Articles, Pronouns, Gender/Number, Past tense, Prepositions
   - Each with detailed rules, examples, and practice exercises

### Project Structure
```
lib/
├── core/
│   ├── constants/          # App-wide constants
│   ├── database/           # SQLite database layer
│   │   ├── database_service.dart
│   │   └── learning_record_repository.dart
│   ├── router/             # GoRouter configuration
│   ├── services/           # Singleton services (audio, etc.)
│   ├── theme/              # Material 3 theme configuration
│   └── utils/              # Utility functions
├── features/               # Feature-based organization
│   ├── home/               # Home screen with quick actions & review reminders
│   ├── vocabulary/         # Vocabulary learning screens
│   │   ├── vocabulary_screen.dart
│   │   ├── vocabulary_learning_screen.dart    # Supports newWordsOnly mode
│   │   ├── vocabulary_review_screen.dart      # Smart review with SRS
│   │   └── vocabulary_list_screen.dart        # Browse, search, filter
│   ├── grammar/            # Grammar lessons with exercises
│   │   ├── grammar_list_screen.dart
│   │   └── grammar_detail_screen.dart
│   ├── practice/           # Practice quizzes (placeholder)
│   ├── profile/            # User profile (placeholder)
│   └── test/               # Development test screens
│       └── persistence_test_screen.dart
└── shared/
    ├── models/             # Data models
    │   ├── word.dart       # Word, LearningRecord
    │   └── grammar.dart    # GrammarPoint, GrammarRule, GrammarExample, etc.
    ├── providers/          # Riverpod state providers
    │   ├── vocabulary_provider.dart    # Word loading, learning progress
    │   └── grammar_provider.dart       # Grammar loading, progress tracking
    └── widgets/            # Reusable UI components
        ├── flip_card.dart
        ├── swipeable_word_card.dart
        └── word_card.dart
```

### Theme
Italian flag-inspired color scheme in `lib/core/theme/app_theme.dart`:
- **Primary**: Italian green (#009246)
- **Accent**: Italian red (#CE2B37)
- **Secondary**: Light blue (#4A90E2)
- **Tertiary**: Warm orange (#FF9F66)
- Material 3 design system
- Rounded corners: 16dp cards, 12dp buttons
- Both light and dark themes defined (light theme active)

### Data Sources

**Vocabulary** (`assets/data/sample_words.json`):
- **163 words** covering all CEFR levels
- Fields: id, italian, chinese, english, pronunciation, category, level, examples, audioUrl, imageUrl, createdAt
- **Level distribution**: A1 (83), A2 (43), B1 (20), B2 (12), C1 (3), C2 (2)
- **Categories**: 日常用语 (47), 食物餐饮 (21), 商务交流 (21), 旅游出行 (18), 家庭生活 (16), 工作学习 (15), 文化艺术 (9), 娱乐运动 (8), 健康医疗 (8)

**Grammar** (`assets/data/sample_grammar.json`):
- **6 grammar points** (A1-A2 level)
- Categories: 时态, 冠词, 代词, 名词, 介词
- Each includes: rules, examples, practice exercises
- Topics: Present tense, Articles, Personal pronouns, Gender/Number, Past tense, Prepositions

### Audio Integration
- Audio files expected at: `assets/audio/words/{wordId}.mp3`
- `AudioPlayerService` provider available via Riverpod
- TTS support planned but not implemented
- Silent failure if audio file missing (no crash)

## Key Dependencies
- `flutter_riverpod` (^2.6.1) - State management with providers
- `go_router` (^14.6.2) - Declarative routing (defined but not integrated)
- `sqflite` (^2.4.1) - SQLite database for learning progress persistence
- `shared_preferences` (^2.3.3) - Key-value storage
- `just_audio` (^0.9.42) / `audioplayers` (^6.1.0) - Audio playback
- `dio` (^5.7.0) - HTTP client for future API calls
- `intl` (^0.20.1) - Internationalization utilities

## Important Implementation Notes

### Adding New Vocabulary
1. Add word entries to `assets/data/sample_words.json`
2. Follow existing JSON structure with all required fields
3. Optionally add audio files to `assets/audio/words/{wordId}.mp3`
4. Run `flutter pub get` if adding new assets

### Extending Learning Features
- Learning progress auto-saves after every `recordWordStudied()` call
- Access statistics via `LearningProgressNotifier.getStatistics()`
- Query words due for review: `getWordsToReview()`
- All database operations are async - use `await`

### Database Schema
Table: `learning_records`
- wordId (TEXT PRIMARY KEY)
- lastReviewed (TEXT NOT NULL) - ISO8601 datetime
- reviewCount (INTEGER NOT NULL)
- correctCount (INTEGER NOT NULL)
- mastery (REAL NOT NULL) - 0.0 to 1.0
- nextReviewDate (TEXT) - ISO8601 datetime, nullable
- isFavorite (INTEGER NOT NULL) - 0 or 1 boolean

Indexes on: nextReviewDate, isFavorite

### Development Testing
- Use `PersistenceTestScreen` (accessible via science icon on home page)
- Add test learning records and verify database persistence
- Clear all data for fresh testing
- View real-time statistics

### Common Dart Null Safety Patterns
When working with nullable properties from database models:
```dart
// ❌ WRONG - Type promotion doesn't work on public properties
if (record != null) {
  Text('${record.reviewCount}')  // Error: Property potentially null
}

// ✅ CORRECT - Use Builder with local variable
if (record != null) {
  Builder(
    builder: (context) {
      final rec = record!;  // Capture non-null value
      return Text('${rec.reviewCount}');  // Works!
    },
  )
}
```
