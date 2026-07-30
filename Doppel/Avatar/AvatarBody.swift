import SwiftUI

enum HairLayer {
    case back, front
}

/// Every hair style is built from plain primitives (circles, capsules,
/// rounded rects) rather than freehand bezier curves — it keeps the whole
/// system easy to extend with new styles and guarantees it always renders
/// as a clean, intentional silhouette.
struct HairView: View {
    var style: HairStyle
    var color: Color
    var layer: HairLayer
    var side: CGFloat
    var headCenter: CGPoint
    var headSize: CGSize

    var body: some View {
        switch layer {
        case .back: backContent
        case .front: frontContent
        }
    }

    /// Every hair piece shares one gradient (light top -> darker base) so
    /// the whole head of hair reads as one lit, rounded volume no matter
    /// how many separate shapes it's built from.
    private var hairFill: LinearGradient {
        LinearGradient(
            colors: [color.lightened(by: 0.22), color.darkened(by: 0.16)],
            startPoint: UnitPoint(x: 0.2, y: 0), endPoint: UnitPoint(x: 0.65, y: 1)
        )
    }

    @ViewBuilder
    private var backContent: some View {
        if style == .long {
            ForEach(AvatarMetrics.mirror, id: \.self) { dir in
                Capsule()
                    .fill(hairFill)
                    .frame(width: headSize.width * 0.30, height: headSize.height * 1.15)
                    .position(
                        x: headCenter.x + dir * headSize.width * 0.40,
                        y: headCenter.y + headSize.height * 0.42
                    )
            }
        }
    }

    @ViewBuilder
    private var frontContent: some View {
        switch style {
        case .shaved:
            EmptyView()
        case .buzz:
            capBand(heightFraction: 0.30, widthFraction: 0.98)
        case .crop:
            ZStack {
                capBand(heightFraction: 0.38, widthFraction: 1.0)
                ForEach(AvatarMetrics.mirror, id: \.self) { dir in
                    RoundedRectangle(cornerRadius: headSize.width * 0.06, style: .continuous)
                        .fill(hairFill)
                        .frame(width: headSize.width * 0.14, height: headSize.height * 0.30)
                        .position(
                            x: headCenter.x + dir * headSize.width * 0.44,
                            y: headCenter.y - headSize.height * 0.14
                        )
                }
            }
        case .waves:
            ZStack {
                capBand(heightFraction: 0.40, widthFraction: 1.06)
                ForEach(AvatarMetrics.mirror, id: \.self) { dir in
                    Capsule()
                        .fill(hairFill)
                        .frame(width: headSize.width * 0.22, height: headSize.height * 0.42)
                        .rotationEffect(.degrees(Double(dir) * 22))
                        .position(
                            x: headCenter.x + dir * headSize.width * 0.46,
                            y: headCenter.y - headSize.height * 0.08
                        )
                }
            }
        case .curls:
            ZStack {
                ForEach(Array(curlOffsets.enumerated()), id: \.offset) { _, point in
                    Circle()
                        .fill(hairFill)
                        .frame(width: headSize.width * 0.24, height: headSize.width * 0.24)
                        .position(
                            x: headCenter.x + point.0 * headSize.width,
                            y: headCenter.y + point.1 * headSize.height
                        )
                }
            }
        case .long:
            capBand(heightFraction: 0.34, widthFraction: 1.0)
        case .bun:
            ZStack {
                capBand(heightFraction: 0.36, widthFraction: 1.02)
                Circle()
                    .fill(hairFill)
                    .frame(width: headSize.width * 0.24, height: headSize.width * 0.24)
                    .position(x: headCenter.x, y: headCenter.y - headSize.height * 0.62)
            }
        case .mohawk:
            Capsule()
                .fill(hairFill)
                .frame(width: headSize.width * 0.16, height: headSize.height * 0.62)
                .position(x: headCenter.x, y: headCenter.y - headSize.height * 0.42)
        }
    }

    /// A rounded band sitting on (and slightly above) the head's top edge —
    /// the base building block for buzz, crop, waves, long and bun styles.
    private func capBand(heightFraction: CGFloat, widthFraction: CGFloat) -> some View {
        let bandHeight = headSize.height * heightFraction
        let headTopY = headCenter.y - headSize.height / 2
        let overshoot = headSize.height * 0.05

        return RoundedRectangle(cornerRadius: headSize.width * 0.4, style: .continuous)
            .fill(hairFill)
            .frame(width: headSize.width * widthFraction, height: bandHeight)
            .position(x: headCenter.x, y: headTopY - overshoot + bandHeight / 2)
    }

