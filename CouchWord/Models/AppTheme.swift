import SwiftUI

/// Visual theme for the crossword grid and UI chrome.
enum AppTheme: String, CaseIterable, Codable, Identifiable {
    case midnight = "Midnight"
    case newspaper = "Newspaper"
    case ocean = "Ocean"
    case forest = "Forest"
    case neon = "Neon"

    var id: String { rawValue }

    var gridBackground: Color {
        switch self {
        case .midnight: return Color(white: 0.08)
        case .newspaper: return Color(red: 0.96, green: 0.94, blue: 0.90)
        case .ocean: return Color(red: 0.05, green: 0.12, blue: 0.20)
        case .forest: return Color(red: 0.06, green: 0.14, blue: 0.08)
        case .neon: return Color(white: 0.04)
        }
    }

    var cellBackground: Color {
        switch self {
        case .midnight: return Color(white: 0.18)
        case .newspaper: return .white
        case .ocean: return Color(red: 0.10, green: 0.22, blue: 0.35)
        case .forest: return Color(red: 0.12, green: 0.25, blue: 0.14)
        case .neon: return Color(white: 0.10)
        }
    }

    var cellBorder: Color {
        switch self {
        case .midnight: return Color(white: 0.3)
        case .newspaper: return .black
        case .ocean: return Color(red: 0.2, green: 0.4, blue: 0.6)
        case .forest: return Color(red: 0.2, green: 0.4, blue: 0.2)
        case .neon: return Color(red: 0.0, green: 1.0, blue: 0.8).opacity(0.4)
        }
    }

    var blackCellColor: Color {
        switch self {
        case .midnight: return .black
        case .newspaper: return .black
        case .ocean: return Color(red: 0.02, green: 0.06, blue: 0.12)
        case .forest: return Color(red: 0.02, green: 0.06, blue: 0.03)
        case .neon: return .black
        }
    }

    var letterColor: Color {
        switch self {
        case .midnight: return .white
        case .newspaper: return .black
        case .ocean: return .white
        case .forest: return .white
        case .neon: return Color(red: 0.0, green: 1.0, blue: 0.8)
        }
    }

    var accentColor: Color {
        switch self {
        case .midnight: return .blue
        case .newspaper: return Color(red: 0.15, green: 0.15, blue: 0.6)
        case .ocean: return Color(red: 0.3, green: 0.7, blue: 0.9)
        case .forest: return Color(red: 0.3, green: 0.8, blue: 0.4)
        case .neon: return Color(red: 1.0, green: 0.0, blue: 0.8)
        }
    }

    var highlightColor: Color {
        accentColor.opacity(0.2)
    }

    var focusColor: Color {
        accentColor.opacity(0.5)
    }

    var clueNumberColor: Color {
        switch self {
        case .newspaper: return .gray
        default: return .secondary
        }
    }

    var correctColor: Color { .green }
    var incorrectColor: Color { .red }

    var preview: String {
        switch self {
        case .midnight: return "Dark with blue accents"
        case .newspaper: return "Classic print style"
        case .ocean: return "Deep blue tones"
        case .forest: return "Natural green palette"
        case .neon: return "Cyberpunk glow"
        }
    }
}

/// Timer display mode
enum TimerMode: String, CaseIterable, Codable {
    case show = "Show Timer"
    case hide = "Hide Timer"
    case countdown = "Countdown"
}

/// Font style for the grid
enum GridFont: String, CaseIterable, Codable {
    case system = "System"
    case serif = "Serif"
    case mono = "Monospaced"
    case rounded = "Rounded"

    var design: Font.Design {
        switch self {
        case .system: return .default
        case .serif: return .serif
        case .mono: return .monospaced
        case .rounded: return .rounded
        }
    }
}
