# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Italian language learning Flutter application (意大利语学习应用) with comprehensive features for vocabulary and grammar learning. The app uses a scientifically-proven spaced repetition algorithm to optimize long-term retention and stores all progress in a local SQLite database.

### Key Features
1. **Learn New Words** - Smart filtering shows only unstudied words (1219 total available)
   - Badge on home screen shows count of new words
   - Interactive flashcard interface with swipe gestures
   - Automatic progress tracking
   - **TTS Support**: KOKORO TTS integration for authentic Italian pronunciation

2. **Review System** - Intelligent spaced repetition based on learning history
   - Shows words due for review based on algorithm
   - Review reminders appear on home screen
   - Tracks accuracy and updates review schedule
   - **TTS Support**: Play word pronunciation during review

3. **Vocabulary Browser** - Complete word list with powerful filtering
   - Search by Italian, Chinese, or English
   - Filter by level (A1-C2) and category
   - Sort by mastery level or recent study
   - Detailed word information sheets
   - **TTS Support**: Play pronunciation for any word in the list

4. **Grammar Lessons** - Interactive grammar teaching with exercises
   - 14 grammar points covering A1-A2 fundamentals with 100% A2 coverage ✅
   - Rules, examples, and practice exercises (140 exercises total)
   - Immediate feedback on exercise answers
   - Progress tracking per grammar point

5. **Reading Comprehension** - Authentic Italian reading passages with comprehension exercises (✅ NEW)
   - 10 carefully curated passages (A1-A2 level)
   - Topics: daily life, travel, culture, practical texts
   - 5 comprehension questions per passage (50 questions total)
   - Multiple choice, true/false, and fill-in-the-blank question types
   - Immediate scoring with detailed explanations
   - Progress tracking and accuracy statistics
   - Filter by level (A1/A2) and category
   - **TTS Support**: Read entire passages aloud for listening practice

6. **AI Conversation Partner** - Real-time conversation practice with AI
   - 6 scenario-based conversations (restaurant, airport, shopping, doctor, interview, friend)
   - AI role-playing with natural language responses
   - Real-time grammar correction and explanations
   - Level-adaptive difficulty (A1-C2 CEFR levels)
   - DeepSeek API integration for conversational AI

7. **Progress Tracking** - Comprehensive statistics and analytics (✅ Complete)
   - **Personal Center Page**: Beautiful statistics dashboard with fl_chart visualizations
   - **Learning Statistics**: Total study days, study time, words learned, grammar points studied
   - **Study Streak Tracking**: Consecutive learning days calculation and display
   - **7-Day Trend Chart**: Line chart showing recent learning activity
   - **Vocabulary Mastery Stats**: Words learned, mastered (≥80%), reviewing, average mastery
   - **Grammar Progress**: Completed and favorited grammar points
   - **Real-time Updates**: Pull-to-refresh capability
   - **Home Screen Integration**: Dynamic streak counter and daily goal progress
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

**Conversation Providers** (`lib/shared/providers/conversation_provider.dart`):
- `deepSeekServiceProvider` - Singleton DeepSeek API service with credentials
- `conversationProvider` - StateNotifierProvider.family for scenario-specific conversation state
  - Each scenario maintains independent conversation history
  - Manages messages, loading state, errors, user level
  - Auto-initializes with AI greeting message
  - Handles real-time grammar correction parsing

Use `ConsumerWidget` or `ConsumerStatefulWidget` for widgets that need to watch providers

### Data Persistence
SQLite database (v2 schema) managed through:
- `DatabaseService` (`lib/core/database/database_service.dart`) - Database initialization and schema management with migrations
- `LearningRecordRepository` (`lib/core/database/learning_record_repository.dart`) - CRUD operations for vocabulary learning records
- `GrammarProgressRepository` (`lib/core/database/grammar_progress_repository.dart`) - Grammar study progress and exercise results
- `ConversationHistoryRepository` (`lib/core/database/conversation_history_repository.dart`) - AI conversation message history per scenario
- `LearningStatisticsRepository` (`lib/core/database/learning_statistics_repository.dart`) - Daily study statistics, streaks, and analytics
- Database file: `italiano_learning.db` with tables: learning_records, grammar_progress, conversation_history, learning_statistics
- All learning progress automatically persists across app restarts
- Provider integration: Notifiers load from database on initialization and save after each update

