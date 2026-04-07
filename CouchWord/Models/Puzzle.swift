import Foundation

// MARK: - Puzzle (matches spec JSON schema)

struct Puzzle: Codable, Identifiable {
    let id: String
    let version: Int
    let size: PuzzleSize
    let difficulty: Difficulty
    let theme: String?
    let date: String?
    let grid: [[String]]
    let clues: ClueSet
    let tags: [String]
    let author: String

    var rows: Int { size.rows }
    var cols: Int { size.cols }

    func solutionAt(row: Int, col: Int) -> Character? {
        guard row >= 0, row < rows, col >= 0, col < cols else { return nil }
        let value = grid[row][col]
        if value == "#" { return nil }
        return value.first
    }

    func isBlack(row: Int, col: Int) -> Bool {
        guard row >= 0, row < rows, col >= 0, col < cols else { return true }
        return grid[row][col] == "#"
    }

    func clueNumber(row: Int, col: Int) -> Int? {
        // A cell gets a number if it starts an across or down word
        let allClues = clues.across + clues.down
        return allClues.first(where: { $0.row == row && $0.col == col })?.number
    }

    func acrossClue(forRow row: Int, col: Int) -> PuzzleClue? {
        clues.across.first { clue in
            row == clue.row && col >= clue.col && col < clue.col + clue.answer.count
        }
    }

    func downClue(forRow row: Int, col: Int) -> PuzzleClue? {
        clues.down.first { clue in
            col == clue.col && row >= clue.row && row < clue.row + clue.answer.count
        }
    }

    func clue(for number: Int, direction: Direction) -> PuzzleClue? {
        let list = direction == .across ? clues.across : clues.down
        return list.first { $0.number == number }
    }
}

struct PuzzleSize: Codable, Equatable {
    let rows: Int
    let cols: Int
}

struct ClueSet: Codable {
    let across: [PuzzleClue]
    let down: [PuzzleClue]
}

struct PuzzleClue: Codable, Identifiable, Hashable {
    let number: Int
    let clue: String
    let answer: String
    let row: Int
    let col: Int

    var id: String { "\(number)" }
    var label: String { "\(number). \(clue)" }
    var length: Int { answer.count }
}

enum Direction: String, Codable, CaseIterable {
    case across = "Across"
    case down = "Down"

    var opposite: Direction {
        self == .across ? .down : .across
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case easy
    case medium
    case hard
    case expert
}
