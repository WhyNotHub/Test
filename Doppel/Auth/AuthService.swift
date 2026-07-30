import Foundation
import Observation
import AuthenticationServices
import GoogleSignIn
import Supabase
import UIKit

/// Owns the signed-in/signed-out state for the whole app. Supabase's own
/// session storage (Keychain-backed) is the real source of truth for "am I
/// still logged in" across launches -- this just mirrors that into
/// something SwiftUI can watch, via the SDK's auth state stream.
@Observable
final class AuthService {
    enum State: Equatable {
        case loading
        case signedOut
        case signedIn(userID: UUID)
    }

    var state: State = .loading
    var isWorking = false
    var errorMessage: String?

    private var sessionTask: Task<Void, Never>?

    init() {
        sessionTask = Task { [weak self] in
            guard let self else { return }
            for await (event, session) in supabase.auth.authStateChanges {
                switch event {
                case .initialSession, .signedIn, .tokenRefreshed, .userUpdated:
                    if let session {
                        self.state = .signedIn(userID: session.user.id)
                    }
                case .signedOut:
                    self.state = .signedOut
                default:
                    break
                }
            }
        }
    }

    deinit {
        sessionTask?.cancel()
    }

    // MARK: - Sign in with Apple

    /// Wired up as `SignInWithAppleButton`'s `onCompletion` in LoginView --
    /// the SwiftUI button handles the ASAuthorizationController delegate
    /// dance internally, so this only ever sees the end result.
    func completeAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .failure(let error):
            if (error as? ASAuthorizationError)?.code != .canceled {
                errorMessage = error.localizedDescription
            }
        case .success(let authorization):
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8)
            else {
                errorMessage = "Apple didn't return the expected sign-in details. Please try again."
                return
            }
            // Apple only ever hands over the person's name on the very
            // first authorization -- capture it now or it's gone for good.
            let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            Task {
                await signIn(
                    credentials: .init(provider: .apple, idToken: idToken),
                    suggestedName: fullName
                )
            }
        }
    }

    // MARK: - Sign in with Google

    @MainActor
    func signInWithGoogle() {
        guard let presenter = Self.topViewController() else {
            errorMessage = "Couldn't find a screen to present Google Sign-In from."
            return
        }
        isWorking = true
        Task {
            defer { isWorking = false }
            do {
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
                guard let idToken = result.user.idToken?.tokenString else {
                    errorMessage = "Google didn't return the expected sign-in details. Please try again."
                    return
                }
                await signIn(
                    credentials: .init(
                        provider: .google,
                        idToken: idToken,
                        accessToken: result.user.accessToken.tokenString
                    ),
                    suggestedName: result.user.profile?.name
                )
            } catch {
                if (error as? GIDSignInError)?.code != .canceled {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Shared

    private func signIn(credentials: OpenIDConnectCredentials, suggestedName: String?) async {
        isWorking = true
        defer { isWorking = false }
        do {
            try await supabase.auth.signInWithIdToken(credentials: credentials)
            if let suggestedName, !suggestedName.isEmpty {
                try? await supabase.auth.update(user: UserAttributes(data: ["full_name": .string(suggestedName)]))
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        Task {
            try? await supabase.auth.signOut()
            GIDSignIn.sharedInstance.signOut()
        }
    }

    /// Permanently deletes the signed-in user's account and all their data.
    /// Backed by a `delete_user` Postgres function invoked over RPC -- the
    /// anon key can never delete an auth user directly (by design), so this
    /// needs the SQL function from the setup guide to exist first.
    func deleteAccount() async {
        isWorking = true
        defer { isWorking = false }
        do {
            try await supabase.rpc("delete_user").execute()
            try await supabase.auth.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private static func topViewController() -> UIViewController? {
        guard
            let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
            let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else { return nil }

        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}
