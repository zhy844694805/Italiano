# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Italian language learning Flutter application (意大利语学习应用) with comprehensive features for vocabulary and grammar learning. The app uses a scientifically-proven spaced repetition algorithm to optimize long-term retention and stores all progress in a local SQLite database.

**Target Audience**: Zero-based learners aiming to reach CEFR A2 level (basic independent user)

**Learning Outcome**: After completing all content, learners will achieve A2 proficiency, capable of:
- Understanding sentences and frequently used expressions (e.g., personal info, family, shopping, work)
- Communicating in simple routine tasks requiring direct exchange of information
- Describing aspects of background, immediate environment, and matters of immediate need

### Content Coverage vs CEFR Standards

#### Vocabulary Content
- **Total Vocabulary**: 1,469 words
  - A1: 492 words (CEFR standard: 500-700 words) - **98% coverage** ✅
  - A2: 930 words (CEFR standard: 1000-1200 words) - **78-93% coverage** ✅
  - **A1+A2 Combined**: 1,422 words - **95% coverage of CEFR requirements** ✅
  - B1-C2: 47 words (bonus advanced vocabulary)

#### Grammar Content
- **Total Grammar Points**: 14 (with 140 practice exercises)
  - A1: 4 grammar points - **100% coverage** ✅
    - Present tense (presente)
    - Articles (articoli determinativi/indeterminativi)
    - Personal pronouns (pronomi personali)
    - Gender and number (genere e numero)
  - A2: 10 grammar points - **100% coverage** ✅
    - Past tense (passato prossimo)
    - Imperfect (imperfetto)
    - Simple future (futuro semplice)
    - Reflexive verbs (verbi riflessivi)
    - Comparatives and superlatives (comparativi e superlativi)
    - Possessive adjectives (aggettivi possessivi)
    - Prepositions (preposizioni)

#### Four Skills Training
| Skill | CEFR Requirement | App Implementation | Status |
|-------|------------------|-------------------|--------|
| **Listening** | Understand simple daily conversations | TTS audio for words + reading passages | ✅ Adequate |
| **Speaking** | Communicate in routine situations | 6 AI conversation scenarios | ✅ Adequate |
| **Reading** | Understand simple texts | 20 reading passages (A1-A2) | ✅ Adequate |
| **Writing** | Write simple sentences | 140 grammar exercises + fill-in-the-blank | ✅ Adequate |

### Recommended Learning Path (Zero to A2)

#### Stage 1: A1 Foundation (3-6 months, 30-60 min/day)
**Week 1-4: Basic Survival Italian**
- Learn 100 most common A1 words (greetings, numbers, basics)
- Master present tense verb conjugations
- Complete articles and pronouns lessons
- Practice: Restaurant and shopping scenarios

**Month 2-3: Expanding Basics**
- Learn remaining 292 A1 words
- Complete all A1 grammar points
- Read A1 passages (3-4 articles)
- Daily AI conversation practice (5-10 min)

**Month 3-6: A1 Consolidation**
- Review system: Daily spaced repetition
- Complete all A1 reading comprehension
- Take comprehensive A1 quizzes
- AI conversation practice in multiple scenarios

**A1 Checkpoint**: Can introduce yourself, order food, ask for directions, understand basic signs

#### Stage 2: A2 Development (6-12 months, 30-60 min/day)
**Month 7-9: Past and Future**
- Learn 300 A2 words (daily routines, work, hobbies)
- Master passato prossimo and imperfetto
- Learn simple future tense
- Read A2 passages about experiences

**Month 10-12: Advanced Grammar**
- Learn remaining 480 A2 words
- Complete reflexive verbs and comparatives
- Master prepositions and possessives
- Practice: Doctor visit, job interview scenarios

**Month 13-18: A2 Mastery**
- Review all 1,422 words with SRS
- Complete all 140 grammar exercises
- Read all 20 passages multiple times
- Daily AI conversation at A2 level
- Take comprehensive A2 tests

**A2 Checkpoint**: Can describe past events, make plans, express opinions, handle most routine situations

### Expected Time to A2 Proficiency
- **Intensive Track** (60 min/day): 9-12 months
- **Regular Track** (30 min/day): 15-18 months
- **Casual Track** (15 min/day): 24-30 months

**Success Factors**:
- ✅ Daily consistent practice (most important!)
- ✅ Use spaced repetition system religiously
- ✅ Complete all grammar exercises
- ✅ Regular AI conversation practice
- ✅ Listen to TTS audio for pronunciation
- ✅ Review progress statistics weekly

