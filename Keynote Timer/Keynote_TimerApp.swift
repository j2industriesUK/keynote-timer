import SwiftUI

@main
struct Keynote_TimerApp: App {
    @State private var settings = SettingsStore()
    @State private var presets = PresetStore()
    @State private var notifications = NotificationService()
    @State private var engine: TimerEngine

    init() {
        let settings = SettingsStore()
        let presets = PresetStore()
        // Restore the user's chosen storage backend
        if settings.iCloudSyncEnabled {
            NSUbiquitousKeyValueStore.default.synchronize()
            presets.switchStorage(to: true)
        }
        let notifications = NotificationService()
        let haptics = HapticsService(enabled: { settings.hapticsEnabled })
        let sound = SoundService(enabled: { settings.soundEnabled })
        let engine = TimerEngine(haptics: haptics, sound: sound, notifications: notifications)
        _settings = State(initialValue: settings)
        _presets = State(initialValue: presets)
        _notifications = State(initialValue: notifications)
        _engine = State(initialValue: engine)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settings)
                .environment(presets)
                .environment(notifications)
                .environment(engine)
                .tint(Palette.deepOrange)
        }
    }
}
