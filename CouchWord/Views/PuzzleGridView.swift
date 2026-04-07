import SwiftUI

struct PuzzleGridView: View {
    @ObservedObject var viewModel: PuzzleViewModel
    @FocusState private var focusedCellID: String?

    var body: some View {
        if let puzzle = viewModel.puzzle {
            VStack(spacing: 2) {
                ForEach(0..<puzzle.size, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<puzzle.size, id: \.self) { col in
                            CellView(
                                cell: puzzle.cells[row][col],
                                isFocused: row == viewModel.focusedRow && col == viewModel.focusedCol,
                                isHighlighted: isCellHighlighted(row: row, col: col)
                            )
                            .focusable(!puzzle.cells[row][col].isBlack)
                            .focused($focusedCellID, equals: cellID(row: row, col: col))
                            .onTapGesture {
                                if row == viewModel.focusedRow && col == viewModel.focusedCol {
                                    viewModel.toggleDirection()
                                } else {
                                    viewModel.focusedRow = row
                                    viewModel.focusedCol = col
                                }
                            }
                            .digitalCrownRotation(
                                Binding(get: { 0.0 }, set: { _ in }),
                                from: 0, through: 0
                            )
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingLetterPicker) {
                LetterInputView(viewModel: viewModel)
            }
            .onChange(of: focusedCellID) { _, newValue in
                if let newValue, let (row, col) = parseCellID(newValue) {
                    viewModel.focusedRow = row
                    viewModel.focusedCol = col
                }
            }
            .onChange(of: viewModel.focusedRow) { _, _ in
                focusedCellID = cellID(row: viewModel.focusedRow, col: viewModel.focusedCol)
            }
            .onChange(of: viewModel.focusedCol) { _, _ in
                focusedCellID = cellID(row: viewModel.focusedRow, col: viewModel.focusedCol)
            }
            .onMoveCommand { direction in
                switch direction {
                case .up: viewModel.moveFocus(.up)
                case .down: viewModel.moveFocus(.down)
                case .left: viewModel.moveFocus(.left)
                case .right: viewModel.moveFocus(.right)
                @unknown default: break
                }
            }
            .onPlayPauseCommand {
                viewModel.toggleDirection()
            }
        }
    }

    private func isCellHighlighted(row: Int, col: Int) -> Bool {
        guard let clue = viewModel.activeClue else { return false }
        if clue.direction == .across {
            return row == clue.startRow
                && col >= clue.startCol
                && col < clue.startCol + clue.length
        } else {
            return col == clue.startCol
                && row >= clue.startRow
                && row < clue.startRow + clue.length
        }
    }

    private func cellID(row: Int, col: Int) -> String {
        "\(row)-\(col)"
    }

    private func parseCellID(_ id: String) -> (Int, Int)? {
        let parts = id.split(separator: "-")
        guard parts.count == 2, let r = Int(parts[0]), let c = Int(parts[1]) else { return nil }
        return (r, c)
    }
}
