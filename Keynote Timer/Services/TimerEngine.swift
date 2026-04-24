import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#endif

@Observable
final class TimerEngine {
    private(set) var configuration: TimerConfiguration = .default
    private(set) var phase: TimerPhase = .idle
    private(set) var elapsed: TimeInterval = 0

    // Alert flags
    private(set) var isInFinalSegment: Bool = false
    private(set) var isInFinalMinute: Bool = false
    private(set) var currentSegmentIndex: Int = 0

    // Dependencies
    private let haptics: HapticsService
    private let sound: SoundService
    private let notifications: NotificationService

    // Internal timing
    private var startDate: Date?
    private var pausedAccum: TimeInterval = 0
    private var pausedAt: Date?
    private var ticker: AnyCancellable?

    init(haptics: HapticsService, sound: SoundService, notifications: NotificationService) {
        self.haptics = haptics
        self.sound = sound
        self.notifications = notifications
    }

    var remaining: TimeInterval {
        max(0, TimeInterval(configuration.totalSeconds) - elapsed)
    }

    var progress: Double {
        guard configuration.totalSeconds > 0 else { return 0 }
        return min(1, elapsed / TimeInterval(configuration.totalSeconds))
    }

    func prepare(with configuration: TimerConfiguration) {
        stop()
        self.configuration = configuration
        self.phase = .idle
        self.elapsed = 0
        self.isInFinalSegment = false
        self.isInFinalMinute = false
        self.currentSegmentIndex = 0
    }

    func start() {
        guard phase == .idle || phase == .paused else { return }
        let now = Date()
        if phase == .idle {
            startDate = now
            pausedAccum = 0
        } else if let pausedAt {
            pausedAccum += now.timeIntervalSince(pausedAt)
            self.pausedAt = nil
        }
        phase = .running
        setIdleTimerDisabled(true)
        Task { await notifications.requestAuthorizationIfNeeded() }
        notifications.schedule(for: configuration, startingAt: now.addingTimeInterval(-elapsed))
        startTicker()
    }

    func pause() {
        guard phase == .running else { return }
        pausedAt = Date()
        phase = .paused
        ticker?.cancel()
        notifications.cancelAll()
        setIdleTimerDisabled(false)
    }

    func reset() {
        stop()
        elapsed = 0
        isInFinalSegment = false
        isInFinalMinute = false
        currentSegmentIndex = 0
        phase = .idle
    }

    func stop() {
        ticker?.cancel()
        ticker = nil
        startDate = nil
        pausedAt = nil
        pausedAccum = 0
        notifications.cancelAll()
        setIdleTimerDisabled(false)
    }

    private func startTicker() {
        ticker?.cancel()
        ticker = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    private func tick() {
        guard phase == .running, let startDate else { return }
        let now = Date()
        let newElapsed = now.timeIntervalSince(startDate) - pausedAccum
        elapsed = min(newElapsed, TimeInterval(configuration.totalSeconds))

        // Segment transition detection (integer seconds to avoid jitter)
        let elapsedSec = Int(elapsed)
        let newSegment = configuration.segmentIndex(forElapsed: elapsedSec)
        if newSegment != currentSegmentIndex {
            currentSegmentIndex = newSegment
            haptics.fire(.segmentTransition)
            if newSegment == configuration.isFinalSegmentIndex && !isInFinalSegment {
                isInFinalSegment = true
                haptics.fire(.finalSegment)
                sound.play(.warning)
            }
        }

        // Final minute check
        if remaining <= 60 && !isInFinalMinute {
            isInFinalMinute = true
            haptics.fire(.finalMinute)
            sound.play(.finalMinute)
        }

        // Finished
        if elapsed >= TimeInterval(configuration.totalSeconds) {
            finish()
        }
    }

    private func finish() {
        ticker?.cancel()
        ticker = nil
        phase = .finished
        elapsed = TimeInterval(configuration.totalSeconds)
        haptics.fire(.finished)
        sound.play(.finished)
        setIdleTimerDisabled(false)
    }

    private func setIdleTimerDisabled(_ disabled: Bool) {
        #if canImport(UIKit) && !os(macOS)
        UIApplication.shared.isIdleTimerDisabled = disabled
        #endif
    }
}
