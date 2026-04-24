import SwiftUI

/// Live, swipeable display of segment notes during a running timer.
/// Auto-tracks the engine's current segment, allows manual swipe with auto-snap-back.
struct SegmentNotesView: View {
    let notes: [[String]]
    let currentSegmentIndex: Int
    let segmentCount: Int

    @State private var displayedIndex: Int = 0
    @State private var isUserBrowsing: Bool = false
    @State private var snapBackWorkItem: DispatchWorkItem?

    private let snapBackDelay: TimeInterval = 5

    var body: some View {
        VStack(spacing: 10) {
            TabView(selection: $displayedIndex) {
                ForEach(0..<segmentCount, id: \.self) { i in
                    notesPage(for: i)
                        .tag(i)
                        .padding(.horizontal, 24)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxHeight: 150)

            pageDots
        }
        .onAppear { displayedIndex = currentSegmentIndex }
        .onChange(of: currentSegmentIndex) { _, newIndex in
            // Auto-advance only if user isn't actively browsing.
            if !isUserBrowsing {
                withAnimation(.easeInOut(duration: 0.35)) {
                    displayedIndex = newIndex
                }
            }
        }
        .onChange(of: displayedIndex) { _, newIndex in
            // If user swiped away from the live segment, schedule snap-back.
            if newIndex != currentSegmentIndex {
                isUserBrowsing = true
                scheduleSnapBack()
            } else {
                isUserBrowsing = false
                snapBackWorkItem?.cancel()
            }
        }
    }

    private var pageDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<segmentCount, id: \.self) { i in
                Circle()
                    .fill(i == displayedIndex ? Palette.deepOrange : Palette.secondaryText.opacity(0.35))
                    .frame(width: 6, height: 6)
                    .overlay(
                        Circle()
                            .strokeBorder(Palette.deepOrange.opacity(0.6), lineWidth: i == currentSegmentIndex && i != displayedIndex ? 1 : 0)
                            .frame(width: 9, height: 9)
                    )
            }
        }
    }

    @ViewBuilder
    private func notesPage(for index: Int) -> some View {
        let bullets = (index < notes.count) ? notes[index] : []
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("SEGMENT \(index + 1)")
                    .font(Typography.rounded(11, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(Palette.deepOrange)
                if index != currentSegmentIndex {
                    Text("• preview")
                        .font(Typography.rounded(10, weight: .medium))
                        .foregroundStyle(Palette.secondaryText)
                }
                Spacer()
            }
            if bullets.filter({ !$0.trimmingCharacters(in: .whitespaces).isEmpty }).isEmpty {
                Text("No notes for this segment")
                    .font(Typography.rounded(15))
                    .foregroundStyle(Palette.secondaryText.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(Array(bullets.enumerated()), id: \.offset) { _, bullet in
                    let trimmed = bullet.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty {
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Circle()
                                .fill(Palette.deepOrange)
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)
                            Text(trimmed)
                                .font(Typography.serif(18, weight: .regular))
                                .foregroundStyle(Palette.primaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Palette.amber.opacity(0.30), lineWidth: 1)
                )
        }
    }

    private func scheduleSnapBack() {
        snapBackWorkItem?.cancel()
        let work = DispatchWorkItem {
            withAnimation(.easeInOut(duration: 0.35)) {
                displayedIndex = currentSegmentIndex
            }
            isUserBrowsing = false
        }
        snapBackWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + snapBackDelay, execute: work)
    }
}
