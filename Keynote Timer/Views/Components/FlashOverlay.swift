import SwiftUI

/// Subtle warm glow shown when entering the final segment (before the final-minute dark/light cycle kicks in).
struct FlashOverlay: View {
    let isFinalSegment: Bool
    let isFinished: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse = false

    var body: some View {
        ZStack {
            if isFinalSegment && !isFinished {
                if reduceMotion {
                    // Static border fallback
                    RoundedRectangle(cornerRadius: 0)
                        .strokeBorder(Palette.orange.opacity(0.50), lineWidth: 8)
                        .ignoresSafeArea()
                        .transition(.opacity)
                } else {
                    RadialGradient(
                        colors: [Palette.amber.opacity(pulse ? 0.30 : 0.08), .clear],
                        center: .center,
                        startRadius: 60,
                        endRadius: 520
                    )
                    .ignoresSafeArea()
                    .animation(
                        .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                        value: pulse
                    )
                    .onAppear { pulse = true }
                    .onDisappear { pulse = false }
                    .transition(.opacity)
                }
            }
        }
        .allowsHitTesting(false)
        .animation(.easeInOut(duration: 0.4), value: isFinalSegment)
    }
}
