import SwiftUI

/// Hand-drawn glyphs matching the icons designed and screenshot-verified
/// in the HTML preview, used in place of SF Symbols for the app's own
/// custom icon language (SF Symbols read as generic/default no matter how
/// they're colored or sized). Each is a `Shape`, not a fixed-size `View`:
/// `path(in:)` scales its coordinates to whatever rect it's actually
/// drawn in (design space is 16x16, matching the HTML/SVG source), so a
/// glyph renders correctly at any of the sizes IconButton uses.
///
/// The reset arc is built as a dense polyline (32 points) rather than
/// through `Path.addArc(clockwise:)` -- that API's clockwise direction is
/// a well-documented source of subtle bugs once y increases downward the
/// way both SVG and SwiftUI's Path coordinate space do, and there's no
/// compiler or simulator here to catch getting it backwards. A polyline
/// has no direction ambiguity: the points themselves, computed with the
/// same trig used to verify the HTML version, are the geometry.
enum Glyph {
    struct Checkmark: Shape {
        func path(in rect: CGRect) -> Path {
            let s = rect.width / 16
            var p = Path()
            p.move(to: CGPoint(x: 3.5 * s, y: 8.5 * s))
            p.addLine(to: CGPoint(x: 6.5 * s, y: 11.5 * s))
            p.addLine(to: CGPoint(x: 12.5 * s, y: 4.5 * s))
            return p
        }
    }

    /// Coordinates here are already normalized to 0...1 (unlike the other
    /// glyphs' raw 0...16 design space), since they came straight out of
    /// the point-sampling script as fractions -- so this scales by
    /// `rect.width` directly, not `rect.width / 16`.
    struct ResetArc: Shape {
        func path(in rect: CGRect) -> Path {
            let s = rect.width
            var p = Path()
            p.move(to: CGPoint(x: 0.67188 * s, y: 0.20230 * s))
            p.addLine(to: CGPoint(x: 0.71222 * s, y: 0.22958 * s))
            p.addLine(to: CGPoint(x: 0.74831 * s, y: 0.26229 * s))
            p.addLine(to: CGPoint(x: 0.77942 * s, y: 0.29977 * s))
            p.addLine(to: CGPoint(x: 0.80491 * s, y: 0.34127 * s))
            p.addLine(to: CGPoint(x: 0.82428 * s, y: 0.38596 * s))
            p.addLine(to: CGPoint(x: 0.83714 * s, y: 0.43294 * s))
            p.addLine(to: CGPoint(x: 0.84324 * s, y: 0.48126 * s))
            p.addLine(to: CGPoint(x: 0.84244 * s, y: 0.52996 * s))
            p.addLine(to: CGPoint(x: 0.83477 * s, y: 0.57806 * s))
            p.addLine(to: CGPoint(x: 0.82038 * s, y: 0.62459 * s))
            p.addLine(to: CGPoint(x: 0.79955 * s, y: 0.66862 * s))
            p.addLine(to: CGPoint(x: 0.77272 * s, y: 0.70926 * s))
            p.addLine(to: CGPoint(x: 0.74040 * s, y: 0.74570 * s))
            p.addLine(to: CGPoint(x: 0.70326 * s, y: 0.77722 * s))
            p.addLine(to: CGPoint(x: 0.66204 * s, y: 0.80316 * s))
            p.addLine(to: CGPoint(x: 0.61757 * s, y: 0.82302 * s))
            p.addLine(to: CGPoint(x: 0.57074 * s, y: 0.83639 * s))
            p.addLine(to: CGPoint(x: 0.52248 * s, y: 0.84301 * s))
            p.addLine(to: CGPoint(x: 0.47378 * s, y: 0.84275 * s))
            p.addLine(to: CGPoint(x: 0.42560 * s, y: 0.83560 * s))
            p.addLine(to: CGPoint(x: 0.37891 * s, y: 0.82172 * s))
            p.addLine(to: CGPoint(x: 0.33466 * s, y: 0.80137 * s))
            p.addLine(to: CGPoint(x: 0.29373 * s, y: 0.77498 * s))
            p.addLine(to: CGPoint(x: 0.25693 * s, y: 0.74307 * s))
            p.addLine(to: CGPoint(x: 0.22502 * s, y: 0.70627 * s))
            p.addLine(to: CGPoint(x: 0.19863 * s, y: 0.66534 * s))
            p.addLine(to: CGPoint(x: 0.17828 * s, y: 0.62109 * s))
            p.addLine(to: CGPoint(x: 0.16440 * s, y: 0.57440 * s))
            p.addLine(to: CGPoint(x: 0.15725 * s, y: 0.52622 * s))
            p.addLine(to: CGPoint(x: 0.15699 * s, y: 0.47752 * s))
            p.addLine(to: CGPoint(x: 0.16361 * s, y: 0.42926 * s))
            p.addLine(to: CGPoint(x: 0.17698 * s, y: 0.38243 * s))
            return p
        }
    }

    struct ResetArrowhead: Shape {
        func path(in rect: CGRect) -> Path {
            let s = rect.width / 16
            var p = Path()
            p.move(to: CGPoint(x: 8.50 * s, y: 1.94 * s))
            p.addLine(to: CGPoint(x: 12.42 * s, y: 2.94 * s))
            p.addLine(to: CGPoint(x: 11.33 * s, y: 4.83 * s))
            p.closeSubpath()
            return p
        }
    }

