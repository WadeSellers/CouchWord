import Foundation

struct Puzzle {
    let size: Int
    var cells: [[Cell]]
    var acrossClues: [Clue]
    var downClues: [Clue]

    var isSolved: Bool {
        cells.allSatisfy { row in
            row.allSatisfy { cell in
                cell.isBlack || cell.letter == cell.solution
            }
        }
    }

    func clue(for number: Int, direction: Direction) -> Clue? {
        let clues = direction == .across ? acrossClues : downClues
        return clues.first { $0.number == number }
    }
}

struct Cell {
    var letter: Character?
    let solution: Character
    let isBlack: Bool
    var clueNumber: Int?
    var acrossClueNumber: Int?
    var downClueNumber: Int?

    static func black() -> Cell {
        Cell(letter: nil, solution: " ", isBlack: true)
    }

    static func letter(_ solution: Character, clueNumber: Int? = nil) -> Cell {
        Cell(letter: nil, solution: solution, isBlack: false, clueNumber: clueNumber)
    }
}

struct Clue: Identifiable, Hashable {
    let number: Int
    let direction: Direction
    let text: String
    let startRow: Int
    let startCol: Int
    let length: Int

    var id: String { "\(direction)-\(number)" }

    var label: String { "\(number). \(text)" }
}

enum Direction: String, CaseIterable {
    case across = "Across"
    case down = "Down"

    var opposite: Direction {
        self == .across ? .down : .across
    }
}
