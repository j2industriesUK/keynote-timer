import SwiftUI

struct PresetsListView: View {
    @Environment(PresetStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let onSelect: (TimerPreset) -> Void

    @State private var editTarget: TimerPreset?

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackground()
                if store.presets.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.presets) { preset in
                            row(preset)
                                .listRowBackground(Color.clear)
                                .listRowSeparatorTint(Palette.amber.opacity(0.3))
                        }
                        .onDelete { offsets in
                            for i in offsets { store.remove(store.presets[i]) }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Saved Timers")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Palette.deepOrange)
                }
            }
            #else
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Palette.deepOrange)
                }
            }
            #endif
            .sheet(item: $editTarget) { preset in
                EditPresetSheet(preset: preset) { name, config in
                    store.update(preset, name: name, configuration: config)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "bookmark")
                .font(.system(size: 40))
                .foregroundStyle(Palette.amber.opacity(0.6))
            Text("No saved timers")
                .font(Typography.serif(20, weight: .medium))
                .foregroundStyle(Palette.primaryText)
            Text("Save favourite timer configurations for quick access.")
                .font(Typography.rounded(14))
                .foregroundStyle(Palette.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private func row(_ preset: TimerPreset) -> some View {
        Button {
            onSelect(preset)
            dismiss()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(Palette.orangeGradient.opacity(0.25))
                        .frame(width: 42, height: 42)
                    Image(systemName: "timer")
                        .foregroundStyle(Palette.deepOrange)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(preset.name)
                        .font(Typography.serif(18, weight: .medium))
                        .foregroundStyle(Palette.primaryText)
                    Text(summary(preset))
                        .font(Typography.rounded(13))
                        .foregroundStyle(Palette.secondaryText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Palette.secondaryText)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) { store.remove(preset) } label: {
                Label("Delete", systemImage: "trash")
            }
            Button {
                editTarget = preset
            } label: { Label("Edit", systemImage: "pencil") }
                .tint(Palette.amber)
        }
    }

    private func summary(_ p: TimerPreset) -> String {
        let m = p.totalSeconds / 60
        let bulletCount = p.segmentNotes.flatMap { $0 }.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count
        let notesPart = bulletCount > 0 ? " · \(bulletCount) note\(bulletCount == 1 ? "" : "s")" : ""
        return "\(m) min · \(p.segmentCount) segment\(p.segmentCount == 1 ? "" : "s")\(notesPart)"
    }
}

// MARK: - Edit sheet

struct EditPresetSheet: View {
    let preset: TimerPreset
    let onSave: (String, TimerConfiguration) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var configuration: TimerConfiguration

    init(preset: TimerPreset, onSave: @escaping (String, TimerConfiguration) -> Void) {
        self.preset = preset
        self.onSave = onSave
        _name = State(initialValue: preset.name)
        _configuration = State(initialValue: preset.configuration)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WarmBackground()
                ScrollView {
                    VStack(spacing: 18) {
                        TextField("Timer name", text: $name)
                            .font(Typography.serif(20, weight: .medium))
                            .foregroundStyle(Palette.primaryText)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .background {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .strokeBorder(Palette.amber.opacity(0.4), lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 12)

                        GlassCard {
                            DurationPicker(totalSeconds: $configuration.totalSeconds)
                        }
                        .padding(.horizontal, 24)

                        GlassCard {
                            SegmentPicker(count: $configuration.segmentCount)
                        }
                        .padding(.horizontal, 24)

                        SegmentNotesEditor(
                            notes: $configuration.segmentNotes,
                            segmentCount: configuration.segmentCount
                        )
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 24)
                }
            }
            .onChange(of: configuration.segmentCount) { _, newCount in
                configuration.segmentNotes = TimerConfiguration.normalize(
                    notes: configuration.segmentNotes, count: newCount
                )
            }
            .navigationTitle("Edit timer")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Palette.secondaryText)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(name, configuration)
                        dismiss()
                    }
                    .foregroundStyle(Palette.deepOrange)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                #else
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name, configuration)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                #endif
            }
        }
    }
}
