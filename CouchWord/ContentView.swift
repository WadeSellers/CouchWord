import SwiftUI

/// Root view that handles profile selection, onboarding, and main app flow.
struct RootView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var puzzleStore: PuzzleStore

    @State private var showOnboarding = false
    @State private var profileSelected = false

    var body: some View {
        Group {
            if profileManager.profiles.isEmpty || !profileSelected {
                // No profiles yet, or user needs to pick one
                ProfilePickerView {
                    profileSelected = true
                }
            } else if let profile = profileManager.activeProfile {
                let progressStore = profileManager.progressStore(for: profile)
                let dailyManager = DailyPuzzleManager(puzzleStore: puzzleStore, progressStore: progressStore)

                HomeScreen()
                    .environmentObject(progressStore)
                    .environmentObject(dailyManager)
                    .fullScreenCover(isPresented: $showOnboarding) {
                        OnboardingView {
                            progressStore.hasShownOnboarding = true
                            showOnboarding = false
                        }
                    }
                    .onAppear {
                        if !progressStore.hasShownOnboarding {
                            showOnboarding = true
                        }
                        dailyManager.loadTodaysPuzzle()
                    }
            }
        }
        .onAppear {
            // Auto-select if only one profile
            if profileManager.profiles.count == 1 {
                profileSelected = true
            }
        }
    }
}
