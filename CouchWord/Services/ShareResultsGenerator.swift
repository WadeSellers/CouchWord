import Foundation

/// Generates a Wordle-style text grid for sharing puzzle results.
enum ShareResultsGenerator {

    /// Generates a shareable text representation of a completed puzzle.
    /// Uses emoji squares: green = correct on first try (no hint),
    /// yellow = correct with hint, black = was black cell.
    static func generate(puzzle: Puzzle, progress: UserProgress, stats: GameStats) -> String {
        var lines: [String] = []

        // Header
        lines.append("CouchWord \(puzzle.theme ?? "Puzzle") (\(puzzle.rows)x\(puzzle.cols))")

        // Time and hints
        let time = formatTime(progress.elapsedSeconds)
        let hints = progress.hintsUsed
        let streak = stats.currentStreak
        lines.append("\(time) | \(hints == 0 ? "No hints" : "\(hints) hint\(hints == 1 ? "" : "s")") | \(streak > 0 ? "\(streak)-day streak" : "No streak")")
        lines.append("")

        // Grid visualization
        for row in 0..<puzzle.rows {
            var rowStr = ""
            for col in 0..<puzzle.cols {
                if puzzle.isBlack(row: row, col: col) {
                    rowStr += "⬛"
                } else {
                    let userLetter = progress.letterAt(row: row, col: col)
                    if let solution = puzzle.solutionAt(row: row, col: col),
                       userLetter.first == solution {
                        rowStr += "🟩"
                    } else if !userLetter.isEmpty {
                        rowStr += "🟨"
                    } else {
                        rowStr += "⬜"
                    }
                }
            }
            lines.append(rowStr)
        }

        lines.append("")
        lines.append("couchword.app")

        return lines.joined(separator: "\n")
    }

    private static func formatTime(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        let minutes = total / 60
        let secs = total % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}
