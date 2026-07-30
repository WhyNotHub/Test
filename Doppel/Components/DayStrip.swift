import SwiftUI
import UIKit

/// The days of the current calendar month, scrollable but bounded to this
/// month (not a continuous multi-month range). There's no separate
/// "selected" state: the highlighted day is whichever one is centered, but
/// it only commits once scrolling settles (debounced ~140ms of no
/// movement) rather than flickering between cells on every scroll tick — a
/// live per-frame highlight looked chaotic during a fast drag. A subtle
/// selection haptic fires on each settle. Tapping a day also opens a sheet
/// to toggle that day's activity badges, so a tap commits the highlight
/// immediately rather than waiting on the settle debounce.
struct DayStrip: View {
    var onSelect: (Date) -> Void = { _ in }

    private let calendar = Calendar.current
    private let days: [Date]
    private let feedbackGenerator = UISelectionFeedbackGenerator()

    @State private var scrollTrackedDate: Date?
    @State private var currentDate: Date
    @State private var settleTask: Task<Void, Never>?
    @State private var dayActivities: [Date: Set<DayActivity>]
    @State private var showDayEditor = false
    @State private var editingDay = Date()

    init(onSelect: @escaping (Date) -> Void = { _ in }) {
        self.onSelect = onSelect

        let cal = Calendar.current
        let now = Date()
        let today = cal.startOfDay(for: now)
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: now)) ?? today
        let dayRange = cal.range(of: .day, in: .month, for: now) ?? 1..<32
        let generatedDays = dayRange.compactMap { cal.date(byAdding: .day, value: $0 - 1, to: startOfMonth) }
        days = generatedDays

        _currentDate = State(initialValue: today)
        _scrollTrackedDate = State(initialValue: today)

        var seededActivities: [Date: Set<DayActivity>] = [:]
        for (index, day) in generatedDays.enumerated() {
            seededActivities[day] = Set(DayActivity.demo(for: index))
        }
        _dayActivities = State(initialValue: seededActivities)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 6) {
                ForEach(days, id: \.self) { day in
                    DayCell(
                        date: day,
                        isSelected: calendar.isDate(day, inSameDayAs: currentDate),
                        activities: dayActivities[day] ?? []
                    )
                    .id(day)
                    .onTapGesture {
                        selectAndEdit(day)
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
        .sheet(isPresented: $showDayEditor) {
            DayActivityEditor(day: editingDay, activeActivities: activitiesBinding(for: editingDay))
                .presentationDetents([.fraction(0.4)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(DoppelRadius.lg)
        }
    }

    /// Tapping a day both scrolls it to center and opens its editor. The
    /// highlight is committed synchronously here rather than left to the
    /// scroll-settle debounce above: that debounce exists to smooth out
    /// fast drags, but a deliberate tap already tells us exactly which day
    /// won, so there's no reason to wait.
    private func selectAndEdit(_ day: Date) {
        scrollTrackedDate = day
        settleTask?.cancel()
        if !calendar.isDate(day, inSameDayAs: currentDate) {
            withAnimation(.easeOut(duration: 0.3)) {
                currentDate = day
            }
            feedbackGenerator.selectionChanged()
            onSelect(day)
        }
        editingDay = day
        showDayEditor = true
    }

    private func activitiesBinding(for day: Date) -> Binding<Set<DayActivity>> {
        Binding(
            get: { dayActivities[day] ?? [] },
            set: { dayActivities[day] = $0 }
        )
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

/// A category for the badges under each day. `demo(for:)` seeds initial
/// state so the strip isn't empty on first launch; from there it's real,
/// user-edited per-day state (in-memory only, not persisted yet) toggled
/// from `DayActivityEditor`.
enum DayActivity: CaseIterable, Hashable {
    case gym, work, school

    var label: String {
        switch self {
        case .gym: "Gym"
        case .work: "Work"
        case .school: "School"
        }
    }

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
    let activities: Set<DayActivity>

    private var weekday: String { date.formatted(.dateTime.weekday(.abbreviated)) }
    private var dayNumber: String { date.formatted(.dateTime.day()) }
    private var orderedActivities: [DayActivity] { DayActivity.allCases.filter(activities.contains) }

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
                ForEach(orderedActivities, id: \.self) { activity in
                    Circle()
                        .fill(activity.color)
                        .frame(width: 5, height: 5)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(height: 6)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: activities)
        }
        .frame(width: 52, height: 84)
    }
}

/// Bottom sheet opened by tapping a day: toggle any combination of
/// gym/work/school on or off for that specific day. Each toggle writes
/// straight into `DayStrip`'s activity state via the binding, so the badge
/// row under the day updates live, immediately behind this sheet.
private struct DayActivityEditor: View {
    @Environment(\.dismiss) private var dismiss
    let day: Date
    @Binding var activeActivities: Set<DayActivity>

    private var title: String {
        Calendar.current.isDateInToday(day)
            ? "Today"
            : day.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: DoppelSpacing.sm) {
                ForEach(DayActivity.allCases, id: \.self) { activity in
                    ActivityToggleRow(
                        activity: activity,
                        isOn: activeActivities.contains(activity)
                    ) {
                        toggle(activity)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(DoppelSpacing.lg)
            .background(DoppelColor.void.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(DoppelColor.violet)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func toggle(_ activity: DayActivity) {
        if activeActivities.contains(activity) {
            activeActivities.remove(activity)
        } else {
            activeActivities.insert(activity)
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

private struct ActivityToggleRow: View {
    let activity: DayActivity
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DoppelSpacing.sm) {
                Circle()
                    .fill(activity.color)
                    .frame(width: 11, height: 11)

                Text(activity.label)
                    .font(DoppelFont.body(14.5))
                    .fontWeight(.bold)
                    .foregroundStyle(DoppelColor.textPrimary)

                Spacer()

                ZStack {
                    Circle()
                        .fill(isOn ? activity.color : Color.clear)
                        .overlay(
                            Circle().stroke(isOn ? activity.color : DoppelColor.hairline, lineWidth: 1.5)
                        )
                    if isOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(DoppelColor.void)
                    }
                }
                .frame(width: 24, height: 24)
            }
            .padding(.horizontal, DoppelSpacing.md)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: DoppelRadius.sm, style: .continuous)
                    .fill(DoppelColor.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: DoppelRadius.sm, style: .continuous)
                            .stroke(isOn ? activity.color : DoppelColor.hairline, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(PressableStyle())
        .animation(.easeOut(duration: 0.2), value: isOn)
    }
}

#Preview {
    ZStack {
        DoppelColor.void.ignoresSafeArea()
        DayStrip()
    }
}
