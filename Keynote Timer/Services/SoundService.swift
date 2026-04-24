import Foundation
import AVFoundation
#if canImport(AudioToolbox)
import AudioToolbox
#endif

enum SoundEvent {
    case warning
    case finalMinute
    case finished
}

struct SoundService {
    var enabled: () -> Bool = { false }

    func play(_ event: SoundEvent) {
        guard enabled() else { return }
        #if canImport(AudioToolbox)
        let id: SystemSoundID
        switch event {
        case .warning:     id = 1113 // SMS-received alert
        case .finalMinute: id = 1005 // new mail
        case .finished:    id = 1025 // calendar alert
        }
        AudioServicesPlaySystemSound(id)
        #endif
    }
}
