import SwiftUI

struct PrimaryButton: View {
    var title: String
    var systemImage: String? = "arrow.right"
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DoppelSpacing.sm) {
                Text(title)
                    .font(DoppelFont.headline(17))
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 15, weight: .semibold))
                }
            }
            .foregroundStyle(DoppelColor.void)
            .padding(.vertical, DoppelSpacing.md)
            .frame(maxWidth: .infinity)
            .background(DoppelGradient.signature, in: Capsule())
            .glow(DoppelColor.violet, radius: 20, opacity: 0.45)
        }
        .buttonStyle(PressableStyle())
    }
}

#Preview {
    PrimaryButton(title: "Enter Doppel") {}
        .padding()
        .background(DoppelColor.void)
}
