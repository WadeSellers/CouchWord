import SwiftUI

/// Root view that handles onboarding vs main app flow.
struct RootView: View {
    @EnvironmentObject var progressStore: ProgressStore
    @State private var showOnboarding: Bool = false

    var body: some View {
        HomeScreen()
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
            }
    }
}
