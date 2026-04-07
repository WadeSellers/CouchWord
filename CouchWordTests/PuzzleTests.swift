import Testing
@testable import CouchWord

@Suite("Puzzle Model Tests")
struct PuzzleTests {

    private func makeSamplePuzzle() -> Puzzle {
        Puzzle(
            id: "test_001",
            version: 1,
            size: PuzzleSize(rows: 5, cols: 5),
            difficulty: .easy,
            theme: "Test",
            date: nil,
            grid: [
                ["S", "T", "A", "R", "S"],
                ["#", "#", "#", "#", "#"],
                ["O", "R", "B", "I", "T"],
                ["#", "#", "#", "#", "#"],
                ["C", "O", "M", "E", "T"],
            ],
            clues: ClueSet(
                across: [
                    PuzzleClue(number: 1, clue: "Night lights", answer: "STARS", row: 0, col: 0),
                    PuzzleClue(number: 2, clue: "Path around planet", answer: "ORBIT", row: 2, col: 0),
                    PuzzleClue(number: 3, clue: "Icy traveler", answer: "COMET", row: 4, col: 0),
                ],
                down: []
            ),
            tags: ["test"],
            author: "Test"
        )
    }

    @Test func puzzleHasCorrectDimensions() {
        let puzzle = makeSamplePuzzle()
        #expect(puzzle.rows == 5)
        #expect(puzzle.cols == 5)
    }

    @Test func blackCellsDetected() {
        let puzzle = makeSamplePuzzle()
        #expect(puzzle.isBlack(row: 1, col: 0))
        #expect(puzzle.isBlack(row: 1, col: 3))
        #expect(puzzle.isBlack(row: 3, col: 0))
        #expect(!puzzle.isBlack(row: 0, col: 0))
        #expect(!puzzle.isBlack(row: 2, col: 2))
    }

    @Test func solutionRetrieval() {
        let puzzle = makeSamplePuzzle()
        #expect(puzzle.solutionAt(row: 0, col: 0) == "S")
        #expect(puzzle.solutionAt(row: 0, col: 4) == "S")
        #expect(puzzle.solutionAt(row: 2, col: 0) == "O")
        #expect(puzzle.solutionAt(row: 1, col: 0) == nil) // black cell
    }

    @Test func outOfBoundsReturnsNil() {
        let puzzle = makeSamplePuzzle()
        #expect(puzzle.solutionAt(row: -1, col: 0) == nil)
        #expect(puzzle.solutionAt(row: 5, col: 0) == nil)
        #expect(puzzle.isBlack(row: -1, col: 0) == true)
    }

    @Test func acrossClueRetrieval() {
        let puzzle = makeSamplePuzzle()
        let clue = puzzle.acrossClue(forRow: 0, col: 2)
        #expect(clue != nil)
        #expect(clue?.number == 1)
        #expect(clue?.answer == "STARS")
    }

    @Test func clueNumberAssignment() {
        let puzzle = makeSamplePuzzle()
        #expect(puzzle.clueNumber(row: 0, col: 0) == 1)
        #expect(puzzle.clueNumber(row: 2, col: 0) == 2)
        #expect(puzzle.clueNumber(row: 4, col: 0) == 3)
        #expect(puzzle.clueNumber(row: 0, col: 3) == nil) // mid-word, no number
    }

    @Test func directionToggle() {
        #expect(Direction.across.opposite == .down)
        #expect(Direction.down.opposite == .across)
    }

    @Test func puzzleDecoding() throws {
        let json = """
        {
            "id": "decode_test",
            "version": 1,
            "size": {"rows": 3, "cols": 3},
            "difficulty": "easy",
            "theme": "Decode",
            "date": null,
            "grid": [["C","A","T"],["#","#","#"],["D","O","G"]],
            "clues": {
                "across": [
                    {"number": 1, "clue": "Feline", "answer": "CAT", "row": 0, "col": 0},
                    {"number": 2, "clue": "Canine", "answer": "DOG", "row": 2, "col": 0}
                ],
                "down": []
            },
            "tags": ["animals"],
            "author": "Test"
        }
        """
        let data = json.data(using: .utf8)!
        let puzzle = try JSONDecoder().decode(Puzzle.self, from: data)
        #expect(puzzle.id == "decode_test")
        #expect(puzzle.rows == 3)
        #expect(puzzle.solutionAt(row: 0, col: 0) == "C")
        #expect(puzzle.clues.across.count == 2)
    }
}

@Suite("UserProgress Tests")
struct UserProgressTests {

    @Test func initialProgressIsEmpty() {
        let progress = UserProgress(puzzleID: "test", rows: 5, cols: 5)
        #expect(progress.state == .notStarted)
        #expect(progress.hintsUsed == 0)
        #expect(progress.elapsedSeconds == 0)
        #expect(progress.undoStack.isEmpty)
        #expect(progress.letterAt(row: 0, col: 0) == "")
    }

    @Test func setAndGetLetter() {
        var progress = UserProgress(puzzleID: "test", rows: 5, cols: 5)
        progress.setLetter("A", row: 0, col: 0)
        #expect(progress.letterAt(row: 0, col: 0) == "A")
    }

    @Test func outOfBoundsSetIsNoOp() {
        var progress = UserProgress(puzzleID: "test", rows: 5, cols: 5)
        progress.setLetter("X", row: -1, col: 0)
        progress.setLetter("X", row: 5, col: 0)
        // Should not crash
    }

    @Test func progressEncoding() throws {
        let progress = UserProgress(puzzleID: "test", rows: 3, cols: 3)
        let data = try JSONEncoder().encode(progress)
        let decoded = try JSONDecoder().decode(UserProgress.self, from: data)
        #expect(decoded.puzzleID == "test")
        #expect(decoded.userGrid.count == 3)
    }
}

@Suite("GameStats Tests")
struct GameStatsTests {

    @Test func initialStatsAreZero() {
        let stats = GameStats()
        #expect(stats.totalSolved == 0)
        #expect(stats.currentStreak == 0)
        #expect(stats.longestStreak == 0)
    }

    @Test func recordCompletionUpdatesStats() {
        var stats = GameStats()
        stats.recordCompletion(puzzleID: "p1", time: 120, hints: 1)
        #expect(stats.totalSolved == 1)
        #expect(stats.currentStreak == 1)
        #expect(stats.totalHintsUsed == 1)
        #expect(stats.bestTimes["p1"] == 120)
    }

    @Test func bestTimeUpdates() {
        var stats = GameStats()
        stats.recordCompletion(puzzleID: "p1", time: 120, hints: 0)
        stats.recordCompletion(puzzleID: "p1", time: 90, hints: 0)
        #expect(stats.bestTimes["p1"] == 90)

        stats.recordCompletion(puzzleID: "p1", time: 150, hints: 0)
        #expect(stats.bestTimes["p1"] == 90) // should not increase
    }
}
