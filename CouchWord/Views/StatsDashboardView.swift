import SwiftUI

struct StatsDashboardView: View {
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var puzzleStore: PuzzleStore

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Top stats cards
                HStack(spacing: 24) {
                    DashboardCard(
                        title: "Puzzles Solved",
                        value: "\(stats.totalSolved)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    DashboardCard(
                        title: "Current Streak",
                        value: "\(stats.currentStreak)",
                        icon: "flame.fill",
                        color: .orange
                    )
                    DashboardCard(
                        title: "Best Streak",
                        value: "\(stats.longestStreak)",
                        icon: "trophy.fill",
                        color: .yellow
                    )
                    DashboardCard(
                        title: "Hints Used",
                        value: "\(stats.totalHintsUsed)",
                        icon: "lightbulb.fill",
                        color: .blue
                    )
                }

                // Completion overview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Completion")
                        .font(.title3)
                        .fontWeight(.semibold)

                    let completed = progressStore.completedPuzzleIDs.count
                    let total = puzzleStore.puzzles.count

                    HStack(spacing: 16) {
                        // Progress bar
                        VStack(alignment: .leading, spacing: 6) {
                            ProgressView(value: Double(completed), total: Double(max(total, 1)))
                                .tint(.green)

                            Text("\(completed) of \(total) puzzles completed")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // By difficulty breakdown
                VStack(alignment: .leading, spacing: 12) {
                    Text("By Difficulty")
                        .font(.title3)
                        .fontWeight(.semibold)

                    HStack(spacing: 20) {
                        ForEach(Difficulty.allCases, id: \.self) { difficulty in
                            DifficultyStatCard(
                                difficulty: difficulty,
                                solved: solvedCount(for: difficulty),
                                total: totalCount(for: difficulty)
                            )
                        }
                    }
                }

                // Best times
                if !stats.bestTimes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Best Times")
                            .font(.title3)
                            .fontWeight(.semibold)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 250), spacing: 16)], spacing: 12) {
                            ForEach(sortedBestTimes, id: \.0) { puzzleID, time in
                                if let puzzle = puzzleStore.puzzle(byID: puzzleID) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(puzzle.theme ?? puzzleID)
                                                .font(.callout)
                                            Text("\(puzzle.rows)×\(puzzle.cols) • \(puzzle.difficulty.rawValue.capitalized)")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text(formatTime(time))
                                            .font(.callout)
                                            .monospacedDigit()
                                            .fontWeight(.semibold)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
            }
            .padding(40)
        }
        .navigationTitle("Statistics")
    }

    private var stats: GameStats { progressStore.stats }

    private var sortedBestTimes: [(String, TimeInterval)] {
        stats.bestTimes.sorted { $0.value < $1.value }
    }

    private func solvedCount(for difficulty: Difficulty) -> Int {
        let completedIDs = progressStore.completedPuzzleIDs
        return puzzleStore.puzzles.filter {
            $0.difficulty == difficulty && completedIDs.contains($0.id)
        }.count
    }

    private func totalCount(for difficulty: Difficulty) -> Int {
        puzzleStore.puzzles.filter { $0.difficulty == difficulty }.count
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        return "\(total / 60):\(String(format: "%02d", total % 60))"
    }
}

struct DashboardCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(white: 0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct DifficultyStatCard: View {
    let difficulty: Difficulty
    let solved: Int
    let total: Int

    var body: some View {
        VStack(spacing: 8) {
            DifficultyBadge(difficulty: difficulty)

            Text("\(solved)/\(total)")
                .font(.title3)
                .fontWeight(.semibold)

            ProgressView(value: Double(solved), total: Double(max(total, 1)))
                .tint(difficultyColor)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(white: 0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var difficultyColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .orange
        case .expert: return .red
        }
    }
}
