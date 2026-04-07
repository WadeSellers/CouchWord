import SwiftUI

/// The main game screen — grid + clue panel + HUD.
struct GameView: View {
    let puzzle: Puzzle

    @StateObject private var viewModel = PuzzleViewModel()
    @StateObject private var shakeDetector = ShakeDetector()
    @EnvironmentObject var progressStore: ProgressStore
    @Environment(\.dismiss) private var dismiss

    @State private var showingCompletion = false
    @State private var showingLetterInput = false

    var body: some View {
        ZStack {
            // Main content
            HStack(spacing: 50) {
                // Left: Puzzle Grid
                ZStack(alignment: .topLeading) {
                    if viewModel.isZoomedOut {
                        MinimapGridView(viewModel: viewModel)
                            .transition(.scale)
                    } else {
                        PuzzleGridView(viewModel: viewModel)
                    }
                }

                // Right: Clue Panel
                VStack(alignment: .leading, spacing: 16) {
                    // Timer & Hints HUD
                    GameHUD(viewModel: viewModel)

                    // Clue list
                    ClueListView(viewModel: viewModel)
                }
                .frame(width: 420)
            }
            .padding(.horizontal, 50)
            .padding(.vertical, 30)

            // Minimap overlay (when not zoomed out)
            if !viewModel.isZoomedOut, let puzzle = viewModel.puzzle, puzzle.rows > 5 {
                VStack {
                    HStack {
                        MinimapOverlay(viewModel: viewModel)
                            .frame(width: 100, height: 100)
                            .padding(16)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadPuzzle(puzzle)
        }
        .onDisappear {
            viewModel.saveCurrentProgress()
        }
        .onChange(of: viewModel.isSolved) { _, solved in
            if solved {
                Task {
                    try? await Task.sleep(for: .seconds(1))
                    showingCompletion = true
                }
            }
        }
        .fullScreenCover(isPresented: $showingCompletion) {
            CompletionView(viewModel: viewModel) {
                dismiss()
            }
        }
        .onPlayPauseCommand {
            viewModel.toggleDirection()
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
        .sheet(isPresented: $showingLetterInput) {
            LetterInputView(viewModel: viewModel)
        }
        .onAppear {
            shakeDetector.onShake = { [weak viewModel] in
                viewModel?.undo()
                SoundManager.shared.play(.undo)
            }
            shakeDetector.startDetecting()
        }
        .onDisappear {
            shakeDetector.stopDetecting()
        }
    }
}

// MARK: - Game HUD

struct GameHUD: View {
    @ObservedObject var viewModel: PuzzleViewModel

    var body: some View {
        HStack(spacing: 24) {
            // Timer
            HStack(spacing: 6) {
                Image(systemName: "clock")
                Text(viewModel.elapsedTimeFormatted)
                    .monospacedDigit()
            }
            .font(.title3)

            Spacer()

            // Hint button
            Button {
                viewModel.useHint()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                    Text("\(viewModel.hintsRemaining)")
                }
            }
            .disabled(viewModel.hintsRemaining <= 0 || viewModel.isSolved)

            // Check button
            Button {
                viewModel.checkPuzzle()
            } label: {
                Image(systemName: "checkmark.circle")
            }
            .disabled(viewModel.isSolved)
        }
        .foregroundStyle(.secondary)
    }
}

// MARK: - Minimap Overlay (small corner view)

struct MinimapOverlay: View {
    @ObservedObject var viewModel: PuzzleViewModel

    var body: some View {
        if let puzzle = viewModel.puzzle {
            VStack(spacing: 1) {
                ForEach(0..<puzzle.rows, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(0..<puzzle.cols, id: \.self) { col in
                            Rectangle()
                                .fill(minimapColor(row: row, col: col))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            }
            .padding(6)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func minimapColor(row: Int, col: Int) -> Color {
        guard let puzzle = viewModel.puzzle else { return .clear }
        if puzzle.isBlack(row: row, col: col) { return .black }
        if row == viewModel.focusedRow && col == viewModel.focusedCol { return .blue }

        let letter = viewModel.progress?.letterAt(row: row, col: col) ?? ""
        return letter.isEmpty ? Color(.darkGray) : .white.opacity(0.7)
    }
}

// MARK: - Minimap Full Grid (zoomed out view)

struct MinimapGridView: View {
    @ObservedObject var viewModel: PuzzleViewModel

    let cellSize: CGFloat = 50

    var body: some View {
        if let puzzle = viewModel.puzzle {
            VStack(spacing: 2) {
                ForEach(0..<puzzle.rows, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<puzzle.cols, id: \.self) { col in
                            ZStack {
                                Rectangle()
                                    .fill(cellColor(row: row, col: col))

                                if !puzzle.isBlack(row: row, col: col) {
                                    let letter = viewModel.progress?.letterAt(row: row, col: col) ?? ""
                                    if !letter.isEmpty {
                                        Text(letter)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                }
                            }
                            .frame(width: cellSize, height: cellSize)
                            .border(Color.gray.opacity(0.5), width: 0.5)
                        }
                    }
                }
            }
            .onTapGesture {
                viewModel.toggleZoom()
            }
        }
    }

    private func cellColor(row: Int, col: Int) -> Color {
        guard let puzzle = viewModel.puzzle else { return .clear }
        if puzzle.isBlack(row: row, col: col) { return .black }
        if row == viewModel.focusedRow && col == viewModel.focusedCol { return .blue.opacity(0.6) }
        return Color(.darkGray)
    }
}
