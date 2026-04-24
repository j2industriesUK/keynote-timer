import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum HapticEvent {
    case segmentTransition
    case finalSegment
    case finalMinute
    case finished
    case buttonTap
}

struct HapticsService {
    var enabled: () -> Bool = { true }

    func fire(_ event: HapticEvent) {
        guard enabled() else { return }
        #if canImport(UIKit) && !os(macOS)
        switch event {
        case .buttonTap:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .segmentTransition:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .finalSegment:
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.warning)
        case .finalMinute:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .finished:
            let gen = UINotificationFeedbackGenerator()
            gen.notificationOccurred(.success)
        }
        #endif
    }
}
