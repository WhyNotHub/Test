import SwiftUI

struct IconButton: View {
    var systemName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(DoppelColor.textPrimary)
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(DoppelColor.hairline, lineWidth: 1))
        }
        .buttonStyle(PressableStyle())
    }
}

#Preview {
    IconButton(systemName: "gearshape.fill") {}
        .padding()
        .background(DoppelColor.void)
}
