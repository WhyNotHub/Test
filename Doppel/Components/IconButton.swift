import SwiftUI

struct IconButton: View {
    var systemName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(DoppelColor.textPrimary)
                .frame(width: 40, height: 40)
                .background(
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
                )
                .overlay(Circle().stroke(DoppelColor.hairline, lineWidth: 1))
                .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
        }
        .buttonStyle(PressableStyle())
    }
}

#Preview {
    IconButton(systemName: "gearshape.fill") {}
        .padding()
        .background(DoppelColor.void)
}
