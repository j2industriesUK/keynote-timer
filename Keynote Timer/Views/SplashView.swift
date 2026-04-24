import SwiftUI

struct SplashView: View {
    @Environment(PresetStore.self) private var presetStore
    let onBegin: () -> Void
    let onSelectPreset: (TimerPreset) -> Void
    let onOpenSettings: () -> Void
    let onOpenSavedTimers: () -> Void

    var body: some View {
        ZStack {
            WarmBackground()

            // Wordmark — pinned to the true screen centre via ZStack.
            wordmark

            // Top bar and action buttons sit in their own VStack layer on top.
            VStack(spacing: 0) {
                topBar
                Spacer()
                actionArea
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
            }
        }
    }

    // MARK: - Sub-views

    private var topBar: some View {
        HStack {
            Spacer()
            Button(action: onOpenSettings) {
                Image(systemName: "gearshape")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Palette.secondaryText)
                    .padding(11)
                    .background(Circle().fill(Palette.surfaceTint))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
        }
        .padding(.horizontal, 22)
        .padding(.top, 10)
    }

    /// Pure-type wordmark — no icon. Large light serif gives the luxury-watch feel.
    private var wordmark: some View {
        VStack(spacing: 10) {
            Text("KEYNOTE")
                .font(Typography.serif(46, weight: .light))
                .tracking(18)
                .foregroundStyle(Palette.primaryText)
            Text("TIMER")
                .font(Typography.serif(46, weight: .light))
                .tracking(22)
                .foregroundStyle(Palette.deepOrange)
            Rectangle()
                .fill(Palette.amber.opacity(0.55))
                .frame(width: 44, height: 1)
                .padding(.top, 4)
            Text("present with confidence")
                .font(Typography.label(14, weight: .light))
                .tracking(3)
                .foregroundStyle(Palette.secondaryText)
                .padding(.top, 2)
        }
        // Slight upward nudge so it reads as optically centred
        // (the buttons at the bottom have more visual weight than the thin top bar).
        .offset(y: -20)
    }

    private var actionArea: some View {
        VStack(spacing: 14) {
            GlassButton(title: "New timer", systemImage: "clock", style: .primary, action: onBegin)

            GlassButton(
                title: "Saved timers",
                systemImage: "bookmark.fill",
                style: .secondary,
                isEnabled: !presetStore.presets.isEmpty,
                action: onOpenSavedTimers
            )

            if presetStore.presets.isEmpty {
                Text("Save a timer after setting up your first session")
                    .font(Typography.label(12))
                    .tracking(0.2)
                    .foregroundStyle(Palette.secondaryText.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)
            }
        }
    }
}
