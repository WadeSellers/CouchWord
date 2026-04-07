import SwiftUI
import Combine

@MainActor
class PuzzleViewModel: ObservableObject {
    // MARK: - Published State

    @Published var puzzle: Puzzle?
    @Published var progress: UserProgress?
    @Published var focusedRow: Int = 0
    @Published var focusedCol: Int = 0
    @Published var currentDirection: Direction = .across
    @Published var isZoomedOut: Bool = false
    @Published var isSolved: Bool = false
    @Published var showingVoiceInput: Bool = false
    @Published var checkMode: CheckMode = .none
    @Published var gameMode: GameMode = .standard
    @Published var speedRoundCount: Int = 0
    @Published var speedRoundTimeRemaining: TimeInterval = GameMode.speedRoundTimeLimit
    @Published var speedRoundGameOver: Bool = false
    @Published var revealedCells: Set<String> = [] // for mystery grid mode

    private var timerCancellable: AnyCancellable?
    private var startTime: Date?
    private let progressStore: ProgressStore

    enum CheckMode {
        case none
        case checking  // show correct/incorrect colors
    }

    init(progressStore: ProgressStore = ProgressStore()) {
        self.progressStore = progressStore
    }

    // MARK: - Computed Properties

    var currentCell: String {
        progress?.letterAt(row: focusedRow, col: focusedCol) ?? ""
    }

    var activeClue: PuzzleClue? {
        guard let puzzle else { return nil }
        if currentDirection == .across {
            return puzzle.acrossClue(forRow: focusedRow, col: focusedCol)
        } else {
            return puzzle.downClue(forRow: focusedRow, col: focusedCol)
        }
    }

    var acrossClues: [PuzzleClue] {
        puzzle?.clues.across ?? []
    }

    var downClues: [PuzzleClue] {
        puzzle?.clues.down ?? []
    }

    var cluesForCurrentDirection: [PuzzleClue] {
        currentDirection == .across ? acrossClues : downClues
    }

    var hintsRemaining: Int {
        3 - (progress?.hintsUsed ?? 0)
    }

    var elapsedTime: TimeInterval {
        progress?.elapsedSeconds ?? 0
    }

