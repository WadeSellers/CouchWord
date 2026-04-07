import SwiftUI

struct CellView: View {
    let letter: String
    let clueNumber: Int?
    let displayState: CellDisplayState
    let isFocused: Bool
    let isHighlighted: Bool

    private let cellSize: CGFloat = 90

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
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(4)
                }

                // Letter
                if !letter.isEmpty {
                    Text(letter)
                        .font(.system(size: 38, weight: .medium, design: .default))
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
        if isFocused {
            return .blue
        }
        return Color(white: 0.3)
    }

    private var letterColor: Color {
        switch displayState {
        case .correct: return .green
        case .incorrect: return .red
        default: return .white
        }
    }
}
