import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PuzzleViewModel()

    var body: some View {
        NavigationStack {
            HStack(spacing: 60) {
                PuzzleGridView(viewModel: viewModel)
                ClueListView(viewModel: viewModel)
            }
            .padding(60)
            .navigationTitle("CouchWord")
            .onAppear {
                viewModel.loadPuzzle(PuzzleGenerator.sample())
            }
        }
    }
}

#Preview {
    ContentView()
}
