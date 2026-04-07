import Foundation

/// Manages the daily puzzle selection and streak logic.
/// Uses a deterministic algorithm: same puzzle for all users on the same date.
/// For v1-v3 (local only), this selects from the bundled library.
/// v4+ will switch to server-delivered daily puzzles.
@MainActor
class DailyPuzzleManager: ObservableObject {
    @Published private(set) var todaysPuzzle: Puzzle?
    @Published private(set) var streakAtRisk: Bool = false

    private let puzzleStore: PuzzleStore
    private let progressStore: ProgressStore

    /// Reference date for daily puzzle cycling (app launch date)
    private static let epoch: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 4
        components.day = 1
        return Calendar.current.date(from: components)!
    }()

    init(puzzleStore: PuzzleStore, progressStore: ProgressStore) {
        self.puzzleStore = puzzleStore
        self.progressStore = progressStore
    }

    /// Selects today's puzzle deterministically from the library.
    func loadTodaysPuzzle() {
        guard !puzzleStore.puzzles.isEmpty else { return }

        let dayNumber = Self.daysSinceEpoch()
        let index = dayNumber % puzzleStore.puzzles.count
        todaysPuzzle = puzzleStore.puzzles[index]

        checkStreakHealth()
    }

    /// The day number since the epoch — same for all users on the same calendar date.
    static func daysSinceEpoch(from date: Date = .now) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: epoch, to: date)
        return max(components.day ?? 0, 0)
    }

    /// Today's date as a consistent string key (e.g., "2026-04-06").
    static func todayKey(from date: Date = .now) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    /// Whether today's daily puzzle has been completed.
    var isTodayCompleted: Bool {
        guard let puzzle = todaysPuzzle else { return false }
        return progressStore.completedPuzzleIDs.contains(puzzle.id)
    }

    // MARK: - Streak

    /// Checks if the user's streak is at risk (haven't solved today, and it's getting late).
    private func checkStreakHealth() {
        let stats = progressStore.stats
        guard stats.currentStreak > 0 else {
            streakAtRisk = false
            return
        }

        let todayKey = Self.todayKey()
        if stats.lastCompletedDate == todayKey {
            // Already solved today
            streakAtRisk = false
        } else {
            // Haven't solved today — streak is at risk
            streakAtRisk = true
        }
    }

    /// Use a streak freeze (once per week). Saves the streak without completing a puzzle.
    func useStreakFreeze() -> Bool {
        var stats = progressStore.stats
        let todayKey = Self.todayKey()

        // Only allow if streak is active and not already completed today
        guard stats.currentStreak > 0, stats.lastCompletedDate != todayKey else {
            return false
        }

        // Check if freeze was used recently (within 7 days)
        if let lastFreeze = progressStore.lastStreakFreezeDate {
            let calendar = Calendar.current
            if let freezeDate = Self.dateFromKey(lastFreeze),
               let daysSinceFreeze = calendar.dateComponents([.day], from: freezeDate, to: .now).day,
               daysSinceFreeze < 7 {
                return false // Can only use once per week
            }
        }

        // Apply the freeze — mark today as "completed" for streak purposes
        stats.lastCompletedDate = todayKey
        progressStore.updateStats(stats)
        progressStore.lastStreakFreezeDate = todayKey
        streakAtRisk = false
        return true
    }

    private static func dateFromKey(_ key: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: key)
    }
}
