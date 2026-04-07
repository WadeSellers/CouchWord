import Foundation

/// Persists user progress and game stats via UserDefaults.
@MainActor
class ProgressStore: ObservableObject {
    @Published private(set) var stats: GameStats

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private static let statsKey = "couchword_stats"
    private static let progressKeyPrefix = "couchword_progress_"
    private static let onboardingKey = "couchword_onboarding_shown"
    private static let soundEnabledKey = "couchword_sound_enabled"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let data = defaults.data(forKey: Self.statsKey),
           let stats = try? JSONDecoder().decode(GameStats.self, from: data) {
            self.stats = stats
        } else {
            self.stats = GameStats()
        }
    }

    // MARK: - Progress

    func loadProgress(for puzzleID: String) -> UserProgress? {
        let key = Self.progressKeyPrefix + puzzleID
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(UserProgress.self, from: data)
    }

    func saveProgress(_ progress: UserProgress) {
        let key = Self.progressKeyPrefix + progress.puzzleID
        if let data = try? encoder.encode(progress) {
            defaults.set(data, forKey: key)
        }
    }

    func deleteProgress(for puzzleID: String) {
        let key = Self.progressKeyPrefix + puzzleID
        defaults.removeObject(forKey: key)
    }

    func hasInProgressPuzzle() -> String? {
        // Check all stored progress for an in-progress puzzle
        let allKeys = defaults.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix(Self.progressKeyPrefix) {
            if let data = defaults.data(forKey: key),
               let progress = try? decoder.decode(UserProgress.self, from: data),
               progress.state == .inProgress {
                return progress.puzzleID
            }
        }
        return nil
    }

    var completedPuzzleIDs: Set<String> {
        let allKeys = defaults.dictionaryRepresentation().keys
        var ids = Set<String>()
        for key in allKeys where key.hasPrefix(Self.progressKeyPrefix) {
            if let data = defaults.data(forKey: key),
               let progress = try? decoder.decode(UserProgress.self, from: data),
               progress.state == .completed {
                ids.insert(progress.puzzleID)
            }
        }
        return ids
    }

    // MARK: - Stats

    func recordCompletion(puzzleID: String, time: TimeInterval, hints: Int) {
        stats.recordCompletion(puzzleID: puzzleID, time: time, hints: hints)
        saveStats()
    }

    private func saveStats() {
        if let data = try? encoder.encode(stats) {
            defaults.set(data, forKey: Self.statsKey)
        }
    }

    // MARK: - Settings

    var hasShownOnboarding: Bool {
        get { defaults.bool(forKey: Self.onboardingKey) }
        set { defaults.set(newValue, forKey: Self.onboardingKey) }
    }

    var soundEnabled: Bool {
        get { defaults.object(forKey: Self.soundEnabledKey) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Self.soundEnabledKey) }
    }

    // MARK: - Theme & Display

    private static let themeKey = "couchword_theme"
    private static let timerModeKey = "couchword_timer_mode"
    private static let gridFontKey = "couchword_grid_font"

    var theme: AppTheme {
        get {
            if let raw = defaults.string(forKey: Self.themeKey),
               let theme = AppTheme(rawValue: raw) {
                return theme
            }
            return .midnight
        }
        set { defaults.set(newValue.rawValue, forKey: Self.themeKey) }
    }

    var timerMode: TimerMode {
        get {
            if let raw = defaults.string(forKey: Self.timerModeKey),
               let mode = TimerMode(rawValue: raw) {
                return mode
            }
            return .show
        }
        set { defaults.set(newValue.rawValue, forKey: Self.timerModeKey) }
    }

    var gridFont: GridFont {
        get {
            if let raw = defaults.string(forKey: Self.gridFontKey),
               let font = GridFont(rawValue: raw) {
                return font
            }
            return .system
        }
        set { defaults.set(newValue.rawValue, forKey: Self.gridFontKey) }
    }

    // MARK: - Daily / Streak

    private static let streakFreezeKey = "couchword_last_streak_freeze"

    var lastStreakFreezeDate: String? {
        get { defaults.string(forKey: Self.streakFreezeKey) }
        set { defaults.set(newValue, forKey: Self.streakFreezeKey) }
    }

    func updateStats(_ newStats: GameStats) {
        stats = newStats
        saveStats()
    }
}
