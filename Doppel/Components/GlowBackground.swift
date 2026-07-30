import SwiftUI

/// The ambient, slowly-drifting backdrop used behind the avatar on Home.
struct GlowBackground: View {
    var colors: [Color]

    @State private var animate = false

    var body: some View {
        ZStack {
            DoppelColor.void

            Circle()
                .fill(colors.first ?? DoppelColor.violet)
                .frame(width: 420, height: 420)
                .blur(radius: 140)
                .opacity(0.35)
                .offset(x: animate ? -90 : -140, y: animate ? -260 : -220)

            Circle()
                .fill(colors.last ?? DoppelColor.pink)
                .frame(width: 380, height: 380)
                .blur(radius: 140)
                .opacity(0.30)
                .offset(x: animate ? 130 : 90, y: animate ? 300 : 340)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

/// The slowly rotating halo directly behind the hero avatar — the
/// "digital" signature of the character.
struct AuraRing: View {
    var colors: [Color]
    var size: CGFloat = 280

    @State private var rotate = false

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(DoppelGradient.aura(colors), lineWidth: 14)
                .frame(width: size, height: size)
                .blur(radius: 24)
                .opacity(0.55)

            Circle()
                .strokeBorder(DoppelGradient.aura(colors), lineWidth: 2.5)
                .frame(width: size, height: size)
        }
        .rotationEffect(.degrees(rotate ? 360 : 0))
        .onAppear {
            withAnimation(.linear(duration: 16).repeatForever(autoreverses: false)) {
                rotate = true
            }
        }
    }
}

#Preview {
    ZStack {
        GlowBackground(colors: [DoppelColor.violet, DoppelColor.pink])
        AuraRing(colors: [DoppelColor.violet, DoppelColor.pink])
    }
    .ignoresSafeArea()
}