### Routing
- Routes defined in `lib/core/router/app_router.dart` (GoRouter configured but not integrated)
- Currently uses basic MaterialApp navigation with `Navigator.push`
- Main entry: `HomeScreen` with bottom navigation bar
- Learning flow: `HomeScreen` → `VocabularyLearningScreen`

### Data Models

**Vocabulary Models** (`lib/shared/models/word.dart`):
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

**Reading Models** (`lib/shared/models/reading.dart`):
- `ReadingPassage` - Reading passage with:
  - Italian and Chinese titles
  - CEFR level (A1, A2) and category
  - Full text content
  - Word count and estimated reading time
  - 5 comprehension questions per passage
  - Optional audio URL

- `ReadingQuestion` - Comprehension question:
  - Question text (Chinese and Italian)
  - Question type: choice, true_false, fill_blank
  - Answer options (for multiple choice)
  - Correct answer and explanation

- `ReadingProgress` - Reading completion tracking:
  - Passage ID and completion date
  - Correct/total questions count
  - User answers for each question
  - Accuracy percentage (auto-calculated)
  - Favorite flag

**Conversation Models** (`lib/shared/models/conversation.dart`):
- `ConversationScenario` - Scenario definition with:
  - Italian and Chinese names
  - Description and difficulty level
  - Icon representation
  - 6 predefined scenarios: restaurant, airport, shopping, doctor, interview, friend

- `AIRole` - AI character definition:
  - Role name in Italian and Chinese
  - System prompt defining AI behavior and personality
  - Generated from ConversationScenario

- `ConversationMessage` - Chat message with:
  - Content text
  - User/AI flag
  - Timestamp
  - Optional translation
  - Optional grammar corrections array

- `GrammarCorrection` - Grammar error correction:
  - Original incorrect text
  - Corrected text
  - Explanation in Chinese
  - Error type classification

### Text-to-Speech (TTS) System
Powered by **KOKORO TTS API** with OpenAI-compatible format (`lib/core/services/tts_service.dart`):

**API Configuration**:
- Base URL: `https://newapi.maiduoduo.it/v1`
- Endpoint: `/audio/speech`
- Model: `kokoro`
- Response Format: MP3 audio

**Voice Options**:
- `im_nicola` - Italian male voice
- `if_sara` - Italian female voice (default)

**Features**:
- Real-time text-to-speech conversion for Italian text
- Audio caching system for improved performance
  - `preloadAudio()` - Download and cache audio without playing
  - `playFromCache()` - Play cached audio instantly
  - `clearCache()` - Clean up cached audio files
- Playback controls: play, pause, stop, resume
- Integration with `audioplayers` package for audio playback
- Used across vocabulary learning, review, list, and reading screens

**Provider** (`lib/shared/providers/tts_provider.dart`):
- `ttsServiceProvider` - Singleton TTSService instance
- `ttsPlayingStateProvider` - Track current playback state

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
   - **14 grammar points** covering A1-A2 fundamentals (100% A2 coverage ✅)
   - **A1 Topics (4)**: Present tense, Articles, Personal pronouns, Gender/Number
   - **A2 Topics (10)**: Passato Prossimo, Imperfetto, Futuro Semplice, Imperativo, Condizionale Semplice, Reflexive verbs, Comparatives/Superlatives, Possessive adjectives, Prepositions, Direct/Indirect Object Pronouns
   - Each with detailed rules, examples, and 10 practice exercises
   - **Total of 140 interactive exercises** across all grammar points

