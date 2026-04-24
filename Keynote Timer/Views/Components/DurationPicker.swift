import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct DurationPicker: View {
    @Binding var totalSeconds: Int
    private let options = TimerConfiguration.allowedTotals

    var body: some View {
        VStack(spacing: 14) {
            Text("Total time")
                .font(Typography.rounded(13, weight: .semibold))
                .foregroundStyle(Palette.secondaryText)
                .textCase(.uppercase)
                .tracking(2)

            Text(formatted(totalSeconds))
                .font(Typography.serif(52, weight: .medium))
                .foregroundStyle(Palette.primaryText)
                .tabularDigits()
                .contentTransition(.numericText())
                .animation(.snappy, value: totalSeconds)

            Picker("Total time", selection: $totalSeconds) {
                ForEach(options, id: \.self) { seconds in
                    Text(shortLabel(seconds)).tag(seconds)
                }
            }
            #if os(iOS)
            .pickerStyle(.wheel)
            .frame(height: 140)
            .clipped()
            #else
            .pickerStyle(.menu)
            #endif
            .onChange(of: totalSeconds) { selectionHaptic() }
        }
    }

    private func formatted(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0 && m == 0 { return "\(h) hr" }
        if h > 0 { return "\(h) h \(m) m" }
        return "\(m) min"
    }

    private func shortLabel(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        if h > 0 && m == 0 { return "\(h)h" }
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}

private func selectionHaptic() {
    #if canImport(UIKit)
    UISelectionFeedbackGenerator().selectionChanged()
    #endif
}
