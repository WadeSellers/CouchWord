import Foundation

/// Tracks a player's performance across puzzle categories for adaptive difficulty.
struct SkillProfile: Codable {
    /// Performance by category tag (e.g., "science", "food", "history")
    var categoryScores: [String: CategoryScore] = [:]

    /// Overall metrics
    var totalPuzzlesSolved: Int = 0
    var averageSolveTimeSeconds: TimeInterval = 0
    var averageAccuracy: Double = 0

    /// Current recommended difficulty
    var recommendedDifficulty: Difficulty {
        if totalPuzzlesSolved < 5 { return .easy }
        let avgScore = overallScore
        if avgScore > 0.85 { return .hard }
        if avgScore > 0.65 { return .medium }
        return .easy
    }

    /// Overall score (0.0 to 1.0) combining accuracy and speed
    var overallScore: Double {
        guard totalPuzzlesSolved > 0 else { return 0 }
        // Weight: 70% accuracy, 30% speed (capped at 10 min)
        let speedScore = max(0, 1.0 - (averageSolveTimeSeconds / 600.0))
        return averageAccuracy * 0.7 + speedScore * 0.3
    }

    /// Top 3 strongest categories
    var strengths: [String] {
        categoryScores
            .sorted { $0.value.score > $1.value.score }
            .prefix(3)
            .map(\.key)
    }

    /// Bottom 3 weakest categories (with at least 2 puzzles solved)
    var weaknesses: [String] {
        categoryScores
            .filter { $0.value.puzzlesSolved >= 2 }
            .sorted { $0.value.score < $1.value.score }
            .prefix(3)
            .map(\.key)
    }

    /// Radar chart data: returns (category, score) pairs for visualization
    var radarData: [(category: String, score: Double)] {
        categoryScores
            .sorted { $0.key < $1.key }
            .map { ($0.key.capitalized, $0.value.score) }
    }

    mutating func recordSolve(tags: [String], time: TimeInterval, accuracy: Double, hints: Int) {
        totalPuzzlesSolved += 1

        // Update running averages
        let n = Double(totalPuzzlesSolved)
        averageSolveTimeSeconds = averageSolveTimeSeconds * (n - 1) / n + time / n
        averageAccuracy = averageAccuracy * (n - 1) / n + accuracy / n

        // Update category scores
        let hintPenalty = Double(hints) * 0.1
        let adjustedAccuracy = max(0, accuracy - hintPenalty)

        for tag in tags {
            var score = categoryScores[tag.lowercased()] ?? CategoryScore()
            score.recordSolve(time: time, accuracy: adjustedAccuracy)
            categoryScores[tag.lowercased()] = score
        }
    }
}

struct CategoryScore: Codable {
    var puzzlesSolved: Int = 0
    var averageTime: TimeInterval = 0
    var averageAccuracy: Double = 0

    /// Combined score (0.0 to 1.0)
    var score: Double {
        guard puzzlesSolved > 0 else { return 0 }
        let speedScore = max(0, 1.0 - (averageTime / 600.0))
        return averageAccuracy * 0.7 + speedScore * 0.3
    }

    mutating func recordSolve(time: TimeInterval, accuracy: Double) {
        puzzlesSolved += 1
        let n = Double(puzzlesSolved)
        averageTime = averageTime * (n - 1) / n + time / n
        averageAccuracy = averageAccuracy * (n - 1) / n + accuracy / n
    }
}
