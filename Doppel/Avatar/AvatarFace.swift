import SwiftUI

/// Head, ears, eyes, eyebrows and mouth — everything that reads the user's
/// selected face traits. Positions are derived once from `AvatarMetrics` so
/// this always lines up with the hair and accessory layers.
struct FaceView: View {
    var avatar: DoppelAvatar
    var side: CGFloat
    var headCenter: CGPoint
    var headSize: CGSize
    var blinking: Bool

    private var eyeOffsetX: CGFloat { AvatarMetrics.eyeOffsetX(side: side) }
    private var eyeCenterY: CGFloat { AvatarMetrics.eyeCenterY(headCenter: headCenter, headSize: headSize) }
    private var eyebrowY: CGFloat { eyeCenterY - side * 0.095 }
    private var mouthCenterY: CGFloat { headCenter.y + headSize.height * 0.27 }

    var body: some View {
        ZStack {
            ears
            head
            eyebrows
            eyes
            mouth
        }
    }

    private var head: some View {
        RoundedRectangle(cornerRadius: headSize.width * 0.42, style: .continuous)
            .fill(avatar.skinTone.color)
            .frame(width: headSize.width, height: headSize.height)
            .position(headCenter)
    }

    private var ears: some View {
        ForEach(AvatarMetrics.mirror, id: \.self) { dir in
            Circle()
                .fill(avatar.skinTone.color)
                .frame(width: side * 0.09, height: side * 0.09)
                .position(
                    x: headCenter.x + dir * (headSize.width / 2) * 0.96,
                    y: headCenter.y + headSize.height * 0.05
                )
        }
    }

    @ViewBuilder
    private var eyes: some View {
        if avatar.eyeStyle == .wink {
            eyeView(open: true).position(x: headCenter.x - eyeOffsetX, y: eyeCenterY)
            eyeView(open: false).position(x: headCenter.x + eyeOffsetX, y: eyeCenterY)
        } else {
            eyeView(open: true).position(x: headCenter.x - eyeOffsetX, y: eyeCenterY)
            eyeView(open: true).position(x: headCenter.x + eyeOffsetX, y: eyeCenterY)
        }
    }

    @ViewBuilder
    private func eyeView(open: Bool) -> some View {
        let baseSize = side * 0.086

        if !open {
            Capsule()
                .fill(DoppelColor.void)
                .frame(width: baseSize * 0.85, height: baseSize * 0.16)
        } else {
            Ellipse()
                .fill(DoppelColor.void)
                .frame(width: baseSize * eyeWidthMultiplier, height: baseSize * eyeHeightMultiplier)
                .overlay(
                    Circle()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: baseSize * 0.22, height: baseSize * 0.22)
                        .offset(x: baseSize * 0.12, y: -baseSize * 0.12)
                )
                .scaleEffect(x: 1, y: blinking ? 0.12 : 1, anchor: .center)
        }
    }

    private var eyeWidthMultiplier: CGFloat {
        switch avatar.eyeStyle {
        case .wide: 1.18
        case .almond: 1.05
        default: 1.0
        }
    }

    private var eyeHeightMultiplier: CGFloat {
        switch avatar.eyeStyle {
        case .sleepy: 0.45
        case .almond: 0.72
        case .wide: 1.08
        default: 1.0
        }
    }

    private var eyebrows: some View {
        ForEach(AvatarMetrics.mirror, id: \.self) { dir in
            Capsule()
                .fill(avatar.hairColor.color)
                .frame(width: side * 0.09, height: side * 0.016)
                .rotationEffect(.degrees(Double(dir) * -8))
                .position(x: headCenter.x + dir * eyeOffsetX, y: eyebrowY)
        }
    }

    @ViewBuilder
    private var mouth: some View {
        let shape = MouthShape(style: avatar.mouthStyle)
        let width = side * 0.15
        let height = side * 0.065

        if avatar.mouthStyle == .grin || avatar.mouthStyle == .open {
            shape
                .fill(DoppelColor.void)
                .frame(width: width, height: height)
                .position(x: headCenter.x, y: mouthCenterY)
        } else {
            shape
                .stroke(DoppelColor.void, style: StrokeStyle(lineWidth: side * 0.014, lineCap: .round))
                .frame(width: width, height: height)
                .position(x: headCenter.x, y: mouthCenterY)
        }
    }
}

/// A single-line mouth silhouette. `.grin` and `.open` are closed shapes
/// meant to be filled; every other case is an open curve meant to be
/// stroked (see `FaceView.mouth`).
struct MouthShape: Shape {
    var style: MouthStyle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let left = CGPoint(x: rect.minX, y: rect.midY)
        let right = CGPoint(x: rect.maxX, y: rect.midY)

        switch style {
        case .smile:
            path.move(to: left)
            path.addQuadCurve(to: right, control: CGPoint(x: rect.midX, y: rect.maxY))
        case .grin:
            path.move(to: left)
            path.addQuadCurve(to: right, control: CGPoint(x: rect.midX, y: rect.maxY * 1.1))
            path.addQuadCurve(to: left, control: CGPoint(x: rect.midX, y: rect.midY + rect.height * 0.12))
            path.closeSubpath()
        case .smirk:
            path.move(to: CGPoint(x: rect.minX, y: rect.midY + rect.height * 0.12))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY), control: CGPoint(x: rect.midX, y: rect.midY))
        case .neutral:
            path.move(to: left)
            path.addLine(to: right)
        case .open:
            path.addEllipse(in: rect.insetBy(dx: rect.width * 0.16, dy: 0))
        case .soft:
            path.move(to: left)
            path.addQuadCurve(to: right, control: CGPoint(x: rect.midX, y: rect.maxY * 0.55))
        }

        return path
    }
}