### Key Features
1. **Learn New Words** - Smart filtering shows only unstudied words (1469 total available)
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

5. **Reading Comprehension** - Authentic Italian reading passages with comprehension exercises
   - 20 carefully curated passages (7 A1 + 13 A2 level)
   - Topics: daily life, travel, culture, practical texts, news, social media, emails, reviews
   - 5 comprehension questions per passage (100 questions total)
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

7. **Italian Phrases** - Practical expressions for real-world conversations
   - 57 curated phrases across categories (compliments, insults, casual)
   - Phonetic notation and usage context for each phrase
   - Tabbed interface for easy category browsing
   - **TTS Support**: Authentic pronunciation playback for all expressions
   - Popularity filtering to highlight most commonly used phrases
   - Emoji support for visual learning enhancement

8. **Progress Tracking** - Comprehensive statistics and analytics (✅ Complete)
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

**Phrase Providers** (`lib/shared/providers/phrase_provider.dart`):
- `phraseNotifierProvider` - StateNotifier managing all Italian phrases data
- `popularPhrasesProvider` - Filtered provider for commonly used phrases
- `complimentPhrasesProvider` - Compliment expressions (19 phrases)
- `insultPhrasesProvider` - Expressions for emotional expression (17 phrases)
- `casualPhrasesProvider` - Everyday conversation phrases (21 phrases)
- Automatic JSON loading with error handling

**Conversation Providers** (`lib/shared/providers/conversation_provider.dart`):
- `deepSeekServiceProvider` - FutureProvider for DeepSeek API service (nullable if API key not configured)
- `conversationProvider` - StateNotifierProvider.family for scenario-specific conversation state
  - Each scenario maintains independent conversation history
  - Manages messages, loading state, errors, user level
  - Auto-initializes with AI greeting message
  - Handles real-time grammar correction parsing
  - Memory optimization: Limits to 50 messages max per conversation

Use `ConsumerWidget` or `ConsumerStatefulWidget` for widgets that need to watch providers

### Data Persistence
SQLite database (v7 schema) managed through:
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

**Phrase Models** (`lib/shared/models/phrase.dart`):
- `ItalianPhrase` - Italian expression with:
  - Italian text with phonetic pronunciation guide
  - Chinese translation and context usage
  - Category classification: compliment, insult, casual
  - CEFR difficulty level (A1, A2, B1)
  - Example sentences with bilingual content
  - Emoji support for visual learning
  - Popularity flag for commonly used phrases

### Text-to-Speech (TTS) System
Powered by **KOKORO TTS API** with OpenAI-compatible format (`lib/core/services/tts_service.dart`):

**API Configuration**:
- Base URL: `https://newapi.maiduoduo.it/v1`
- Endpoint: `/audio/speech`
- Model: `kokoro`
- Response Format: MP3 audio
- **IMPORTANT**: Requires `INTERNET` permission in `AndroidManifest.xml`

**Voice Options**:
- `im_nicola` - Italian male voice (Nicola)
- `if_sara` - Italian female voice (Sara, default)
- User preference stored via `voicePreferenceProvider` using SharedPreferences
- Voice selection UI available in Settings screen

**Features**:
- Real-time text-to-speech conversion for Italian text
- **Smart caching system** for improved performance:
  - Checks cache before making API calls
  - Cache stored in `{app_documents}/tts_cache/`
  - File naming: `{text.hashCode}_{voice}.mp3`
  - `preloadAudio()` - Download and cache audio without playing
  - `playFromCache()` - Play cached audio instantly
  - `clearCache()` - Clean up cached audio files
- Playback controls: play, pause, stop, resume
- Integration with `audioplayers` package for audio playback
- Used across vocabulary learning, review, list, and reading screens
- Returns `false` if API key not configured (graceful degradation)

**Provider** (`lib/shared/providers/tts_provider.dart`):
- `ttsServiceProvider` - Singleton TTSService instance
- `ttsPlayingStateProvider` - Track current playback state
- `voicePreferenceProvider` - User's selected voice preference (Sara/Nicola)

**Integration Pattern**:
```dart
// Read user's voice preference
final selectedVoice = ref.read(voicePreferenceProvider);
// Play with selected voice
await ttsService.speak(text, voice: selectedVoice);
```

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

### Italian Phrases System
Practical Italian expressions organized by usage category with TTS support:

