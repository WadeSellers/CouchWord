import Testing
@testable import CouchWord

@Suite("PuzzleViewModel Tests")
struct PuzzleViewModelTests {

    @MainActor
    @Test func loadPuzzleSetsState() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(PuzzleGenerator.sample())
        #expect(vm.puzzle != nil)
        #expect(vm.focusedRow == 0)
        #expect(vm.focusedCol == 0)
        #expect(!vm.isSolved)
    }

    @MainActor
    @Test func moveFocusRight() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(PuzzleGenerator.sample())
        vm.moveFocus(.right)
        #expect(vm.focusedCol == 1)
    }

    @MainActor
    @Test func moveFocusSkipsBlackCells() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(PuzzleGenerator.sample())
        // Move to row 1, col 0
        vm.focusedRow = 1
        vm.focusedCol = 0
        // Move right — should skip col 1 (black) and land on col 2
        vm.moveFocus(.right)
        #expect(vm.focusedCol == 2)
    }

    @MainActor
    @Test func moveFocusStopsAtBounds() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(PuzzleGenerator.sample())
        vm.focusedRow = 0
        vm.focusedCol = 0
        vm.moveFocus(.left)
        #expect(vm.focusedCol == 0)
        vm.moveFocus(.up)
        #expect(vm.focusedRow == 0)
    }

    @MainActor
    @Test func toggleDirectionWhenBothCluesExist() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(PuzzleGenerator.sample())
        // Cell (0,0) has both across and down clues
        vm.focusedRow = 0
        vm.focusedCol = 0
        vm.currentDirection = .across
        vm.toggleDirection()
        #expect(vm.currentDirection == .down)
        vm.toggleDirection()
        #expect(vm.currentDirection == .across)
    }

    @MainActor
    @Test func enterLetterUpdatesCell() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(PuzzleGenerator.sample())
        vm.focusedRow = 0
        vm.focusedCol = 0
        vm.enterLetter("S")
        #expect(vm.puzzle?.cells[0][0].letter == "S")
    }

    @MainActor
    @Test func enterLetterAdvancesFocus() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(PuzzleGenerator.sample())
        vm.currentDirection = .across
        vm.focusedRow = 0
        vm.focusedCol = 0
        vm.enterLetter("S")
        #expect(vm.focusedCol == 1)
    }

    @MainActor
    @Test func clearCurrentCell() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(PuzzleGenerator.sample())
        vm.enterLetter("X")
        vm.focusedRow = 0
        vm.focusedCol = 0
        vm.clearCurrentCell()
        #expect(vm.puzzle?.cells[0][0].letter == nil)
    }

    @MainActor
    @Test func selectClueUpdatesFocus() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(PuzzleGenerator.sample())
        let clue = vm.puzzle!.acrossClues.first { $0.number == 5 }!
        vm.selectClue(clue)
        #expect(vm.focusedRow == clue.startRow)
        #expect(vm.focusedCol == clue.startCol)
        #expect(vm.currentDirection == .across)
    }

    @MainActor
    @Test func solvingPuzzleSetsFlag() {
        let vm = PuzzleViewModel()
        vm.loadPuzzle(PuzzleGenerator.sample())
        guard let puzzle = vm.puzzle else { return }
        // Fill in all letters correctly
        for row in 0..<puzzle.size {
            for col in 0..<puzzle.size {
                if !puzzle.cells[row][col].isBlack {
                    vm.focusedRow = row
                    vm.focusedCol = col
                    vm.enterLetter(puzzle.cells[row][col].solution)
                }
            }
        }
        #expect(vm.isSolved)
    }
}
