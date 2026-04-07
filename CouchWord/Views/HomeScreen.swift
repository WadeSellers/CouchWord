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
        case stats
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

                    // Stats
                    NavigationLink(value: Destination.stats) {
                        MenuButton(
                            title: "Statistics",
                            subtitle: "\(progressStore.stats.totalSolved) solved",
                            icon: "chart.bar.fill"
                        )
                    }
                    .buttonStyle(.card)

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
                case .stats:
                    StatsDashboardView()
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

// MARK: - Puzzle Picker with Filters

struct PuzzlePickerView: View {
    @EnvironmentObject var puzzleStore: PuzzleStore
    @EnvironmentObject var progressStore: ProgressStore

    @State private var sizeFilter: SizeFilter = .all
    @State private var difficultyFilter: DifficultyFilter = .all
    @State private var showCompleted = true

    enum SizeFilter: String, CaseIterable {
        case all = "All Sizes"
        case small = "5×5"
        case medium = "9×9"
        case large = "13×13"
        case full = "15×15"

        func matches(_ puzzle: Puzzle) -> Bool {
            switch self {
            case .all: return true
            case .small: return puzzle.rows == 5
            case .medium: return puzzle.rows == 9
            case .large: return puzzle.rows == 13
            case .full: return puzzle.rows == 15
            }
        }
    }

    enum DifficultyFilter: String, CaseIterable {
        case all = "All Levels"
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        case expert = "Expert"

        func matches(_ puzzle: Puzzle) -> Bool {
            switch self {
            case .all: return true
            case .easy: return puzzle.difficulty == .easy
            case .medium: return puzzle.difficulty == .medium
            case .hard: return puzzle.difficulty == .hard
            case .expert: return puzzle.difficulty == .expert
            }
        }
    }

    private var filteredPuzzles: [Puzzle] {
        let completed = progressStore.completedPuzzleIDs
        return puzzleStore.puzzles.filter { puzzle in
            sizeFilter.matches(puzzle)
            && difficultyFilter.matches(puzzle)
            && (showCompleted || !completed.contains(puzzle.id))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filters bar
            HStack(spacing: 20) {
                Picker("Size", selection: $sizeFilter) {
                    ForEach(SizeFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .frame(width: 200)

                Picker("Difficulty", selection: $difficultyFilter) {
                    ForEach(DifficultyFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .frame(width: 200)

                Toggle("Show Completed", isOn: $showCompleted)

                Spacer()

                Text("\(filteredPuzzles.count) puzzles")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 16)

            // Puzzle grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 20)], spacing: 20) {
                    ForEach(filteredPuzzles) { puzzle in
                        NavigationLink(value: HomeScreen.Destination.puzzle(puzzle.id)) {
                            PuzzleCard(
                                puzzle: puzzle,
                                isCompleted: progressStore.completedPuzzleIDs.contains(puzzle.id),
                                bestTime: progressStore.stats.bestTimes[puzzle.id]
                            )
                        }
                        .buttonStyle(.card)
                    }
                }
                .padding(40)
            }
        }
        .navigationTitle("Quick Play")
    }
}

struct PuzzleCard: View {
    let puzzle: Puzzle
    let isCompleted: Bool
    var bestTime: TimeInterval? = nil

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

                DifficultyBadge(difficulty: puzzle.difficulty)

                if let bestTime {
                    Label(formatTime(bestTime), systemImage: "clock")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        return "\(total / 60):\(String(format: "%02d", total % 60))"
    }
}

struct DifficultyBadge: View {
    let difficulty: Difficulty

    var body: some View {
        Text(difficulty.rawValue.capitalized)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private var color: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .orange
        case .expert: return .red
        }
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
