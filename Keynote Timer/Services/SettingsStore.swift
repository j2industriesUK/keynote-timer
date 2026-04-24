import SwiftUI

enum ThemePreference: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var label: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

@Observable
final class SettingsStore {
    static let hapticsKey = "settings.hapticsEnabled"
    static let soundKey = "settings.soundEnabled"
    static let themeKey = "settings.themePreference"
    static let iCloudSyncKey = "settings.iCloudSyncEnabled"

    var hapticsEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticsEnabled, forKey: Self.hapticsKey) }
    }
    var soundEnabled: Bool {
        didSet { UserDefaults.standard.set(soundEnabled, forKey: Self.soundKey) }
    }
    var themePreference: ThemePreference {
        didSet { UserDefaults.standard.set(themePreference.rawValue, forKey: Self.themeKey) }
    }
    var iCloudSyncEnabled: Bool {
        didSet { UserDefaults.standard.set(iCloudSyncEnabled, forKey: Self.iCloudSyncKey) }
    }

    init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Self.hapticsKey) == nil {
            defaults.set(true, forKey: Self.hapticsKey)
        }
        self.hapticsEnabled = defaults.bool(forKey: Self.hapticsKey)
        self.soundEnabled = defaults.bool(forKey: Self.soundKey)
        let raw = defaults.string(forKey: Self.themeKey) ?? ThemePreference.system.rawValue
        self.themePreference = ThemePreference(rawValue: raw) ?? .system
        self.iCloudSyncEnabled = defaults.bool(forKey: Self.iCloudSyncKey)
    }
}