    var elapsedTimeFormatted: String {
        let total = Int(elapsedTime)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Puzzle Lifecycle

    func loadPuzzle(_ puzzle: Puzzle) {
        self.puzzle = puzzle
        self.isSolved = false
        self.checkMode = .none
        self.isZoomedOut = false
        self.currentDirection = .across

        // Try to resume existing progress
        if let saved = progressStore.loadProgress(for: puzzle.id),
           saved.state == .inProgress {
            self.progress = saved
        } else {
            self.progress = UserProgress(puzzleID: puzzle.id, rows: puzzle.rows, cols: puzzle.cols)
        }

        moveToFirstEditableCell()
        startTimer()
    }

    func saveCurrentProgress() {
        guard var progress else { return }
        progress.elapsedSeconds = elapsedTime
        if !isSolved {
            progress.state = .inProgress
        }
        self.progress = progress
        progressStore.saveProgress(progress)
    }

    // MARK: - Navigation

    func moveFocus(_ direction: FocusDirection) {
        guard let puzzle else { return }
        var newRow = focusedRow
        var newCol = focusedCol

        switch direction {
        case .up: newRow -= 1
        case .down: newRow += 1
        case .left: newCol -= 1
        case .right: newCol += 1
        }

        // Skip black cells
        while isValidPosition(row: newRow, col: newCol) && puzzle.isBlack(row: newRow, col: newCol) {
            switch direction {
            case .up: newRow -= 1
            case .down: newRow += 1
            case .left: newCol -= 1
            case .right: newCol += 1
            }
        }

        if isValidPosition(row: newRow, col: newCol) {
            focusedRow = newRow
            focusedCol = newCol
        }
    }

    func toggleDirection() {
        guard let puzzle else { return }
        let hasAcross = puzzle.acrossClue(forRow: focusedRow, col: focusedCol) != nil
        let hasDown = puzzle.downClue(forRow: focusedRow, col: focusedCol) != nil
        if hasAcross && hasDown {
            currentDirection = currentDirection.opposite
        }
    }

    func selectClue(_ clue: PuzzleClue, direction: Direction) {
        currentDirection = direction
        focusedRow = clue.row
        focusedCol = clue.col
    }

    func toggleZoom() {
        isZoomedOut.toggle()
    }

    // MARK: - Input

    func enterLetter(_ letter: Character) {
        guard var progress, let puzzle else { return }
        guard !puzzle.isBlack(row: focusedRow, col: focusedCol) else { return }

        // Record undo action
        let snapshot = CellSnapshot(
            row: focusedRow,
            col: focusedCol,
            previousValue: progress.letterAt(row: focusedRow, col: focusedCol)
        )
        let action = UndoAction(type: .letter, cellSnapshots: [snapshot])
        progress.undoStack.append(action)

        // Place the letter
        progress.setLetter(String(letter).uppercased(), row: focusedRow, col: focusedCol)
        self.progress = progress

        // Check for completion
        if checkPuzzleSolved() {
            completePuzzle()
        } else {
            advanceToNextCell()
        }

        saveCurrentProgress()
    }

    func enterWord(_ word: String) {
        guard var progress, let puzzle, let clue = activeClue else { return }
        let letters = Array(word.uppercased())

        var snapshots: [CellSnapshot] = []
        let dRow = currentDirection == .down ? 1 : 0
        let dCol = currentDirection == .across ? 1 : 0

        for (i, letter) in letters.enumerated() {
            let row = focusedRow + i * dRow
            let col = focusedCol + i * dCol

            guard isValidPosition(row: row, col: col),
                  !puzzle.isBlack(row: row, col: col) else { break }

            // Check we're still within the same clue
            let clueEndRow = clue.row + (currentDirection == .down ? clue.length - 1 : 0)
            let clueEndCol = clue.col + (currentDirection == .across ? clue.length - 1 : 0)
            guard row <= clueEndRow, col <= clueEndCol else { break }

            let prev = progress.letterAt(row: row, col: col)
            snapshots.append(CellSnapshot(row: row, col: col, previousValue: prev))
            progress.setLetter(String(letter), row: row, col: col)
        }

        if !snapshots.isEmpty {
            let action = UndoAction(type: .word, cellSnapshots: snapshots)
            progress.undoStack.append(action)
            self.progress = progress

            if checkPuzzleSolved() {
                completePuzzle()
            }

            saveCurrentProgress()
        }
    }

    func clearCurrentCell() {
        guard var progress, let puzzle else { return }
        guard !puzzle.isBlack(row: focusedRow, col: focusedCol) else { return }

        let snapshot = CellSnapshot(
            row: focusedRow,
            col: focusedCol,
            previousValue: progress.letterAt(row: focusedRow, col: focusedCol)
        )
        let action = UndoAction(type: .letter, cellSnapshots: [snapshot])
        progress.undoStack.append(action)
        progress.setLetter("", row: focusedRow, col: focusedCol)
        self.progress = progress
        saveCurrentProgress()
    }

    // MARK: - Undo

    func undo() {
        guard var progress, !progress.undoStack.isEmpty else { return }
        let action = progress.undoStack.removeLast()

        for snapshot in action.cellSnapshots {
            progress.setLetter(snapshot.previousValue, row: snapshot.row, col: snapshot.col)
        }

        // Move focus to the first cell in the undo action
        if let first = action.cellSnapshots.first {
            focusedRow = first.row
            focusedCol = first.col
        }

        self.progress = progress
        saveCurrentProgress()
    }

    // MARK: - Hints

    func useHint() {
        guard var progress, let puzzle else { return }
        guard progress.hintsUsed < 3 else { return }
        guard !puzzle.isBlack(row: focusedRow, col: focusedCol) else { return }

        let solution = puzzle.solutionAt(row: focusedRow, col: focusedCol)
        guard let solution else { return }

        let snapshot = CellSnapshot(
            row: focusedRow,
            col: focusedCol,
            previousValue: progress.letterAt(row: focusedRow, col: focusedCol)
        )
        let action = UndoAction(type: .hint, cellSnapshots: [snapshot])
        progress.undoStack.append(action)
        progress.setLetter(String(solution), row: focusedRow, col: focusedCol)
        progress.hintsUsed += 1
        self.progress = progress

        if checkPuzzleSolved() {
            completePuzzle()
        } else {
            advanceToNextCell()
        }

        saveCurrentProgress()
    }

    // MARK: - Game Mode Helpers

    /// In mystery grid mode, black cells are hidden until adjacent cells are filled.
    func isCellVisiblyBlack(row: Int, col: Int) -> Bool {
        guard let puzzle else { return false }
        guard puzzle.isBlack(row: row, col: col) else { return false }

        if gameMode != .mysteryGrid { return true }

        // In mystery mode, black cells are revealed when any adjacent non-black cell has a letter
        let key = "\(row)-\(col)"
        if revealedCells.contains(key) { return true }

        let neighbors = [(row-1, col), (row+1, col), (row, col-1), (row, col+1)]
        for (r, c) in neighbors {
            if isValidPosition(row: r, col: c),
               !puzzle.isBlack(row: r, col: c),
               let progress,
               !progress.letterAt(row: r, col: c).isEmpty {
                return true
            }
        }
        return false
    }

    /// In clueless mode, clue text is hidden. Only word lengths shown.
    var cluelessClueText: String? {
        guard gameMode == .clueless, let clue = activeClue else { return nil }
        return "\(clue.length) letters"
    }

    // MARK: - Checking

    func cellState(row: Int, col: Int) -> CellDisplayState {
        guard let puzzle, let progress else { return .empty }

        if puzzle.isBlack(row: row, col: col) {
            // In mystery mode, hide black cells until revealed
            if gameMode == .mysteryGrid && !isCellVisiblyBlack(row: row, col: col) {
                return .empty // Looks like an empty cell
            }
            return .black
        }

        let userLetter = progress.letterAt(row: row, col: col)
        if userLetter.isEmpty { return .empty }

        if checkMode == .checking || isSolved {
            let solution = puzzle.solutionAt(row: row, col: col)
            if userLetter.first == solution {
                return .correct
            } else {
                return .incorrect
            }
        }

        return .filled
    }

    func checkPuzzle() {
        checkMode = .checking
        // Auto-dismiss after 2 seconds
        Task {
            try? await Task.sleep(for: .seconds(2))
            if !isSolved {
                checkMode = .none
            }
        }
    }

    // MARK: - Private

    private func checkPuzzleSolved() -> Bool {
        guard let puzzle, let progress else { return false }
        for row in 0..<puzzle.rows {
            for col in 0..<puzzle.cols {
                if puzzle.isBlack(row: row, col: col) { continue }
                let userLetter = progress.letterAt(row: row, col: col)
                guard let solution = puzzle.solutionAt(row: row, col: col) else { continue }
                if userLetter.isEmpty || userLetter.first != solution {
                    return false
                }
            }
        }
        return true
    }

    private func completePuzzle() {
        guard var progress else { return }
        stopTimer()
        isSolved = true
        checkMode = .checking
        progress.state = .completed
        progress.completedAt = .now

        // Calculate accuracy
        var totalCells = 0
        var correctCells = 0
        if let puzzle {
            for row in 0..<puzzle.rows {
                for col in 0..<puzzle.cols {
                    if !puzzle.isBlack(row: row, col: col) {
                        totalCells += 1
                        let userLetter = progress.letterAt(row: row, col: col)
                        if let solution = puzzle.solutionAt(row: row, col: col),
                           userLetter.first == solution {
                            correctCells += 1
                        }
                    }
                }
            }
        }
        progress.accuracy = totalCells > 0 ? Double(correctCells) / Double(totalCells) : 1.0
        self.progress = progress
        progressStore.saveProgress(progress)
        progressStore.recordCompletion(
            puzzleID: progress.puzzleID,
            time: progress.elapsedSeconds,
            hints: progress.hintsUsed
        )

        // Record skill profile and achievements data
        if let puzzle {
            progressStore.recordSkillSolve(
                tags: puzzle.tags,
                time: progress.elapsedSeconds,
                accuracy: progress.accuracy ?? 1.0,
                hints: progress.hintsUsed
            )
            progressStore.recordPuzzleCompletion(
                puzzle: puzzle,
                time: progress.elapsedSeconds,
                hints: progress.hintsUsed,
                accuracy: progress.accuracy ?? 1.0
            )

            // Check for new achievements
            let newAchievements = AchievementRegistry.checkUnlocks(
                stats: progressStore.stats,
                achievementProgress: progressStore.achievementProgress,
                skillProfile: progressStore.skillProfile,
                wordCount: progressStore.wordJournal.totalUniqueWords
            )
            if !newAchievements.isEmpty {
                var ap = progressStore.achievementProgress
                for achievement in newAchievements {
                    ap.unlockedIDs.insert(achievement.id)
                }
                progressStore.achievementProgress = ap
            }
        }
    }

    private func advanceToNextCell() {
        guard let puzzle else { return }
        let dRow = currentDirection == .down ? 1 : 0
        let dCol = currentDirection == .across ? 1 : 0
        let newRow = focusedRow + dRow
        let newCol = focusedCol + dCol

        if isValidPosition(row: newRow, col: newCol) && !puzzle.isBlack(row: newRow, col: newCol) {
            focusedRow = newRow
            focusedCol = newCol
        }
    }

    private func moveToFirstEditableCell() {
        guard let puzzle else { return }
        for row in 0..<puzzle.rows {
            for col in 0..<puzzle.cols {
                if !puzzle.isBlack(row: row, col: col) {
                    focusedRow = row
                    focusedCol = col
                    return
                }
            }
        }
    }

    private func isValidPosition(row: Int, col: Int) -> Bool {
        guard let puzzle else { return false }
        return row >= 0 && row < puzzle.rows && col >= 0 && col < puzzle.cols
    }

    // MARK: - Timer

    private func startTimer() {
        startTime = Date()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, var progress = self.progress, !self.isSolved else { return }
                if let start = self.startTime {
                    let elapsed = Date().timeIntervalSince(start)
                    progress.elapsedSeconds += elapsed
                    self.startTime = Date()
                    self.progress = progress

                    // Speed round countdown
                    if self.gameMode == .speedRound {
                        self.speedRoundTimeRemaining -= elapsed
                        if self.speedRoundTimeRemaining <= 0 {
                            self.speedRoundTimeRemaining = 0
                            self.speedRoundGameOver = true
                            self.stopTimer()
                        }
                    }
                }
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}

// MARK: - Cell Display State

enum CellDisplayState {
    case empty
    case filled
    case correct
    case incorrect
    case black
}

enum FocusDirection {
    case up, down, left, right
}
