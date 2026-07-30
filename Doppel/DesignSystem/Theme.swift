import SwiftUI

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        let r = Double((hex & 0xFF0000) >> 16) / 255
        let g = Double((hex & 0x00FF00) >> 8) / 255
        let b = Double(hex & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b, opacity: opacity)
    }
}

/// Core color tokens for Doppel. The app is designed dark-first: a near-black
/// canvas with a small set of electric accents used sparingly.
enum DoppelColor {
    static let void = Color(hex: 0x0B0B10)
    static let surface = Color(hex: 0x16161F)
    static let surfaceElevated = Color(hex: 0x1E1E2A)
    static let hairline = Color(hex: 0x2A2A35)

    static let violet = Color(hex: 0x7C5CFF)
    static let pink = Color(hex: 0xFF4FD8)
    static let lime = Color(hex: 0xC6FF3B)
    static let ice = Color(hex: 0x5CE1FF)
    static let sunset = Color(hex: 0xFF8A5C)

    static let textPrimary = Color(hex: 0xF5F5F7)
    static let textSecondary = Color(hex: 0x8E8E9A)
    static let textTertiary = Color(hex: 0x5B5B66)
}

enum DoppelGradient {
    static let signature = LinearGradient(
        colors: [DoppelColor.violet, DoppelColor.pink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func aura(_ colors: [Color]) -> AngularGradient {
        AngularGradient(colors: colors + [colors[0]], center: .center)
    }
}
