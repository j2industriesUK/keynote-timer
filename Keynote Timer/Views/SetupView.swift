import SwiftUI

struct SetupView: View {
    @State var configuration: TimerConfiguration
    let onStart: (TimerConfiguration) -> Void
    let onBack: () -> Void
    let onSavePreset: (String, TimerConfiguration) -> Void

    @State private var showSaveSheet = false

    var body: some View {
        ZStack {
            WarmBackground()
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 18) {
                        header
                        GlassCard {
                            DurationPicker(totalSeconds: $configuration.totalSeconds)
                        }
                        .padding(.horizontal, 24)

                        GlassCard {
                            SegmentPicker(count: $configuration.segmentCount)
                        }
                        .padding(.horizontal, 24)

                        summary

                        SegmentNotesEditor(
                            notes: $configuration.segmentNotes,
                            segmentCount: configuration.segmentCount
                        )
                        .padding(.horizontal, 24)
                        .padding(.top, 4)
                    }
                    .padding(.bottom, 16)
                }

                VStack(spacing: 12) {
                    GlassButton(title: "Go to timer", systemImage: "arrow.right.circle.fill", style: .primary) {
                        onStart(configuration)
                    }
                    HStack(spacing: 12) {
                        GlassButton(title: "Save timer", systemImage: "square.and.arrow.down", style: .secondary) {
                            showSaveSheet = true
                        }
                        GlassButton(title: "Back", systemImage: "chevron.left", style: .secondary, action: onBack)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .background(
                    LinearGradient(
                        colors: [Palette.background.opacity(0), Palette.background.opacity(0.95)],
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(height: 90)
                    .allowsHitTesting(false),
                    alignment: .top
                )
            }
        }
        .onChange(of: configuration.segmentCount) { _, newCount in
            configuration.segmentNotes = TimerConfiguration.normalize(
                notes: configuration.segmentNotes, count: newCount
            )
        }
        .sheet(isPresented: $showSaveSheet) {
            SavePresetSheet(configuration: configuration) { name in
                onSavePreset(name, configuration)
            }
            .presentationDetents([.medium])
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("SET YOUR TIMER")
                .font(Typography.serif(13, weight: .medium))
                .tracking(6)
                .foregroundStyle(Palette.deepOrange)
            Text("Duration & segments")
                .font(Typography.serif(26, weight: .medium))
                .foregroundStyle(Palette.primaryText)
        }
        .padding(.top, 24)
    }

    private var summary: some View {
        let per = configuration.segmentDuration
        let m = per / 60
        let s = per % 60
        let label = s == 0 ? "\(m) min" : "\(m)m \(s)s"
        return Text("Each segment: \(label)")
            .font(Typography.rounded(14))
            .foregroundStyle(Palette.secondaryText)
    }
}
