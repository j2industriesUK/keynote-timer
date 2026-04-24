import SwiftUI

@Observable
final class PresetStore {
    private static let key = "presets.v1"
    private static let icloud = NSUbiquitousKeyValueStore.default

    private(set) var presets: [TimerPreset] = []
    private(set) var iCloudEnabled: Bool = false

    init() {
        // Default: load from local storage
        load()
    }

    // MARK: - Public mutations

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

    // MARK: - Storage switching

    /// Switch between local (UserDefaults) and iCloud (NSUbiquitousKeyValueStore) storage.
    /// Migrates current presets into the destination store if it is empty.
    func switchStorage(to useICloud: Bool) {
        guard useICloud != iCloudEnabled else { return }

        if useICloud {
            enableICloud()
        } else {
            disableICloud()
        }
    }

    // MARK: - Private

    private func load() {
        let data: Data?
        if iCloudEnabled {
            data = Self.icloud.data(forKey: Self.key)
        } else {
            data = UserDefaults.standard.data(forKey: Self.key)
        }
        guard let data,
              let decoded = try? JSONDecoder().decode([TimerPreset].self, from: data) else { return }
        presets = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(presets) else { return }
        if iCloudEnabled {
            Self.icloud.set(data, forKey: Self.key)
            Self.icloud.synchronize()
        } else {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }

    private func enableICloud() {
        // Migrate current local presets into iCloud if iCloud is empty
        let cloudData = Self.icloud.data(forKey: Self.key)
        if cloudData == nil, let localData = UserDefaults.standard.data(forKey: Self.key) {
            Self.icloud.set(localData, forKey: Self.key)
            Self.icloud.synchronize()
        }

        iCloudEnabled = true

        // Pull freshest data from iCloud (may have presets from other devices)
        Self.icloud.synchronize()
        load()

        // Listen for changes pushed from other devices
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(icloudDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: Self.icloud
        )
    }

    private func disableICloud() {
        // Persist current presets (which may have been synced from iCloud) to local store
        if let data = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }

        iCloudEnabled = false
        NotificationCenter.default.removeObserver(
            self,
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: Self.icloud
        )
    }

    @objc private func icloudDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int,
              let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String],
              changedKeys.contains(Self.key) else { return }

        let validReasons = [
            NSUbiquitousKeyValueStoreServerChange,
            NSUbiquitousKeyValueStoreInitialSyncChange,
            NSUbiquitousKeyValueStoreAccountChange
        ]
        guard validReasons.contains(reason) else { return }

        DispatchQueue.main.async { self.load() }
    }
}
