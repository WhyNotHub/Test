import SwiftUI

struct IconButton<Icon: View>: View {
    enum Style {
        /// Subtle frosted-glass circle. Default -- for secondary/transient
        /// actions inside a sheet (e.g. Reset).
        case glass
        /// Flat white fill, void glyph -- the one primary/confirming
        /// action in a group (e.g. a sheet's Done), same high-contrast
        /// language as the Bamboo CTA and selected-state chips.
        case solid
    }

    var style: Style = .glass
    var size: CGFloat = 40
    var action: () -> Void
    @ViewBuilder var icon: () -> Icon

    var body: some View {
        Button(action: action) {
            icon()
                .frame(width: size * 0.375, height: size * 0.375)
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
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        IconButton(action: {}) {
            ResetGlyph()
        }
        IconButton(style: .solid, action: {}) {
            Glyph.Checkmark()
                .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
    }
    .padding()
    .background(DoppelColor.void)
}