### AI Conversation System
Real-time conversation practice with intelligent AI partner powered by DeepSeek API:

1. **DeepSeek API Service** (`lib/core/services/deepseek_service.dart`)
   - OpenAI-compatible chat completion endpoint
   - API Configuration:
     - Base URL: `https://api.deepseek.com`
     - Model: `deepseek-chat`
     - Timeouts: 30s connect, 60s receive
   - Features:
     - Level-adaptive system prompts (A1-C2)
     - Conversation history management
     - Grammar correction parsing with regex
     - Error handling with retry logic

2. **Conversation State Management** (`lib/shared/providers/conversation_provider.dart`)
   - `ConversationNotifier` - StateNotifier managing chat state:
     - Message history (user + AI)
     - Loading states during API calls
     - Error state with user-friendly messages
     - User level setting (affects AI difficulty)
   - `conversationProvider` - Family provider for scenario-specific state
     - Each scenario has independent conversation
     - Auto-initialization with AI greeting
   - `deepSeekServiceProvider` - Singleton API service

3. **ConversationScenarioScreen** (`lib/features/conversation/conversation_scenario_screen.dart`)
   - Grid view of 6 conversation scenarios
   - Scenario cards display:
     - Icon and level badge (A1-C2)
     - Italian/Chinese scenario names
     - Description text
     - Color-coded level indicators
   - Click to start conversation with selected scenario

4. **AIConversationScreen** (`lib/features/conversation/ai_conversation_screen.dart`)
   - Main chat interface with:
     - Message bubbles (user: blue, AI: gray)
     - Avatar icons for user/AI distinction
     - Timestamp for each message
     - Auto-scroll to latest message
   - **Grammar Correction Display**:
     - Orange cards with lightbulb icon
     - Format: "错误" → "正确" - 解释
     - Appears below user messages when errors detected
   - **Controls**:
     - Level selector (A1-C2) in app bar
     - Reset conversation button
     - Text input with send button
     - Loading indicator during AI response
   - **Error Handling**:
     - Red banner for API errors
     - Dismissible error messages
     - Retry capability

5. **Grammar Correction System**
   - AI responses include corrections in format:
     ```
     [CORREZIONE: "incorrect" → "correct" - explanation in Chinese]
     ```
   - Regex-based parsing extracts corrections
   - Multiple corrections per message supported
   - Corrections displayed separately from message content

6. **Level-Adaptive Prompts**
   System prompts adjust AI behavior based on user level:
   - **A1/A2**: Simple vocabulary, present tense, short sentences
   - **B1/B2**: Common phrases, past/future tenses, medium complexity
   - **C1/C2**: Advanced vocabulary, subjunctive mood, complex structures
   - All levels receive grammar corrections in Chinese

