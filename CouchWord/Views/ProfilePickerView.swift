import SwiftUI

/// Profile picker shown at app launch or accessible from settings.
struct ProfilePickerView: View {
    @EnvironmentObject var profileManager: ProfileManager
    let onSelect: () -> Void

    @State private var showingCreateProfile = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            Text("Who's Playing?")
                .font(.system(size: 48, weight: .bold, design: .serif))

            // Profile grid
            HStack(spacing: 24) {
                ForEach(profileManager.profiles) { profile in
                    Button {
                        profileManager.setActiveProfile(profile)
                        onSelect()
                    } label: {
                        ProfileCard(profile: profile, isActive: profile.id == profileManager.activeProfile?.id)
                    }
                    .buttonStyle(.card)
                }

                // Add profile button (if under max)
                if profileManager.profiles.count < ProfileManager.maxProfiles {
                    Button {
                        showingCreateProfile = true
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.secondary)
                            Text("Add Player")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 180, height: 200)
                    }
                    .buttonStyle(.card)
                }
            }

            Spacer()
        }
        .sheet(isPresented: $showingCreateProfile) {
            CreateProfileView { name, color in
                if let profile = profileManager.createProfile(name: name, color: color) {
                    profileManager.setActiveProfile(profile)
                    onSelect()
                }
            }
        }
    }
}

struct ProfileCard: View {
    let profile: UserProfile
    let isActive: Bool

    var body: some View {
        VStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(profile.avatarColor.color)
                .frame(width: 80, height: 80)
                .overlay {
                    Text(String(profile.name.prefix(1)).uppercased())
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                }
                .overlay {
                    if isActive {
                        Circle()
                            .stroke(.white, lineWidth: 3)
                    }
                }

            Text(profile.name)
                .font(.headline)
                .lineLimit(1)
        }
        .frame(width: 180, height: 200)
    }
}

struct CreateProfileView: View {
    let onCreate: (String, ProfileColor) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedColor: ProfileColor = .blue

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                TextField("Player Name", text: $name)
                    .textFieldStyle(.plain)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 400)

                HStack(spacing: 20) {
                    ForEach(ProfileColor.allCases, id: \.self) { color in
                        Button {
                            selectedColor = color
                        } label: {
                            Circle()
                                .fill(color.color)
                                .frame(width: 60, height: 60)
                                .overlay {
                                    if selectedColor == color {
                                        Image(systemName: "checkmark")
                                            .font(.title2)
                                            .foregroundStyle(.white)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button("Create Profile") {
                    guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    onCreate(name, selectedColor)
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(40)
            .navigationTitle("New Player")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
