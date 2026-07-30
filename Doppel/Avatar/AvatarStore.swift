import Foundation
import Observation
import Supabase

/// Single source of truth for the user's identity within Bamboo: their name
/// and their digital twin. Persists to UserDefaults so the twin greets you
/// the same way every time you open the app -- and, once signed in, syncs
/// that same data to Supabase so it follows you to a new device too.
///
/// UserDefaults stays in the loop even though there's now a backend: it's
/// what makes the avatar show up instantly on launch instead of waiting on
/// a network round trip, and it's what a change is saved into immediately
/// even if the debounced remote push hasn't fired yet or the network is
/// down. Supabase is the thing that makes the data outlive this device.
@Observable
final class AvatarStore {
    var avatar: DoppelAvatar {
        didSet {
            guard avatar != oldValue else { return }
            persist()
            scheduleRemoteSync()
        }
    }

    var userName: String {
        didSet {
            guard userName != oldValue else { return }
            persist()
            scheduleRemoteSync()
        }
    }

    private let defaults: UserDefaults
    private let avatarKey = "doppel.avatar.v1"
    private let nameKey = "doppel.username.v1"

    private var userID: UUID?
    private var syncTask: Task<Void, Never>?

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

    // MARK: - Remote sync

    /// Called once sign-in completes. Pulls this account's saved profile
    /// down if one already exists; if this is the very first sign-in for
    /// this account, there's nothing to pull yet, so it pushes whatever's
    /// currently on-device to create that row.
    func attach(userID: UUID) async {
        self.userID = userID
        do {
            let profile: RemoteProfile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: userID)
                .single()
                .execute()
                .value
            avatar = profile.avatar
            userName = profile.userName
        } catch {
            await pushRemote()
        }
    }

    /// Called on sign-out. Resets to the default twin rather than leaving
    /// the previous account's data sitting on-device -- otherwise whoever
    /// signs in next would see a flash of a stranger's avatar and name
    /// before their own profile finishes loading.
    func detach() {
        userID = nil
        syncTask?.cancel()
        avatar = .default
        userName = "You"
    }

    private func scheduleRemoteSync() {
        guard userID != nil else { return }
        syncTask?.cancel()
        syncTask = Task {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            await pushRemote()
        }
    }

    private func pushRemote() async {
        guard let userID else { return }
        let row = RemoteProfile(id: userID, userName: userName, avatar: avatar)
        try? await supabase.from("profiles").upsert(row).execute()
    }
}

private struct RemoteProfile: Codable {
    var id: UUID
    var userName: String
    var avatar: DoppelAvatar

    enum CodingKeys: String, CodingKey {
        case id
        case userName = "user_name"
        case avatar
    }
}
