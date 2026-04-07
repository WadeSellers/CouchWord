import Foundation

// MARK: - Game Statistics

struct GameStats: Codable {
    var totalSolved: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastCompletedDate: String?
    var totalHintsUsed: Int = 0
    var bestTimes: [String: TimeInterval] = [:] // puzzleID -> best time

    mutating func recordCompletion(puzzleID: String, time: TimeInterval, hints: Int, date: Date = .now) {
        totalSolved += 1
        totalHintsUsed += hints

        let dateString = Self.dateFormatter.string(from: date)

        if let lastDate = lastCompletedDate {
            let yesterday = Self.dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: date)!)
            if lastDate == yesterday {
                currentStreak += 1
            } else if lastDate != dateString {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }

        longestStreak = max(longestStreak, currentStreak)
        lastCompletedDate = dateString

        if let existing = bestTimes[puzzleID] {
            bestTimes[puzzleID] = min(existing, time)
        } else {
            bestTimes[puzzleID] = time
        }
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
