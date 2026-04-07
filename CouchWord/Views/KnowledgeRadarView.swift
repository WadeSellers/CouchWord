import SwiftUI

/// Radar chart showing the player's strengths across puzzle categories.
struct KnowledgeRadarView: View {
    let profile: SkillProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Knowledge Radar")
                .font(.title3)
                .fontWeight(.semibold)

            if profile.radarData.isEmpty {
                Text("Solve more puzzles to build your knowledge radar!")
                    .foregroundStyle(.secondary)
            } else {
                // Bar chart representation (radar charts are complex in SwiftUI)
                VStack(spacing: 8) {
                    ForEach(profile.radarData.sorted(by: { $0.score > $1.score }), id: \.category) { item in
                        HStack(spacing: 12) {
                            Text(item.category)
                                .font(.callout)
                                .frame(width: 120, alignment: .trailing)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    // Background
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(white: 0.15))

                                    // Fill
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(barColor(for: item.score))
                                        .frame(width: geo.size.width * CGFloat(item.score))
                                }
                            }
                            .frame(height: 20)

                            Text("\(Int(item.score * 100))%")
                                .font(.caption)
                                .monospacedDigit()
                                .frame(width: 40, alignment: .trailing)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Strengths & Weaknesses
                HStack(spacing: 40) {
                    if !profile.strengths.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Strengths")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.green)
                            ForEach(profile.strengths, id: \.self) { cat in
                                Text(cat.capitalized)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    if !profile.weaknesses.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Needs Work")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.orange)
                            ForEach(profile.weaknesses, id: \.self) { cat in
                                Text(cat.capitalized)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.top, 8)

                // Recommended difficulty
                HStack {
                    Text("Recommended Difficulty:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    DifficultyBadge(difficulty: profile.recommendedDifficulty)
                }
                .padding(.top, 4)
            }
        }
    }

    private func barColor(for score: Double) -> Color {
        if score > 0.8 { return .green }
        if score > 0.6 { return .yellow }
        if score > 0.4 { return .orange }
        return .red
    }
}
