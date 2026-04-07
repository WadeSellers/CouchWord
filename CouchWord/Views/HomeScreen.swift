import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var puzzleStore: PuzzleStore
    @EnvironmentObject var progressStore: ProgressStore

    @State private var selectedDestination: Destination?
    @State private var showingSettings = false

    enum Destination: Hashable {
        case quickPlay
        case continuePuzzle(String) // puzzle ID
        case puzzle(String) // puzzle ID for "Today's Puzzle"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()

                // Logo
                VStack(spacing: 8) {
                    Text("CouchWord")
                        .font(.system(size: 72, weight: .bold, design: .serif))
                        .foregroundStyle(.blue)

                    Text("Crossword puzzles for your couch")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Spacer().frame(height: 20)

                // Menu
                VStack(spacing: 16) {
                    // Today's Puzzle
                    NavigationLink(value: todaysPuzzleDestination) {
                        MenuButton(
                            title: "Today's Puzzle",
                            subtitle: todaysPuzzleSubtitle,
                            icon: "calendar"
                        )
                    }
                    .buttonStyle(.card)

                    // Quick Play
                    NavigationLink(value: Destination.quickPlay) {
                        MenuButton(
                            title: "Quick Play (5×5)",
                            subtitle: "\(availablePuzzleCount) puzzles available",
                            icon: "play.fill"
                        )
                    }
                    .buttonStyle(.card)

                    // Continue Puzzle (only if one is in progress)
                    if let inProgressID = progressStore.hasInProgressPuzzle(),
                       let puzzle = puzzleStore.puzzle(byID: inProgressID) {
                        NavigationLink(value: Destination.continuePuzzle(inProgressID)) {
                            MenuButton(
                                title: "Continue Puzzle",
                                subtitle: puzzle.theme ?? "In progress",
                                icon: "arrow.forward.circle"
                            )
                        }
                        .buttonStyle(.card)
                    }

                    // Settings
                    Button {
                        showingSettings = true
                    } label: {
                        MenuButton(
                            title: "Settings",
                            subtitle: nil,
                            icon: "gear"
                        )
                    }
                    .buttonStyle(.card)
                }
                .frame(maxWidth: 500)

                Spacer()

                // Stats bar
                StatsBar(stats: progressStore.stats)
            }
            .padding(60)
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .quickPlay:
                    PuzzlePickerView()
                case .continuePuzzle(let id):
                    if let puzzle = puzzleStore.puzzle(byID: id) {
                        GameView(puzzle: puzzle)
                    }
                case .puzzle(let id):
                    if let puzzle = puzzleStore.puzzle(byID: id) {
                        GameView(puzzle: puzzle)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    private var todaysPuzzleDestination: Destination {
        // Use a deterministic puzzle based on the date
        let dayIndex = Calendar.current.ordinality(of: .day, in: .era, for: .now) ?? 0
        let puzzleIndex = dayIndex % max(puzzleStore.puzzles.count, 1)
        if let puzzle = puzzleStore.puzzles[safe: puzzleIndex] {
            return .puzzle(puzzle.id)
        }
        return .quickPlay
    }

    private var todaysPuzzleSubtitle: String {
        if progressStore.stats.currentStreak > 0 {
            return "\(progressStore.stats.currentStreak)-day streak"
        }
        return "Start your streak!"
    }

    private var availablePuzzleCount: Int {
        let completed = progressStore.completedPuzzleIDs
        return puzzleStore.puzzles.filter { !completed.contains($0.id) }.count
    }
}

// MARK: - Menu Button

struct MenuButton: View {
    let title: String
    let subtitle: String?
    let icon: String

    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 44)
                .foregroundStyle(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.medium)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Stats Bar

struct StatsBar: View {
    let stats: GameStats

    var body: some View {
        HStack(spacing: 40) {
            StatItem(value: "\(stats.totalSolved)", label: "Solved")
            StatItem(value: "\(stats.currentStreak)", label: "Streak")
            StatItem(value: "\(stats.longestStreak)", label: "Best Streak")
        }
        .foregroundStyle(.secondary)
    }
}

struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            Text(label)
                .font(.caption2)
        }
    }
}

// MARK: - Puzzle Picker

struct PuzzlePickerView: View {
    @EnvironmentObject var puzzleStore: PuzzleStore
    @EnvironmentObject var progressStore: ProgressStore

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 20)], spacing: 20) {
                ForEach(puzzleStore.puzzles) { puzzle in
                    NavigationLink(value: HomeScreen.Destination.puzzle(puzzle.id)) {
                        PuzzleCard(
                            puzzle: puzzle,
                            isCompleted: progressStore.completedPuzzleIDs.contains(puzzle.id)
                        )
                    }
                    .buttonStyle(.card)
                }
            }
            .padding(40)
        }
        .navigationTitle("Quick Play")
    }
}

struct PuzzleCard: View {
    let puzzle: Puzzle
    let isCompleted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(puzzle.theme ?? "Puzzle")
                    .font(.headline)
                Spacer()
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            HStack(spacing: 12) {
                Label("\(puzzle.rows)×\(puzzle.cols)", systemImage: "grid")
                Label(puzzle.difficulty.rawValue.capitalized, systemImage: "speedometer")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Settings

struct SettingsView: View {
    @EnvironmentObject var progressStore: ProgressStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Audio") {
                    Toggle("Sound Effects", isOn: Binding(
                        get: { progressStore.soundEnabled },
                        set: { progressStore.soundEnabled = $0 }
                    ))
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0")
                    LabeledContent("Puzzles", value: "\(20)")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Array Safe Subscript

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
