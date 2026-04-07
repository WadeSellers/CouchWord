import Foundation

/// Tracks every unique word the player has encountered across all puzzles.
struct WordJournal: Codable {
    /// Words mapped to encounter count
    var words: [String: WordEntry] = [:]

    var totalUniqueWords: Int { words.count }
    var totalEncounters: Int { words.values.reduce(0) { $0 + $1.encounterCount } }

    /// Most recently encountered words
    var recentWords: [WordEntry] {
        words.values
            .sorted { ($0.lastEncountered ?? .distantPast) > ($1.lastEncountered ?? .distantPast) }
            .prefix(20)
            .map { $0 }
    }

    /// Most frequently encountered words
    var frequentWords: [WordEntry] {
        words.values
            .sorted { $0.encounterCount > $1.encounterCount }
            .prefix(20)
            .map { $0 }
    }

    mutating func recordWords(from puzzle: Puzzle) {
        let allAnswers = (puzzle.clues.across + puzzle.clues.down).map(\.answer)
        for answer in allAnswers {
            let word = answer.uppercased()
            if var entry = words[word] {
                entry.encounterCount += 1
                entry.lastEncountered = .now
                words[word] = entry
            } else {
                words[word] = WordEntry(word: word, encounterCount: 1, firstEncountered: .now, lastEncountered: .now)
            }
        }
    }
}

struct WordEntry: Codable, Identifiable {
    let word: String
    var encounterCount: Int
    var firstEncountered: Date
    var lastEncountered: Date?

    var id: String { word }
}
