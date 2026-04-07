import SwiftUI

struct ClueListView: View {
    @ObservedObject var viewModel: PuzzleViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Direction picker
            Picker("Direction", selection: $viewModel.currentDirection) {
                ForEach(Direction.allCases, id: \.self) { direction in
                    Text(direction.rawValue).tag(direction)
                }
            }
            .pickerStyle(.segmented)

            // Active clue callout
            if let active = viewModel.activeClue {
                Text(active.label)
                    .font(.headline)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.blue.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Scrollable clue list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        Section {
                            ForEach(viewModel.acrossClues) { clue in
                                ClueRow(
                                    clue: clue,
                                    isActive: isActiveClue(clue, direction: .across),
                                    onSelect: {
                                        viewModel.selectClue(clue, direction: .across)
                                    }
                                )
                                .id("across-\(clue.number)")
                            }
                        } header: {
                            Text("ACROSS")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                        }

                        Section {
                            ForEach(viewModel.downClues) { clue in
                                ClueRow(
                                    clue: clue,
                                    isActive: isActiveClue(clue, direction: .down),
                                    onSelect: {
                                        viewModel.selectClue(clue, direction: .down)
                                    }
                                )
                                .id("down-\(clue.number)")
                            }
                        } header: {
                            Text("DOWN")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .padding(.top, 12)
                        }
                    }
                }
                .onChange(of: viewModel.activeClue) { _, newClue in
                    if let clue = newClue {
                        let id = "\(viewModel.currentDirection == .across ? "across" : "down")-\(clue.number)"
                        withAnimation {
                            proxy.scrollTo(id, anchor: .center)
                        }
                    }
                }
            }
        }
    }

    private func isActiveClue(_ clue: PuzzleClue, direction: Direction) -> Bool {
        guard let active = viewModel.activeClue else { return false }
        return active.number == clue.number && viewModel.currentDirection == direction
    }
}

struct ClueRow: View {
    let clue: PuzzleClue
    let isActive: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            Text(clue.label)
                .font(.callout)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(isActive ? .blue.opacity(0.2) : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}