### Project Structure
```
lib/
├── core/
│   ├── constants/          # App-wide constants
│   ├── database/           # SQLite database layer (v3)
│   │   ├── database_service.dart
│   │   ├── learning_record_repository.dart
│   │   ├── grammar_progress_repository.dart
│   │   ├── conversation_history_repository.dart
│   │   ├── learning_statistics_repository.dart
│   │   └── reading_progress_repository.dart
│   ├── router/             # GoRouter configuration
│   ├── services/           # Singleton services
│   │   ├── audio_player_service.dart    # Audio playback
│   │   ├── deepseek_service.dart        # DeepSeek API integration
│   │   └── reading_service.dart         # Reading passages loading
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
│   ├── reading/            # Reading comprehension (NEW)
│   │   ├── reading_list_screen.dart          # Browse passages with filters
│   │   └── reading_detail_screen.dart        # Read passage and answer questions
│   ├── conversation/       # AI conversation practice
│   │   ├── conversation_scenario_screen.dart  # Scenario selection
│   │   └── ai_conversation_screen.dart        # Chat interface
│   ├── practice/           # Integrated into reading feature
│   └── profile/            # User profile with statistics and charts
│       └── profile_screen.dart
└── shared/
    ├── models/             # Data models
    │   ├── word.dart       # Word, LearningRecord
    │   ├── grammar.dart    # GrammarPoint, GrammarRule, GrammarExample, etc.
    │   ├── reading.dart    # ReadingPassage, ReadingQuestion, ReadingProgress
    │   └── conversation.dart    # ConversationScenario, AIRole, ConversationMessage
    ├── providers/          # Riverpod state providers
    │   ├── vocabulary_provider.dart      # Word loading, learning progress
    │   ├── grammar_provider.dart         # Grammar loading, progress tracking
    │   ├── reading_provider.dart         # Reading passages, progress tracking
    │   └── conversation_provider.dart    # Conversation state, DeepSeek API
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
- **1219 words** covering all CEFR levels ✅ (Exceeds A2 CEFR requirement of 1000-1200 words)
- Fields: id, italian, chinese, english, pronunciation, category, level, examples, audioUrl, imageUrl, createdAt
- **Level distribution**:
  - A1: 392 words (100% coverage)
  - A2: 780 words (exceeds CEFR A2 standard) ✅
  - B1-C2: 47 words
- **A2 Categories** (top 10):
  - 日常用语: 287 words (daily expressions, verbs, states)
  - 形容词: 141 words (descriptive, personality, quality adjectives)
  - 家庭生活: 84 words (home items, appliances, daily routines)
  - 旅游出行: 54 words (travel, places, city facilities)
  - 健康医疗: 42 words (body parts, health conditions)
  - 时间副词: 38 words (frequency, temporal expressions)
  - 食物餐饮: 36 words (food, cooking, dining)
  - 商务交流: 33 words (shopping, business, transactions)
  - 工作学习: 29 words (study, work, cognition)
  - 娱乐运动: 17 words (sports, entertainment)
- **Recent Expansion (2025)**: Added 420 A2 core words:
  - 80 daily action verbs (basic movements, communication, activities)
  - 70 emotional & cognitive verbs (feelings, mental states)
  - 120 adjectives & adverbs (personality, appearance, frequency)
  - 150 lifestyle vocabulary (home, clothing, body, weather, city)
- **Vocabulary Expansion**: Use Python scripts for bulk additions (50-100 words at a time)

**Grammar** (`assets/data/sample_grammar.json`):
- **14 grammar points** (4 A1 + 10 A2 level)
- Categories: 时态, 冠词, 代词, 名词, 介词, 动词, 形容词
- Each includes: rules (with bullet points), bilingual examples, 10 practice exercises (fill_blank/choice types)
- **A1 Topics**: Present tense, Articles, Personal pronouns, Gender/Number
- **A2 Topics**: Passato Prossimo, Imperfetto, Futuro Semplice, Imperativo, Condizionale Semplice, Reflexive verbs, Comparatives/Superlatives, Possessive adjectives, Prepositions, Direct/Indirect Object Pronouns
- **A2 Coverage**: 100% ✅ (All core CEFR A2 requirements complete!)

**Reading Comprehension** (`assets/data/reading_passages.json`):
- **10 reading passages** (4 A1 + 6 A2 level) ✅
- **Total**: 1,454 words of reading material
- **Categories**:
  - 日常生活 (Daily Life): 5 passages (La mia famiglia, Al ristorante, Una giornata tipica, Il mio hobby, etc.)
  - 旅游 (Travel): 1 passage (Il mio weekend a Firenze)
  - 实用文本 (Practical Texts): 3 passages (Cerco un appartamento, L'orario dei negozi, Una lettera)
  - 文化 (Culture): 1 passage (Le stagioni in Italia)
  - 学习 (Learning): 1 passage (Imparare l'italiano)
- **Questions**: 5 comprehension questions per passage (50 total)
  - Question types: Multiple choice, True/False, Fill-in-the-blank
  - All questions include Chinese and Italian versions
  - Detailed explanations for each answer
- **Passage characteristics**:
  - Word count: 96-162 words per passage
  - Estimated reading time: 2-3 minutes each
  - Authentic Italian language and cultural contexts
  - Level-appropriate vocabulary and grammar structures

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
- `dio` (^5.7.0) - HTTP client for DeepSeek API and future API calls
- `intl` (^0.20.1) - Internationalization utilities
- `path` (^1.9.0) - Path manipulation utilities
- `fl_chart` (^0.69.0) - Charts for statistics visualization

## DeepSeek API Configuration
The app uses DeepSeek's conversational AI for language practice:
- **API Key**: Stored in `conversation_provider.dart`
- **Base URL**: `https://api.deepseek.com`
- **Model**: `deepseek-chat`
- **Endpoint**: `/chat/completions` (OpenAI-compatible)
- **Rate Limits**: Follow DeepSeek's standard rate limits
- **Error Handling**: Network errors, timeout errors, API errors gracefully handled with user feedback

