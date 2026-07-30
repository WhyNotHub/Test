import SwiftUI

struct IconButton: View {
    var systemName: String
    /// A solid, high-contrast variant for the one primary action in a
    /// group (e.g. "Done" among icon buttons) -- same language as the
    /// Bamboo CTA and the selected-state chips: flat white fill, void
    /// glyph, no glass/shadow.
    var filled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(filled ? DoppelColor.void : DoppelColor.textPrimary)
                .frame(width: 40, height: 40)
                .background(background)
                .overlay(Circle().stroke(filled ? Color.clear : DoppelColor.hairline, lineWidth: 1))
                .shadow(color: .black.opacity(filled ? 0 : 0.25), radius: filled ? 0 : 6, y: filled ? 0 : 3)
        }
        .buttonStyle(PressableStyle())
    }

    @ViewBuilder
    private var background: some View {
        if filled {
            Circle().fill(DoppelColor.textPrimary)
        } else {
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
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        IconButton(systemName: "arrow.counterclockwise") {}
        IconButton(systemName: "checkmark", filled: true) {}
    }
    .padding()
    .background(DoppelColor.void)
}
