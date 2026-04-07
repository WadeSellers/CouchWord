import SwiftUI

struct CellView: View {
    let cell: Cell
    let isFocused: Bool
    let isHighlighted: Bool

    private let cellSize: CGFloat = 80

    var body: some View {
        if cell.isBlack {
            Rectangle()
                .fill(.black)
                .frame(width: cellSize, height: cellSize)
        } else {
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(backgroundColor)
                    .border(Color.gray, width: 1)

                if let number = cell.clueNumber {
                    Text("\(number)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(4)
                }

                if let letter = cell.letter {
                    Text(String(letter))
                        .font(.title)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(width: cellSize, height: cellSize)
            .scaleEffect(isFocused ? 1.1 : 1.0)
            .shadow(color: isFocused ? .white.opacity(0.8) : .clear, radius: isFocused ? 10 : 0)
            .animation(.easeInOut(duration: 0.15), value: isFocused)
        }
    }

    private var backgroundColor: Color {
        if isFocused {
            return .blue.opacity(0.6)
        } else if isHighlighted {
            return .blue.opacity(0.2)
        } else {
            return Color(.darkGray)
        }
    }
}