    private var curlOffsets: [(CGFloat, CGFloat)] {
        [(-0.20, -0.30), (-0.08, -0.36), (0.05, -0.37), (0.18, -0.32), (0.26, -0.20), (-0.28, -0.16)]
    }
}

/// A simple neck-to-hip silhouette: narrow at the collar, widening at the
/// shoulders, full width at the hips. One shape reused for every outfit —
/// styles differentiate themselves with small decorations layered on top.
struct TorsoShape: Shape {
    var neckWidthFraction: CGFloat = 0.19
    var shoulderWidthFraction: CGFloat = 0.70
    var collarDepthFraction: CGFloat = 0.10

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let cx = rect.midX

        let neckHalf = w * neckWidthFraction / 2
        let shoulderHalf = w * shoulderWidthFraction / 2
        let hipHalf = w / 2

        let neckY = rect.minY
        let shoulderY = rect.minY + h * collarDepthFraction
        let bottomY = rect.maxY

        var path = Path()
        path.move(to: CGPoint(x: cx - neckHalf, y: neckY))
        path.addLine(to: CGPoint(x: cx - shoulderHalf, y: shoulderY))
        path.addLine(to: CGPoint(x: cx - hipHalf, y: bottomY))
        path.addLine(to: CGPoint(x: cx + hipHalf, y: bottomY))
        path.addLine(to: CGPoint(x: cx + shoulderHalf, y: shoulderY))
        path.addLine(to: CGPoint(x: cx + neckHalf, y: neckY))
        path.addQuadCurve(
            to: CGPoint(x: cx - neckHalf, y: neckY),
            control: CGPoint(x: cx, y: neckY + h * collarDepthFraction * 0.6)
        )
        path.closeSubpath()
        return path
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct TorsoView: View {
    var avatar: DoppelAvatar
    var side: CGFloat
    var headCenter: CGPoint
    var headSize: CGSize

    private var torsoWidth: CGFloat { side * 0.94 }
    private var torsoTopY: CGFloat { headCenter.y + headSize.height * 0.52 }
    private var torsoHeight: CGFloat { max(side * 1.05 - torsoTopY, side * 0.2) }

    var body: some View {
        ZStack {
            neck
            base
            decoration
        }
    }

    /// A touch darker than the lit face, suggesting the jaw's shadow.
    private var neck: some View {
        RoundedRectangle(cornerRadius: side * 0.03, style: .continuous)
            .fill(avatar.skinTone.color.darkened(by: 0.06))
            .frame(width: side * 0.16, height: side * 0.16)
            .position(x: headCenter.x, y: headCenter.y + headSize.height * 0.46)
    }

    /// Vertical gradient (lighter at the collar, darker toward the hem)
    /// reads as soft fabric shading instead of a flat color block.
    private var base: some View {
        TorsoShape(
            neckWidthFraction: avatar.outfitStyle == .tank ? 0.24 : 0.19,
            shoulderWidthFraction: avatar.outfitStyle == .tank ? 0.56 : 0.70,
            collarDepthFraction: 0.10
        )
        .fill(
            LinearGradient(
                colors: [avatar.outfitColor.color.lightened(by: 0.14), avatar.outfitColor.color.darkened(by: 0.20)],
                startPoint: .top, endPoint: .bottom
            )
        )
        .frame(width: torsoWidth, height: torsoHeight)
        .position(x: headCenter.x, y: torsoTopY + torsoHeight / 2)
    }

    @ViewBuilder
    private var decoration: some View {
        switch avatar.outfitStyle {
        case .crew, .tank:
            EmptyView()
        case .hoodie:
            ZStack {
                Capsule()
                    .stroke(avatar.outfitColor.color.opacity(0.6), lineWidth: side * 0.012)
                    .frame(width: side * 0.30, height: side * 0.16)
                    .position(x: headCenter.x, y: torsoTopY + side * 0.02)

                ForEach(AvatarMetrics.mirror, id: \.self) { dir in
                    Circle()
                        .fill(DoppelColor.textPrimary.opacity(0.85))
                        .frame(width: side * 0.016, height: side * 0.016)
                        .position(x: headCenter.x + dir * side * 0.03, y: torsoTopY + side * 0.06)
                }
            }
        case .turtleneck:
            Capsule()
                .fill(avatar.outfitColor.color)
                .frame(width: side * 0.20, height: side * 0.12)
                .position(x: headCenter.x, y: headCenter.y + headSize.height * 0.44)
        case .collar:
            ForEach(AvatarMetrics.mirror, id: \.self) { dir in
                Triangle()
                    .fill(DoppelColor.void.opacity(0.16))
                    .frame(width: side * 0.07, height: side * 0.07)
                    .rotationEffect(.degrees(Double(dir) * 20))
                    .position(x: headCenter.x + dir * side * 0.07, y: torsoTopY + side * 0.045)
            }
        }
    }
}

struct AccessoryView: View {
    var avatar: DoppelAvatar
    var side: CGFloat
    var headCenter: CGPoint
    var headSize: CGSize

