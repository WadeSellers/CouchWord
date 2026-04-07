import SwiftUI

/// A household profile. Up to 4 profiles per Apple TV.
struct UserProfile: Codable, Identifiable, Hashable {
    let id: String
    var name: String
    var avatarColor: ProfileColor
    var createdAt: Date

    init(name: String, color: ProfileColor) {
        self.id = UUID().uuidString
        self.name = name
        self.avatarColor = color
        self.createdAt = .now
    }
}

enum ProfileColor: String, Codable, CaseIterable {
    case blue, green, orange, purple

    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .orange: return .orange
        case .purple: return .purple
        }
    }

    var emoji: String {
        switch self {
        case .blue: return "🔵"
        case .green: return "🟢"
        case .orange: return "🟠"
        case .purple: return "🟣"
        }
    }
}