    /// A diagonal pencil silhouette (body quad + triangular tip) rather
    /// than SF Symbol "pencil" -- pure line segments, no arcs, so this
    /// one has no geometry-conversion risk at all.
    struct Pencil: Shape {
        func path(in rect: CGRect) -> Path {
            let s = rect.width / 16
            var p = Path()
            p.move(to: CGPoint(x: 3.52 * s, y: 11.55 * s))
            p.addLine(to: CGPoint(x: 9.05 * s, y: 4.96 * s))
            p.addLine(to: CGPoint(x: 10.81 * s, y: 6.44 * s))
            p.addLine(to: CGPoint(x: 5.28 * s, y: 13.03 * s))
            p.closeSubpath()
            p.move(to: CGPoint(x: 9.05 * s, y: 4.96 * s))
            p.addLine(to: CGPoint(x: 11.60 * s, y: 3.71 * s))
            p.addLine(to: CGPoint(x: 10.81 * s, y: 6.44 * s))
            p.closeSubpath()
            return p
        }
    }

    /// Two weights + a bar, all rounded rects -- no arcs, so this is
    /// built with `addRoundedRect` sub-paths rather than a hand-placed
    /// ZStack of shapes (which wouldn't automatically rescale to
    /// whatever size the glyph is drawn at the way `path(in:)` does).
    struct Dumbbell: Shape {
        func path(in rect: CGRect) -> Path {
            let s = rect.width / 16
            var p = Path()
            p.addRoundedRect(in: CGRect(x: 1 * s, y: 5.5 * s, width: 2.2 * s, height: 5 * s), cornerSize: CGSize(width: s, height: s))
            p.addRoundedRect(in: CGRect(x: 12.8 * s, y: 5.5 * s, width: 2.2 * s, height: 5 * s), cornerSize: CGSize(width: s, height: s))
            p.addRoundedRect(in: CGRect(x: 3.2 * s, y: 7 * s, width: 9.6 * s, height: 2 * s), cornerSize: CGSize(width: s, height: s))
            return p
        }
    }

    /// Handle + body as two overlapping rounded rects -- deliberately not
    /// an open handle arc sitting above the body (that needs a
    /// top-corners-only rounded rect or an arc, both riskier), which also
    /// sidesteps needing to know what background color the icon sits on.
    struct Briefcase: Shape {
        func path(in rect: CGRect) -> Path {
            let s = rect.width / 16
            var p = Path()
            p.addRoundedRect(in: CGRect(x: 2.5 * s, y: 3 * s, width: 7 * s, height: 4.4 * s), cornerSize: CGSize(width: 1.4 * s, height: 1.4 * s))
            p.addRoundedRect(in: CGRect(x: 1.5 * s, y: 5.4 * s, width: 13 * s, height: 8.1 * s), cornerSize: CGSize(width: 1.8 * s, height: 1.8 * s))
            return p
        }
    }

    /// The mortarboard diamond + a straight-sided band, filled. Was a
    /// curved band (cubic bezier under the diamond in the original SVG);
    /// simplified to a plain rounded rect here rather than translate
    /// bezier control points by hand with no way to render and check.
    struct Graduation: Shape {
        func path(in rect: CGRect) -> Path {
            let s = rect.width / 16
            var p = Path()
            p.move(to: CGPoint(x: 8 * s, y: 3 * s))
            p.addLine(to: CGPoint(x: 14.5 * s, y: 6.2 * s))
            p.addLine(to: CGPoint(x: 8 * s, y: 9.4 * s))
            p.addLine(to: CGPoint(x: 1.5 * s, y: 6.2 * s))
            p.closeSubpath()
            p.addRoundedRect(in: CGRect(x: 4.6 * s, y: 7.6 * s, width: 6.8 * s, height: 2.9 * s), cornerSize: CGSize(width: 0.6 * s, height: 0.6 * s))
            return p
        }
    }

    /// The graduation cap's tassel -- a separate stroked line, since it
    /// can't share a single fill pass with the diamond+band above.
    struct GraduationTassel: Shape {
        func path(in rect: CGRect) -> Path {
            let s = rect.width / 16
            var p = Path()
            p.move(to: CGPoint(x: 14.5 * s, y: 6.2 * s))
            p.addLine(to: CGPoint(x: 14.5 * s, y: 10 * s))
            return p
        }
    }
}

/// The reset icon is two pieces (arc + separate arrowhead) layered
/// together, matching the HTML source exactly.
struct ResetGlyph: View {
    var body: some View {
        ZStack {
            Glyph.ResetArc()
                .stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
            Glyph.ResetArrowhead()
                .fill()
        }
    }
}

/// Diamond + band (filled) with the tassel (stroked) layered on top.
struct GraduationGlyph: View {
    var body: some View {
        ZStack {
            Glyph.Graduation().fill()
            Glyph.GraduationTassel()
                .stroke(style: StrokeStyle(lineWidth: 1.2, lineCap: .round))
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        Glyph.Checkmark()
            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            .frame(width: 22, height: 22)
        ResetGlyph()
            .frame(width: 22, height: 22)
        Glyph.Pencil()
            .fill()
            .frame(width: 22, height: 22)
        Glyph.Dumbbell()
            .fill()
            .frame(width: 22, height: 22)
        Glyph.Briefcase()
            .fill()
            .frame(width: 22, height: 22)
        GraduationGlyph()
            .frame(width: 22, height: 22)
    }
    .foregroundStyle(.white)
    .padding()
    .background(DoppelColor.void)
}
