# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CouchWord is a tvOS crossword puzzle app built with SwiftUI, designed for Apple TV with Siri Remote navigation. Targets tvOS 17.0+, Swift 5, device family 3 (Apple TV only). No third-party dependencies — Apple frameworks only.

## Build & Test

Requires Xcode (not just Command Line Tools) to build since it targets tvOS.

```bash
# Build
xcodebuild -project CouchWord.xcodeproj -scheme CouchWord -destination 'platform=tvOS Simulator,name=Apple TV' build

# Run all tests
xcodebuild -project CouchWord.xcodeproj -scheme CouchWord -destination 'platform=tvOS Simulator,name=Apple TV' test

# Run a specific test suite
xcodebuild -project CouchWord.xcodeproj -scheme CouchWord -destination 'platform=tvOS Simulator,name=Apple TV' test -only-testing:CouchWordTests/PuzzleTests

# Run a single test
xcodebuild -project CouchWord.xcodeproj -scheme CouchWord -destination 'platform=tvOS Simulator,name=Apple TV' test -only-testing:CouchWordTests/PuzzleViewModelTests/enterLetterUpdatesProgress
```

## Architecture

**MVVM with environment-injected services.** `ProfileManager` and `PuzzleStore` are created in `CouchWordApp`. Per-profile `ProgressStore` and `DailyPuzzleManager` are created in `RootView` based on the active profile.

### App Flow
`CouchWordApp` → `RootView` (profile selection + onboarding) → `HomeScreen` → `GameView` (puzzle session)

### Models
- **Puzzle** (Codable) — JSON schema matching `tv-crossword-concept.html`. Grid is 2D string array ("#" = black). 100 puzzles bundled in `Resources/Puzzles/`.
- **UserProgress** (Codable) — tracks user grid, undo stack (letter/word/hint granularity), hints, elapsed time.
- **GameStats** (Codable) — lifetime stats: solved count, streaks, best times.
- **UserProfile** — household profiles (up to 4) with name and avatar color.
- **SkillProfile** — per-category performance tracking for adaptive difficulty. Knowledge radar data.
- **AppTheme** — 5 visual themes (Midnight, Newspaper, Ocean, Forest, Neon) with full color palettes.
- **GameMode** — Standard, Speed Round (60s), Mystery Grid (hidden blacks), Clueless (no clue text).
- **Achievement** — 18 achievements across 5 categories with automatic unlock checking.
- **WordJournal** — tracks every unique word encountered with count and dates.

### Services
- **PuzzleStore** — loads bundled puzzle JSON from `Resources/Puzzles/`.
- **ProgressStore** — wraps UserDefaults with profile-namespaced keys. Stores progress, stats, skill profile, achievements, word journal, theme, and settings.
- **ProfileManager** — manages household profiles (create, delete, switch active).
- **DailyPuzzleManager** — deterministic daily puzzle selection, streak freeze logic.
- **ShakeDetector** — CMMotionManager accelerometer for Siri Remote shake-to-undo.
- **SoundManager** — system sounds via AudioServicesPlaySystemSound.
- **VoiceInputManager** — processes dictation text into letter/word input.
- **ShareResultsGenerator** — Wordle-style emoji grid for sharing results.

### Views
- **HomeScreen** — menu: Today's Puzzle, Quick Play, Continue, Statistics, Achievements, Settings.
- **GameView** — game container with grid, clue panel, HUD, shake detection.
- **PuzzleGridView** — focus-engine grid with dynamic cell sizing via `GridLayout`.
- **CellView** — themed cells with VoiceOver labels, reduced motion support.
- **ClueListView** — across/down sections with scroll-to-active.
- **CompletionView** — animated results with share button.
- **StatsDashboardView** — totals, streaks, by-difficulty, best times, knowledge radar.
- **AchievementsView** — achievement cards + word journal cloud.
- **ProfilePickerView** — multi-player profile selection.
- **OnboardingView** — 3-page tutorial.
- **SettingsView** — theme, font, timer mode, sound toggle.

### tvOS Focus & Input
- Grid: `.focusable()` + `@FocusState` with "row-col" IDs, bidirectional sync.
- `.onMoveCommand` for d-pad, `.onPlayPauseCommand` for direction toggle.
- Shake-to-undo via CMMotionManager.
- Voice input via system dictation through focused TextField.

### Tests
Swift Testing (`@Test`, `#expect`). Suites: PuzzleTests, UserProgressTests, GameStatsTests, PuzzleViewModelTests, VoiceInputManagerTests.

### Puzzle JSON Format
```json
{
  "id": "puzzle_001", "version": 1,
  "size": {"rows": 5, "cols": 5}, "difficulty": "easy",
  "theme": "Space", "date": null,
  "grid": [["S","T","A","R","S"], ...],
  "clues": {
    "across": [{"number": 1, "clue": "...", "answer": "STARS", "row": 0, "col": 0}],
    "down": [...]
  },
  "tags": ["space"], "author": "CouchWord"
}
```

## Product Spec & Build Log

Full 52-version roadmap: `tv-crossword-concept.html`
Build decisions and progress: `BUILD_LOG.md`
Current build: through v15.0 (of 52 versions)
