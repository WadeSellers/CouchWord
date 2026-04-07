import Foundation

/// Persists user progress and game stats via UserDefaults.
@MainActor
class ProgressStore: ObservableObject {
    @Published private(set) var stats: GameStats

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private let keyPrefix: String

    private var statsKey: String { "\(keyPrefix)stats" }
    private var progressKeyPrefix: String { "\(keyPrefix)progress_" }
    private var onboardingKeyValue: String { "\(keyPrefix)onboarding_shown" }
    private var soundEnabledKeyValue: String { "\(keyPrefix)sound_enabled" }

    /// Creates a ProgressStore. If profileID is provided, all keys are namespaced to that profile.
    init(defaults: UserDefaults = .standard, profileID: String? = nil) {
        self.defaults = defaults
        if let profileID {
            self.keyPrefix = "couchword_\(profileID)_"
        } else {
            self.keyPrefix = "couchword_"
        }

        if let data = defaults.data(forKey: "\(keyPrefix)stats"),
           let stats = try? JSONDecoder().decode(GameStats.self, from: data) {
            self.stats = stats
        } else {
            self.stats = GameStats()
        }
    }

    // MARK: - Progress

    func loadProgress(for puzzleID: String) -> UserProgress? {
        let key = progressKeyPrefix + puzzleID
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(UserProgress.self, from: data)
    }

    func saveProgress(_ progress: UserProgress) {
        let key = progressKeyPrefix + progress.puzzleID
        if let data = try? encoder.encode(progress) {
            defaults.set(data, forKey: key)
        }
    }

    func deleteProgress(for puzzleID: String) {
        let key = progressKeyPrefix + puzzleID
        defaults.removeObject(forKey: key)
    }

    func hasInProgressPuzzle() -> String? {
        // Check all stored progress for an in-progress puzzle
        let allKeys = defaults.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix(progressKeyPrefix) {
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
        for key in allKeys where key.hasPrefix(progressKeyPrefix) {
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
            defaults.set(data, forKey: statsKey)
        }
    }

    // MARK: - Settings

    var hasShownOnboarding: Bool {
        get { defaults.bool(forKey: onboardingKeyValue) }
        set { defaults.set(newValue, forKey: onboardingKeyValue) }
    }

    var soundEnabled: Bool {
        get { defaults.object(forKey: soundEnabledKeyValue) as? Bool ?? true }
        set { defaults.set(newValue, forKey: soundEnabledKeyValue) }
    }

    // MARK: - Theme & Display

    private var themeKeyValue: String { "\(keyPrefix)theme" }
    private var timerModeKeyValue: String { "\(keyPrefix)timer_mode" }
    private var gridFontKeyValue: String { "\(keyPrefix)grid_font" }

    var theme: AppTheme {
        get {
            if let raw = defaults.string(forKey: themeKeyValue),
               let theme = AppTheme(rawValue: raw) {
                return theme
            }
            return .midnight
        }
        set { defaults.set(newValue.rawValue, forKey: themeKeyValue) }
    }

    var timerMode: TimerMode {
        get {
            if let raw = defaults.string(forKey: timerModeKeyValue),
               let mode = TimerMode(rawValue: raw) {
                return mode
            }
            return .show
        }
        set { defaults.set(newValue.rawValue, forKey: timerModeKeyValue) }
    }

    var gridFont: GridFont {
        get {
            if let raw = defaults.string(forKey: gridFontKeyValue),
               let font = GridFont(rawValue: raw) {
                return font
            }
            return .system
        }
        set { defaults.set(newValue.rawValue, forKey: gridFontKeyValue) }
    }

    // MARK: - Daily / Streak

    private var streakFreezeKeyValue: String { "\(keyPrefix)last_streak_freeze" }

    var lastStreakFreezeDate: String? {
        get { defaults.string(forKey: streakFreezeKeyValue) }
        set { defaults.set(newValue, forKey: streakFreezeKeyValue) }
    }

    func updateStats(_ newStats: GameStats) {
        stats = newStats
        saveStats()
    }
}
