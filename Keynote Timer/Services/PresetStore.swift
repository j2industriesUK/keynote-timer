import SwiftUI

@Observable
final class PresetStore {
    private static let key = "presets.v1"
    private(set) var presets: [TimerPreset] = []

    init() { load() }

    func add(name: String, configuration: TimerConfiguration) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let preset = TimerPreset(name: trimmed, configuration: configuration)
        presets.insert(preset, at: 0)
        save()
    }

    func remove(_ preset: TimerPreset) {
        presets.removeAll { $0.id == preset.id }
        save()
    }

    func rename(_ preset: TimerPreset, to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let i = presets.firstIndex(where: { $0.id == preset.id }) else { return }
        presets[i].name = trimmed
        save()
    }

    /// Replace a preset's content while preserving its id and createdAt.
    func update(_ preset: TimerPreset, name: String, configuration: TimerConfiguration) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let i = presets.firstIndex(where: { $0.id == preset.id }) else { return }
        var updated = TimerPreset(id: preset.id, name: trimmed, configuration: configuration, createdAt: preset.createdAt)
        updated.segmentNotes = TimerConfiguration.normalize(notes: configuration.segmentNotes, count: configuration.segmentCount)
        presets[i] = updated
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.key) else { return }
        if let decoded = try? JSONDecoder().decode([TimerPreset].self, from: data) {
            presets = decoded
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }
}
