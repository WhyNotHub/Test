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
                .padding(.vertical, 2)
            }
        }
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
                .scaleEffect(isSelected ? 1.08 : 1.0)
        }
        .buttonStyle(PressableStyle())
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
                            .stroke(isSelected ? DoppelColor.violet : DoppelColor.hairline, lineWidth: isSelected ? 2.5 : 1)
                    )

                Text(label)
                    .font(DoppelFont.caption(11))
                    .foregroundStyle(isSelected ? DoppelColor.textPrimary : DoppelColor.textSecondary)
            }
        }
        .buttonStyle(PressableStyle())
    }
}

struct PillChip: View {
    var label: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(DoppelFont.body(14))
                .foregroundStyle(isSelected ? DoppelColor.void : DoppelColor.textPrimary)
                .padding(.horizontal, DoppelSpacing.md)
                .padding(.vertical, DoppelSpacing.sm)
                .background(
                    Capsule().fill(
                        isSelected ? AnyShapeStyle(DoppelGradient.signature) : AnyShapeStyle(DoppelColor.surfaceElevated)
                    )
                )
        }
        .buttonStyle(PressableStyle())
    }
}
