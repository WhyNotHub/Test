import SwiftUI

/// A single-line, horizontally scrolling calendar: the selected day centers
/// itself in the strip. Selection is color-only — a bigger, gradient-filled
/// number — no pill, no ring, no extra chrome. Chevrons page whole months.
struct DayStrip: View {
    var onSelect: (Date) -> Void = { _ in }

    @State private var activeMonth = Calendar.current.doppelStartOfMonth(for: Date())
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())

    private let calendar = Calendar.current

    private var monthTitle: String {
        activeMonth.formatted(.dateTime.month(.wide).year())
    }

    private var days: [Date] {
        calendar.doppelDaysInMonth(for: activeMonth)
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(monthTitle.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(DoppelColor.textSecondary)
                .tracking(1.4)

            HStack(spacing: 0) {
                stepButton(system: "chevron.left") { shiftMonth(-1) }

                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 2) {
                            ForEach(days, id: \.self) { day in
                                DayCell(date: day, isSelected: calendar.isDate(day, inSameDayAs: selectedDate))
                                    .id(day)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                            selectedDate = day
                                        }
                                        onSelect(day)
                                    }
                            }
                        }
                        .padding(.horizontal, 130)
                    }
                    .onAppear {
                        proxy.scrollTo(selectedDate, anchor: .center)
                    }
                    .onChange(of: selectedDate) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(selectedDate, anchor: .center)
                        }
                    }
                }
                .frame(height: 68)
                .mask(edgeFade)

                stepButton(system: "chevron.right") { shiftMonth(1) }
            }
        }
    }

    private var edgeFade: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: 0.06),
                .init(color: .black, location: 0.94),
                .init(color: .clear, location: 1)
            ],
            startPoint: .leading, endPoint: .trailing
        )
    }

    private func stepButton(system: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(DoppelColor.textTertiary)
                .frame(width: 26, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle())
    }

    private func shiftMonth(_ value: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: value, to: activeMonth) else { return }
        let normalized = calendar.doppelStartOfMonth(for: newMonth)

        withAnimation(.easeInOut(duration: 0.2)) {
            activeMonth = normalized
        }

        if calendar.isDate(normalized, equalTo: Date(), toGranularity: .month) {
            selectedDate = calendar.startOfDay(for: Date())
        } else {
            selectedDate = normalized
        }
        onSelect(selectedDate)
    }
}

private struct DayCell: View {
    let date: Date
    let isSelected: Bool

    private var dayNumber: String { date.formatted(.dateTime.day()) }

    var body: some View {
        Text(dayNumber)
            .font(.system(size: isSelected ? 30 : 21, weight: isSelected ? .heavy : .bold, design: .rounded))
            .foregroundStyle(isSelected ? AnyShapeStyle(DoppelGradient.signature) : AnyShapeStyle(DoppelColor.textTertiary))
            .frame(width: 44, height: 68)
    }
}

private extension Calendar {
    func doppelStartOfMonth(for date: Date) -> Date {
        self.date(from: dateComponents([.year, .month], from: date)) ?? date
    }

    func doppelDaysInMonth(for monthDate: Date) -> [Date] {
        guard let range = range(of: .day, in: .month, for: monthDate) else { return [] }
        let start = doppelStartOfMonth(for: monthDate)
        return range.compactMap { day in
            date(byAdding: .day, value: day - 1, to: start)
        }
    }
}

#Preview {
    ZStack {
        DoppelColor.void.ignoresSafeArea()
        DayStrip()
    }
}
