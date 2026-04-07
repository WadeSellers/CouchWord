import SwiftUI

struct ClueListView: View {
    @ObservedObject var viewModel: PuzzleViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Direction toggle
            Picker("Direction", selection: $viewModel.currentDirection) {
                ForEach(Direction.allCases, id: \.self) { direction in
                    Text(direction.rawValue).tag(direction)
                }
            }
            .pickerStyle(.segmented)

            // Active clue highlight
            if let activeClue = viewModel.activeClue {
                Text(activeClue.label)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.blue.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Clue list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.cluesForCurrentDirection) { clue in
                        Button {
                            viewModel.selectClue(clue)
                        } label: {
                            Text(clue.label)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(width: 400)
    }
}
