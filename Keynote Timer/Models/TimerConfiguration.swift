import Foundation

struct TimerConfiguration: Equatable, Hashable {
    var totalSeconds: Int
    var segmentCount: Int
    /// Up to 3 bullet strings per segment. Always sized to `segmentCount`.
    var segmentNotes: [[String]]

    static let maxNotesPerSegment = 3

    static let allowedTotals: [Int] = {
        // 1–4 min in 1-min steps, then 5–120 min in 5-min steps
        let short = Array(stride(from: 60,  through: 240,  by: 60))   // 1, 2, 3, 4 min
        let long  = Array(stride(from: 300, through: 7200, by: 300))  // 5, 10, 15…120 min
        return short + long
    }()

    static let allowedSegmentCounts: [Int] = Array(1...6)

    static let `default` = TimerConfiguration(
        totalSeconds: 900,
        segmentCount: 3,
        segmentNotes: Array(repeating: [], count: 3)
    )

    init(totalSeconds: Int, segmentCount: Int, segmentNotes: [[String]] = []) {
        self.totalSeconds = totalSeconds
        self.segmentCount = segmentCount
        self.segmentNotes = Self.normalize(notes: segmentNotes, count: segmentCount)
    }

    var segmentDuration: Int { totalSeconds / segmentCount }

    /// Array of segment end-times in seconds from start (cumulative), covering rounding remainders in final segment.
    var segmentBoundaries: [Int] {
        let base = segmentDuration
        var result: [Int] = []
        for i in 1..<segmentCount { result.append(base * i) }
        result.append(totalSeconds)
        return result
    }

    /// Returns 0-based segment index for a given elapsed second count.
    func segmentIndex(forElapsed elapsed: Int) -> Int {
        for (i, boundary) in segmentBoundaries.enumerated() where elapsed < boundary { return i }
        return segmentCount - 1
    }

    var isFinalSegmentIndex: Int { segmentCount - 1 }

    /// Mutate segmentCount while preserving any existing notes.
    mutating func setSegmentCount(_ newCount: Int) {
        segmentCount = newCount
        segmentNotes = Self.normalize(notes: segmentNotes, count: newCount)
    }

    static func normalize(notes: [[String]], count: Int) -> [[String]] {
        var result = notes
        if result.count < count {
            result.append(contentsOf: Array(repeating: [], count: count - result.count))
        } else if result.count > count {
            result = Array(result.prefix(count))
        }
        return result.map { Array($0.prefix(maxNotesPerSegment)) }
    }
}
