import Foundation
import Combine
#if canImport(CoreMotion)
import CoreMotion
#endif

/// Detects shake gestures from the Siri Remote using CMMotionManager.
/// The Siri Remote has an accelerometer that reports via CoreMotion.
/// Falls back gracefully on simulator where CoreMotion may not be available.
@MainActor
class ShakeDetector: ObservableObject {
    @Published private(set) var shakeDetected = false

    #if canImport(CoreMotion)
    private let motionManager = CMMotionManager()
    #endif

    private var lastShakeTime: Date = .distantPast
    private let shakeThreshold: Double = 2.5  // g-force threshold
    private let cooldownInterval: TimeInterval = 0.5  // prevent double-triggers

    var onShake: (() -> Void)?

    func startDetecting() {
        #if canImport(CoreMotion)
        guard motionManager.isAccelerometerAvailable else {
            print("ShakeDetector: Accelerometer not available (likely running in simulator)")
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
                        try? await Task.sleep(for: .milliseconds(200))
                        self.shakeDetected = false
                    }
                }
            }
        }
        #else
        print("ShakeDetector: CoreMotion not available on this platform")
        #endif
    }

    func stopDetecting() {
        #if canImport(CoreMotion)
        motionManager.stopAccelerometerUpdates()
        #endif
    }

    deinit {
        #if canImport(CoreMotion)
        motionManager.stopAccelerometerUpdates()
        #endif
    }
}
