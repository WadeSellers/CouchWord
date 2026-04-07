# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CouchWord is a tvOS crossword puzzle app built with SwiftUI, designed for Apple TV with Siri Remote navigation. Targets tvOS 17.0+, Swift 5, device family 3 (Apple TV only).

## Build & Test

This project requires Xcode (not just Command Line Tools) to build and test since it targets tvOS.

```bash
# Build
xcodebuild -project CouchWord.xcodeproj -scheme CouchWord -destination 'platform=tvOS Simulator,name=Apple TV' build

# Run all tests
xcodebuild -project CouchWord.xcodeproj -scheme CouchWord -destination 'platform=tvOS Simulator,name=Apple TV' test

# Run a specific test suite
xcodebuild -project CouchWord.xcodeproj -scheme CouchWord -destination 'platform=tvOS Simulator,name=Apple TV' test -only-testing:CouchWordTests/PuzzleTests

# Run a single test
xcodebuild -project CouchWord.xcodeproj -scheme CouchWord -destination 'platform=tvOS Simulator,name=Apple TV' test -only-testing:CouchWordTests/PuzzleTests/samplePuzzleHasCorrectSize
```

## Architecture

**MVVM with SwiftUI.** The app uses a single `PuzzleViewModel` (MainActor-isolated ObservableObject) as the central game state, shared across all views via `@ObservedObject`.

### Data flow
- `Puzzle` (value type) holds the grid of `Cell`s and arrays of `Clue`s. Cells know which across/down clue they belong to.
- `PuzzleGenerator` produces puzzles. Currently has a hardcoded sample — this is the integration point for real puzzle sources (API, file import, etc.).
- `PuzzleViewModel` owns the puzzle, tracks cursor position (`focusedRow`/`focusedCol`), current direction, and solved state. All mutation goes through the view model.

### tvOS Focus & Input
- The grid uses tvOS focus engine: each non-black cell is `.focusable()` with `@FocusState` tracked by cell ID strings ("row-col").
- Siri Remote directional input is handled via `.onMoveCommand` — the view model skips black cells automatically.
- Play/Pause button toggles between across/down direction.
- Letter entry uses a modal `LetterInputView` with a grid of A-Z buttons using `.buttonStyle(.card)` for tvOS card focus appearance.
- Focus state syncs bidirectionally: tvOS focus changes update the view model, and programmatic navigation (e.g., selecting a clue) updates focus.

### Tests
Tests use Swift Testing (`@Test`, `#expect`) not XCTest. The test target depends on the app target and imports `@testable import CouchWord`.
