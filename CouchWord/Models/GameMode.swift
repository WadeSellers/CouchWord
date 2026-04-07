import SwiftUI

/// Available game modes beyond standard play.
enum GameMode: String, CaseIterable, Identifiable {
    case standard = "Standard"
    case speedRound = "Speed Round"
    case mysteryGrid = "Mystery Grid"
    case clueless = "Clueless"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .standard: return "Classic crossword — take your time"
        case .speedRound: return "60 seconds per 5×5 puzzle — how many can you chain?"
        case .mysteryGrid: return "Black squares are hidden — revealed as you solve"
        case .clueless: return "No clues — just the grid pattern and word lengths"
        }
    }

    var icon: String {
        switch self {
        case .standard: return "grid"
        case .speedRound: return "bolt.fill"
        case .mysteryGrid: return "eye.slash.fill"
        case .clueless: return "questionmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .standard: return .blue
        case .speedRound: return .orange
        case .mysteryGrid: return .purple
        case .clueless: return .red
        }
    }

    /// Speed round time limit in seconds
    static let speedRoundTimeLimit: TimeInterval = 60
}
