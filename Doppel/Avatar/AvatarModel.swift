import SwiftUI

/// The full description of a user's digital twin. Value type + Codable so it
/// can be persisted, diffed, and cheaply copied for live preview thumbnails.
struct DoppelAvatar: Codable, Equatable {
    var skinTone: SkinTone = .amber
    var hairStyle: HairStyle = .waves
    var hairColor: HairColor = .midnight
    var eyeStyle: EyeStyle = .round
    var mouthStyle: MouthStyle = .smile
    var outfitStyle: OutfitStyle = .crew
    var outfitColor: OutfitColor = .violet
    var accessory: Accessory = .none
    var auraPalette: AuraPalette = .violetPink

    static let `default` = DoppelAvatar()

    func with(hairStyle: HairStyle) -> DoppelAvatar {
        var copy = self
        copy.hairStyle = hairStyle
        return copy
    }

    func with(outfitStyle: OutfitStyle) -> DoppelAvatar {
        var copy = self
        copy.outfitStyle = outfitStyle
        return copy
    }

    func with(accessory: Accessory) -> DoppelAvatar {
        var copy = self
        copy.accessory = accessory
        return copy
    }
}

enum SkinTone: String, Codable, CaseIterable, Identifiable {
    case porcelain, ivory, honey, amber, umber, espresso

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .porcelain: Color(hex: 0xFCE3D3)
        case .ivory: Color(hex: 0xF3C7A0)
        case .honey: Color(hex: 0xE0A874)
        case .amber: Color(hex: 0xC17A4E)
        case .umber: Color(hex: 0x8B5334)
        case .espresso: Color(hex: 0x5A3624)
        }
    }
}

enum HairColor: String, Codable, CaseIterable, Identifiable {
    case midnight, cocoa, sand, platinum, crimson, violetDye, iceDye

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .midnight: Color(hex: 0x1C1B22)
        case .cocoa: Color(hex: 0x5B3A29)
        case .sand: Color(hex: 0xC9A26D)
        case .platinum: Color(hex: 0xE7E4DD)
        case .crimson: Color(hex: 0xB33951)
        case .violetDye: DoppelColor.violet
        case .iceDye: DoppelColor.ice
        }
    }
}

enum HairStyle: String, Codable, CaseIterable, Identifiable {
    case shaved, buzz, crop, waves, curls, long, bun, mohawk

    var id: String { rawValue }

    var label: String {
        switch self {
        case .shaved: "Shaved"
        case .buzz: "Buzz"
        case .crop: "Crop"
        case .waves: "Waves"
        case .curls: "Curls"
        case .long: "Long"
        case .bun: "Bun"
        case .mohawk: "Mohawk"
        }
    }
}

enum EyeStyle: String, Codable, CaseIterable, Identifiable {
    case round, almond, sleepy, wide, wink

    var id: String { rawValue }

    var label: String {
        switch self {
        case .round: "Round"
        case .almond: "Almond"
        case .sleepy: "Sleepy"
        case .wide: "Wide"
        case .wink: "Wink"
        }
    }
}

enum MouthStyle: String, Codable, CaseIterable, Identifiable {
    case smile, grin, smirk, neutral, open, soft

    var id: String { rawValue }

    var label: String {
        switch self {
        case .smile: "Smile"
        case .grin: "Grin"
        case .smirk: "Smirk"
        case .neutral: "Neutral"
        case .open: "Open"
        case .soft: "Soft"
        }
    }
}

enum OutfitStyle: String, Codable, CaseIterable, Identifiable {
    case crew, hoodie, turtleneck, collar, tank

    var id: String { rawValue }

    var label: String {
        switch self {
        case .crew: "Crew"
        case .hoodie: "Hoodie"
        case .turtleneck: "Turtle"
        case .collar: "Collar"
        case .tank: "Tank"
        }
    }
}

enum OutfitColor: String, Codable, CaseIterable, Identifiable {
    case violet, pink, lime, ice, sunset, mono

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .violet: DoppelColor.violet
        case .pink: DoppelColor.pink
        case .lime: DoppelColor.lime
        case .ice: DoppelColor.ice
        case .sunset: DoppelColor.sunset
        case .mono: DoppelColor.surfaceElevated
        }
    }
}

enum Accessory: String, Codable, CaseIterable, Identifiable {
    case none, glasses, shades, earrings, headphones, cap

    var id: String { rawValue }

    var label: String {
        switch self {
        case .none: "None"
        case .glasses: "Glasses"
        case .shades: "Shades"
        case .earrings: "Earrings"
        case .headphones: "Headphones"
        case .cap: "Cap"
        }
    }
}

enum AuraPalette: String, Codable, CaseIterable, Identifiable {
    case violetPink, limeIce, sunsetPink, mono

    var id: String { rawValue }

    var label: String {
        switch self {
        case .violetPink: "Nova"
        case .limeIce: "Volt"
        case .sunsetPink: "Ember"
        case .mono: "Mono"
        }
    }

    var colors: [Color] {
        switch self {
        case .violetPink: [DoppelColor.violet, DoppelColor.pink]
        case .limeIce: [DoppelColor.lime, DoppelColor.ice]
        case .sunsetPink: [DoppelColor.sunset, DoppelColor.pink]
        case .mono: [DoppelColor.textSecondary, DoppelColor.surfaceElevated]
        }
    }
}
