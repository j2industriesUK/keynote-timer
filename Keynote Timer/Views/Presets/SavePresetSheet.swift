import SwiftUI

struct SavePresetSheet: View {
    let configuration: TimerConfiguration
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            WarmBackground()
            VStack(spacing: 20) {
                Text("Save timer")
                    .font(Typography.serif(24, weight: .medium))
                    .foregroundStyle(Palette.primaryText)
                    .padding(.top, 24)

                Text(summary)
                    .font(Typography.rounded(14))
                    .foregroundStyle(Palette.secondaryText)

                TextField("Name this timer", text: $name)
                    .font(Typography.rounded(18))
                    .textFieldStyle(.plain)
                    .focused($focused)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(Palette.amber.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 24)
                    .submitLabel(.done)
                    .onSubmit(save)

                Spacer()

                VStack(spacing: 10) {
                    GlassButton(title: "Save", systemImage: "checkmark",
                                style: .primary,
                                isEnabled: !trimmed.isEmpty, action: save)
                    GlassButton(title: "Cancel", style: .secondary) { dismiss() }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .onAppear { focused = true }
    }

    private var trimmed: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var summary: String {
        let m = configuration.totalSeconds / 60
        return "\(m) min · \(configuration.segmentCount) segment\(configuration.segmentCount == 1 ? "" : "s")"
    }

    private func save() {
        guard !trimmed.isEmpty else { return }
        onSave(trimmed)
        dismiss()
    }
}
