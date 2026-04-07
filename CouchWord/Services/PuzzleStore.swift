import Foundation

/// Loads and manages bundled puzzle JSON files.
@MainActor
class PuzzleStore: ObservableObject {
    @Published private(set) var puzzles: [Puzzle] = []
    @Published private(set) var isLoaded = false

    func loadBundledPuzzles() {
        guard !isLoaded else { return }

        var loaded: [Puzzle] = []
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        guard let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "Puzzles") else {
            // Fallback: try loading from bundle root with puzzle_ prefix
            loadFromBundleRoot(decoder: decoder)
            return
        }

        for url in urls.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            do {
                let data = try Data(contentsOf: url)
                let puzzle = try decoder.decode(Puzzle.self, from: data)
                loaded.append(puzzle)
            } catch {
                print("Failed to load puzzle at \(url.lastPathComponent): \(error)")
            }
        }

        puzzles = loaded
        isLoaded = true
    }

    private func loadFromBundleRoot(decoder: JSONDecoder) {
        var loaded: [Puzzle] = []

        for i in 1...20 {
            let name = String(format: "puzzle_%03d", i)
            guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
                continue
            }
            do {
                let data = try Data(contentsOf: url)
                let puzzle = try decoder.decode(Puzzle.self, from: data)
                loaded.append(puzzle)
            } catch {
                print("Failed to load \(name): \(error)")
            }
        }

        puzzles = loaded
        isLoaded = true
    }

    func puzzle(byID id: String) -> Puzzle? {
        puzzles.first { $0.id == id }
    }

    func randomPuzzle(excluding completedIDs: Set<String> = []) -> Puzzle? {
        let available = puzzles.filter { !completedIDs.contains($0.id) }
        return available.randomElement() ?? puzzles.randomElement()
    }

    func nextPuzzle(after currentID: String) -> Puzzle? {
        guard let index = puzzles.firstIndex(where: { $0.id == currentID }) else {
            return puzzles.first
        }
        let nextIndex = puzzles.index(after: index)
        return nextIndex < puzzles.endIndex ? puzzles[nextIndex] : puzzles.first
    }
}
