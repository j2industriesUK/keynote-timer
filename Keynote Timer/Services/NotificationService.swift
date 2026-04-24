import Foundation
import UserNotifications

@Observable
final class NotificationService {
    private let center = UNUserNotificationCenter.current()
    private let idFinalSegment = "keynote.finalSegment"
    private let idFinalMinute = "keynote.finalMinute"
    private let idFinished = "keynote.finished"

    /// Request authorization if not yet determined. Returns final granted state.
    @discardableResult
    func requestAuthorizationIfNeeded() async -> Bool {
        let current = await center.notificationSettings()
        switch current.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        @unknown default:
            return false
        }
    }

    /// Schedule notifications relative to now for the given configuration and start time.
    func schedule(for configuration: TimerConfiguration, startingAt start: Date) {
        cancelAll()
        let total = TimeInterval(configuration.totalSeconds)
        let segmentDuration = total / Double(configuration.segmentCount)
        let finalSegmentStart = total - segmentDuration
        let finalMinuteStart = max(0, total - 60)

        // Only schedule final-segment warning if it's distinct from final minute and > 0 from now
        if finalSegmentStart > 0 && abs(finalSegmentStart - finalMinuteStart) > 1 {
            schedule(id: idFinalSegment,
                     after: finalSegmentStart,
                     title: "Final segment",
                     body: "You've entered the last segment of your talk.")
        }
        if finalMinuteStart > 0 {
            schedule(id: idFinalMinute,
                     after: finalMinuteStart,
                     title: "One minute left",
                     body: "Sixty seconds remaining — wrap up.")
        }
        schedule(id: idFinished,
                 after: total,
                 title: "Time's up",
                 body: "Your keynote timer has ended.")
    }

    func cancelAll() {
        center.removePendingNotificationRequests(withIdentifiers: [idFinalSegment, idFinalMinute, idFinished])
    }

    private func schedule(id: String, after interval: TimeInterval, title: String, body: String) {
        guard interval > 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }
}