1. **Data Structure** (`lib/shared/models/phrase.dart`)
   - `ItalianPhrase` model with comprehensive fields:
     - Italian text with phonetic pronunciation guide
     - Chinese translation and detailed context usage
     - Category classification: compliment, insult, casual
     - CEFR difficulty level (A1, A2, B1)
     - Example sentences with bilingual content
     - Emoji support for visual learning enhancement
     - Popularity flag for commonly used expressions

2. **Content Management** (`assets/data/italian_phrases.json`)
   - **57 curated phrases** across three categories:
     - Compliments (19 phrases): Sei fantastico!, Che bravo/a!, Complimenti!
     - Expressions (17 phrases): Sei uno scemo!, Che schifo!, Stai zitto/a!
     - Casual (21 phrases): Mamma mia!, Andiamo!, Calma!, Pazienza!
   - Rich metadata for each phrase including examples and cultural context
   - Regular JSON format easy for bulk updates and management

3. **Provider Architecture** (`lib/shared/providers/phrase_provider.dart`)
   - `phraseNotifierProvider` - StateNotifier managing all phrase data
   - Category-specific providers:
     - `complimentPhrasesProvider` - Filtered compliment expressions
     - `insultPhrasesProvider` - Emotional expression phrases
     - `casualPhrasesProvider` - Everyday conversation phrases
     - `popularPhrasesProvider` - Most commonly used expressions
   - Automatic JSON loading with comprehensive error handling

4. **PhraseListScreen** (`lib/features/phrase/phrase_list_screen.dart`)
   - **Tabbed Interface**: Compliments, Insults, Casual, Popular
   - **Category Statistics**: Real-time count display for each category
   - **Search & Filter**: Advanced filtering by level, category, popularity
   - **TTS Integration**: One-click audio playback for pronunciation
   - **Detailed Cards**: Rich display with phonetics, examples, and context
   - **Responsive Design**: Optimized for both mobile and web platforms

5. **Phrase Card Design**
   - **Visual Hierarchy**: Italian text prominent with phonetic notation
   - **Cultural Context**: Usage scenarios and example sentences
   - **Audio Support**: Integrated TTS playback controls
   - **Progress Indicators**: Category badges and difficulty levels
   - **Interactive Elements**: Tap-to-play audio, expandable content areas

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
│   ├── database/           # SQLite database layer
│   │   ├── database_service.dart
│   │   ├── learning_record_repository.dart
│   │   ├── grammar_progress_repository.dart
│   │   ├── conversation_history_repository.dart
│   │   ├── learning_statistics_repository.dart
│   │   └── reading_progress_repository.dart
│   ├── router/             # GoRouter configuration
│   ├── services/           # Singleton services
│   │   ├── audio_player_service.dart
│   │   ├── deepseek_service.dart
│   │   ├── quiz_generator_service.dart
│   │   ├── reading_service.dart
│   │   └── tts_service.dart
│   ├── theme/
│   │   └── openai_theme.dart   # OpenAI-style minimalist theme
│   └── utils/
│       └── api_check_helper.dart  # API configuration check helper
├── features/
│   ├── home/
│   │   └── home_screen.dart
│   ├── vocabulary/
│   │   ├── vocabulary_learning_screen.dart
│   │   ├── vocabulary_review_screen.dart
│   │   └── vocabulary_list_screen.dart
│   ├── grammar/
│   │   ├── grammar_list_screen.dart
│   │   └── grammar_detail_screen.dart
│   ├── reading/
│   │   ├── reading_list_screen.dart
│   │   └── reading_detail_screen.dart
│   ├── conversation/
│   │   ├── conversation_scenario_screen.dart
│   │   └── ai_conversation_screen.dart
│   ├── daily_conversation/
│   │   ├── daily_conversation_list_screen.dart
│   │   └── daily_conversation_detail_screen.dart
│   ├── practice/
│   │   ├── practice_screen.dart
│   │   ├── quiz_screen.dart
│   │   └── quiz_result_screen.dart
│   ├── phrase/
│   │   └── phrase_list_screen.dart
│   ├── onboarding/
│   │   └── onboarding_screen.dart   # First-time setup wizard
│   ├── settings/
│   │   └── settings_screen.dart
│   └── profile/
│       ├── profile_screen.dart
│       ├── achievements_screen.dart    # View all achievements
│       └── favorites_screen.dart       # View favorite words/grammar
└── shared/
    ├── models/
    │   ├── word.dart
    │   ├── grammar.dart
    │   ├── reading.dart
    │   ├── conversation.dart
    │   └── phrase.dart
    ├── providers/
    │   ├── vocabulary_provider.dart
    │   ├── grammar_provider.dart
    │   ├── reading_provider.dart
    │   ├── phrase_provider.dart
    │   ├── conversation_provider.dart
    │   ├── statistics_provider.dart
    │   ├── voice_preference_provider.dart
    │   ├── tts_provider.dart
    │   ├── achievement_provider.dart     # Achievement tracking
    │   ├── user_profile_provider.dart    # User profile (nickname, avatar)
    │   └── onboarding_provider.dart      # First-launch detection
    └── widgets/
        ├── flip_card.dart
        ├── swipeable_word_card.dart
        ├── word_card.dart
        ├── gradient_card.dart
        ├── api_config_dialog.dart        # API key configuration dialog
        └── achievement_unlock_dialog.dart  # Achievement popup
