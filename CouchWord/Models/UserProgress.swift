import Foundation

// MARK: - User Progress (matches spec schema)

struct UserProgress: Codable {
    let puzzleID: String
    var state: ProgressState
    var userGrid: [[String]]
    var hintsUsed: Int
    var elapsedSeconds: TimeInterval
    var undoStack: [UndoAction]
    var completedAt: Date?
    var accuracy: Double?

    enum ProgressState: String, Codable {
        case notStarted = "not_started"
        case inProgress = "in_progress"
        case completed
    }

    init(puzzleID: String, rows: Int, cols: Int) {
        self.puzzleID = puzzleID
        self.state = .notStarted
        self.userGrid = Array(repeating: Array(repeating: "", count: cols), count: rows)
        self.hintsUsed = 0
        self.elapsedSeconds = 0
        self.undoStack = []
        self.completedAt = nil
        self.accuracy = nil
    }

    mutating func setLetter(_ letter: String, row: Int, col: Int) {
        guard row >= 0, row < userGrid.count, col >= 0, col < userGrid[0].count else { return }
        userGrid[row][col] = letter.uppercased()
    }

    func letterAt(row: Int, col: Int) -> String {
        guard row >= 0, row < userGrid.count, col >= 0, col < userGrid[0].count else { return "" }
        return userGrid[row][col]
    }
}

// MARK: - Undo Stack

struct UndoAction: Codable {
    let type: ActionType
    let cellSnapshots: [CellSnapshot]

    enum ActionType: String, Codable {
        case letter
        case word
        case hint
    }
}

struct CellSnapshot: Codable {
    let row: Int
    let col: Int
    let previousValue: String
}
