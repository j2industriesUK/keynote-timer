import SwiftUI

struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 26
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(22)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Palette.surfaceTint)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Palette.glassStroke, lineWidth: 1)
                    )
                    .shadow(color: Palette.deepOrange.opacity(0.15), radius: 18, x: 0, y: 10)
            }
    }
}

struct GlassPill<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(Capsule().fill(Palette.surfaceTint))
                    .overlay(Capsule().strokeBorder(Palette.glassStroke, lineWidth: 1))
            }
    }
}
