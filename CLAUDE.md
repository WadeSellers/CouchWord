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

**MVVM with environment-injected services.** Two `@StateObject` services (`PuzzleStore`, `ProgressStore`) are created in `CouchWordApp` and injected via `.environmentObject()`.

### App Flow
`CouchWordApp` → `RootView` (checks onboarding) → `HomeScreen` → `GameView` (puzzle session)

### Data Layer
- **Puzzle** (Codable) — matches the JSON schema in `tv-crossword-concept.html`. Loaded from bundled JSON files in `Resources/Puzzles/`. Each puzzle has an id, grid (2D string array where "#" = black), clues with across/down arrays, difficulty, theme, and tags.
- **UserProgress** (Codable) — tracks the user's grid state, undo stack, hints used, elapsed time. Serialized to UserDefaults via `ProgressStore`.
- **GameStats** (Codable) — lifetime stats: total solved, streaks, best times.
- **UndoAction** — captures `CellSnapshot`s. Word undo stores all cells changed by that word; letter undo stores one cell. Shake-to-undo pops the stack and restores only the snapshotted cells.

### Services
- **PuzzleStore** — loads and indexes bundled puzzle JSON from `Resources/Puzzles/`.
- **ProgressStore** — wraps UserDefaults for save/resume, stats, and settings (sound, onboarding flag).
- **ShakeDetector** — CMMotionManager accelerometer monitoring on Siri Remote. Fires `onShake` closure when acceleration exceeds threshold, with cooldown to prevent double-triggers.
- **SoundManager** — singleton playing system sounds via `AudioServicesPlaySystemSound`. Effects: letterPlaced, wordCompleted, puzzleComplete, undo, error, hint, navigate.
- **VoiceInputManager** — processes raw dictation text into `.letter(Character)` or `.word(String)`. Handles phonetic names ("BEE" → B), "the letter X" patterns, and multi-character word input.

### Views
- **HomeScreen** — menu with Today's Puzzle, Quick Play, Continue, Settings. Uses `NavigationStack` with typed destinations.
- **GameView** — main game container. Owns `PuzzleViewModel` and `ShakeDetector`. Wires up `.onMoveCommand`, `.onPlayPauseCommand`, shake-to-undo, and presents completion overlay.
- **PuzzleGridView** — the 5x5 grid using `@FocusState` with cell ID strings. Focus syncs bidirectionally with the view model.
- **CellView** — renders a single cell with states: empty, filled, correct, incorrect, black. Focus scale/glow animation.
- **ClueListView** — across/down sections with scroll-to-active behavior.
- **LetterInputView** — A-Z card grid + hidden TextField for Siri dictation capture.
- **CompletionView** — animated results: time, hints, streak, accuracy. Next puzzle / home buttons.
- **OnboardingView** — 3-page tutorial (navigate, voice, shake). Skippable, persisted via ProgressStore.

### tvOS Focus & Input
- Grid cells use `.focusable()` + `@FocusState` tracked by "row-col" string IDs.
- `.onMoveCommand` handles Siri Remote d-pad — view model skips black cells.
- Play/Pause button toggles across/down direction.
- Click center on a cell opens the letter input sheet.
- Shake remote triggers undo via CMMotionManager.
- Voice input uses system dictation through a focused TextField.

### Tests
Tests use Swift Testing (`@Test`, `#expect`). Suites: PuzzleTests, UserProgressTests, GameStatsTests, PuzzleViewModelTests, VoiceInputManagerTests.

### Puzzle JSON Format
Each puzzle file in `Resources/Puzzles/` follows this schema:
```json
{
  "id": "puzzle_001",
  "version": 1,
  "size": {"rows": 5, "cols": 5},
  "difficulty": "easy",
  "theme": "Space",
  "date": null,
  "grid": [["S","T","A","R","S"], ...],
  "clues": {
    "across": [{"number": 1, "clue": "...", "answer": "STARS", "row": 0, "col": 0}],
    "down": [...]
  },
  "tags": ["space"],
  "author": "CouchWord"
}
```

## Product Spec

Full product roadmap is in `tv-crossword-concept.html` (52 versions across 13 eras). Current build is v1.0 MVP. Build decisions and morning review items are logged in `BUILD_LOG.md`.
