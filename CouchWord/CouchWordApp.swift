import SwiftUI

@main
struct CouchWordApp: App {
    @StateObject private var puzzleStore = PuzzleStore()
    @StateObject private var progressStore = ProgressStore()
    @StateObject private var dailyManager: DailyPuzzleManager

    init() {
        let ps = PuzzleStore()
        let pr = ProgressStore()
        _puzzleStore = StateObject(wrappedValue: ps)
        _progressStore = StateObject(wrappedValue: pr)
        _dailyManager = StateObject(wrappedValue: DailyPuzzleManager(puzzleStore: ps, progressStore: pr))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(puzzleStore)
                .environmentObject(progressStore)
                .environmentObject(dailyManager)
                .onAppear {
                    puzzleStore.loadBundledPuzzles()
                    dailyManager.loadTodaysPuzzle()
                }
                .preferredColorScheme(.dark)
        }
    }
}
