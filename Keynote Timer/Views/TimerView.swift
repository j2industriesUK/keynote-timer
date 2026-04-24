import SwiftUI

struct TimerView: View {
    @Environment(TimerEngine.self) private var engine
    let onBack: () -> Void

    @State private var showBackConfirm = false
    @State private var showResetConfirm = false

    var body: some View {
        ZStack {
            WarmBackground()
            VStack(spacing: 14) {
                topRow
                ringSection
                    .padding(.top, 4)
                segmentNotes
                    .padding(.top, 4)
                Spacer(minLength: 4)
                controls
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
            FlashOverlay(
                isFinalSegment: engine.isInFinalSegment && !engine.isInFinalMinute,
                isFinished: engine.phase == .finished
            )
        }
        .confirmAction(
            isPresented: $showBackConfirm,
            title: "Leave this timer?",
            message: "The current timer will be cancelled.",
            confirmLabel: "Leave"
        ) {
            engine.reset()
            onBack()
        }
        .confirmAction(
            isPresented: $showResetConfirm,
            title: "Reset the timer?",
            message: "Progress will be cleared.",
            confirmLabel: "Reset"
        ) {
            engine.reset()
        }
    }

    private var topRow: some View {
        HStack {
            Button {
                if engine.phase == .running || engine.phase == .paused {
                    showBackConfirm = true
                } else {
                    engine.reset(); onBack()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Palette.secondaryText)
                    .padding(12)
                    .background(Circle().fill(Palette.surfaceTint))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            Spacer()
            VStack(spacing: 2) {
                Text(segmentLabel)
                    .font(Typography.rounded(12, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(Palette.deepOrange)
                Text(phaseLabel)
                    .font(Typography.serif(16, weight: .medium))
                    .foregroundStyle(Palette.primaryText)
            }
            Spacer()
            Color.clear.frame(width: 42, height: 42)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }

    private var segmentLabel: String {
        "SEGMENT \(engine.currentSegmentIndex + 1) OF \(engine.configuration.segmentCount)"
    }

    private var phaseLabel: String {
        switch engine.phase {
        case .idle: return "Ready"
        case .running: return "In progress"
        case .paused: return "Paused"
        case .finished: return "Time's up"
        }
    }

    private var ringSection: some View {
        ZStack {
            ProgressRing(
                progress: engine.progress,
                segmentCount: engine.configuration.segmentCount,
                currentSegmentIndex: engine.currentSegmentIndex,
                isInFinalSegment: engine.isInFinalSegment,
                isInFinalMinute: engine.isInFinalMinute
            )
            VStack(spacing: 6) {
                Text(formatTime(engine.remaining))
                    .font(Typography.mono(50, weight: .medium))
                    .foregroundStyle(flashingTextColor)
                    .tabularDigits()
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.linear(duration: 0.25), value: Int(engine.remaining))
                    .accessibilityLabel("Time remaining \(formatSpoken(engine.remaining))")
                Text("REMAINING")
                    .font(Typography.rounded(10, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(Palette.secondaryText)

                Divider()
                    .frame(width: 70)
                    .overlay(Palette.amber.opacity(0.4))
                    .padding(.vertical, 2)

                HStack(spacing: 18) {
                    innerReadout(label: "ELAPSED", value: formatTime(engine.elapsed))
                    innerReadout(label: "TOTAL", value: formatTime(TimeInterval(engine.configuration.totalSeconds)))
                }
            }
            .padding(.horizontal, 32)
        }
        .padding(.horizontal, 36)
        .aspectRatio(1, contentMode: .fit)
    }

    private func innerReadout(label: String, value: String) -> some View {
        VStack(spacing: 1) {
            Text(label)
                .font(Typography.rounded(9, weight: .semibold))
                .tracking(1.5)
                .foregroundStyle(Palette.secondaryText)
            Text(value)
                .font(Typography.mono(13, weight: .medium))
                .foregroundStyle(Palette.primaryText)
                .tabularDigits()
        }
    }

    private var flashingTextColor: Color {
        if engine.isInFinalMinute { return Palette.ember }
        if engine.isInFinalSegment { return Palette.deepOrange }
        return Palette.primaryText
    }

    private var segmentNotes: some View {
        SegmentNotesView(
            notes: engine.configuration.segmentNotes,
            currentSegmentIndex: engine.currentSegmentIndex,
            segmentCount: engine.configuration.segmentCount
        )
    }

    private var controls: some View {
        VStack(spacing: 12) {
            primaryButton
            HStack(spacing: 12) {
                GlassButton(title: "Reset", systemImage: "arrow.counterclockwise",
                            style: .secondary,
                            isEnabled: engine.phase != .idle) {
                    if engine.phase == .running || engine.phase == .paused {
                        showResetConfirm = true
                    } else {
                        engine.reset()
                    }
                }
                GlassButton(title: "Back", systemImage: "chevron.left", style: .secondary) {
                    if engine.phase == .running || engine.phase == .paused {
                        showBackConfirm = true
                    } else {
                        engine.reset(); onBack()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var primaryButton: some View {
        switch engine.phase {
        case .idle:
            GlassButton(title: "Start", systemImage: "play.fill", style: .primary) { engine.start() }
        case .running:
            GlassButton(title: "Pause", systemImage: "pause.fill", style: .primary) { engine.pause() }
        case .paused:
            GlassButton(title: "Resume", systemImage: "play.fill", style: .primary) { engine.start() }
        case .finished:
            GlassButton(title: "Done", systemImage: "checkmark", style: .primary) {
                engine.reset(); onBack()
            }
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds.rounded(.up)))
        let h = total / 3600, m = (total % 3600) / 60, s = total % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    private func formatSpoken(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds.rounded(.up)))
        let m = total / 60, s = total % 60
        if m == 0 { return "\(s) seconds" }
        if s == 0 { return "\(m) minutes" }
        return "\(m) minutes \(s) seconds"
    }
}
