import SwiftUI

enum GlassButtonStyle {
    case primary
    case secondary
    case destructive
}

struct GlassButton: View {
    let title: String
    var systemImage: String? = nil
    var style: GlassButtonStyle = .primary
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title)
                    .font(Typography.rounded(17, weight: .semibold))
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(backgroundFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(borderColor, lineWidth: 1.5)
                    )
                    .shadow(
                        color: shadowColor,
                        radius: style == .primary ? 16 : 8,
                        x: 0, y: 8
                    )
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.40)
        .contentShape(RoundedRectangle(cornerRadius: 22))
    }

    private var foreground: AnyShapeStyle {
        switch style {
        case .primary:     return AnyShapeStyle(.white)
        case .secondary:   return AnyShapeStyle(Palette.primaryText)
        case .destructive: return AnyShapeStyle(Palette.ember)
        }
    }

    private var backgroundFill: AnyShapeStyle {
        switch style {
        case .primary:     return AnyShapeStyle(Palette.orangeGradient)
        case .secondary:   return AnyShapeStyle(Palette.surfaceTint)
        case .destructive: return AnyShapeStyle(Palette.ember.opacity(0.12))
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary:     return Palette.deepOrange.opacity(0.60)
        case .secondary:   return Palette.primaryText.opacity(0.08)   // barely-there hairline
        case .destructive: return Palette.ember.opacity(0.55)
        }
    }

    private var shadowColor: Color {
        switch style {
        case .primary:     return Palette.deepOrange.opacity(0.30)
        case .secondary:   return Palette.orange.opacity(0.10)
        case .destructive: return Palette.ember.opacity(0.20)
        }
    }
}
