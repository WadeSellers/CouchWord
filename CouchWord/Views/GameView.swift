import SwiftUI

/// The main game screen — newspaper crossword layout.
/// Grid on the left with active clue below, flowing clue columns on the right,
/// daily puzzle banner at the bottom.
struct GameView: View {
    let puzzle: Puzzle

    @StateObject private var viewModel = PuzzleViewModel()
    @StateObject private var shakeDetector = ShakeDetector()
    @EnvironmentObject var progressStore: ProgressStore
    @Environment(\.dismiss) private var dismiss

    @State private var showingCompletion = false
    @State private var isInputMode = false
    @State private var inputText = ""
    @FocusState private var inputFieldFocused: Bool

    private var dailyDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: Date())
    }

    var body: some View {
        VStack(spacing: 0) {
            // Main content — grid left, clue columns right
            HStack(alignment: .top, spacing: 30) {
                // Left side: Grid + active clue below
                VStack(alignment: .leading, spacing: 10) {
                    if viewModel.isZoomedOut {
                        MinimapGridView(viewModel: viewModel)
                            .transition(.scale)
                    } else {
                        PuzzleGridView(viewModel: viewModel)
                    }

                    // Active clue — displayed prominently below the grid
                    if let clue = viewModel.activeClue {
                        HStack(spacing: 8) {
                            Text("\(clue.number)")
                                .font(.system(size: 22, weight: .bold, design: .serif))
                                .foregroundStyle(Color(white: 0.15))
                            Text(viewModel.currentDirection.rawValue.uppercased())
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color(white: 0.5))
                                .tracking(1.5)
                            Text(clue.clue)
                                .font(.system(size: 20, weight: .regular, design: .serif))
                                .foregroundStyle(Color(white: 0.15))
                                .lineLimit(2)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 0.83, green: 0.91, blue: 0.97))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }

                // Right side: Newspaper-style flowing clue columns
                ClueListView(viewModel: viewModel)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 48)
            .padding(.top, 20)

            Spacer(minLength: 4)

            // Inline input field
            if isInputMode {
                HStack(spacing: 16) {
                    if let clue = viewModel.activeClue {
                        Text("\(clue.number) \(viewModel.currentDirection.rawValue.uppercased()):")
                            .font(.system(.headline, design: .serif))
                            .foregroundStyle(.secondary)
                    }

                    TextField("Speak or type...", text: $inputText)
                        .focused($inputFieldFocused)
                        .textInputAutocapitalization(.characters)
                        .onChange(of: inputText) { _, newValue in
                            handleInput(newValue)
                        }
                        .frame(maxWidth: 400)
                }
                .padding(.horizontal, 48)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Bottom banner — newspaper-style daily masthead
            Rectangle()
                .fill(Color(white: 0.3))
                .frame(height: 1)
                .padding(.horizontal, 48)

            HStack(alignment: .center) {
                Text("CouchWord")
                    .font(.system(size: 26, weight: .black, design: .serif))
                    .foregroundStyle(Color(white: 0.1))

                Text("\u{2022}")
                    .font(.system(size: 22))
                    .foregroundStyle(Color(white: 0.4))
                    .padding(.horizontal, 6)

                Text(dailyDateText)
                    .font(.system(size: 22, weight: .regular, design: .serif))
                    .foregroundStyle(Color(white: 0.3))

                Spacer()

                GameHUD(viewModel: viewModel)
            }
            .padding(.horizontal, 48)
            .padding(.vertical, 14)
        }
        .background(Color(red: 0.97, green: 0.96, blue: 0.94))
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
            if isInputMode {
                exitInputMode()
            }
            switch direction {
            case .up: viewModel.moveFocus(.up)
            case .down: viewModel.moveFocus(.down)
            case .left: viewModel.moveFocus(.left)
            case .right: viewModel.moveFocus(.right)
            @unknown default: break
            }
        }
        .onExitCommand {
            if isInputMode {
                exitInputMode()
            } else {
                viewModel.saveCurrentProgress()
                dismiss()
            }
        }
        .onLongPressGesture(minimumDuration: 0.01, pressing: { _ in }) {
            enterInputMode()
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
        .animation(.easeInOut(duration: 0.2), value: isInputMode)
    }

    // MARK: - Input Mode

    private func enterInputMode() {
        guard !viewModel.isSolved else { return }
        inputText = ""
        isInputMode = true
        inputFieldFocused = true
    }

    private func exitInputMode() {
        isInputMode = false
        inputFieldFocused = false
        inputText = ""
    }

    private func handleInput(_ text: String) {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !cleaned.isEmpty else { return }

        let result = VoiceInputManager.process(cleaned)

        switch result {
        case .letter(let letter):
            viewModel.enterLetter(letter)
            SoundManager.shared.play(.letterPlaced)
            inputText = ""
        case .word(let word):
            viewModel.enterWord(word)
            SoundManager.shared.play(.wordCompleted)
            inputText = ""
        case .empty:
            break
        }
    }
}

// MARK: - Game HUD

struct GameHUD: View {
    @ObservedObject var viewModel: PuzzleViewModel
    @EnvironmentObject var progressStore: ProgressStore

    var body: some View {
        HStack(spacing: 24) {
            // Timer
            if progressStore.timerMode != .hide {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                    Text(viewModel.elapsedTimeFormatted)
                        .monospacedDigit()
                }
                .font(.system(size: 18))
            }

            // Hint button
            Button {
                viewModel.useHint()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                    Text("\(viewModel.hintsRemaining)")
                }
                .font(.system(size: 18))
            }
            .disabled(viewModel.hintsRemaining <= 0 || viewModel.isSolved)

            // Check button
            Button {
                viewModel.checkPuzzle()
            } label: {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 18))
            }
            .disabled(viewModel.isSolved)
        }
        .foregroundStyle(Color(white: 0.4))
    }
}

// MARK: - Minimap Overlay (small corner view)

struct MinimapOverlay: View {
    @ObservedObject var viewModel: PuzzleViewModel

    var body: some View {
        if let puzzle = viewModel.puzzle {
            VStack(spacing: 0) {
                ForEach(0..<puzzle.rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<puzzle.cols, id: \.self) { col in
                            Rectangle()
                                .fill(minimapColor(row: row, col: col))
                                .frame(width: 6, height: 6)
                                .border(Color.gray.opacity(0.3), width: 0.5)
                        }
                    }
                }
            }
            .padding(4)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }

    private func minimapColor(row: Int, col: Int) -> Color {
        guard let puzzle = viewModel.puzzle else { return .clear }
        if puzzle.isBlack(row: row, col: col) { return .black }
        if row == viewModel.focusedRow && col == viewModel.focusedCol { return .blue }

        let letter = viewModel.progress?.letterAt(row: row, col: col) ?? ""
        return letter.isEmpty ? .white : .gray
    }
}

// MARK: - Minimap Full Grid (zoomed out view)

struct MinimapGridView: View {
    @ObservedObject var viewModel: PuzzleViewModel

    let cellSize: CGFloat = 50

    var body: some View {
        if let puzzle = viewModel.puzzle {
            VStack(spacing: 0) {
                ForEach(0..<puzzle.rows, id: \.self) { row in
                    HStack(spacing: 0) {
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
                            .border(Color.black.opacity(0.3), width: 0.5)
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
        return .white
    }
}
