import SwiftUI

/// The ambient, slowly-drifting backdrop used behind the avatar on Home.
/// Lowkey by design: the two color blobs used to run at 0.35/0.30 opacity,
/// loud enough to compete with the avatar for attention. Dimmed way down so
/// they read as ambient tint, with a vignette doing the real work of
/// focusing the eye on the center.
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
                .opacity(0.16)
                .offset(x: animate ? -90 : -140, y: animate ? -260 : -220)

            Circle()
                .fill(colors.last ?? DoppelColor.pink)
                .frame(width: 380, height: 380)
                .blur(radius: 140)
                .opacity(0.13)
                .offset(x: animate ? 130 : 90, y: animate ? 300 : 340)

            RadialGradient(
                colors: [.clear, DoppelColor.void.opacity(0.35)],
                center: UnitPoint(x: 0.5, y: 0.4), startRadius: 160, endRadius: 460
            )
            .allowsHitTesting(false)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 14).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

/// The halo directly behind the hero avatar -- the "digital" signature of
/// the character. Three lowkey layers instead of one loud blurred glow: a
/// soft glass lens behind the avatar (depth, not glow), a thin bezel stroke
/// (the actual "ring"), and a much dimmer, tighter glow that reads as a
/// quiet emission rather than a spotlight, plus a faint counter-rotating
/// inner bezel for a little parallax.
struct AuraRing: View {
    var colors: [Color]
    var size: CGFloat = 280

    @State private var rotate = false
    @State private var counterRotate = false

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(DoppelGradient.aura(colors), lineWidth: 14)
                .frame(width: size, height: size)
                .blur(radius: 20)
                .opacity(0.22)
                .rotationEffect(.degrees(rotate ? 360 : 0))

            Circle()
                .strokeBorder(DoppelGradient.aura(colors), lineWidth: 1)
                .frame(width: size * 1.10, height: size * 1.10)
                .opacity(0.14)
                .rotationEffect(.degrees(counterRotate ? -360 : 0))

            Circle()
                .fill(
                    RadialGradient(
                        colors: [(colors.first ?? DoppelColor.violet).opacity(0.22), .clear],
                        center: UnitPoint(x: 0.36, y: 0.30), startRadius: 0, endRadius: size * 0.42
                    )
                )
                .frame(width: size * 0.92, height: size * 0.92)

            Circle()
                .strokeBorder(DoppelGradient.aura(colors), lineWidth: 2.5)
                .frame(width: size, height: size)
                .opacity(0.85)
                .rotationEffect(.degrees(rotate ? 360 : 0))
        }
        .onAppear {
            withAnimation(.linear(duration: 26).repeatForever(autoreverses: false)) {
                rotate = true
            }
            withAnimation(.linear(duration: 34).repeatForever(autoreverses: false)) {
                counterRotate = true
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
