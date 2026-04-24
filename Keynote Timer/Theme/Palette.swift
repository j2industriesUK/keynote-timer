import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Adaptive colour helper
extension Color {
    /// Creates a colour that automatically switches between light and dark variants
    /// when the environment's colorScheme changes (including programmatic preferredColorScheme).
    init(
        lightR: Double, lightG: Double, lightB: Double,
        darkR:  Double, darkG:  Double, darkB:  Double,
        opacity: Double = 1
    ) {
        #if canImport(UIKit)
        let uiColor = UIColor(dynamicProvider: { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: darkR,  green: darkG,  blue: darkB,  alpha: opacity)
                : UIColor(red: lightR, green: lightG, blue: lightB, alpha: opacity)
        })
        self = Color(uiColor: uiColor)
        #else
        self = Color(red: lightR, green: lightG, blue: lightB, opacity: opacity)
        #endif
    }
}

// MARK: - Palette
enum Palette {

    // ── Backgrounds ─────────────────────────────────────────────────────────
    /// Warm off-white (light) / deep midnight blue-black (dark)
    static let background = Color(
        lightR: 0.985, lightG: 0.960, lightB: 0.930,
        darkR:  0.035, darkG:  0.045, darkB:  0.075
    )
    static let surface = Color(
        lightR: 0.960, lightG: 0.928, lightB: 0.885,
        darkR:  0.070, darkG:  0.085, darkB:  0.130
    )

    // ── Primary orange accents ────────────────────────────────────────────
    /// Vivid warm orange — main brand colour
    static let orange = Color(
        lightR: 0.898, lightG: 0.416, lightB: 0.122,
        darkR:  0.985, darkG:  0.520, darkB:  0.180
    )
    /// Deeper burnt-orange for borders / ring fill
    static let deepOrange = Color(
        lightR: 0.740, lightG: 0.295, lightB: 0.065,
        darkR:  0.900, darkG:  0.400, darkB:  0.120
    )
    /// Amber — lighter warm accent, hover / secondary highlights
    static let amber = Color(
        lightR: 0.940, lightG: 0.660, lightB: 0.200,
        darkR:  1.000, darkG:  0.760, darkB:  0.300
    )
    /// Alert ember — used during final-minute warning ring fill
    static let ember = Color(
        lightR: 0.870, lightG: 0.200, lightB: 0.080,
        darkR:  1.000, darkG:  0.330, darkB:  0.160
    )

    // ── Text ─────────────────────────────────────────────────────────────
    static let primaryText = Color(
        lightR: 0.095, lightG: 0.072, lightB: 0.050,
        darkR:  0.965, darkG:  0.955, darkB:  0.940
    )
    static let secondaryText = Color(
        lightR: 0.430, lightG: 0.350, lightB: 0.260,
        darkR:  0.620, darkG:  0.665, darkB:  0.755
    )

    // ── Surface overlays ─────────────────────────────────────────────────
    static let surfaceTint = Color(
        lightR: 0.898, lightG: 0.416, lightB: 0.122,
        darkR:  0.985, darkG:  0.520, darkB:  0.180,
        opacity: 0.16
    )
    static let glassStroke = Color(
        lightR: 0.898, lightG: 0.416, lightB: 0.122,
        darkR:  0.985, darkG:  0.520, darkB:  0.180,
        opacity: 0.45
    )

    // ── Gradients (rebuilt from adaptive base colours) ───────────────────
    static let orangeGradient = LinearGradient(
        colors: [amber, orange, deepOrange],
        startPoint: .topLeading,
        endPoint:   .bottomTrailing
    )
}

// MARK: - WarmBackground (adaptive)
struct WarmBackground: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            Palette.background.ignoresSafeArea()
            // Subtle radial glow
            RadialGradient(
                colors: [
                    scheme == .dark
                        ? Palette.orange.opacity(0.16)
                        : Palette.amber.opacity(0.22),
                    .clear
                ],
                center: .top,
                startRadius: 60,
                endRadius: 520
            )
            .ignoresSafeArea()

            // In dark mode, add a subtle deep-blue ambient at the bottom
            if scheme == .dark {
                RadialGradient(
                    colors: [
                        Color(red: 0.10, green: 0.16, blue: 0.32).opacity(0.55),
                        .clear
                    ],
                    center: .bottom,
                    startRadius: 80,
                    endRadius: 600
                )
                .ignoresSafeArea()
            }
        }
    }
}
