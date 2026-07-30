import SwiftUI

struct IconButton: View {
    enum Style {
        /// Subtle frosted-glass circle. Default -- for secondary/transient
        /// actions inside a sheet (e.g. Reset).
        case glass
        /// Flat white fill, void glyph -- the one primary/confirming
        /// action in a group (e.g. a sheet's Done), same high-contrast
        /// language as the Bamboo CTA and selected-state chips.
        case solid
        /// Flat violet fill, white glyph -- for a persistent nav icon
        /// that should read as a real destination rather than a small
        /// utility glyph. One deliberate spot of the signature accent
        /// color against an otherwise monochrome UI.
        case accent
    }

    var systemName: String
    var style: Style = .glass
    var size: CGFloat = 40
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size * 0.375, weight: .semibold))
                .foregroundStyle(foregroundColor)
                .frame(width: size, height: size)
                .background(background)
                .overlay(Circle().stroke(style == .glass ? DoppelColor.hairline : Color.clear, lineWidth: 1))
                .shadow(color: .black.opacity(style == .glass ? 0.25 : 0), radius: style == .glass ? 6 : 0, y: style == .glass ? 3 : 0)
        }
        .buttonStyle(PressableStyle())
    }

    private var foregroundColor: Color {
        switch style {
        case .glass: DoppelColor.textPrimary
        case .solid: DoppelColor.void
        case .accent: .white
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .glass:
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(
                    // A faint top-lit sheen so the glass reads as
                    // catching light rather than a flat gray disc.
                    Circle().fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.10), Color.white.opacity(0)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                )
        case .solid:
            Circle().fill(DoppelColor.textPrimary)
        case .accent:
            Circle().fill(DoppelColor.violet)
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        IconButton(systemName: "arrow.counterclockwise") {}
        IconButton(systemName: "checkmark", style: .solid) {}
        IconButton(systemName: "gearshape.fill", style: .accent, size: 48) {}
    }
    .padding()
    .background(DoppelColor.void)
}
