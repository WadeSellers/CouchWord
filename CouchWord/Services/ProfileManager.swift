import Foundation

/// Manages household profiles. Up to 4 profiles per Apple TV.
/// Each profile gets its own namespaced UserDefaults keys for stats and progress.
@MainActor
class ProfileManager: ObservableObject {
    @Published private(set) var profiles: [UserProfile] = []
    @Published var activeProfile: UserProfile?

    private let defaults: UserDefaults
    private static let profilesKey = "couchword_profiles"
    private static let activeProfileKey = "couchword_active_profile"
    static let maxProfiles = 4

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        loadProfiles()
    }

    // MARK: - Profile Management

    func createProfile(name: String, color: ProfileColor) -> UserProfile? {
        guard profiles.count < Self.maxProfiles else { return nil }
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }

        let profile = UserProfile(name: name, color: color)
        profiles.append(profile)
        saveProfiles()

        if activeProfile == nil {
            setActiveProfile(profile)
        }

        return profile
    }

    func deleteProfile(_ profile: UserProfile) {
        profiles.removeAll { $0.id == profile.id }

        // Clean up profile's data
        clearProfileData(profile.id)
        saveProfiles()

        if activeProfile?.id == profile.id {
            activeProfile = profiles.first
            if let active = activeProfile {
                defaults.set(active.id, forKey: Self.activeProfileKey)
            }
        }
    }

    func setActiveProfile(_ profile: UserProfile) {
        activeProfile = profile
        defaults.set(profile.id, forKey: Self.activeProfileKey)
    }

    func updateProfile(_ profile: UserProfile) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
            saveProfiles()
            if activeProfile?.id == profile.id {
                activeProfile = profile
            }
        }
    }

    /// Returns a ProgressStore namespaced to the given profile.
    func progressStore(for profile: UserProfile) -> ProgressStore {
        ProgressStore(defaults: defaults, profileID: profile.id)
    }

    /// Returns the ProgressStore for the active profile.
    var activeProgressStore: ProgressStore {
        guard let profile = activeProfile else {
            return ProgressStore(defaults: defaults)
        }
        return ProgressStore(defaults: defaults, profileID: profile.id)
    }

    // MARK: - Private

    private func loadProfiles() {
        if let data = defaults.data(forKey: Self.profilesKey),
           let decoded = try? JSONDecoder().decode([UserProfile].self, from: data) {
            profiles = decoded
        }

        // Restore active profile
        if let activeID = defaults.string(forKey: Self.activeProfileKey) {
            activeProfile = profiles.first { $0.id == activeID }
        }
        if activeProfile == nil {
            activeProfile = profiles.first
        }
    }

    private func saveProfiles() {
        if let data = try? JSONEncoder().encode(profiles) {
            defaults.set(data, forKey: Self.profilesKey)
        }
    }

    private func clearProfileData(_ profileID: String) {
        let prefix = "couchword_\(profileID)_"
        let allKeys = defaults.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix(prefix) {
            defaults.removeObject(forKey: key)
        }
    }
}
