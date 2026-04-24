import SwiftUI

enum Typography {
    /// Serif display (New York) — elegant heritage feel for headings and large numbers.
    static func serif(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    /// Monospace for timer digits — tabular to prevent jitter.
    /// Using SF Mono gives the precise, instrument-panel feel of a mechanical timepiece.
    static func mono(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    /// Clean SF Pro (default) for all supporting UI text.
    /// Replaces Rounded — the standard SF design reads as more refined and watchlike.
    static func label(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    // Legacy alias so existing call sites that used `rounded` compile without changes.
    static func rounded(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        label(size, weight: weight)
    }
}

extension View {
    /// Tabular numerals so digits have constant width.
    func tabularDigits() -> some View {
        self.monospacedDigit()
    }
}
