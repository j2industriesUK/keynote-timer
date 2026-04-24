import SwiftUI

@Observable
final class PresetStore {
    private static let key = "presets.v1"
    private static let icloud = NSUbiquitousKeyValueStore.default
    private(set) var presets: [TimerPreset] = []

    init() {
        migrateFromUserDefaultsIfNeeded()
        load()
        // Pull latest values from iCloud before showing UI
        Self.icloud.synchronize()
        // Listen for changes pushed from other devices
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(icloudDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: Self.icloud
        )
    }

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

    // MARK: - Private

    private func load() {
        guard let data = Self.icloud.data(forKey: Self.key) else { return }
        if let decoded = try? JSONDecoder().decode([TimerPreset].self, from: data) {
            presets = decoded
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(presets) {
            Self.icloud.set(data, forKey: Self.key)
            Self.icloud.synchronize()
        }
    }

    /// One-time migration: copy existing UserDefaults presets into iCloud KV store.
    private func migrateFromUserDefaultsIfNeeded() {
        let localData = UserDefaults.standard.data(forKey: Self.key)
        let cloudData = Self.icloud.data(forKey: Self.key)
        // Only migrate if local data exists and iCloud is empty
        guard let local = localData, cloudData == nil else { return }
        Self.icloud.set(local, forKey: Self.key)
        Self.icloud.synchronize()
        UserDefaults.standard.removeObject(forKey: Self.key)
    }

    @objc private func icloudDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int,
              let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String],
              changedKeys.contains(Self.key) else { return }

        // Reasons: server change, initial sync, quota violation
        let validReasons = [
            NSUbiquitousKeyValueStoreServerChange,
            NSUbiquitousKeyValueStoreInitialSyncChange,
            NSUbiquitousKeyValueStoreAccountChange
        ]
        guard validReasons.contains(reason) else { return }

        DispatchQueue.main.async { self.load() }
    }
}
