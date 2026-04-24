import SwiftUI

/// Editor that lets the user attach up to 3 short bullet notes to each segment.
struct SegmentNotesEditor: View {
    @Binding var notes: [[String]]
    let segmentCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("SEGMENT NOTES")
                    .font(Typography.serif(11, weight: .semibold))
                    .tracking(3)
                    .foregroundStyle(Palette.deepOrange)
                Spacer()
                Text("Up to 3 bullets each")
                    .font(Typography.rounded(11))
                    .foregroundStyle(Palette.secondaryText)
            }

            ForEach(0..<segmentCount, id: \.self) { i in
                segmentBlock(index: i)
            }
        }
        .onAppear { sync() }
        .onChange(of: segmentCount) { _, _ in sync() }
    }

    private func sync() {
        notes = TimerConfiguration.normalize(notes: notes, count: segmentCount)
    }

    private func segmentBlock(index i: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Segment \(i + 1)")
                .font(Typography.serif(15, weight: .medium))
                .foregroundStyle(Palette.primaryText)

            ForEach(0..<bulletsCount(for: i), id: \.self) { j in
                bulletField(seg: i, idx: j)
            }

            if bulletsCount(for: i) < TimerConfiguration.maxNotesPerSegment {
                Button {
                    addBullet(seg: i)
                } label: {
                    Label("Add bullet", systemImage: "plus.circle.fill")
                        .font(Typography.rounded(13, weight: .medium))
                        .foregroundStyle(Palette.deepOrange)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Palette.amber.opacity(0.30), lineWidth: 1)
                )
        }
    }

    private func bulletsCount(for i: Int) -> Int {
        guard i < notes.count else { return 0 }
        return notes[i].count
    }

    private func bulletField(seg i: Int, idx j: Int) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Palette.deepOrange)
                .frame(width: 5, height: 5)
            TextField("Bullet \(j + 1)", text: bulletBinding(seg: i, idx: j), axis: .vertical)
                .lineLimit(1...3)
                .font(Typography.rounded(15))
                .foregroundStyle(Palette.primaryText)
            Button {
                removeBullet(seg: i, idx: j)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Palette.secondaryText.opacity(0.6))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove bullet")
        }
        .padding(.vertical, 4)
    }

    private func bulletBinding(seg i: Int, idx j: Int) -> Binding<String> {
        Binding(
            get: {
                guard i < notes.count, j < notes[i].count else { return "" }
                return notes[i][j]
            },
            set: { newValue in
                guard i < notes.count, j < notes[i].count else { return }
                notes[i][j] = newValue
            }
        )
    }

    private func addBullet(seg i: Int) {
        guard i < notes.count else { return }
        guard notes[i].count < TimerConfiguration.maxNotesPerSegment else { return }
        notes[i].append("")
    }

    private func removeBullet(seg i: Int, idx j: Int) {
        guard i < notes.count, j < notes[i].count else { return }
        notes[i].remove(at: j)
    }
}
