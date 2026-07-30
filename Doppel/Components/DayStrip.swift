import SwiftUI

/// A single-line, horizontally scrolling calendar: the selected day centers
/// itself in the strip, chevrons page whole months, today gets a hairline
/// ring and the selected day gets the signature gradient pill.
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
        VStack(spacing: DoppelSpacing.sm) {
            Text(monthTitle.uppercased())
                .font(DoppelFont.caption())
                .foregroundStyle(DoppelColor.textSecondary)
                .tracking(1.0)

            HStack(spacing: DoppelSpacing.sm) {
                stepButton(system: "chevron.left") { shiftMonth(-1) }

                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DoppelSpacing.sm) {
                            ForEach(days, id: \.self) { day in
                                DayCell(
                                    date: day,
                                    isSelected: calendar.isDate(day, inSameDayAs: selectedDate),
                                    isToday: calendar.isDateInToday(day)
                                )
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
                .frame(height: 60)
                .mask(edgeFade)

                stepButton(system: "chevron.right") { shiftMonth(1) }
            }
        }
    }

    private var edgeFade: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: 0.08),
                .init(color: .black, location: 0.92),
                .init(color: .clear, location: 1)
            ],
            startPoint: .leading, endPoint: .trailing
        )
    }

    private func stepButton(system: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(DoppelColor.textPrimary)
                .frame(width: 30, height: 30)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(DoppelColor.hairline, lineWidth: 1))
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
    let isToday: Bool

    private var weekdayLetter: String { date.formatted(.dateTime.weekday(.narrow)) }
    private var dayNumber: String { date.formatted(.dateTime.day()) }

    var body: some View {
        VStack(spacing: 4) {
            Text(weekdayLetter.uppercased())
                .font(DoppelFont.caption(10))
                .foregroundStyle(isSelected ? DoppelColor.void.opacity(0.7) : DoppelColor.textTertiary)

            Text(dayNumber)
                .font(DoppelFont.headline(16))
                .foregroundStyle(isSelected ? DoppelColor.void : DoppelColor.textPrimary)
        }
        .frame(width: 42, height: 54)
        .background(
            RoundedRectangle(cornerRadius: DoppelRadius.sm, style: .continuous)
                .fill(isSelected ? AnyShapeStyle(DoppelGradient.signature) : AnyShapeStyle(Color.clear))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DoppelRadius.sm, style: .continuous)
                .stroke(isToday && !isSelected ? DoppelColor.violet.opacity(0.6) : Color.clear, lineWidth: 1.5)
        )
        .scaleEffect(isSelected ? 1.06 : 1.0)
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