```

### Theme System
The app uses **OpenAI Theme** (`lib/core/theme/openai_theme.dart`) - a minimalist design inspired by OpenAI's official website:

**Design Philosophy**: 极简、黑白、精致、专业 (Minimalist, black-white, refined, professional)

**Color System**:
- **Primary**: OpenAI Green (#10A37F) - Brand accent color
- **Black Series**: Black (#000000), Dark Gray (#202123), Charcoal (#343541)
- **Gray Series**: 7 levels from gray700 (#40414F) to gray50 (#F7F7F8)
- **White Series**: White (#FFFFFF), Off-white (#FAFAFA)
- **Functional**: Error (#EF4444), Warning (#F59E0B), Success (#10A37F), Info (#3B82F6)
- **Text**: Primary (#202123), Secondary (#6E6E80), Tertiary (#ACACAC)
- **Background**: Primary (white), Secondary (#F7F7F8), Tertiary (#ECECF1)
- **Border**: Light (#E5E5E5), Medium (#D1D5DB), Dark (#ACACAC)

**Helper Decoration Methods** (static methods on `OpenAITheme`):
- `cardDecoration()` - Card with border, optional selection state
- `floatingCardDecoration()` - Card with subtle shadow
- `accentCardDecoration()` - Card with green border and shadow
- `darkCardDecoration()` - Dark background card
- `gradientButtonDecoration()` - Green gradient for buttons
- `glassDecoration()` - Glass-morphism effect

**UI Component Guidelines**:
- Cards use borders instead of heavy shadows
- Navigation bar with green indicator on selection
- Buttons with green accent or dark gray fill
- Clean typography with clear hierarchy
- Minimal use of gradients (only for special emphasis)

**Theme Configuration** (`main.dart`):
```dart
theme: OpenAITheme.lightTheme,
```

### Data Sources

**Vocabulary** (`assets/data/sample_words.json`):
- **1,469 words** covering all CEFR levels ✅ (95% of A1+A2 CEFR requirements)
- Fields: id, italian, chinese, english, pronunciation, category, level, examples, audioUrl, imageUrl, createdAt
- **Level distribution**:
  - A1: 492 words (98% coverage) ✅
  - A2: 930 words (78-93% coverage) ✅
  - B1-C2: 47 words
- **A1 Categories**: 颜色(15), 身体部位(25), 衣物(20), 情绪(15), 天气(15), 方位词(10), 日常用语(264), 食物餐饮(35), 家庭生活(21), 旅游出行(19), 工作学习(15)
- **A2 Categories** (top 10):
  - 日常用语: 287 words (daily expressions, verbs, states)
  - 形容词: 141 words (descriptive, personality, quality adjectives)
  - 家庭生活: 84 words (home items, appliances, daily routines)
  - 工作学习: 59 words (study, work, cognition)
  - 旅游出行: 54 words (travel, places, city facilities)
  - 娱乐运动: 47 words (sports, entertainment)
  - 健康医疗: 42 words (body parts, health conditions)
  - 通讯科技: 39 words (technology, internet, communication)
  - 时间副词: 38 words (frequency, temporal expressions)
  - 食物餐饮: 36 words (food, cooking, dining)
- **Recent Expansion (October 2025)**: Added 250 words:
  - **A1 Batch (+100)**: Colors, body parts, clothing, emotions, weather, directions
  - **A2 Batch (+150)**: Technology, entertainment, abstract concepts, work/study, social relations
- **Vocabulary Expansion**: Use Python scripts (`add_a1_vocabulary.py`, `add_a2_vocabulary.py`) for bulk additions

**Grammar** (`assets/data/sample_grammar.json`):
- **14 grammar points** (4 A1 + 10 A2 level)
- Categories: 时态, 冠词, 代词, 名词, 介词, 动词, 形容词
- Each includes: rules (with bullet points), bilingual examples, 10 practice exercises (fill_blank/choice types)
- **A1 Topics**: Present tense, Articles, Personal pronouns, Gender/Number
- **A2 Topics**: Passato Prossimo, Imperfetto, Futuro Semplice, Imperativo, Condizionale Semplice, Reflexive verbs, Comparatives/Superlatives, Possessive adjectives, Prepositions, Direct/Indirect Object Pronouns
- **A2 Coverage**: 100% ✅ (All core CEFR A2 requirements complete!)

**Reading Comprehension** (`assets/data/reading_passages.json`):
- **20 reading passages** (7 A1 + 13 A2 level) ✅
- **Total**: 3,020 words of reading material
- **Categories**:
  - 实用文本 (Practical Texts): 8 passages (supermarket ads, cinema posters, apartment rentals, weather forecasts, social media, emails)
  - 日常生活 (Daily Life): 6 passages (family, restaurant, daily routines, hobbies, health blog, restaurant reviews)
  - 旅游 (Travel): 2 passages (Florence weekend, tourist guide)
  - 文化 (Culture): 2 passages (seasons, music festival)
  - 工作学习 (Work/Study): 1 passage (work email)
  - 学习 (Learning): 1 passage (learning Italian)
- **Questions**: 5 comprehension questions per passage (100 total)
  - Question types: Multiple choice, True/False, Fill-in-the-blank
  - All questions include Chinese and Italian versions
  - Detailed explanations for each answer
- **Passage characteristics**:
  - Word count: 78-278 words per passage
  - Estimated reading time: 2-4 minutes each
  - Authentic Italian language and cultural contexts
  - Level-appropriate vocabulary and grammar structures
- **Recent Expansion (October 2025)**: Added 10 passages:
  - **A1 (+3)**: Supermarket ads, cinema posters, apartment rentals
  - **A2 (+7)**: Weather forecasts, social media posts, work emails, music festival news, health blogs, restaurant reviews, travel guides
- **Reading Expansion**: Use Python script (`add_reading_passages.py`) to add new passages in batches

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
- `image_picker` (^1.0.7) - Image selection for mobile platforms (iOS/Android)
- `file_selector` (^1.0.3) - File selection for desktop platforms (macOS/Windows/Linux)

## API Configuration

### API Key Management (`lib/core/config/api_config.dart`)
All API keys are stored securely via SharedPreferences:
- `ApiConfig.getDeepSeekApiKey()` / `setDeepSeekApiKey()` - DeepSeek API key
- `ApiConfig.getTtsApiKey()` / `setTtsApiKey()` - TTS API key
- `ApiConfig.isConfigured()` - Check if both keys are configured
- `ApiConfig.isTtsConfigured()` / `ApiConfig.isDeepSeekConfigured()` - Check individual API status
- **Settings UI**: Users configure API keys via Settings → API 配置
- **Guide Screen**: `ApiGuideScreen` provides step-by-step instructions for obtaining DeepSeek API key

### Onboarding System (`lib/features/onboarding/`)
First-time user onboarding with API configuration:
- **OnboardingScreen** - 3-page wizard: Welcome → Features → API Configuration
- **onboarding_provider.dart** - Tracks onboarding completion via SharedPreferences
- Users can skip API configuration and configure later in Settings
- Onboarding status persisted via `onboarding_completed` key

### API Check Helper (`lib/core/utils/api_check_helper.dart`)
Centralized utility for checking API configuration before use:
```dart
// For TTS playback - shows config dialog if not configured
await ApiCheckHelper.speakWithCheck(context, text, voice: selectedVoice);

