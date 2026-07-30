import SwiftUI

/// A titled, horizontally-scrolling row of trait options. Every picker in
/// the customize sheet is one of these.
struct TraitSection<Content: View>: View {
    var title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: DoppelSpacing.sm) {
            Text(title.uppercased())
                .font(DoppelFont.caption())
                .foregroundStyle(DoppelColor.textSecondary)
                .tracking(1.0)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DoppelSpacing.sm) {
                    content()
                }
                // A scroll view clips to its own frame on every axis, and
                // a selected item grows past its resting size (scaleEffect
                // + a thicker selection ring). Zero slack meant that
                // growth got sliced off at the row's own edge -- top on
                // any item, left on whichever item starts the row. Padding
                // sized to the largest selected-state growth in play fixes
                // it everywhere at once instead of per-component.
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
            .mask(trailingFade)
        }
    }

    /// Signals "more content, keep scrolling" past the sheet edge instead
    /// of a hard clip. Leading edge is untouched -- at rest nothing there
    /// is cut off, so fading it too would just dim an intact item.
    private var trailingFade: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .black, location: 0),
                .init(color: .black, location: 0.93),
                .init(color: .clear, location: 1)
            ],
            startPoint: .leading, endPoint: .trailing
        )
    }
}

struct ColorSwatchButton: View {
    var color: Color
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 42, height: 42)
                .overlay(
                    Circle()
                        .stroke(isSelected ? DoppelColor.textPrimary : DoppelColor.hairline, lineWidth: isSelected ? 3 : 1)
                )
                .overlay(alignment: .bottomTrailing) { checkBadge }
                .scaleEffect(isSelected ? 1.08 : 1.0)
        }
        .buttonStyle(PressableStyle())
        .animation(.easeOut(duration: 0.2), value: isSelected)
    }

    /// Always present rather than conditionally inserted -- opacity/scale
    /// only, no .transition() -- so it never nudges the swatch's layout
    /// size (an insertion transition would re-trigger the same clipping
    /// class of bug the row padding above just fixed).
    private var checkBadge: some View {
        Circle()
            .fill(DoppelColor.textPrimary)
            .frame(width: 16, height: 16)
            .overlay(
                Image(systemName: "checkmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(DoppelColor.void)
            )
            .overlay(Circle().stroke(DoppelColor.void, lineWidth: 2))
            .offset(x: 3, y: 3)
            .opacity(isSelected ? 1 : 0)
            .scaleEffect(isSelected ? 1 : 0.4)
    }
}

/// A small live-rendered avatar thumbnail used to preview how a trait
/// option would look on the user's *current* avatar before they commit.
struct AvatarPreviewChip: View {
    var avatar: DoppelAvatar
    var label: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DoppelSpacing.xs) {
                AvatarView(avatar: avatar, animated: false)
                    .frame(width: 60, height: 60)
                    .padding(6)
                    .background(Circle().fill(DoppelColor.surfaceElevated))
                    .overlay(
                        Circle()
                            .stroke(isSelected ? DoppelColor.textPrimary : DoppelColor.hairline, lineWidth: isSelected ? 2.5 : 1)
                    )
                    .scaleEffect(isSelected ? 1.08 : 1.0)

                Text(label)
                    .font(DoppelFont.caption(11))
                    .foregroundStyle(isSelected ? DoppelColor.textPrimary : DoppelColor.textSecondary)
            }
        }
        .buttonStyle(PressableStyle())
        .animation(.easeOut(duration: 0.2), value: isSelected)
    }
}

struct PillChip: View {
    var label: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(isSelected ? DoppelFont.bodyBold(14) : DoppelFont.body(14))
                .foregroundStyle(isSelected ? DoppelColor.void : DoppelColor.textPrimary)
                .padding(.horizontal, DoppelSpacing.md)
                .padding(.vertical, DoppelSpacing.sm)
                .background(
                    Capsule().fill(isSelected ? DoppelColor.textPrimary : DoppelColor.surfaceElevated)
                )
                .scaleEffect(isSelected ? 1.04 : 1.0)
        }
        .buttonStyle(PressableStyle())
        .animation(.easeOut(duration: 0.2), value: isSelected)
    }
}