## Important Implementation Notes

### Adding New Vocabulary
1. **Manual Addition**:
   - Add word entries to `assets/data/sample_words.json`
   - Follow existing JSON structure with all required fields
   - Optionally add audio files to `assets/audio/words/{wordId}.mp3`
   - Run `flutter pub get` if adding new assets

2. **Bulk Addition** (for large datasets):
   - Use Python scripts to add 50-100 words at a time
   - Read existing words, find max ID, increment for new words
   - Validate JSON structure and maintain formatting
   - Group vocabulary by theme (e.g., Imperfetto-related, reflexive verbs, etc.)
   - Example pattern:
     ```python
     import json
     with open('assets/data/sample_words.json', 'r', encoding='utf-8') as f:
         words = json.load(f)
     # Find max ID, create new words with IDs, append, write back
     ```

### Adding New Grammar Points
1. **Structure Requirements**:
   - Each grammar point needs: id, title, category, level, description, rules, examples, exercises
   - Rules: Array of objects with title, content, and bullet points
   - Examples: Italian/Chinese/English with highlighted grammar elements
   - Exercises: Mix of fill_blank and choice types (recommend 10 per grammar point)

2. **Using Python Scripts**:
   ```python
   import json
   with open('assets/data/sample_grammar.json', 'r', encoding='utf-8') as f:
       grammar_data = json.load(f)
   # Add new grammar point object
   grammar_data.append(new_grammar)
   # Write back with proper encoding
   ```

### Extending Learning Features
- Learning progress auto-saves after every `recordWordStudied()` call
- Access statistics via `LearningProgressNotifier.getStatistics()`
- Query words due for review: `getWordsToReview()`
- All database operations are async - use `await`

### Working with AI Conversations
- Each conversation scenario has independent state (via `.family` provider)
- Conversation history is persisted to database via `ConversationHistoryRepository`
- Grammar corrections are parsed from AI response using regex pattern
- To add new scenarios: Update `ConversationScenario.all` in `conversation.dart`
- To modify AI behavior: Edit system prompts in `AIRole.fromScenario()`
- Level changes apply immediately to next message (no reset required)

### Working with Statistics
- Statistics are tracked automatically across all learning activities
- `LearningStatisticsRepository` maintains daily records in `learning_statistics` table
- Key methods:
  - `incrementWordsLearned(date, count)` - Track new vocabulary learned
  - `incrementWordsReviewed(date, count)` - Track review sessions
  - `incrementGrammarStudied(date, count)` - Track grammar lessons completed
  - `getStudyStreak()` - Calculate consecutive study days
  - `getRecentStatistics(days)` - Get daily stats for time range
- Use `statisticsProvider` (FutureProvider) to access aggregated statistics in UI
- Includes vocabulary stats (`vocabularyStatsProvider`) and grammar stats (`grammarStatsProvider`)

### Database Schema (Version 3)

