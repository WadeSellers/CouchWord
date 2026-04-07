import SwiftUI

struct PuzzleGridView: View {
    @ObservedObject var viewModel: PuzzleViewModel
    @EnvironmentObject var progressStore: ProgressStore
    @FocusState private var focusedCellID: String?

    var body: some View {
        if let puzzle = viewModel.puzzle {
            let size = GridLayout.cellSize(forRows: puzzle.rows, cols: puzzle.cols)

            VStack(spacing: GridLayout.cellSpacing) {
                ForEach(0..<puzzle.rows, id: \.self) { row in
                    HStack(spacing: GridLayout.cellSpacing) {
                        ForEach(0..<puzzle.cols, id: \.self) { col in
                            let isBlack = puzzle.isBlack(row: row, col: col)

                            CellView(
                                letter: viewModel.progress?.letterAt(row: row, col: col) ?? "",
                                clueNumber: puzzle.clueNumber(row: row, col: col),
                                displayState: viewModel.cellState(row: row, col: col),
                                isFocused: row == viewModel.focusedRow && col == viewModel.focusedCol,
                                isHighlighted: isCellHighlighted(row: row, col: col),
                                cellSize: size,
                                theme: progressStore.theme,
                                fontDesign: progressStore.gridFont.design
                            )
                            .focusable(!isBlack)
                            .focused($focusedCellID, equals: cellID(row: row, col: col))
                            .disabled(isBlack)
                        }
                    }
                }
            }
            .onChange(of: focusedCellID) { _, newValue in
                if let newValue, let (row, col) = parseCellID(newValue) {
                    viewModel.focusedRow = row
                    viewModel.focusedCol = col
                }
            }
            .onChange(of: viewModel.focusedRow) { _, _ in syncFocus() }
            .onChange(of: viewModel.focusedCol) { _, _ in syncFocus() }
            .onAppear { syncFocus() }
            .onExitCommand {
                viewModel.saveCurrentProgress()
            }
        }
    }

    private func syncFocus() {
        focusedCellID = cellID(row: viewModel.focusedRow, col: viewModel.focusedCol)
    }

    private func isCellHighlighted(row: Int, col: Int) -> Bool {
        guard let clue = viewModel.activeClue else { return false }
        if viewModel.currentDirection == .across {
            return row == clue.row && col >= clue.col && col < clue.col + clue.length
        } else {
            return col == clue.col && row >= clue.row && row < clue.row + clue.length
        }
    }

    private func cellID(row: Int, col: Int) -> String { "\(row)-\(col)" }

    private func parseCellID(_ id: String) -> (Int, Int)? {
        let parts = id.split(separator: "-")
        guard parts.count == 2, let r = Int(parts[0]), let c = Int(parts[1]) else { return nil }
        return (r, c)
    }
}
