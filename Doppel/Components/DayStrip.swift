import SwiftUI

/// A continuous day strip spanning roughly ±400 days around today — scroll
/// past the end of a month and you're simply in the next one, no button
/// required. Selection is tap-only and stays independent of scroll
/// position; whatever date is currently centered is reported via
/// `visibleDate` so a parent can show it as a month/year label.
struct DayStrip: View {
    @Binding var visibleDate: Date
    var onSelect: (Date) -> Void = { _ in }

    private let calendar = Calendar.current
    private let days: [Date]

    @State private var selectedDate: Date

    init(visibleDate: Binding<Date>, onSelect: @escaping (Date) -> Void = { _ in }) {
        _visibleDate = visibleDate
        self.onSelect = onSelect

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        days = (-400...400).compactMap { cal.date(byAdding: .day, value: $0, to: today) }
        _selectedDate = State(initialValue: today)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 6) {
                ForEach(days, id: \.self) { day in
                    DayCell(date: day, isSelected: calendar.isDate(day, inSameDayAs: selectedDate))
                        .id(day)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                selectedDate = day
                                visibleDate = day
                            }
                            onSelect(day)
                        }
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, 130)
        }
        .scrollPosition(id: visibleDateBinding, anchor: .center)
        .frame(height: 68)
        .mask(edgeFade)
    }

    private var visibleDateBinding: Binding<Date?> {
        Binding(get: { visibleDate }, set: { if let newValue = $0 { visibleDate = newValue } })
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

private struct DayCell: View {
    let date: Date
    let isSelected: Bool

    private var dayNumber: String { date.formatted(.dateTime.day()) }

    var body: some View {
        Text(dayNumber)
            .font(.system(size: isSelected ? 28 : 20, weight: isSelected ? .heavy : .bold, design: .rounded))
            .foregroundStyle(isSelected ? DoppelColor.violet : DoppelColor.textTertiary)
            .frame(width: 52, height: 68)
    }
}

#Preview {
    ZStack {
        DoppelColor.void.ignoresSafeArea()
        DayStrip(visibleDate: .constant(Calendar.current.startOfDay(for: Date())))
    }
}
