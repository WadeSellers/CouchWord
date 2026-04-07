import SwiftUI

@main
struct CouchWordApp: App {
    @StateObject private var puzzleStore = PuzzleStore()
    @StateObject private var profileManager = ProfileManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(puzzleStore)
                .environmentObject(profileManager)
                .onAppear {
                    puzzleStore.loadBundledPuzzles()
                }
                .preferredColorScheme(.dark)
        }
    }
}
