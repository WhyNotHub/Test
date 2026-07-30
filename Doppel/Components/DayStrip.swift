import SwiftUI
import UIKit

/// Always exactly five days, the middle one always the current day --
/// centered by construction, not by scroll-physics tuned against a guessed
/// viewport width. The previous version was a free-scrolling strip
/// (ScrollView + scrollPosition + viewAligned, centered via a hand-tuned
/// padding trick) that turned out crooked and janky on a real device:
/// "centered" depended on scroll math that had never actually been run.
/// A fixed row of five cells can't be off-center -- there's no scroll
/// state to get wrong. Tapping any of the five re-centers the strip on
/// that day and opens its editor, so walking a few days over is just a
/// couple of taps on an edge cell rather than a drag gesture.
struct DayStrip: View {
    var onSelect: (Date) -> Void = { _ in }

    private let calendar = Calendar.current
    private let feedbackGenerator = UISelectionFeedbackGenerator()

    @State private var centerDate: Date
    @State private var dayActivities: [Date: Set<DayActivity>]
    @State private var categoryInfo: [DayActivity: ActivityCategoryInfo] = DayActivity.defaultCategoryInfo
    @State private var showDayEditor = false
    @State private var editingDay = Date()

    init(onSelect: @escaping (Date) -> Void = { _ in }) {
        self.onSelect = onSelect

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        _centerDate = State(initialValue: today)

        // Seed a few weeks either side of today from the old deterministic
        // demo pattern, so there's something to see while tapping around
        // near launch. Any day outside this range just starts empty, same
        // as a brand new day always would.
        var seededActivities: [Date: Set<DayActivity>] = [:]
        for offset in -21...21 {
            guard let day = cal.date(byAdding: .day, value: offset, to: today) else { continue }
            seededActivities[day] = Set(DayActivity.demo(for: cal.component(.day, from: day)))
        }
        _dayActivities = State(initialValue: seededActivities)
    }

    private var visibleDays: [Date] {
        (-2...2).compactMap { calendar.date(byAdding: .day, value: $0, to: centerDate) }
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(visibleDays, id: \.self) { day in
                DayCell(
                    date: day,
                    isSelected: calendar.isDate(day, inSameDayAs: centerDate),
                    activities: dayActivities[day] ?? [],
                    categoryInfo: categoryInfo
                )
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectAndEdit(day)
                }
            }
        }
        .sheet(isPresented: $showDayEditor) {
            DayActivityEditor(
                day: editingDay,
                activeActivities: activitiesBinding(for: editingDay),
                categoryInfo: $categoryInfo
            )
            .presentationDetents([.fraction(0.4)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(DoppelRadius.lg)
        }
    }

    /// Tapping any of the five visible days re-centers the strip on it and
    /// opens its editor -- both happen from the same tap, no separate
    /// "browse" vs "select" gesture to keep in sync.
    private func selectAndEdit(_ day: Date) {
        let startOfDay = calendar.startOfDay(for: day)
        let moved = !calendar.isDate(startOfDay, inSameDayAs: centerDate)
        withAnimation(.easeOut(duration: 0.25)) {
            centerDate = startOfDay
        }
        if moved {
            feedbackGenerator.selectionChanged()
            onSelect(startOfDay)
        }
        editingDay = startOfDay
        showDayEditor = true
    }

    private func activitiesBinding(for day: Date) -> Binding<Set<DayActivity>> {
        Binding(
            get: { dayActivities[day] ?? [] },
            set: { dayActivities[day] = $0 }
        )
    }
}

/// A category for the badges under each day. `demo(for:)` seeds initial
/// state so the strip isn't empty on first launch; from there it's real,
/// user-edited per-day state (in-memory only, not persisted yet) toggled
/// from `DayActivityEditor`. Each case's color is fixed identity (Gym is
/// always the lime slot); its display name and icon live separately in
/// `ActivityCategoryInfo` since those are the parts someone might rename
/// or re-icon (e.g. "Gym" -> "Yoga").
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

    static let defaultCategoryInfo: [DayActivity: ActivityCategoryInfo] = [
        .gym: ActivityCategoryInfo(label: "Gym", icon: .dumbbell),
        .work: ActivityCategoryInfo(label: "Work", icon: .briefcase),
        .school: ActivityCategoryInfo(label: "School", icon: .graduation)
    ]
}

/// The editable part of a category: what it's called and which glyph
/// represents it.
struct ActivityCategoryInfo: Hashable {
    var label: String
    var icon: ActivityIcon
}

/// Five modern, minimal, single-purpose glyphs -- covers the common
/// categories out of the box (gym/work/school) with headroom to reassign
/// as someone's actual routine varies. See `glyph` below for which of
/// these are custom-drawn vs. SF Symbols.
enum ActivityIcon: CaseIterable {
    case dumbbell, briefcase, graduation, moon, heart

