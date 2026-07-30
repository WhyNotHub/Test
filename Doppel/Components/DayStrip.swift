import SwiftUI
import UIKit

/// A continuous day strip spanning roughly ±400 days around today — scroll
/// past the end of a month and you're simply in the next one, no button
/// required. There's no separate "selected" state: the highlighted day is
/// whichever one is centered, but it only commits once scrolling settles
/// (debounced ~140ms of no movement) rather than flickering between cells
/// on every scroll tick — a live per-frame highlight looked chaotic during
/// a fast drag. A subtle selection haptic fires on each settle. Tapping a
/// day scrolls it to center; the same settle logic picks up the highlight.
struct DayStrip: View {
    var onSelect: (Date) -> Void = { _ in }

    private let calendar = Calendar.current
    private let days: [Date]
    private let feedbackGenerator = UISelectionFeedbackGenerator()

    @State private var scrollTrackedDate: Date?
    @State private var currentDate: Date
    @State private var settleTask: Task<Void, Never>?

    init(onSelect: @escaping (Date) -> Void = { _ in }) {
        self.onSelect = onSelect

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        days = (-400...400).compactMap { cal.date(byAdding: .day, value: $0, to: today) }
        _currentDate = State(initialValue: today)
        _scrollTrackedDate = State(initialValue: today)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 6) {
                ForEach(Array(days.enumerated()), id: \.element) { index, day in
                    DayCell(
                        date: day,
                        isSelected: calendar.isDate(day, inSameDayAs: currentDate),
                        activities: DayActivity.demo(for: index)
                    )
                    .id(day)
                    .onTapGesture {
                        scrollTrackedDate = day
                    }
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, 130)
        }
        .scrollPosition(id: $scrollTrackedDate, anchor: .center)
        .scrollTargetBehavior(.viewAligned)
        .frame(height: 84)
        .mask(edgeFade)
        .onChange(of: scrollTrackedDate) { _, newValue in
            settleTask?.cancel()
            guard let newValue else { return }
            settleTask = Task {
                try? await Task.sleep(nanoseconds: 140_000_000)
                guard !Task.isCancelled else { return }
                withAnimation(.easeOut(duration: 0.3)) {
                    currentDate = newValue
                }
                feedbackGenerator.selectionChanged()
                onSelect(newValue)
            }
        }
    }

    private var edgeFade: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: 0.05),
                .init(color: .black, location: 0.95),
                .init(color: .clear, location: 1)
            ],
            startPoint: .leading, endPoint: .trailing
        )
    }
}

/// Placeholder category for the badges under each day — not backed by real
/// tracked data yet. `demo(for:)` exists purely to make the concept visible
/// while the design is being evaluated; swap it for real per-day activity
/// data once that exists.
enum DayActivity: CaseIterable, Hashable {
    case gym, work, school

    var color: Color {
        switch self {
        case .gym: DoppelColor.lime
        case .work: DoppelColor.violet
        case .school: DoppelColor.ice
        }
    }

    static func demo(for index: Int) -> [DayActivity] {
        var activities: [DayActivity] = []
        if index % 4 == 1 { activities.append(.work) }
        if index % 5 == 2 { activities.append(.gym) }
        if index % 9 == 4 { activities.append(.school) }
        return activities
    }
}

private struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let activities: [DayActivity]

    private var weekday: String { date.formatted(.dateTime.weekday(.abbreviated)) }
    private var dayNumber: String { date.formatted(.dateTime.day()) }

    var body: some View {
        VStack(spacing: 4) {
            Text(weekday.uppercased())
                .font(.system(size: 9.5, weight: .bold, design: .rounded))
                .foregroundStyle(isSelected ? DoppelColor.textSecondary : DoppelColor.textTertiary)

            Text(dayNumber)
                .font(.system(size: isSelected ? 28 : 20, weight: isSelected ? .heavy : .bold, design: .rounded))
                .foregroundStyle(isSelected ? DoppelColor.violet : DoppelColor.textTertiary)
                .animation(.easeOut(duration: 0.3), value: isSelected)

            HStack(spacing: 3) {
                ForEach(activities, id: \.self) { activity in
                    Circle()
                        .fill(activity.color)
                        .frame(width: 5, height: 5)
                }
            }
            .frame(height: 6)
        }
        .frame(width: 52, height: 84)
    }
}

#Preview {
    ZStack {
        DoppelColor.void.ignoresSafeArea()
        DayStrip()
    }
}
