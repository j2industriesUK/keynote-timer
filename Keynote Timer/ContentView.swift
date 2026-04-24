import SwiftUI
import Combine

enum AppScreen: Hashable {
    case splash
    case setup(TimerConfiguration)
    case timer
}

struct ContentView: View {
    @Environment(PresetStore.self) private var presets
    @Environment(TimerEngine.self) private var engine
    @Environment(SettingsStore.self) private var settings

    @State private var screen: AppScreen = .splash
    @State private var showSettings = false
    @State private var showSavedTimers = false

    // Final-minute dark/light cycling — fires for exactly 3 s then stops.
    @State private var alertSchemeDark = false
    @State private var alertFlashActive = false        // true only during the 3-s window
    @State private var alertFlashStartedAt: Date? = nil
    private let alertTicker = Timer.publish(every: 0.55, on: .main, in: .common).autoconnect()
    private let flashDuration: TimeInterval = 3.0

    var body: some View {
        ZStack {
            switch screen {
            case .splash:
                SplashView(
                    onBegin: { screen = .setup(.default) },
                    onSelectPreset: { preset in
                        engine.prepare(with: preset.configuration)
                        screen = .timer
                    },
                    onOpenSettings:    { showSettings = true },
                    onOpenSavedTimers: { showSavedTimers = true }
                )
                .transition(.opacity)

            case .setup(let config):
                SetupView(
                    configuration: config,
                    onStart: { cfg in
                        engine.prepare(with: cfg)
                        screen = .timer
                    },
                    onBack: { screen = .splash },
                    onSavePreset: { name, cfg in
                        presets.add(name: name, configuration: cfg)
                    }
                )
                .transition(.opacity)

            case .timer:
                TimerView(onBack: { screen = .splash })
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: screen)
        .preferredColorScheme(alertColorScheme)
        // Detect when final minute first becomes active — start the 3-s window.
        .onChange(of: engine.isInFinalMinute) { _, nowActive in
            if nowActive && engine.phase == .running {
                alertFlashStartedAt = Date()
                alertFlashActive = true
                alertSchemeDark = false
            } else {
                alertFlashActive = false
                alertFlashStartedAt = nil
                alertSchemeDark = false
            }
        }
        // Ticker drives the toggle — but only during the 3-s window.
        .onReceive(alertTicker) { now in
            guard alertFlashActive,
                  engine.isInFinalMinute,
                  engine.phase == .running else {
                if !engine.isInFinalMinute || engine.phase != .running {
                    alertFlashActive = false
                    alertSchemeDark = false
                }
                return
            }
            if let start = alertFlashStartedAt,
               now.timeIntervalSince(start) >= flashDuration {
                // 3 s elapsed — stop flashing, return to user's chosen scheme.
                alertFlashActive = false
                alertSchemeDark = false
                return
            }
            alertSchemeDark.toggle()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSavedTimers) {
            PresetsListView { preset in
                engine.prepare(with: preset.configuration)
                screen = .timer
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    private var alertColorScheme: ColorScheme? {
        if alertFlashActive && engine.isInFinalMinute && engine.phase == .running {
            return alertSchemeDark ? .dark : .light
        }
        return settings.themePreference.colorScheme
    }
}