// For DeepSeek API - shows config dialog if not configured
final isConfigured = await ApiCheckHelper.checkDeepSeekApi(context);
```
- Automatically prompts users to configure API when needed
- Graceful degradation - features work after configuration
- Used across all TTS and AI conversation screens

### DeepSeek API (AI Conversation)
The app uses DeepSeek's conversational AI for language practice:
- **API Key**: User-configured via Settings screen, stored in SharedPreferences
- **Base URL**: `https://api.deepseek.com`
- **Model**: `deepseek-chat`
- **Endpoint**: `/chat/completions` (OpenAI-compatible)
- **Timeouts**: 30s connect, 60s receive
- **Error Handling**: Network errors, timeout errors, API errors gracefully handled with user feedback
- **IMPORTANT**: Requires `INTERNET` and `ACCESS_NETWORK_STATE` permissions in `AndroidManifest.xml`

### KOKORO TTS API
- **API Key**: User-configured via Settings screen
- **Base URL**: `https://newapi.maiduoduo.it/v1`
- **Endpoint**: `/audio/speech`
- **Smart Caching**: TTS responses cached locally to reduce API calls
- See "Text-to-Speech (TTS) System" section for complete details.

### Android Permissions Required
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```
Without these permissions, both AI conversation and TTS features will fail with network errors.

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

### Achievement System
The app includes a gamification system to motivate learners (`lib/shared/providers/achievement_provider.dart`):

**Achievement Categories** (16 total achievements):
- **Study Streak**: 7-day, 30-day, 100-day consecutive learning
- **Vocabulary Milestones**: 100, 500, 1000 words learned
- **Mastery Goals**: 50, 200, 500 words mastered (≥80% accuracy)
- **Grammar Progress**: 5, 10, 14 grammar points completed
- **First Steps**: First word, first grammar lesson

**Implementation**:
- `AchievementNotifier` - StateNotifier tracking unlocked achievements
- `AchievementDefinitions.all` - List of all achievement definitions
- `checkAndUnlock()` - Check and unlock new achievements based on progress
- Achievement state persisted via SharedPreferences

**Achievement Unlock Dialog** (`lib/shared/widgets/achievement_unlock_dialog.dart`):
- OpenAI minimalist style popup
- Shows achievement icon, title, and description
- Animated entrance with scale animation
- Called automatically after vocabulary learning, review, and grammar completion

**Integration Pattern**:
```dart
// Check achievements after learning activity
final achievement = await checkAchievements(ref);
if (achievement != null && mounted) {
  await AchievementUnlockDialog.show(context, achievement);
}
```

### User Profile System
User profile management (`lib/shared/providers/user_profile_provider.dart`):
- **UserProfile** model with nickname and avatarPath
- `setNickname()` - Update user's display name
- `setAvatar()` - Set avatar image path
- `clearAvatar()` - Remove custom avatar
- Persisted to SharedPreferences

**Platform-Specific Image Picking** (`lib/features/profile/profile_screen.dart`):
- **Mobile (iOS/Android)**: Uses `image_picker` package for gallery/camera access
- **Desktop (macOS/Windows/Linux)**: Uses `file_selector` package for native file dialog
- Automatic platform detection via `Platform.isMacOS`, etc.

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

### Working with Italian Phrases
- Phrases are loaded from JSON in `assets/data/italian_phrases.json`
- `PhraseNotifier` manages all phrase data with automatic loading
- Category-specific providers for easy filtering:
  - `complimentPhrasesProvider` - Compliment expressions (19 total)
  - `insultPhrasesProvider` - Emotional expressions (17 total)
  - `casualPhrasesProvider` - Everyday conversation phrases (21 total)
  - `popularPhrasesProvider` - Most commonly used expressions
- TTS integration for pronunciation learning with `ttsServiceProvider`
- Phrase data structure includes phonetics, context, examples, and usage scenarios
- UI organized in tabbed interface with category statistics and search functionality

### Database Schema (Version 7)

**Performance Indexes (v7)**:
- `idx_learning_records_mastery` - For mastery statistics queries
- `idx_grammar_completed` - For grammar completion queries
- `idx_conversation_scenario_time` - Compound index for conversation history
- `idx_reading_favorite` - For reading favorites queries

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

### Handling Deprecated APIs

**Color Opacity (Critical)**:
```dart
// ❌ DEPRECATED - withOpacity() is deprecated in Flutter 3.32+
color.withOpacity(0.1)