    private var eyeOffsetX: CGFloat { AvatarMetrics.eyeOffsetX(side: side) }
    private var eyeCenterY: CGFloat { AvatarMetrics.eyeCenterY(headCenter: headCenter, headSize: headSize) }

    var body: some View {
        switch avatar.accessory {
        case .none:
            EmptyView()
        case .glasses:
            glasses(lensOpacity: 0.32)
        case .shades:
            glasses(lensOpacity: 1.0)
        case .earrings:
            ForEach(AvatarMetrics.mirror, id: \.self) { dir in
                Circle()
                    .fill(avatar.auraPalette.colors.first ?? DoppelColor.violet)
                    .frame(width: side * 0.028, height: side * 0.028)
                    .position(
                        x: headCenter.x + dir * (headSize.width / 2) * 0.98,
                        y: headCenter.y + headSize.height * 0.16
                    )
            }
        case .headphones:
            ZStack {
                headphoneBand
                    .stroke(DoppelColor.surfaceElevated, style: StrokeStyle(lineWidth: side * 0.026, lineCap: .round))

                ForEach(AvatarMetrics.mirror, id: \.self) { dir in
                    RoundedRectangle(cornerRadius: side * 0.02, style: .continuous)
                        .fill(DoppelColor.surfaceElevated)
                        .frame(width: side * 0.06, height: side * 0.11)
                        .position(x: headCenter.x + dir * headSize.width * 0.53, y: headCenter.y + headSize.height * 0.04)
                }
            }
        case .cap:
            ZStack {
                RoundedRectangle(cornerRadius: headSize.width * 0.4, style: .continuous)
                    .fill(DoppelColor.surfaceElevated)
                    .frame(width: headSize.width * 1.02, height: headSize.height * 0.38)
                    .position(x: headCenter.x, y: headCenter.y - headSize.height * 0.34)
                Ellipse()
                    .fill(DoppelColor.surfaceElevated)
                    .frame(width: headSize.width * 0.5, height: headSize.height * 0.10)
                    .position(x: headCenter.x + headSize.width * 0.30, y: headCenter.y - headSize.height * 0.20)
            }
        }
    }

    /// Built from raw trig rather than `Path.addArc` so the sweep direction
    /// (over the top of the head, not under the chin) is unambiguous.
    private var headphoneBand: Path {
        var path = Path()
        let radius = headSize.width * 0.62
        let steps = 24
        let startDeg: CGFloat = 200
        let endDeg: CGFloat = 340

        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let deg = startDeg + (endDeg - startDeg) * t
            let rad = deg * .pi / 180
            let point = CGPoint(
                x: headCenter.x + radius * cos(rad),
                y: headCenter.y + radius * sin(rad)
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        return path
    }

    private func glasses(lensOpacity: Double) -> some View {
        let lensSize = side * 0.11

        return ZStack {
            Rectangle()
                .fill(DoppelColor.void)
                .frame(width: side * 0.05, height: side * 0.01)
                .position(x: headCenter.x, y: eyeCenterY)

            ForEach(AvatarMetrics.mirror, id: \.self) { dir in
                ZStack {
                    RoundedRectangle(cornerRadius: side * 0.025, style: .continuous)
                        .fill(DoppelColor.void.opacity(lensOpacity))
                    RoundedRectangle(cornerRadius: side * 0.025, style: .continuous)
                        .stroke(DoppelColor.void, lineWidth: side * 0.012)
                }
                .frame(width: lensSize, height: lensSize * 0.8)
                .position(x: headCenter.x + dir * eyeOffsetX, y: eyeCenterY)
            }
        }
    }
}
