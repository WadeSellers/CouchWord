import SwiftUI

struct CellView: View {
    let letter: String
    let clueNumber: Int?
    let displayState: CellDisplayState
    let isFocused: Bool
    let isHighlighted: Bool
    var cellSize: CGFloat = 90
    var theme: AppTheme = .midnight
    var fontDesign: Font.Design = .default

    var body: some View {
        if displayState == .black {
            Rectangle()
                .fill(theme.blackCellColor)
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
                        .foregroundStyle(theme.clueNumberColor)
                        .padding(clueNumberPadding)
                }

                // Letter
                if !letter.isEmpty {
                    Text(letter)
                        .font(.system(size: letterFontSize, weight: .medium, design: fontDesign))
                        .foregroundStyle(letterColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(width: cellSize, height: cellSize)
            .scaleEffect(isFocused ? 1.12 : 1.0)
            .shadow(color: isFocused ? theme.accentColor.opacity(0.7) : .clear, radius: isFocused ? 12 : 0)
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
            return theme.correctColor.opacity(0.3)
        case .incorrect:
            return theme.incorrectColor.opacity(0.3)
        default:
            if isFocused {
                return theme.focusColor
            } else if isHighlighted {
                return theme.highlightColor
            } else {
                return theme.cellBackground
            }
        }
    }

    private var borderColor: Color {
        isFocused ? theme.accentColor : theme.cellBorder
    }

    private var letterColor: Color {
        switch displayState {
        case .correct: return theme.correctColor
        case .incorrect: return theme.incorrectColor
        default: return theme.letterColor
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
