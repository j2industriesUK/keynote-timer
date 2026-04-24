import Foundation

struct TimerPreset: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var totalSeconds: Int
    var segmentCount: Int
    var segmentNotes: [[String]]
    var createdAt: Date

    init(id: UUID = UUID(), name: String, configuration: TimerConfiguration, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.totalSeconds = configuration.totalSeconds
        self.segmentCount = configuration.segmentCount
        self.segmentNotes = configuration.segmentNotes
        self.createdAt = createdAt
    }

    var configuration: TimerConfiguration {
        TimerConfiguration(
            totalSeconds: totalSeconds,
            segmentCount: segmentCount,
            segmentNotes: segmentNotes
        )
    }

    // Backwards-compatible decoding for presets saved before notes existed.
    enum CodingKeys: String, CodingKey {
        case id, name, totalSeconds, segmentCount, segmentNotes, createdAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(UUID.self, forKey: .id)
        self.name = try c.decode(String.self, forKey: .name)
        self.totalSeconds = try c.decode(Int.self, forKey: .totalSeconds)
        self.segmentCount = try c.decode(Int.self, forKey: .segmentCount)
        self.segmentNotes = (try? c.decode([[String]].self, forKey: .segmentNotes))
            ?? Array(repeating: [], count: self.segmentCount)
        self.createdAt = try c.decode(Date.self, forKey: .createdAt)
        // normalize length
        self.segmentNotes = TimerConfiguration.normalize(notes: self.segmentNotes, count: self.segmentCount)
    }
}
