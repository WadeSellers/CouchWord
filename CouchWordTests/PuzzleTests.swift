import Testing
@testable import CouchWord

@Suite("Puzzle Model Tests")
struct PuzzleTests {

    @Test func samplePuzzleHasCorrectSize() {
        let puzzle = PuzzleGenerator.sample()
        #expect(puzzle.size == 5)
        #expect(puzzle.cells.count == 5)
        #expect(puzzle.cells[0].count == 5)
    }

    @Test func blackCellsAreCorrectlyPlaced() {
        let puzzle = PuzzleGenerator.sample()
        #expect(puzzle.cells[1][1].isBlack)
        #expect(puzzle.cells[1][3].isBlack)
        #expect(puzzle.cells[3][1].isBlack)
        #expect(puzzle.cells[3][3].isBlack)
        #expect(!puzzle.cells[0][0].isBlack)
    }

    @Test func clueNumbersAssigned() {
        let puzzle = PuzzleGenerator.sample()
        #expect(puzzle.cells[0][0].clueNumber == 1)
        #expect(puzzle.cells[0][2].clueNumber == 2)
        #expect(puzzle.cells[2][0].clueNumber == 5)
    }

    @Test func acrossClueNumbersWired() {
        let puzzle = PuzzleGenerator.sample()
        // Row 0 should all reference across clue 1
        for col in 0..<5 {
            #expect(puzzle.cells[0][col].acrossClueNumber == 1)
        }
        // Row 2 should all reference across clue 5
        for col in 0..<5 {
            #expect(puzzle.cells[2][col].acrossClueNumber == 5)
        }
    }

    @Test func downClueNumbersWired() {
        let puzzle = PuzzleGenerator.sample()
        // Column 0 should reference down clue 1
        for row in 0..<5 {
            #expect(puzzle.cells[row][0].downClueNumber == 1)
        }
    }

    @Test func unsovledPuzzleIsNotSolved() {
        let puzzle = PuzzleGenerator.sample()
        #expect(!puzzle.isSolved)
    }

    @Test func solvedPuzzleIsSolved() {
        var puzzle = PuzzleGenerator.sample()
        // Fill in all solutions
        for row in 0..<puzzle.size {
            for col in 0..<puzzle.size {
                if !puzzle.cells[row][col].isBlack {
                    puzzle.cells[row][col].letter = puzzle.cells[row][col].solution
                }
            }
        }
        #expect(puzzle.isSolved)
    }

    @Test func clueRetrieval() {
        let puzzle = PuzzleGenerator.sample()
        let clue1across = puzzle.clue(for: 1, direction: .across)
        #expect(clue1across != nil)
        #expect(clue1across?.text == "Apple's programming language")

        let clue3down = puzzle.clue(for: 3, direction: .down)
        #expect(clue3down != nil)
        #expect(clue3down?.startCol == 4)
    }

    @Test func directionToggle() {
        #expect(Direction.across.opposite == .down)
        #expect(Direction.down.opposite == .across)
    }
}
