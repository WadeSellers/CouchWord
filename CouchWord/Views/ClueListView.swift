import SwiftUI

/// Newspaper-style flowing clue columns — no scrolling.
/// ACROSS clues flow down column 1, continue into column 2, then DOWN header
/// and down clues continue flowing through remaining columns.
/// Dynamically splits into enough columns so everything fits on screen.
struct ClueListView: View {
    @ObservedObject var viewModel: PuzzleViewModel

    /// Items that flow through the columns — headers and clues in reading order.
    enum ClueItem: Identifiable {
        case header(String)
        case clue(PuzzleClue, Direction)

        var id: String {
            switch self {
            case .header(let title): return "header-\(title)"
            case .clue(let clue, let dir): return "\(dir.rawValue)-\(clue.id)"
            }
        }
    }

    private var allItems: [ClueItem] {
        var items: [ClueItem] = [.header("ACROSS")]
        items += viewModel.acrossClues.map { .clue($0, .across) }
        items.append(.header("DOWN"))
        items += viewModel.downClues.map { .clue($0, .down) }
        return items
    }

    /// Split items into N roughly equal columns.
    private func splitIntoColumns(_ items: [ClueItem], count: Int) -> [[ClueItem]] {
        guard count > 0 else { return [items] }
        let perColumn = Int(ceil(Double(items.count) / Double(count)))
        var columns: [[ClueItem]] = []
        var start = 0
        for _ in 0..<count {
            let end = min(start + perColumn, items.count)
            if start < end {
                columns.append(Array(items[start..<end]))
            }
            start = end
        }
        return columns
    }

    var body: some View {
        let items = allItems
        // 3 columns keeps clue text readable while fitting ~60 clues without scroll
        let columns = splitIntoColumns(items, count: 3)

        HStack(alignment: .top, spacing: 20) {
            ForEach(0..<columns.count, id: \.self) { i in
                clueColumn(items: columns[i])
            }
        }
    }

    @ViewBuilder
    private func clueColumn(items: [ClueItem]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(items) { item in
                switch item {
                case .header(let title):
                    Text(title)
                        .font(.system(size: 19, weight: .heavy))
                        .foregroundStyle(Color(white: 0.15))
                        .tracking(2.5)
                        .padding(.top, title == "DOWN" ? 12 : 0)
                        .padding(.bottom, 4)
                        .padding(.leading, 4)
                case .clue(let clue, let direction):
                    let isActive = (direction == viewModel.currentDirection
                        && viewModel.activeClue?.number == clue.number
                        && viewModel.activeClue?.row == clue.row
                        && viewModel.activeClue?.col == clue.col)

                    ClueRow(clue: clue, isActive: isActive) {
                        viewModel.selectClue(clue, direction: direction)
                    }
                }
            }
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Clue Row

struct ClueRow: View {
    let clue: PuzzleClue
    let isActive: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .top, spacing: 2) {
                Text("\(clue.number).")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(isActive ? Color(white: 0.1) : Color(white: 0.45))
                    .frame(width: 34, alignment: .trailing)

                Text(clue.clue)
                    .font(.system(size: 19, weight: .regular))
                    .foregroundStyle(isActive ? Color(white: 0.1) : Color(white: 0.3))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 5)
            .background(isActive ? Color(red: 0.83, green: 0.91, blue: 0.97) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 3))
        }
        .buttonStyle(.plain)
    }
}
