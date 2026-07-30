import Foundation
import Observation

/// Single source of truth for the user's identity within Doppel: their name
/// and their digital twin. Persists to UserDefaults so the twin greets you
/// the same way every time you open the app.
@Observable
final class AvatarStore {
    var avatar: DoppelAvatar {
        didSet { persist() }
    }

    var userName: String {
        didSet { persist() }
    }

    private let defaults: UserDefaults
    private let avatarKey = "doppel.avatar.v1"
    private let nameKey = "doppel.username.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let data = defaults.data(forKey: avatarKey),
           let decoded = try? JSONDecoder().decode(DoppelAvatar.self, from: data) {
            avatar = decoded
        } else {
            avatar = .default
        }

        userName = defaults.string(forKey: nameKey) ?? "You"
    }

    func resetAvatar() {
        avatar = .default
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(avatar) {
            defaults.set(data, forKey: avatarKey)
        }
        defaults.set(userName, forKey: nameKey)
    }
}
