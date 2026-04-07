import Foundation

/// Generates sample puzzles for development and demonstration.
/// Replace with a real puzzle source (API, file import, etc.) for production.
enum PuzzleGenerator {

    static func sample() -> Puzzle {
        // A simple 5x5 crossword grid
        // Layout (# = black):
        //  S W I F T
        //  C # A # V
        //  A P P L E
        //  N # E # R
        //  S O F A S

        let size = 5

        var cells: [[Cell]] = []

        // Row 0: SWIFT
        cells.append([
            .letter("S", clueNumber: 1),
            .letter("W"),
            .letter("I", clueNumber: 2),
            .letter("F"),
            .letter("T", clueNumber: 3),
        ])
        // Row 1: C#A#V
        cells.append([
            .letter("C", clueNumber: 4),
            .black(),
            .letter("A"),
            .black(),
            .letter("V"),
        ])
        // Row 2: APPLE
        cells.append([
            .letter("A", clueNumber: 5),
            .letter("P", clueNumber: 6),
            .letter("P"),
            .letter("L"),
            .letter("E"),
        ])
        // Row 3: N#E#R
        cells.append([
            .letter("N"),
            .black(),
            .letter("E", clueNumber: 7),
            .black(),
            .letter("R"),
        ])
        // Row 4: SOFAS
        cells.append([
            .letter("S", clueNumber: 8),
            .letter("O"),
            .letter("F"),
            .letter("A"),
            .letter("S"),
        ])

        // Wire up clue numbers for each cell
        let acrossClues = [
            Clue(number: 1, direction: .across, text: "Apple's programming language", startRow: 0, startCol: 0, length: 5),
            Clue(number: 4, direction: .across, text: "Musical note after B", startRow: 1, startCol: 0, length: 1),
            Clue(number: 5, direction: .across, text: "Fruit from Cupertino", startRow: 2, startCol: 0, length: 5),
            Clue(number: 7, direction: .across, text: "Common article", startRow: 3, startCol: 2, length: 1),
            Clue(number: 8, direction: .across, text: "Living room seating, plural", startRow: 4, startCol: 0, length: 5),
        ]

        let downClues = [
            Clue(number: 1, direction: .down, text: "Grifts or deceptions", startRow: 0, startCol: 0, length: 5),
            Clue(number: 2, direction: .down, text: "Simian relatives", startRow: 0, startCol: 2, length: 5),
            Clue(number: 3, direction: .down, text: "Television or Apple ___", startRow: 0, startCol: 4, length: 5),
            Clue(number: 6, direction: .down, text: "Music on a turntable, for short", startRow: 2, startCol: 1, length: 1),
        ]

        // Assign across/down clue numbers to cells
        for clue in acrossClues {
            for i in 0..<clue.length {
                cells[clue.startRow][clue.startCol + i].acrossClueNumber = clue.number
            }
        }
        for clue in downClues {
            for i in 0..<clue.length {
                cells[clue.startRow + i][clue.startCol].downClueNumber = clue.number
            }
        }

        return Puzzle(
            size: size,
            cells: cells,
            acrossClues: acrossClues,
            downClues: downClues
        )
    }
}