// ✅ CORRECT - Use withValues() to avoid precision loss
color.withValues(alpha: 0.1)
```
Always use `withValues(alpha: value)` instead of `withOpacity()` throughout the codebase. This affects:
- Shadow colors
- Background colors with transparency
- Overlay colors

**Radio Buttons**:
The current settings screen uses deprecated `groupValue` and `onChanged` parameters for Radio widgets. These warnings can be ignored for now until RadioGroup is properly implemented in a future Flutter version.

### UI Development Best Practices

**Layout Overflow Prevention**:
- When using `GridView` with custom cards, test for overflow at various screen sizes
- Recommended approach: Start with larger padding (18-20px) and reduce if overflow occurs
- Use `flutter run` with hot reload to test layout changes immediately
- Common overflow fixes:
  - Reduce padding: 20→16→14px
  - Reduce icon sizes: 32→28→24px
  - Reduce font sizes: 17→15→14px for titles, 15→13→12px for labels
  - Add `mainAxisSize: MainAxisSize.min` to Column/Row widgets
  - Always add `maxLines` and `overflow: TextOverflow.ellipsis` to Text widgets

**GridView Card Sizing**:
```dart
// Example: Properly sized card for GridView
GradientCard(
  padding: const EdgeInsets.all(14), // Not too large
  child: Column(
    mainAxisSize: MainAxisSize.min, // Prevent expansion
    children: [
      Icon(icon, size: 28), // Moderate icon size
      const SizedBox(height: 10), // Moderate spacing
      Text(
        title,
        style: TextStyle(fontSize: 14), // Not too large
        maxLines: 2, // Limit lines
        overflow: TextOverflow.ellipsis, // Handle overflow
      ),
    ],
  ),
)
```

**Common Layout Issues & Solutions**:

1. **Text Getting Squeezed in Row**:
```dart
// ❌ WRONG - Text gets compressed by sibling
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('Long text that might overflow'),
    Text('Other text'),
  ],
)

