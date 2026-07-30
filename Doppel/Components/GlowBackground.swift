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
/// the character. Used to be four animated, blurred layers (glow halo +
/// counter-rotating inner bezel + glass lens + stroke) -- busy, expensive
/// to animate, and read as neon/sci-fi rather than clean. Now it's one
/// static thin ring with a soft shadow for a touch of ambient light: no
/// blur layer, no rotation, nothing continuously repainting.
struct AuraRing: View {
    var colors: [Color]
    var size: CGFloat = 280

    var body: some View {
        Circle()
            .strokeBorder(DoppelGradient.aura(colors), lineWidth: 2)
            .frame(width: size, height: size)
            .shadow(color: (colors.first ?? DoppelColor.violet).opacity(0.35), radius: 10)
    }
}

#Preview {
    ZStack {
        GlowBackground(colors: [DoppelColor.violet, DoppelColor.pink])
        AuraRing(colors: [DoppelColor.violet, DoppelColor.pink])
    }
    .ignoresSafeArea()
}
