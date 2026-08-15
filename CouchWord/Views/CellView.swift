import SwiftUI

struct CellView: View {
    let letter: String
    let clueNumber: Int?
    let displayState: CellDisplayState
    let isFocused: Bool
    let isHighlighted: Bool
    var cellSize: CGFloat = 90
    var theme: AppTheme = .newspaper
    var fontDesign: Font.Design = .default
    var row: Int = 0
    var col: Int = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if displayState == .black {
            Rectangle()
                .fill(Color.black)
                .frame(width: cellSize, height: cellSize)
        } else {
            ZStack(alignment: .topLeading) {
                // Background
                Rectangle()
                    .fill(backgroundColor)

                // Grid lines — light gray internal, heavier when focused
                Rectangle()
                    .stroke(Color(white: 0.75), lineWidth: 0.5)

                // Clue number — small, top-left, sans-serif
                if let number = clueNumber {
                    Text("\(number)")
                        .font(.system(size: clueNumberFontSize, weight: .regular))
                        .foregroundStyle(Color(white: 0.33))
                        .padding(clueNumberPadding)
                }

                // Letter — centered, bold, sans-serif (SF Pro)
                if !letter.isEmpty {
                    Text(letter)
                        .font(.system(size: letterFontSize, weight: .bold, design: fontDesign))
                        .foregroundStyle(letterColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .offset(y: clueNumber != nil ? 2 : 0) // Shift slightly down when number present
                }
            }
            .frame(width: cellSize, height: cellSize)
            .accessibilityLabel(accessibilityDescription)
            .accessibilityHint(isFocused ? "Selected. Click to enter a letter." : "")
        }
    }

    private var accessibilityDescription: String {
        var parts: [String] = []
        parts.append("Row \(row + 1), Column \(col + 1)")
        if let number = clueNumber {
            parts.append("Clue \(number)")
        }
        if !letter.isEmpty {
            parts.append("Letter \(letter)")
        } else {
            parts.append("Empty")
        }
        switch displayState {
        case .correct: parts.append("Correct")
        case .incorrect: parts.append("Incorrect")
        default: break
        }
        return parts.joined(separator: ". ")
    }

    // Dynamic font sizes based on cell size
    private var letterFontSize: CGFloat { cellSize * 0.42 }
    private var clueNumberFontSize: CGFloat { max(cellSize * 0.18, 10) }
    private var clueNumberPadding: CGFloat { max(cellSize * 0.04, 2) }

    private var backgroundColor: Color {
        switch displayState {
        case .correct:
            return Color.green.opacity(0.25)
        case .incorrect:
            return Color.red.opacity(0.25)
        default:
            if isFocused {
                // Active cell — NYT signature blue (#5C9ACF)
                return Color(red: 0.36, green: 0.60, blue: 0.81)
            } else if isHighlighted {
                // Active word — lighter blue (#D4E7F7)
                return Color(red: 0.83, green: 0.91, blue: 0.97)
            } else {
                return .white
            }
        }
    }

    private var letterColor: Color {
        switch displayState {
        case .correct: return .green.opacity(0.8)
        case .incorrect: return .red
        default: return .black
        }
    }
}

/// Calculates the optimal cell size for a given grid dimension on tvOS.
enum GridLayout {
    static let gridAreaWidth: CGFloat = 660
    static let gridAreaHeight: CGFloat = 660
    static let cellSpacing: CGFloat = 0  // Newspaper grids have no spacing — borders touch

    static func cellSize(forRows rows: Int, cols: Int) -> CGFloat {
        let maxWidth = gridAreaWidth / CGFloat(cols)
        let maxHeight = gridAreaHeight / CGFloat(rows)
        return min(min(maxWidth, maxHeight), 70).rounded(.down)
    }
}
