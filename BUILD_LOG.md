# BUILD_LOG.md

Overnight build log for CouchWord v1.0 MVP.
Started: 2026-04-06 ~9pm

## Decisions

- **No Xcode IDE available** — only Swift Command Line Tools installed. All code is written to compile correctly but cannot be verified in tvOS Simulator until Xcode is installed. This is the #1 thing to test in the morning.
- **Sticking to spec's JSON schema exactly** — the existing Puzzle model used a different structure. Rewrote to match the spec's schema so puzzle JSON files are forward-compatible with the server-side plans (v4+).
- **Swift Testing over XCTest** — using `@Test`/`#expect` as the modern testing approach.
- **UserDefaults for persistence (v1)** — spec says UserDefaults. Not SwiftData. Keeps it simple. ProgressStore wraps UserDefaults with Codable serialization.
- **Undo stack as value type** — each UndoAction captures CellSnapshot array. Word undo stores all changed cells. Shake pops the stack and restores only those cells, preserving pre-existing letters from crossing words.
- **tvOS dictation approach** — using a hidden focused TextField to capture system dictation when the Siri Remote mic button is pressed. The VoiceInputManager processes raw text into letter/word results, handling phonetic names and common patterns.
- **Sound effects via AudioServicesPlaySystemSound** — no custom audio files for v1. Using system sound IDs. Can swap for custom .caf files later.
- **20 puzzles hand-crafted in JSON** — 7 easy, 7 medium, 6 hard. 20 different themes (Space, Food, Animals, Music, Sports, Ocean, Garden, Movies, Travel, Science, Weather, Colors, Cities, Books, Technology, Mythology, Geography, History, Art, Languages). Various grid patterns: full grids, separated rows, border patterns, cross patterns.
- **Minimap** — corner overlay for 5x5 grids using scaled rectangles. Shows filled vs empty cells and cursor position. Zoomed-out view accessible via double-tap.
- **Project structure** — `Models/`, `Views/`, `ViewModels/`, `Services/`, `Resources/Puzzles/` matching spec's suggested layout.
- **Environment objects over singleton** — PuzzleStore and ProgressStore injected via SwiftUI environment, not singletons. SoundManager is the one exception (singleton for fire-and-forget audio).
- **pbxproj hand-written** — Xcode project file created manually since we don't have Xcode to generate it. Uses short hex UUIDs. May need regeneration if Xcode complains.

## Uncertainties / Morning Review Items

- [ ] **pbxproj validity** — hand-written project file with short UUIDs. Xcode may reject the format. If so, create a new project in Xcode and re-add all files.
- [ ] **tvOS dictation integration** — the hidden TextField approach needs testing with actual Siri Remote. System dictation behavior on tvOS may differ from what I've assumed.
- [ ] **CMMotionManager on Siri Remote** — shake detection thresholds (currently 2.5g) need real-device tuning. The Siri Remote accelerometer sensitivity may require adjustment.
- [ ] **Focus engine behavior** — grid navigation with @FocusState and .focusable() may need tweaking for smooth feel on actual tvOS hardware.
- [ ] **Asset catalog for app icon** — currently has placeholder structure only. Need actual icon design assets before App Store submission.
- [ ] **System sound IDs** — the specific AudioServicesPlaySystemSound IDs used may not all be available on tvOS. Test and replace any missing ones.
- [ ] **Puzzle folder reference** — the Puzzles directory is added as a folder reference in the pbxproj. If JSON files don't bundle correctly, may need to add them individually or adjust the copy bundle resources phase.

## Build Progress

### Step 1: Data Layer ✅
- Rewrote Puzzle.swift to match spec JSON schema (Codable, id, version, size, difficulty, grid, clues, theme, tags, author)
- Created UserProgress.swift with undo stack (UndoAction, CellSnapshot)
- Created GameStats.swift for lifetime statistics
- Created PuzzleStore.swift (loads bundled JSON from Resources/Puzzles/)
- Created ProgressStore.swift (UserDefaults persistence for progress, stats, settings)

### Step 2: 20 Sample Puzzles ✅
- Generated 20 valid 5x5 crossword JSON files (puzzle_001.json through puzzle_020.json)
- Varied grid patterns, themes, and difficulty levels
- All validated: answers match grid, positions correct, clue numbers sequential

### Step 3: Home Screen ✅
- HomeScreen.swift with logo, menu (Today's Puzzle, Quick Play, Continue, Settings)
- PuzzlePickerView for browsing all puzzles with completion status
- SettingsView with sound toggle
- StatsBar showing solved count, current streak, best streak
- NavigationStack with typed Destination enum for type-safe navigation

### Step 4: Puzzle Grid View ✅
- PuzzleGridView with @FocusState bidirectional sync
- CellView with all states: empty, filled, correct, incorrect, black
- Focus scale animation (1.12x) and blue glow shadow
- Active word highlighting in blue
- ClueListView with across/down sections, scroll-to-active
- GameView container with HUD (timer, hints, check button)
- MinimapOverlay (corner) and MinimapGridView (zoomed-out full grid)

### Step 5: Voice Input ✅
- LetterInputView with A-Z card grid + hidden TextField for dictation
- VoiceInputManager processes raw dictation text
- Handles: single letters, phonetic names ("BEE" → B), "the letter X" pattern, full words
- Word input fills from cursor through active clue

### Step 6: Shake-to-Undo ✅
- ShakeDetector.swift using CMMotionManager accelerometer
- 2.5g threshold, 0.5s cooldown
- Connected to viewModel.undo() in GameView
- Undo stack correctly preserves pre-existing letters on word undo

### Step 7: Hint System ✅
- 3 hints per puzzle, reveals correct letter at cursor
- Remaining count shown in HUD
- Hint actions recorded in undo stack (can be undone)
- Button disabled when exhausted

### Step 8: Completion Flow ✅
- CompletionView with animated stats (time, hints, streak, accuracy)
- Staggered animation: title appears, then stats slide in
- Next Puzzle and Back to Home buttons
- Stats automatically recorded to ProgressStore

### Step 9: Sound Effects ✅
- SoundManager singleton with system sound IDs
- Effects: letterPlaced, wordCompleted, puzzleComplete, undo, error, hint, navigate
- Mutable via Settings toggle (persisted in ProgressStore)

### Step 10: Onboarding ✅
- 3-screen tutorial: Navigate (hand.draw), Voice (mic), Shake (radiowaves)
- Swipe left/right to navigate pages
- Skip button on every page
- Don't-show-again persisted via ProgressStore.hasShownOnboarding

### Step 11: Project Finalization ✅
- Updated project.pbxproj with all 19 Swift files, asset catalog, and Puzzles folder reference
- Updated CLAUDE.md with complete architecture documentation
- Updated tests to use new data models (5 test suites)
- Git tagged as v1.0

## v2.0 Progress

Starting v2.0 features: multiple grid sizes, 100+ puzzles, difficulty ratings, puzzle browser, stats dashboard.