    /// Custom hand-drawn glyphs for the three most common categories;
    /// moon/heart stay as SF Symbols -- a crescent and a heart are
    /// already about as minimal as those shapes get, so redrawing them
    /// wasn't worth the added geometry risk with no compiler to check it.
    @ViewBuilder
    var glyph: some View {
        switch self {
        case .dumbbell: Glyph.Dumbbell().fill()
        case .briefcase: Glyph.Briefcase().fill()
        case .graduation: GraduationGlyph()
        case .moon: Image(systemName: "moon.fill").resizable().scaledToFit()
        case .heart: Image(systemName: "heart.fill").resizable().scaledToFit()
        }
    }

    var next: ActivityIcon {
        let all = Self.allCases
        let index = all.firstIndex(of: self) ?? 0
        return all[(index + 1) % all.count]
    }
}

private struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let activities: Set<DayActivity>
    let categoryInfo: [DayActivity: ActivityCategoryInfo]

    private var weekday: String { date.formatted(.dateTime.weekday(.abbreviated)) }
    private var dayNumber: String { date.formatted(.dateTime.day()) }
    private var orderedActivities: [DayActivity] { DayActivity.allCases.filter(activities.contains) }

    var body: some View {
        VStack(spacing: 4) {
            Text(weekday.uppercased())
                .font(DoppelFont.bodyBold(9.5))
                .foregroundStyle(isSelected ? DoppelColor.textSecondary : DoppelColor.textTertiary)

            Text(dayNumber)
                .font(isSelected ? DoppelFont.display(28) : DoppelFont.headline(20))
                .foregroundStyle(isSelected ? DoppelColor.violet : DoppelColor.textTertiary)
                .animation(.easeOut(duration: 0.3), value: isSelected)

            HStack(spacing: 3) {
                ForEach(orderedActivities, id: \.self) { activity in
                    Group {
                        if let icon = categoryInfo[activity]?.icon {
                            icon.glyph
                                .foregroundStyle(activity.color)
                        }
                    }
                    .frame(width: 13, height: 13)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(height: 13)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: activities)
        }
        .frame(height: 84)
    }
}

/// Bottom sheet opened by tapping a day: toggle any combination of
/// gym/work/school on or off for that specific day. Each toggle writes
/// straight into `DayStrip`'s activity state via the binding, so the badge
/// row under the day updates live, immediately behind this sheet.
///
/// Edit mode repurposes the same rows instead of adding a separate picker
/// screen: the icon becomes a tap target that cycles to the next glyph and
/// the label becomes directly typeable. Category color stays fixed to its
/// slot regardless -- only name and icon are editable.
private struct DayActivityEditor: View {
    @Environment(\.dismiss) private var dismiss
    let day: Date
    @Binding var activeActivities: Set<DayActivity>
    @Binding var categoryInfo: [DayActivity: ActivityCategoryInfo]

    @State private var editMode = false

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
                        info: categoryInfo[activity] ?? ActivityCategoryInfo(label: "", icon: .dumbbell),
                        isOn: activeActivities.contains(activity),
                        editMode: editMode,
                        onToggle: { toggle(activity) },
                        onCycleIcon: { cycleIcon(activity) },
                        onRename: { categoryInfo[activity]?.label = $0 }
                    )
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
                    IconButton(style: editMode ? .solid : .glass, action: { editMode.toggle() }) {
                        Glyph.Pencil().fill()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    IconButton(style: .solid, action: { dismiss() }) {
                        Glyph.Checkmark()
                            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    }
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

    private func cycleIcon(_ activity: DayActivity) {
        categoryInfo[activity]?.icon = categoryInfo[activity]?.icon.next ?? .dumbbell
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

private struct ActivityToggleRow: View {
    let activity: DayActivity
    let info: ActivityCategoryInfo
    let isOn: Bool
    let editMode: Bool
    let onToggle: () -> Void
    let onCycleIcon: () -> Void
    let onRename: (String) -> Void

    var body: some View {
        HStack(spacing: DoppelSpacing.sm) {
            Button(action: onCycleIcon) {
                info.icon.glyph
                    .frame(width: 28, height: 28)
                    .foregroundStyle(activity.color)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(PressableStyle())
            .allowsHitTesting(editMode)

            if editMode {
                TextField("", text: Binding(get: { info.label }, set: onRename))
                    .textFieldStyle(.plain)
                    .font(DoppelFont.bodyBold(14.5))
                    .foregroundStyle(DoppelColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(info.label)
                    .font(DoppelFont.bodyBold(14.5))
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
        .contentShape(Rectangle())
        .onTapGesture {
            guard !editMode else { return }
            onToggle()
        }
        .animation(.easeOut(duration: 0.2), value: isOn)
    }
}

#Preview {
    ZStack {
        DoppelColor.void.ignoresSafeArea()
        DayStrip()
    }
}
