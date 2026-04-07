import AudioToolbox
import AVFoundation

/// Manages sound effects for the game.
/// Uses system sounds for v1 — can swap for custom .caf files later.
@MainActor
class SoundManager {
    static let shared = SoundManager()

    private var isEnabled = true

    private init() {}

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }

    func play(_ effect: SoundEffect) {
        guard isEnabled else { return }

        // System sound IDs for tvOS
        // These are standard AudioServices system sounds
        let soundID: SystemSoundID
        switch effect {
        case .letterPlaced:
            soundID = 1104  // Tock
        case .wordCompleted:
            soundID = 1025  // Short chime
        case .puzzleComplete:
            soundID = 1026  // Longer chime/fanfare
        case .undo:
            soundID = 1306  // Swoosh
        case .error:
            soundID = 1073  // Error buzz
        case .hint:
            soundID = 1057  // Subtle notification
        case .navigate:
            soundID = 1104  // Light tock
        }

        AudioServicesPlaySystemSound(soundID)
    }

    enum SoundEffect {
        case letterPlaced
        case wordCompleted
        case puzzleComplete
        case undo
        case error
        case hint
        case navigate
    }
}
