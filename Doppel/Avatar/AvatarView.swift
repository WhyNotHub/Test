import SwiftUI

/// Shared layout constants so every avatar sub-view (face, hair, torso,
/// accessories) agrees on where the head actually is. Everything is
/// expressed as a fraction of `side`, the square canvas size, so the whole
/// character scales cleanly from a small list row to a full-screen hero.
enum AvatarMetrics {
    static let mirror: [CGFloat] = [-1, 1]

    static func headSize(side: CGFloat) -> CGSize {
        CGSize(width: side * 0.52, height: side * 0.56)
    }

    static func headCenter(side: CGFloat) -> CGPoint {
        CGPoint(x: side / 2, y: side * 0.40)
    }

    static func eyeOffsetX(side: CGFloat) -> CGFloat {
        side * 0.105
    }

    static func eyeCenterY(headCenter: CGPoint, headSize: CGSize) -> CGFloat {
        headCenter.y - headSize.height * 0.03
    }
}

/// Renders a `DoppelAvatar` as a fully vector, code-drawn character — no
/// image assets involved. Usable at any size, from a small list glyph to a
/// full hero portrait on the home screen.
///
/// No continuous scale/"breathing" animation here -- a portrait that keeps
/// resizing itself reads as cheap, not alive. Blinking (a small, localized
/// eye animation, not a resize) is the only idle motion left.
struct AvatarView: View {
    var avatar: DoppelAvatar
    var animated: Bool = true

    @State private var blinking = false
    @State private var blinkTask: Task<Void, Never>?

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let headSize = AvatarMetrics.headSize(side: side)
            let headCenter = AvatarMetrics.headCenter(side: side)

            ZStack {
                HairView(style: avatar.hairStyle, color: avatar.hairColor.color, layer: .back, side: side, headCenter: headCenter, headSize: headSize)

                TorsoView(avatar: avatar, side: side, headCenter: headCenter, headSize: headSize)

                FaceView(avatar: avatar, side: side, headCenter: headCenter, headSize: headSize, blinking: blinking)

                HairView(style: avatar.hairStyle, color: avatar.hairColor.color, layer: .front, side: side, headCenter: headCenter, headSize: headSize)

                AccessoryView(avatar: avatar, side: side, headCenter: headCenter, headSize: headSize)
            }
            .frame(width: side, height: side)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear { if animated { startAnimations() } }
        .onDisappear { stopAnimations() }
        .accessibilityLabel("Your Bamboo avatar")
    }

    private func startAnimations() {
        blinkTask = Task {
            while !Task.isCancelled {
                let delay = Double.random(in: 2.4...5.2)
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                guard !Task.isCancelled else { return }

                withAnimation(.easeInOut(duration: 0.09)) { blinking = true }
                try? await Task.sleep(nanoseconds: 130_000_000)
                guard !Task.isCancelled else { return }

                withAnimation(.easeInOut(duration: 0.14)) { blinking = false }
            }
        }
    }

    private func stopAnimations() {
        blinkTask?.cancel()
        blinkTask = nil
    }
}

#Preview {
    AvatarView(avatar: .default)
        .frame(width: 260, height: 260)
        .background(DoppelColor.void)
}