**learning_records** (vocabulary learning progress):
- wordId (TEXT PRIMARY KEY)
- lastReviewed (TEXT NOT NULL) - ISO8601 datetime
- reviewCount (INTEGER NOT NULL)
- correctCount (INTEGER NOT NULL)
- mastery (REAL NOT NULL) - 0.0 to 1.0
- nextReviewDate (TEXT) - ISO8601 datetime, nullable
- isFavorite (INTEGER NOT NULL) - 0 or 1 boolean
- Indexes: nextReviewDate, isFavorite

**grammar_progress** (grammar study tracking):
- grammarId (TEXT PRIMARY KEY)
- completedAt (TEXT) - ISO8601 datetime, nullable
- exerciseResults (TEXT NOT NULL) - Format: "correct/total" (e.g., "8/10")
- isFavorite (INTEGER NOT NULL) - 0 or 1 boolean

**conversation_history** (AI conversation messages):
- id (INTEGER PRIMARY KEY AUTOINCREMENT)
- scenarioId (TEXT NOT NULL)
- content (TEXT NOT NULL)
- isUser (INTEGER NOT NULL) - 0 or 1 boolean
- timestamp (TEXT NOT NULL) - ISO8601 datetime
- translation (TEXT) - Nullable
- grammarCorrections (TEXT) - JSON array of corrections, nullable
- Index: scenarioId

**learning_statistics** (daily study metrics):
- date (TEXT PRIMARY KEY) - ISO8601 date (YYYY-MM-DD)
- wordsLearned (INTEGER NOT NULL)
- wordsReviewed (INTEGER NOT NULL)
- grammarPointsStudied (INTEGER NOT NULL)
- conversationMessages (INTEGER NOT NULL)
- studyTimeMinutes (INTEGER NOT NULL)

**reading_progress** (reading comprehension progress):
- passage_id (TEXT PRIMARY KEY)
- completed_at (TEXT NOT NULL) - ISO8601 datetime
- correct_answers (INTEGER NOT NULL)
- total_questions (INTEGER NOT NULL)
- user_answers (TEXT NOT NULL) - Serialized "q1:A,q2:B" format
- is_favorite (INTEGER NOT NULL) - 0 or 1 boolean

### Development Testing
- ~~Use `PersistenceTestScreen` (accessible via science icon on home page)~~ - REMOVED
- Test database operations through actual app usage
- Use Flutter DevTools for debugging state and database
- Clear app data: `flutter clean` or uninstall/reinstall app

### Adding New Features

**Adding a new content type** (similar to reading comprehension):
1. Create data model in `lib/shared/models/`
2. Add JSON data file in `assets/data/`
3. Create repository in `lib/core/database/` and update schema in `database_service.dart`
4. Create provider in `lib/shared/providers/`
5. Create UI screens in `lib/features/[feature_name]/`
6. Integrate into navigation in `home_screen.dart`
7. Update CLAUDE.md documentation

**Adding vocabulary/grammar content**:
- Use Python scripts to bulk-add data (see `add_verbs_batch*.py` examples in git history)
- Follow existing JSON structure in `sample_words.json` or `sample_grammar.json`
- Maintain consistent formatting and required fields

**Database migrations**:
- Increment version number in `database_service.dart`
- Add migration logic in `_upgradeDB()` method
- Test migration with existing user data

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

### Future Enhancement Ideas
Based on CEFR A2 requirements, potential additions:
- **Listening Practice**: Audio comprehension exercises with transcripts
- **Writing Practice**: Guided writing tasks with AI feedback (using DeepSeek)
- **Pronunciation Practice**: Speech recognition for pronunciation scoring
- **More Content**: Expand to 1500+ A2 words, 20+ reading passages
- **B1 Level**: Begin B1 content for advanced learners
- **Offline Mode**: Download audio and enable full offline usage
- **Gamification**: Achievements, streaks, leaderboards
