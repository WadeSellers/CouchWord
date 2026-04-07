import SwiftUI

struct CellView: View {
    let letter: String
    let clueNumber: Int?
    let displayState: CellDisplayState
    let isFocused: Bool
    let isHighlighted: Bool
    var cellSize: CGFloat = 90

    var body: some View {
        if displayState == .black {
            Rectangle()
                .fill(.black)
                .frame(width: cellSize, height: cellSize)
        } else {
            ZStack(alignment: .topLeading) {
                // Background
                Rectangle()
                    .fill(backgroundColor)

                // Border
                Rectangle()
                    .stroke(borderColor, lineWidth: isFocused ? 3 : 1)

                // Clue number
                if let number = clueNumber {
                    Text("\(number)")
                        .font(.system(size: clueNumberFontSize, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(clueNumberPadding)
                }

                // Letter
                if !letter.isEmpty {
                    Text(letter)
                        .font(.system(size: letterFontSize, weight: .medium, design: .default))
                        .foregroundStyle(letterColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(width: cellSize, height: cellSize)
            .scaleEffect(isFocused ? 1.12 : 1.0)
            .shadow(color: isFocused ? .blue.opacity(0.7) : .clear, radius: isFocused ? 12 : 0)
            .animation(.easeInOut(duration: 0.15), value: isFocused)
            .animation(.easeInOut(duration: 0.2), value: displayState)
        }
    }

    // Dynamic font sizes based on cell size
    private var letterFontSize: CGFloat { cellSize * 0.42 }
    private var clueNumberFontSize: CGFloat { max(cellSize * 0.15, 10) }
    private var clueNumberPadding: CGFloat { max(cellSize * 0.04, 2) }

    private var backgroundColor: Color {
        switch displayState {
        case .correct:
            return .green.opacity(0.3)
        case .incorrect:
            return .red.opacity(0.3)
        default:
            if isFocused {
                return .blue.opacity(0.5)
            } else if isHighlighted {
                return .blue.opacity(0.15)
            } else {
                return Color(white: 0.18)
            }
        }
    }

    private var borderColor: Color {
        isFocused ? .blue : Color(white: 0.3)
    }

    private var letterColor: Color {
        switch displayState {
        case .correct: return .green
        case .incorrect: return .red
        default: return .white
        }
    }
}

/// Calculates the optimal cell size for a given grid dimension on tvOS.
/// The grid area is roughly 700pt wide for the puzzle portion of the screen.
enum GridLayout {
    static let gridAreaWidth: CGFloat = 700
    static let gridAreaHeight: CGFloat = 700
    static let cellSpacing: CGFloat = 2

    static func cellSize(forRows rows: Int, cols: Int) -> CGFloat {
        let maxWidth = (gridAreaWidth - CGFloat(cols - 1) * cellSpacing) / CGFloat(cols)
        let maxHeight = (gridAreaHeight - CGFloat(rows - 1) * cellSpacing) / CGFloat(rows)
        return min(maxWidth, maxHeight).rounded(.down)
    }
}
