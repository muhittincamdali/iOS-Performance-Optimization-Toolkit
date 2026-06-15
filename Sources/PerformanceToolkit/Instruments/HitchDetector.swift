import Foundation
#if canImport(QuartzCore)
import QuartzCore
#endif

/// A high-precision Hitch Detector that monitors the Main Thread for frame drops.
/// Built for the 2026 standard, aiming for a 120Hz ProMotion environment.
@MainActor
public final class HitchDetector: Sendable {
    public static let shared = HitchDetector()
    
    private var displayLink: Any?
    private var lastTimestamp: CFTimeInterval = 0
    private let hitchThreshold: CFTimeInterval = 1.0 / 60.0 // 16.6ms
    
    private init() {}
    
    public func start() {
        #if os(iOS) && canImport(QuartzCore)
        if displayLink != nil { return }
        
        let link = CADisplayLink(target: HitchDetectorProxy(target: self), selector: #selector(HitchDetectorProxy.tick(_:)))
        link.add(to: .main, forMode: .common)
        self.displayLink = link
        print("📈 [Performance] HitchDetector active. Monitoring 120Hz pipeline.")
        #endif
    }
    
    public func stop() {
        #if os(iOS) && canImport(QuartzCore)
        guard let link = displayLink as? CADisplayLink else { return }
        link.invalidate()
        self.displayLink = nil
        self.lastTimestamp = 0
        print("🛑 [Performance] HitchDetector stopped.")
        #endif
    }
    
    nonisolated func recordTick(timestamp: CFTimeInterval) {
        Task { @MainActor in
            if lastTimestamp == 0 {
                lastTimestamp = timestamp
                return
            }
            
            let delta = timestamp - lastTimestamp
            if delta > hitchThreshold * 1.5 {
                print("⚠️ [Performance] HITCH DETECTED: Frame dropped. Delta: \\(String(format: \"%.2f\", delta * 1000))ms")
            }
            lastTimestamp = timestamp
        }
    }
}

#if os(iOS) && canImport(QuartzCore)
private final class HitchDetectorProxy {
    private weak var target: HitchDetector?
    
    init(target: HitchDetector) {
        self.target = target
    }
    
    @objc func tick(_ sender: CADisplayLink) {
        target?.recordTick(timestamp: sender.timestamp)
    }
}
#endif
