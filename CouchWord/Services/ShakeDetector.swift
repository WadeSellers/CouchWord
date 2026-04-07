import CoreMotion
import Combine

/// Detects shake gestures from the Siri Remote using CMMotionManager.
/// The Siri Remote has an accelerometer that reports via CoreMotion.
@MainActor
class ShakeDetector: ObservableObject {
    @Published private(set) var shakeDetected = false

    private let motionManager = CMMotionManager()
    private var lastShakeTime: Date = .distantPast
    private let shakeThreshold: Double = 2.5  // g-force threshold
    private let cooldownInterval: TimeInterval = 0.5  // prevent double-triggers

    var onShake: (() -> Void)?

    func startDetecting() {
        guard motionManager.isAccelerometerAvailable else {
            print("ShakeDetector: Accelerometer not available")
            return
        }

        motionManager.accelerometerUpdateInterval = 1.0 / 30.0  // 30 Hz

        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self, let data, error == nil else { return }

            let acceleration = data.acceleration
            let magnitude = sqrt(
                acceleration.x * acceleration.x +
                acceleration.y * acceleration.y +
                acceleration.z * acceleration.z
            )

            // Subtract 1g for gravity, check if remaining force exceeds threshold
            if magnitude > self.shakeThreshold {
                let now = Date()
                if now.timeIntervalSince(self.lastShakeTime) > self.cooldownInterval {
                    self.lastShakeTime = now
                    Task { @MainActor in
                        self.shakeDetected = true
                        self.onShake?()
                        // Reset after a moment
                        try? await Task.sleep(for: .milliseconds(200))
                        self.shakeDetected = false
                    }
                }
            }
        }
    }

    func stopDetecting() {
        motionManager.stopAccelerometerUpdates()
    }

    deinit {
        motionManager.stopAccelerometerUpdates()
    }
}
