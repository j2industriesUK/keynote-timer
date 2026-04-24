import SwiftUI

struct SettingsView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(PresetStore.self) private var presets
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var settings = settings
        NavigationStack {
            ZStack {
                WarmBackground()
                Form {
                    Section {
                        Picker("Theme", selection: $settings.themePreference) {
                            ForEach(ThemePreference.allCases) { pref in
                                Text(pref.label).tag(pref)
                            }
                        }
                        .pickerStyle(.segmented)
                    } header: {
                        Text("Appearance")
                    } footer: {
                        Text("Dark mode uses deep blues and warm orange accents. The final-minute alert temporarily cycles light/dark regardless of this setting.")
                    }

                    Section {
                        Toggle("Haptics", isOn: $settings.hapticsEnabled)
                        Toggle("Sound alerts", isOn: $settings.soundEnabled)
                    } header: {
                        Text("Feedback")
                    } footer: {
                        Text("Haptics and subtle chimes play at segment transitions, the final segment, the final minute, and when time is up. Sound respects the device silent switch.")
                    }

                    Section {
                        Toggle(isOn: Binding(
                            get: { settings.iCloudSyncEnabled },
                            set: { newValue in
                                settings.iCloudSyncEnabled = newValue
                                presets.switchStorage(to: newValue)
                            }
                        )) {
                            Label("iCloud Sync", systemImage: "icloud")
                        }
                    } header: {
                        Text("Saved Timers")
                    } footer: {
                        Text(settings.iCloudSyncEnabled
                             ? "Your saved timers are synced across all your devices via iCloud."
                             : "Your saved timers are stored locally on this device only.")
                    }

                    Section {
                        LabeledContent("Version", value: Bundle.main.shortVersion)
                        LabeledContent("Build", value: Bundle.main.buildNumber)
                    } header: {
                        Text("About")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
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
        }
    }
}

extension Bundle {
    var shortVersion: String {
        (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "—"
    }
    var buildNumber: String {
        (infoDictionary?["CFBundleVersion"] as? String) ?? "—"
    }
}
