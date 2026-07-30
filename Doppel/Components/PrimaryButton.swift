import SwiftUI

/// Was a violet-pink gradient pill with a colored glow -- reads as a dated
/// "2016 app store" cliche. Modern fintech/consumer references (Robinhood,
/// Kalshi) favor stark black/white monochrome and no colored glow at all --
/// confidence from contrast, not decoration. Pill shape stays (Robinhood's
/// own CTAs are high-radius pills too); the fill and shadow are what
/// changed there. The label itself uses the app's Unbounded display face
/// (the same one used for the name/headlines) rather than the plain Outfit
/// grotesk -- Outfit read as too generic/interchangeable for a single-word
/// primary CTA; Unbounded's blocky geometric letterforms give it actual
/// character.
struct PrimaryButton: View {
    var title: String
    var systemImage: String? = "arrow.right"
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DoppelSpacing.sm) {
                Text(title)
                    .font(DoppelFont.display(14))
                    .textCase(.uppercase)
                    .tracking(0.4)
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 15, weight: .semibold))
                }
            }
            .foregroundStyle(DoppelColor.void)
            .padding(.vertical, DoppelSpacing.md + 1)
            .frame(maxWidth: .infinity)
            .background(DoppelColor.textPrimary, in: Capsule())
        }
        .buttonStyle(PressableStyle())
    }
}

#Preview {
    PrimaryButton(title: "Bamboo", systemImage: nil) {}
        .padding()
        .background(DoppelColor.void)
}
