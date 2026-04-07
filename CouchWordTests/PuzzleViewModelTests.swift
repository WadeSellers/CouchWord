import Testing
@testable import CouchWord

@Suite("PuzzleViewModel Tests")
struct PuzzleViewModelTests {

    private func makePuzzle() -> Puzzle {
        Puzzle(
            id: "vm_test",
            version: 1,
            size: PuzzleSize(rows: 5, cols: 5),
            difficulty: .easy,
            theme: "Test",
            date: nil,
            grid: [
                ["S", "T", "A", "R", "S"],
                ["#", "#", "R", "#", "#"],
                ["C", "A", "R", "D", "S"],
                ["#", "#", "E", "#", "#"],
                ["P", "L", "A", "N", "S"],
            ],
            clues: ClueSet(
                across: [
                    PuzzleClue(number: 1, clue: "Night lights", answer: "STARS", row: 0, col: 0),
                    PuzzleClue(number: 3, clue: "Playing deck", answer: "CARDS", row: 2, col: 0),
                    PuzzleClue(number: 5, clue: "Intentions", answer: "PLANS", row: 4, col: 0),
                ],
                down: [
                    PuzzleClue(number: 2, clue: "Region", answer: "AREA", row: 0, col: 2),
                ]
            ),
            tags: ["test"],
            author: "Test"
        )
    }

    @MainActor
    @Test func loadPuzzleSetsInitialState() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(makePuzzle())
        #expect(vm.puzzle != nil)
        #expect(vm.focusedRow == 0)
        #expect(vm.focusedCol == 0)
        #expect(!vm.isSolved)
        #expect(vm.currentDirection == .across)
    }

    @MainActor
    @Test func moveFocusRight() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(makePuzzle())
        vm.moveFocus(.right)
        #expect(vm.focusedCol == 1)
    }

    @MainActor
    @Test func moveFocusSkipsBlackCells() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(makePuzzle())
        vm.focusedRow = 0
        vm.focusedCol = 1
        vm.moveFocus(.down)
        // Row 1 col 1 is black, should skip to row 2
        #expect(vm.focusedRow == 2)
    }

    @MainActor
    @Test func moveFocusStopsAtBounds() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(makePuzzle())
        vm.moveFocus(.left)
        #expect(vm.focusedCol == 0)
        vm.moveFocus(.up)
        #expect(vm.focusedRow == 0)
    }

    @MainActor
    @Test func toggleDirectionWhenBothCluesExist() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(makePuzzle())
        // Cell (0,2) has across clue 1 and down clue 2
        vm.focusedRow = 0
        vm.focusedCol = 2
        vm.currentDirection = .across
        vm.toggleDirection()
        #expect(vm.currentDirection == .down)
    }

    @MainActor
    @Test func enterLetterUpdatesProgress() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(makePuzzle())
        vm.enterLetter("S")
        #expect(vm.progress?.letterAt(row: 0, col: 0) == "S")
    }

    @MainActor
    @Test func enterLetterAdvancesFocus() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(makePuzzle())
        vm.currentDirection = .across
        vm.enterLetter("S")
        #expect(vm.focusedCol == 1) // moved to next cell
    }

    @MainActor
    @Test func undoRestoresCell() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(makePuzzle())
        vm.enterLetter("X")
        #expect(vm.progress?.letterAt(row: 0, col: 0) == "X")
        // Undo moves focus back, so set it explicitly
        vm.focusedRow = 0
        vm.focusedCol = 0
        vm.undo()
        #expect(vm.progress?.letterAt(row: 0, col: 0) == "")
    }

    @MainActor
    @Test func enterWordFillsMultipleCells() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(makePuzzle())
        vm.currentDirection = .across
        vm.focusedRow = 0
        vm.focusedCol = 0
        vm.enterWord("STARS")
        #expect(vm.progress?.letterAt(row: 0, col: 0) == "S")
        #expect(vm.progress?.letterAt(row: 0, col: 1) == "T")
        #expect(vm.progress?.letterAt(row: 0, col: 2) == "A")
        #expect(vm.progress?.letterAt(row: 0, col: 3) == "R")
        #expect(vm.progress?.letterAt(row: 0, col: 4) == "S")
    }

    @MainActor
    @Test func wordUndoRestoresAllCells() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(makePuzzle())
        vm.currentDirection = .across
        vm.enterWord("STARS")
        vm.undo()
        #expect(vm.progress?.letterAt(row: 0, col: 0) == "")
        #expect(vm.progress?.letterAt(row: 0, col: 4) == "")
    }

    @MainActor
    @Test func hintRevealsCorrectLetter() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(makePuzzle())
        vm.focusedRow = 0
        vm.focusedCol = 0
        vm.useHint()
        #expect(vm.progress?.letterAt(row: 0, col: 0) == "S")
        #expect(vm.progress?.hintsUsed == 1)
        #expect(vm.hintsRemaining == 2)
    }

    @MainActor
    @Test func maxThreeHints() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(makePuzzle())
        vm.useHint()
        vm.focusedCol = 1
        vm.useHint()
        vm.focusedCol = 2
        vm.useHint()
        vm.focusedCol = 3
        vm.useHint() // should be no-op
        #expect(vm.progress?.hintsUsed == 3)
        #expect(vm.hintsRemaining == 0)
    }

    @MainActor
    @Test func selectClueUpdatesFocus() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(makePuzzle())
        let clue = vm.puzzle!.clues.across[1] // clue 3, row 2
        vm.selectClue(clue, direction: .across)
        #expect(vm.focusedRow == 2)
        #expect(vm.focusedCol == 0)
        #expect(vm.currentDirection == .across)
    }

    @MainActor
    @Test func cellStatesReflectProgress() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(makePuzzle())
        #expect(vm.cellState(row: 0, col: 0) == .empty)
        #expect(vm.cellState(row: 1, col: 0) == .black)

        vm.enterLetter("S")
        vm.focusedRow = 0
        vm.focusedCol = 0
        #expect(vm.cellState(row: 0, col: 0) == .filled)
    }
}

@Suite("VoiceInputManager Tests")
struct VoiceInputManagerTests {

    @Test func singleLetterProcessing() {
        let result = VoiceInputManager.process("B")
        if case .letter(let c) = result {
            #expect(c == "B")
        } else {
            #expect(Bool(false), "Expected single letter")
        }
    }

    @Test func wordProcessing() {
        let result = VoiceInputManager.process("BANANA")
        if case .word(let w) = result {
            #expect(w == "BANANA")
        } else {
            #expect(Bool(false), "Expected word")
        }
    }

    @Test func phoneticLetterProcessing() {
        let result = VoiceInputManager.process("BEE")
        if case .letter(let c) = result {
            #expect(c == "B")
        } else {
            #expect(Bool(false), "Expected phonetic B")
        }
    }

    @Test func emptyInputReturnsEmpty() {
        let result = VoiceInputManager.process("")
        if case .empty = result {
            // pass
        } else {
            #expect(Bool(false), "Expected empty")
        }
    }

    @Test func thLetterPattern() {
        let result = VoiceInputManager.process("the letter R")
        if case .letter(let c) = result {
            #expect(c == "R")
        } else {
            #expect(Bool(false), "Expected letter R from 'the letter R'")
        }
    }
}
