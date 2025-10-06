# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Italian language learning Flutter application (意大利语学习应用) with features for vocabulary learning, grammar practice, and user progress tracking. The app uses a spaced repetition algorithm to optimize learning and stores all progress in a local SQLite database.

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
- Providers are defined in `lib/shared/providers/vocabulary_provider.dart`
- `VocabularyService` loads words from JSON assets (`assets/data/sample_words.json`)
- `LearningProgressNotifier` (StateNotifier) manages user progress with automatic database persistence
- `LearningRecordRepository` handles all database operations
- Use `ConsumerWidget` or `ConsumerStatefulWidget` for widgets that need to watch providers

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
Complete card-based learning flow:

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
   - Card stack with visual depth (scaled background card)
   - Real-time progress bar and statistics
   - Swipe callbacks trigger `recordWordStudied()` → auto-saves to database
   - Completion screen with learning summary
   - SnackBar feedback for each action

4. **AudioPlayerService** (`lib/core/services/audio_player_service.dart`)
   - Based on `just_audio` package
   - Plays local assets: `assets/audio/words/{wordId}.mp3`
   - Supports network URLs and playback controls
   - TTS integration placeholder for future

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
│   ├── home/               # Home screen with quick actions
│   ├── vocabulary/         # Vocabulary learning screens
│   │   ├── vocabulary_screen.dart
│   │   └── vocabulary_learning_screen.dart
│   ├── grammar/            # Grammar lessons (placeholder)
│   ├── practice/           # Practice quizzes (placeholder)
│   ├── profile/            # User profile (placeholder)
│   └── test/               # Development test screens
│       └── persistence_test_screen.dart
└── shared/
    ├── models/             # Data models (Word, LearningRecord)
    ├── providers/          # Riverpod state providers
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

### Data Source
Vocabulary loaded from `assets/data/sample_words.json`:
- JSON array of word objects
- Fields: id, italian, chinese, english, pronunciation, category, level, examples, audioUrl, imageUrl, createdAt
- CEFR levels: A1, A2, B1, B2, C1, C2
- Categories: 日常用语, 食物, 交通, etc.

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
