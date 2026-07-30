import SwiftUI

/// Was a violet-pink gradient pill with a colored glow -- reads as a dated
/// "2016 app store" cliche. Modern fintech/consumer references (Robinhood,
/// Kalshi) favor stark black/white monochrome, bold clean type, and no
/// colored glow at all -- confidence from contrast, not decoration. Pill
/// shape stays (Robinhood's own CTAs are high-radius pills too); the
/// fill, type and shadow are what changed.
struct PrimaryButton: View {
    var title: String
    var systemImage: String? = "arrow.right"
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DoppelSpacing.sm) {
                Text(title)
                    .font(DoppelFont.bodyBold(14))
                    .textCase(.uppercase)
                    .tracking(1.2)
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
