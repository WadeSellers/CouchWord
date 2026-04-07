import Foundation

/// Handles processing of voice dictation results for crossword input.
/// On tvOS, voice input comes through the system dictation (Siri Remote mic button)
/// which is captured by a focused TextField. This manager processes the raw
/// dictated text into usable letter/word input.
enum VoiceInputManager {

    /// Processes raw dictation text and returns clean letter(s).
    /// Handles common dictation quirks like "the letter B", "capital A", etc.
    static func process(_ rawText: String) -> VoiceResult {
        let cleaned = rawText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()

        guard !cleaned.isEmpty else { return .empty }

        // Handle "the letter X" pattern
        if let match = cleaned.range(of: #"(?:THE )?LETTER ([A-Z])"#, options: .regularExpression) {
            let letterStr = String(cleaned[match]).last!
            return .letter(letterStr)
        }

        // Handle single character
        if cleaned.count == 1, let char = cleaned.first, char.isLetter {
            return .letter(char)
        }

        // Handle spelled-out single letters: "BEE" -> B, "ARE" -> R, etc.
        if let letter = phoneticToLetter(cleaned) {
            return .letter(letter)
        }

        // Multi-character: treat as a word
        let wordOnly = cleaned.filter { $0.isLetter }
        if !wordOnly.isEmpty {
            return .word(wordOnly)
        }

        return .empty
    }

    /// Maps phonetic letter names to their character.
    private static func phoneticToLetter(_ spoken: String) -> Character? {
        let map: [String: Character] = [
            "AY": "A", "BEE": "B", "SEE": "C", "DEE": "D", "EE": "E",
            "EF": "F", "GEE": "G", "AITCH": "H", "EYE": "I", "JAY": "J",
            "KAY": "K", "EL": "L", "EM": "M", "EN": "N", "OH": "O",
            "PEE": "P", "CUE": "Q", "ARE": "R", "ESS": "S", "TEE": "T",
            "YOU": "U", "VEE": "V", "DOUBLE YOU": "W", "EX": "X",
            "WHY": "Y", "ZEE": "Z", "ZED": "Z",
        ]
        return map[spoken]
    }

    enum VoiceResult {
        case empty
        case letter(Character)
        case word(String)
    }
}