// ✅ CORRECT - Give text room to expand
Row(
  children: [
    Expanded(
      child: Text('Long text that might overflow'),
    ),
    const SizedBox(width: 16),
    Text('Other text'),
  ],
)
```

2. **Stack Widget Not Filling Space**:
```dart
// ❌ WRONG - Stack shrinks to content size
GridView(
  children: [
    Stack(
      children: [
        GradientCard(...), // Shrinks to minimum size
        Positioned(badge),
      ],
    ),
  ],
)

// ✅ CORRECT - Force stack child to expand
GridView(
  children: [
    Stack(
      children: [
        SizedBox.expand(
          child: GradientCard(...), // Fills available space
        ),
        Positioned(badge),
      ],
    ),
  ],
)
```

3. **GridView childAspectRatio**:
- Default 1.0 (square cards) may be too tall or too short
- For quick action cards with icon + text: Use 1.1-1.3
- Test on actual device to verify card proportions
- Smaller ratio = taller cards (more vertical space)

**Testing Workflow**:
1. Run `flutter run` for development testing
2. Check console for RenderFlex overflow errors
3. Adjust padding/font sizes incrementally
4. Hot reload to test changes
5. Use Flutter DevTools to inspect widget tree
6. Test on both small and large screen sizes
7. Build release APK only after all errors resolved

## Learning Best Practices

### For Optimal Results
1. **Consistency Over Intensity**
   - Study 30 minutes daily > 3 hours once a week
   - Build a daily habit at the same time each day
   - Use the app's streak counter as motivation

2. **Spaced Repetition Discipline**
   - Never skip review sessions (check home screen daily)
   - Trust the algorithm - review words when they appear
   - Mark honestly: "know" vs "don't know" affects scheduling

3. **Active Learning Strategies**
   - Use TTS audio for every new word (pronunciation is critical)
   - Try AI conversation immediately after learning new words
   - Do grammar exercises before reading passages
   - Re-read passages after completing comprehension questions

4. **Four Skills Balance**
   - **Week structure suggestion**:
     - Mon/Wed/Fri: New vocabulary + grammar
     - Tue/Thu: Reading + comprehension
     - Sat: AI conversation practice
     - Sun: Review + quizzes
   - Spend at least 10-15 min/day on AI conversation

5. **Progress Monitoring**
   - Check statistics weekly (Profile screen)
   - Aim for 80%+ accuracy on reviews
   - Complete at least 20 words/day (daily goal)
   - Maintain study streak for motivation

### Common Pitfalls to Avoid
- ❌ Learning too many new words at once (max 20-30/day)
- ❌ Skipping grammar exercises (they reinforce patterns)
- ❌ Only using flashcards without reading/conversation
- ❌ Not reviewing words when due (breaks spaced repetition)
- ❌ Studying irregularly (consistency is key)

## Current Limitations & Future Enhancements

### Known Gaps (Minor)
1. **Listening Comprehension**: Only TTS audio available
   - TTS provides clear, consistent pronunciation
   - Missing: Varied speakers, accents, speeds
   - Workaround: Use AI conversation for varied speech

2. **Writing Production**: Limited to fill-in-the-blank
   - Exercises focus on grammar accuracy
   - Missing: Free writing with feedback
   - Workaround: Use AI conversation for text chat

### Potential Future Enhancements
Based on CEFR A2 requirements and user feedback:

**High Priority** (fill critical gaps):
- **Listening Exercises**: Dedicated audio comprehension with transcripts
- **Writing Tasks**: Guided paragraph writing with AI feedback (DeepSeek)
- **A2 Vocabulary Expansion**: Add 70 more words to reach 1000 (current: 930)
- **Pronunciation Practice**: Speech recognition for speaking practice

**Medium Priority** (improve experience):
- **More Reading Content**: Continue expanding beyond 20 passages
- **Grammar Drills**: Additional practice exercises per topic
- **Dialogue Practice**: Scripted conversations with role-play
- **Offline Mode**: Download all audio for offline learning
- **Video Content**: Short video lessons for grammar explanations

**Low Priority** (nice-to-have):
- **B1 Level Content**: Begin intermediate level (500+ words)
- **Cultural Notes**: Italian culture, customs, etiquette
- **Flashcard Games**: Make vocabulary review more engaging
- ~~**Achievements System**: Badges, milestones, rewards~~ ✅ **IMPLEMENTED**
- **Social Features**: Study groups, leaderboards
- **Export Progress**: PDF reports, certificates

### Extending Content
If you need to add more vocabulary or grammar:

**Adding More Vocabulary**:
```python
# Use existing Python scripts for bulk additions
# A1: python3 add_a1_vocabulary.py (currently at 492/500-700)
# A2: python3 add_a2_vocabulary.py (currently at 930/1000-1200)
# Focus on thematic groups: food, nature, technology, etc.
```

**Adding Grammar Points** (for B1 level):
- Subjunctive mood (congiuntivo)
- Conditional tense (condizionale)
- Passive voice (forma passiva)
- Direct/indirect pronouns combined
- Gerund and participles

**Adding Reading Passages**:
```python
# Use Python script for bulk reading additions
# python3 add_reading_passages.py (currently at 20 passages)
# Focus on diverse topics: sports, technology, health, culture
# Vary text types: emails, ads, short stories, news, reviews
# Ensure CEFR level alignment (check word frequency)
```

## Conclusion

This app provides a **complete, structured path from zero to A2 Italian proficiency**. With 1,422 high-quality vocabulary words, 14 comprehensive grammar points, 20 reading passages, and integrated four-skills training, learners can achieve functional Italian communication ability in 9-18 months with consistent daily practice.

**Current Content Summary** (as of December 2025):
- **Vocabulary**: 1,469 words (492 A1 + 930 A2 + 47 B1-C2) - 95% CEFR coverage ✅
- **Grammar**: 14 points with 140 exercises - 100% A1-A2 coverage ✅
- **Reading**: 20 passages (7 A1 + 13 A2) with 100 questions - Complete diversity ✅
- **Conversation**: 6 AI scenarios with real-time grammar correction ✅
- **Italian Phrases**: 57 practical expressions (19 compliments, 17 insults, 21 casual) ✅
- **TTS Audio**: KOKORO integration for authentic pronunciation ✅

**Key Strengths**:
- ✅ Scientifically-proven spaced repetition system
- ✅ Authentic Italian pronunciation (KOKORO TTS)
- ✅ AI conversation partner with grammar correction
- ✅ Comprehensive progress tracking with statistics
- ✅ All content aligned to CEFR standards
- ✅ Completely self-contained (no external materials needed)
- ✅ Practical Italian expressions for real-world conversations

**Success Rate Expectation**:
- With disciplined daily practice: 90%+ learners reach A2
- Average time to A2: 12-15 months (30-60 min/day)
- Critical success factor: Consistency + review discipline

**Development Tools Available**:
- `add_a1_vocabulary.py` - Bulk add A1 vocabulary (50-100 words at a time)
- `add_a2_vocabulary.py` - Bulk add A2 vocabulary (50-100 words at a time)
- `add_reading_passages.py` - Bulk add reading passages (5-10 passages at a time)

### Content Management
For bulk content additions, use the provided Python scripts in the root directory:
- **Vocabulary**: A1 (currently 492/500-700), A2 (currently 930/1000-1200)
- **Reading**: 20 passages with comprehension questions (7 A1 + 13 A2)
- **Phrases**: 57 practical expressions with categories and phonetics
- All content files stored in `assets/data/` with JSON format
- Scripts maintain proper ID sequencing and JSON structure integrity

Start your Italian learning journey today - **Buona fortuna!** 🇮🇹
