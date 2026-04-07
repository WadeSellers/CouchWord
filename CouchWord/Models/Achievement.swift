import SwiftUI

/// Definition of an unlockable achievement.
struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let requirement: AchievementRequirement

    enum AchievementCategory: String, CaseIterable {
        case milestones = "Milestones"
        case speed = "Speed"
        case skill = "Skill"
        case dedication = "Dedication"
        case special = "Special"
    }

    enum AchievementRequirement {
        case puzzlesSolved(Int)
        case currentStreak(Int)
        case solveUnder(seconds: Int) // solve a puzzle under N seconds
        case noHints(count: Int) // solve N puzzles without hints
        case perfectAccuracy(count: Int) // N puzzles with 100% accuracy
        case categoriesMastered(count: Int) // N categories with score > 0.8
        case totalWordsLearned(Int)
        case allDifficulties // solve at least one of each difficulty
        case speedRoundChain(Int) // chain N speed round puzzles
    }
}

/// Tracks which achievements have been unlocked.
struct AchievementProgress: Codable {
    var unlockedIDs: Set<String> = []
    var noHintsSolveCount: Int = 0
    var perfectAccuracyCount: Int = 0
    var fastestSolveTime: TimeInterval?
    var speedRoundBestChain: Int = 0
    var difficultiesSolved: Set<String> = []

    mutating func recordSolve(time: TimeInterval, hints: Int, accuracy: Double, difficulty: Difficulty) {
        if hints == 0 {
            noHintsSolveCount += 1
        }
        if accuracy >= 1.0 {
            perfectAccuracyCount += 1
        }
        if let fastest = fastestSolveTime {
            fastestSolveTime = min(fastest, time)
        } else {
            fastestSolveTime = time
        }
        difficultiesSolved.insert(difficulty.rawValue)
    }
}

/// All available achievements in the game.
enum AchievementRegistry {
    static let all: [Achievement] = [
        // Milestones
        Achievement(id: "first_puzzle", title: "First Steps", description: "Complete your first puzzle", icon: "star.fill", category: .milestones, requirement: .puzzlesSolved(1)),
        Achievement(id: "ten_puzzles", title: "Getting Started", description: "Complete 10 puzzles", icon: "10.circle.fill", category: .milestones, requirement: .puzzlesSolved(10)),
        Achievement(id: "fifty_puzzles", title: "Dedicated Solver", description: "Complete 50 puzzles", icon: "50.circle.fill", category: .milestones, requirement: .puzzlesSolved(50)),
        Achievement(id: "century_club", title: "Century Club", description: "Complete 100 puzzles", icon: "100.circle.fill", category: .milestones, requirement: .puzzlesSolved(100)),

        // Speed
        Achievement(id: "speed_demon", title: "Speed Demon", description: "Solve a puzzle in under 60 seconds", icon: "bolt.fill", category: .speed, requirement: .solveUnder(seconds: 60)),
        Achievement(id: "lightning", title: "Lightning", description: "Solve a puzzle in under 30 seconds", icon: "bolt.circle.fill", category: .speed, requirement: .solveUnder(seconds: 30)),
        Achievement(id: "speed_chain_5", title: "Chain Reaction", description: "Chain 5 speed round puzzles", icon: "link", category: .speed, requirement: .speedRoundChain(5)),
        Achievement(id: "speed_chain_10", title: "Unstoppable", description: "Chain 10 speed round puzzles", icon: "flame.fill", category: .speed, requirement: .speedRoundChain(10)),

        // Skill
        Achievement(id: "no_hints_5", title: "Self-Reliant", description: "Solve 5 puzzles without hints", icon: "brain.head.profile", category: .skill, requirement: .noHints(count: 5)),
        Achievement(id: "no_hints_25", title: "Independent Mind", description: "Solve 25 puzzles without hints", icon: "brain.fill", category: .skill, requirement: .noHints(count: 25)),
        Achievement(id: "perfect_10", title: "Perfectionist", description: "Solve 10 puzzles with 100% accuracy", icon: "target", category: .skill, requirement: .perfectAccuracy(count: 10)),
        Achievement(id: "all_difficulties", title: "Well Rounded", description: "Solve at least one puzzle of each difficulty", icon: "circle.grid.3x3.fill", category: .skill, requirement: .allDifficulties),
        Achievement(id: "master_3", title: "Triple Threat", description: "Master 3 categories (80%+ score)", icon: "crown.fill", category: .skill, requirement: .categoriesMastered(count: 3)),

        // Dedication
        Achievement(id: "streak_7", title: "Weekly Warrior", description: "Maintain a 7-day streak", icon: "flame", category: .dedication, requirement: .currentStreak(7)),
        Achievement(id: "streak_30", title: "Monthly Master", description: "Maintain a 30-day streak", icon: "flame.fill", category: .dedication, requirement: .currentStreak(30)),
        Achievement(id: "streak_100", title: "Legendary", description: "Maintain a 100-day streak", icon: "crown.fill", category: .dedication, requirement: .currentStreak(100)),
        Achievement(id: "words_100", title: "Wordsmith", description: "Encounter 100 unique words", icon: "textformat.abc", category: .dedication, requirement: .totalWordsLearned(100)),
        Achievement(id: "words_500", title: "Lexicon", description: "Encounter 500 unique words", icon: "book.fill", category: .dedication, requirement: .totalWordsLearned(500)),
    ]

    /// Check which achievements should be newly unlocked given current state.
    static func checkUnlocks(
        stats: GameStats,
        achievementProgress: AchievementProgress,
        skillProfile: SkillProfile,
        wordCount: Int
    ) -> [Achievement] {
        var newlyUnlocked: [Achievement] = []

        for achievement in all {
            guard !achievementProgress.unlockedIDs.contains(achievement.id) else { continue }

            let met: Bool
            switch achievement.requirement {
            case .puzzlesSolved(let n):
                met = stats.totalSolved >= n
            case .currentStreak(let n):
                met = stats.currentStreak >= n
            case .solveUnder(let seconds):
                met = (achievementProgress.fastestSolveTime ?? .infinity) < TimeInterval(seconds)
            case .noHints(let count):
                met = achievementProgress.noHintsSolveCount >= count
            case .perfectAccuracy(let count):
                met = achievementProgress.perfectAccuracyCount >= count
            case .categoriesMastered(let count):
                let mastered = skillProfile.categoryScores.values.filter { $0.score > 0.8 }.count
                met = mastered >= count
            case .totalWordsLearned(let n):
                met = wordCount >= n
            case .allDifficulties:
                met = achievementProgress.difficultiesSolved.count >= Difficulty.allCases.count
            case .speedRoundChain(let n):
                met = achievementProgress.speedRoundBestChain >= n
            }

            if met {
                newlyUnlocked.append(achievement)
            }
        }

        return newlyUnlocked
    }
}
