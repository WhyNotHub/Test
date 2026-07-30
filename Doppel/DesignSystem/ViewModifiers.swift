import SwiftUI

private struct GlassSurface: ViewModifier {
    var radius: CGFloat = DoppelRadius.lg

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .stroke(DoppelColor.hairline, lineWidth: 1)
                    )
            )
    }
}

/// Scales a control down slightly while pressed instead of relying on the
/// default opacity fade — feels more tactile and "alive".
struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension View {
    func glassSurface(radius: CGFloat = DoppelRadius.lg) -> some View {
        modifier(GlassSurface(radius: radius))
    }
}
