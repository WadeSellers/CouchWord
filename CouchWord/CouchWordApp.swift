import SwiftUI

@main
struct CouchWordApp: App {
    @StateObject private var puzzleStore = PuzzleStore()
    @StateObject private var progressStore = ProgressStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(puzzleStore)
                .environmentObject(progressStore)
                .onAppear {
                    puzzleStore.loadBundledPuzzles()
                }
                .preferredColorScheme(.dark)
        }
    }
}
