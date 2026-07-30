import SwiftUI

/// A tight, custom type scale: Unbounded (geometric, blocky, loud) for
/// anything display/headline-sized, Outfit (clean grotesk) for body and
/// caption text. Bundled as static-weight TTFs (see Resources/Fonts and
/// Info.plist's UIAppFonts) rather than the system font, matching the
/// fonts already used in the HTML design preview.
///
/// Each case here is backed by one specific weight file, not a weight
/// *trait* -- stacking a `.fontWeight()` modifier on top of any of these
/// asks CoreText to synthesize a heavier face on top of an already-static
/// design, which looks noticeably worse than using the real weight file.
/// If you need a different weight, add a case here instead.
enum DoppelFont {
    static func display(_ size: CGFloat = 42) -> Font {
        .custom("Unbounded-ExtraBold", size: size)
    }

    static func title(_ size: CGFloat = 28) -> Font {
        .custom("Unbounded-ExtraBold", size: size)
    }

    static func headline(_ size: CGFloat = 20) -> Font {
        .custom("Unbounded-Bold", size: size)
    }

    static func body(_ size: CGFloat = 17) -> Font {
        .custom("OutfitThin-Regular", size: size)
    }

    static func bodyBold(_ size: CGFloat = 17) -> Font {
        .custom("OutfitThin-Bold", size: size)
    }

    static func caption(_ size: CGFloat = 13) -> Font {
        .custom("OutfitThin-Medium", size: size)
    }
}
