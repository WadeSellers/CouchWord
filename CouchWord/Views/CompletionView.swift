import SwiftUI

struct CompletionView: View {
    @ObservedObject var viewModel: PuzzleViewModel
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var puzzleStore: PuzzleStore

    let onDismiss: () -> Void

    @State private var showContent = false
    @State private var showStats = false
    @State private var shareButtonText = "Share Results"

    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Title with animation
                if showContent {
                    VStack(spacing: 12) {
                        Text("Puzzle Complete!")
                            .font(.system(size: 56, weight: .bold, design: .serif))
                            .foregroundStyle(.green)
                            .transition(.scale.combined(with: .opacity))

                        if let theme = viewModel.puzzle?.theme {
                            Text(theme)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Stats
                if showStats {
                    VStack(spacing: 24) {
                        // Time
                        StatRow(
                            icon: "clock.fill",
                            label: "Time",
                            value: viewModel.elapsedTimeFormatted,
                            color: .blue
                        )

                        // Hints
                        StatRow(
                            icon: "lightbulb.fill",
                            label: "Hints Used",
                            value: "\(viewModel.progress?.hintsUsed ?? 0) / 3",
                            color: hintsColor
                        )

                        // Streak
                        StatRow(
                            icon: "flame.fill",
                            label: "Streak",
                            value: "\(progressStore.stats.currentStreak) days",
                            color: .orange
                        )

                        // Accuracy
                        if let accuracy = viewModel.progress?.accuracy {
                            StatRow(
                                icon: "target",
                                label: "Accuracy",
                                value: "\(Int(accuracy * 100))%",
                                color: accuracy == 1.0 ? .green : .yellow
                            )
                        }
                    }
                    .frame(maxWidth: 400)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()

                // Actions
                if showStats {
                    VStack(spacing: 16) {
                        // Next Puzzle
                        if let nextPuzzle = nextPuzzle {
                            Button {
                                viewModel.loadPuzzle(nextPuzzle)
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.right.circle.fill")
                                    Text("Next Puzzle")
                                }
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(maxWidth: 400)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.card)
                        }

                        // Share Results
                        if let puzzle = viewModel.puzzle, let progress = viewModel.progress {
                            Button {
                                let text = ShareResultsGenerator.generate(
                                    puzzle: puzzle,
                                    progress: progress,
                                    stats: progressStore.stats
                                )
                                UIPasteboard.general.string = text
                                shareButtonText = "Copied!"
                                Task {
                                    try? await Task.sleep(for: .seconds(2))
                                    shareButtonText = "Share Results"
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text(shareButtonText)
                                }
                                .font(.title3)
                                .frame(maxWidth: 400)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.card)
                        }

                        // Back to Home
                        Button {
                            onDismiss()
                        } label: {
                            HStack {
                                Image(systemName: "house.fill")
                                Text("Back to Home")
                            }
                            .font(.title3)
                            .frame(maxWidth: 400)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.card)
                    }
                    .transition(.opacity)
                }

                Spacer().frame(height: 40)
            }
        }
        .onAppear {
            SoundManager.shared.play(.puzzleComplete)
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                showStats = true
            }
        }
    }

    private var hintsColor: Color {
        let hints = viewModel.progress?.hintsUsed ?? 0
        if hints == 0 { return .green }
        if hints <= 2 { return .yellow }
        return .orange
    }

    private var nextPuzzle: Puzzle? {
        guard let currentID = viewModel.puzzle?.id else { return nil }
        return puzzleStore.nextPuzzle(after: currentID)
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 36)

            Text(label)
                .font(.title3)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
        .padding(.vertical, 8)
    }
}
