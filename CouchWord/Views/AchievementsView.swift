import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var progressStore: ProgressStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Summary
                HStack(spacing: 24) {
                    DashboardCard(
                        title: "Unlocked",
                        value: "\(unlockedCount)/\(totalCount)",
                        icon: "trophy.fill",
                        color: .yellow
                    )
                    DashboardCard(
                        title: "Words Learned",
                        value: "\(progressStore.wordJournal.totalUniqueWords)",
                        icon: "textformat.abc",
                        color: .blue
                    )
                }

                // Achievements by category
                ForEach(Achievement.AchievementCategory.allCases, id: \.self) { category in
                    let categoryAchievements = AchievementRegistry.all.filter { $0.category == category }
                    if !categoryAchievements.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(category.rawValue)
                                .font(.title3)
                                .fontWeight(.semibold)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 16)], spacing: 12) {
                                ForEach(categoryAchievements) { achievement in
                                    AchievementCard(
                                        achievement: achievement,
                                        isUnlocked: progressStore.achievementProgress.unlockedIDs.contains(achievement.id)
                                    )
                                }
                            }
                        }
                    }
                }

                // Word Journal preview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Word Journal")
                        .font(.title3)
                        .fontWeight(.semibold)

                    if progressStore.wordJournal.totalUniqueWords == 0 {
                        Text("Complete puzzles to start building your word journal!")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("You've encountered \(progressStore.wordJournal.totalUniqueWords) unique words across \(progressStore.wordJournal.totalEncounters) total encounters.")
                            .foregroundStyle(.secondary)

                        // Recent words
                        FlowLayout(spacing: 8) {
                            ForEach(progressStore.wordJournal.recentWords.prefix(30)) { entry in
                                Text(entry.word)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color(white: 0.15))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .padding(40)
        }
        .navigationTitle("Achievements")
    }

    private var unlockedCount: Int {
        progressStore.achievementProgress.unlockedIDs.count
    }

    private var totalCount: Int {
        AchievementRegistry.all.count
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundStyle(isUnlocked ? .yellow : .gray)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(isUnlocked ? .primary : .secondary)

                Text(achievement.description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isUnlocked {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(12)
        .background(isUnlocked ? Color.yellow.opacity(0.05) : Color(white: 0.10))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

/// Simple horizontal flow layout for word tags.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, origin) in result.origins.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, origins: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var origins: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            origins.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (CGSize(width: maxX, height: y + rowHeight), origins)
    }
}
