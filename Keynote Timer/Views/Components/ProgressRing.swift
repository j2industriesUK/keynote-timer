import SwiftUI

struct ProgressRing: View {
    let progress: Double           // 0…1 overall
    let segmentCount: Int
    let currentSegmentIndex: Int
    let isInFinalSegment: Bool
    let isInFinalMinute: Bool

    // Gap between segment arcs in degrees
    private let gap: Double = 5

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let lw   = size * 0.085

            ZStack {
                // ── Background tracks ─────────────────────────────────
                ForEach(0..<segmentCount, id: \.self) { i in
                    arc(segment: i)
                        .stroke(
                            Palette.orange.opacity(0.14),
                            style: StrokeStyle(lineWidth: lw, lineCap: .butt)
                        )
                        .rotationEffect(.degrees(-90))
                }

                // ── Completed segments ────────────────────────────────
                ForEach(0..<segmentCount, id: \.self) { i in
                    if i < currentSegmentIndex {
                        arc(segment: i)
                            .stroke(
                                segmentFill(i),
                                style: StrokeStyle(lineWidth: lw, lineCap: .butt)
                            )
                            .rotationEffect(.degrees(-90))
                    }
                }

                // ── Current segment (partial fill) ────────────────────
                let (cs, ce) = segFraction(currentSegmentIndex)
                let filled = cs + (ce - cs) * progressWithinSegment
                Arc(from: cs, to: max(cs + 0.0005, filled))
                    .stroke(
                        segmentFill(currentSegmentIndex),
                        style: StrokeStyle(lineWidth: lw, lineCap: .butt)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: filled)

                // ── Watch-face tick marks ─────────────────────────────
                ForEach(0..<12, id: \.self) { i in
                    let major = i % 3 == 0
                    Capsule()
                        .fill(Palette.primaryText.opacity(major ? 0.45 : 0.20))
                        .frame(width: major ? 3 : 2,
                               height: major ? size * 0.038 : size * 0.022)
                        .offset(y: -(size / 2 - lw - 7))
                        .rotationEffect(.degrees(Double(i) * 30))
                }

                // ── Segment boundary markers ──────────────────────────
                ForEach(1..<segmentCount, id: \.self) { i in
                    let angle = Double(i) * 360.0 / Double(segmentCount)
                    Capsule()
                        .fill(Palette.background.opacity(0.9))
                        .frame(width: lw + 2, height: gap * .pi * size / 360 + 4)
                        .rotationEffect(.degrees(angle - 90))
                        .offset(y: -(size / 2 - lw / 2))
                        .rotationEffect(.degrees(angle))
                }
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Helpers

    private func segFraction(_ i: Int) -> (Double, Double) {
        let per = 1.0 / Double(segmentCount)
        let gapFrac = gap / 360.0
        let start = Double(i) * per + gapFrac / 2
        let end   = Double(i + 1) * per - gapFrac / 2
        return (start, end)
    }

    private func arc(segment i: Int) -> Arc {
        let (s, e) = segFraction(i)
        return Arc(from: s, to: e)
    }

    private var progressWithinSegment: Double {
        guard segmentCount > 0 else { return 0 }
        let frac = 1.0 / Double(segmentCount)
        let segStart = Double(currentSegmentIndex) * frac
        return min(1, max(0, (progress - segStart) / frac))
    }

    private func segmentFill(_ i: Int) -> AnyShapeStyle {
        if isInFinalMinute {
            return AnyShapeStyle(LinearGradient(
                colors: [Palette.ember, Palette.deepOrange],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))
        }
        if isInFinalSegment && i == segmentCount - 1 {
            return AnyShapeStyle(LinearGradient(
                colors: [Palette.amber, Palette.ember],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))
        }
        // Subtle per-segment shift across the warm palette.
        // Use the natural amber → orange → deepOrange progression, picking a
        // pair of adjacent palette stops based on segment position.
        let stops: [Color] = [Palette.amber, Palette.orange, Palette.deepOrange]
        let t: Double = segmentCount > 1 ? Double(i) / Double(segmentCount - 1) : 0.5
        let scaled = t * Double(stops.count - 1)
        let lo = Int(scaled.rounded(.down))
        let hi = min(lo + 1, stops.count - 1)
        return AnyShapeStyle(LinearGradient(
            colors: [stops[lo], stops[hi]],
            startPoint: .topLeading, endPoint: .bottomTrailing
        ))
    }
}

// MARK: - Arc shape
private struct Arc: Shape {
    var from: Double  // 0…1 fraction of circle
    var to:   Double

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(from, to) }
        set { from = newValue.first; to = newValue.second }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: min(rect.width, rect.height) / 2,
            startAngle: .radians(from * 2 * .pi),
            endAngle:   .radians(to   * 2 * .pi),
            clockwise: false
        )
        return p
    }
}
