import SwiftUI

@main
struct Keynote_TimerApp: App {
    @State private var settings = SettingsStore()
    @State private var presets = PresetStore()
    @State private var notifications = NotificationService()
    @State private var engine: TimerEngine

    init() {
        NSUbiquitousKeyValueStore.default.synchronize()
        let settings = SettingsStore()
        let presets = PresetStore()
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
