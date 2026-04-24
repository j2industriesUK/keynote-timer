import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct SegmentPicker: View {
    @Binding var count: Int

    var body: some View {
        VStack(spacing: 14) {
            Text("Segments")
                .font(Typography.rounded(13, weight: .semibold))
                .foregroundStyle(Palette.secondaryText)
                .textCase(.uppercase)
                .tracking(2)

            HStack(spacing: 10) {
                ForEach(TimerConfiguration.allowedSegmentCounts, id: \.self) { n in
                    Button {
                        count = n
                        #if canImport(UIKit)
                        UISelectionFeedbackGenerator().selectionChanged()
                        #endif
                    } label: {
                        Text("\(n)")
                            .font(Typography.serif(22, weight: .medium))
                            .frame(width: 48, height: 48)
                            .foregroundStyle(count == n ? Color.white : Palette.primaryText)
                            .background {
                                Circle()
                                    .fill(count == n
                                          ? AnyShapeStyle(Palette.orangeGradient)
                                          : AnyShapeStyle(Palette.surfaceTint))
                                    .overlay(
                                        Circle().strokeBorder(
                                            count == n ? AnyShapeStyle(Palette.deepOrange) : AnyShapeStyle(Palette.glassStroke),
                                            lineWidth: 1.5
                                        )
                                    )
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(n) segment\(n == 1 ? "" : "s")")
                }
            }
        }
    }
}
