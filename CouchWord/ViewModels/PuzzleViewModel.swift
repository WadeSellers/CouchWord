import SwiftUI

@MainActor
class PuzzleViewModel: ObservableObject {
    @Published var puzzle: Puzzle?
    @Published var focusedRow: Int = 0
    @Published var focusedCol: Int = 0
    @Published var currentDirection: Direction = .across
    @Published var showingLetterPicker = false
    @Published var isSolved = false

    var currentCell: Cell? {
        guard let puzzle, validPosition(row: focusedRow, col: focusedCol) else { return nil }
        return puzzle.cells[focusedRow][focusedCol]
    }

    var activeClue: Clue? {
        guard let puzzle, let cell = currentCell else { return nil }
        let number = currentDirection == .across ? cell.acrossClueNumber : cell.downClueNumber
        guard let number else { return nil }
        return puzzle.clue(for: number, direction: currentDirection)
    }

    var cluesForCurrentDirection: [Clue] {
        guard let puzzle else { return [] }
        return currentDirection == .across ? puzzle.acrossClues : puzzle.downClues
    }

    func loadPuzzle(_ puzzle: Puzzle) {
        self.puzzle = puzzle
        self.isSolved = false
        moveToFirstEditableCell()
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

        // Skip black cells in the movement direction
        while validPosition(row: newRow, col: newCol) && puzzle.cells[newRow][newCol].isBlack {
            switch direction {
            case .up: newRow -= 1
            case .down: newRow += 1
            case .left: newCol -= 1
            case .right: newCol += 1
            }
        }

        if validPosition(row: newRow, col: newCol) {
            focusedRow = newRow
            focusedCol = newCol
        }
    }

    func toggleDirection() {
        guard let cell = currentCell else { return }
        // Only toggle if the cell belongs to clues in both directions
        if cell.acrossClueNumber != nil && cell.downClueNumber != nil {
            currentDirection = currentDirection.opposite
        }
    }

    func selectClue(_ clue: Clue) {
        currentDirection = clue.direction
        focusedRow = clue.startRow
        focusedCol = clue.startCol
    }

    // MARK: - Input

    func enterLetter(_ letter: Character) {
        guard var puzzle, validPosition(row: focusedRow, col: focusedCol) else { return }
        guard !puzzle.cells[focusedRow][focusedCol].isBlack else { return }

        puzzle.cells[focusedRow][focusedCol].letter = letter
        self.puzzle = puzzle
        showingLetterPicker = false

        if puzzle.isSolved {
            isSolved = true
        } else {
            advanceToNextCell()
        }
    }

    func clearCurrentCell() {
        guard var puzzle, validPosition(row: focusedRow, col: focusedCol) else { return }
        puzzle.cells[focusedRow][focusedCol].letter = nil
        self.puzzle = puzzle
    }

    // MARK: - Private

    private func advanceToNextCell() {
        guard let puzzle else { return }
        let dRow = currentDirection == .down ? 1 : 0
        let dCol = currentDirection == .across ? 1 : 0
        var newRow = focusedRow + dRow
        var newCol = focusedCol + dCol

        if validPosition(row: newRow, col: newCol) && !puzzle.cells[newRow][newCol].isBlack {
            focusedRow = newRow
            focusedCol = newCol
        }
    }

    private func moveToFirstEditableCell() {
        guard let puzzle else { return }
        for row in 0..<puzzle.size {
            for col in 0..<puzzle.size {
                if !puzzle.cells[row][col].isBlack {
                    focusedRow = row
                    focusedCol = col
                    return
                }
            }
        }
    }

    private func validPosition(row: Int, col: Int) -> Bool {
        guard let puzzle else { return false }
        return row >= 0 && row < puzzle.size && col >= 0 && col < puzzle.size
    }
}

enum FocusDirection {
    case up, down, left, right
}
