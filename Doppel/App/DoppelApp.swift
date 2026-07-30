import SwiftUI
import GoogleSignIn

@main
struct DoppelApp: App {
    @State private var store = AvatarStore()
    @State private var auth = AuthService()

    var body: some Scene {
        WindowGroup {
            Group {
                switch auth.state {
                case .loading:
                    DoppelColor.void.ignoresSafeArea()
                case .signedOut:
                    LoginView()
                case .signedIn:
                    HomeView()
                }
            }
            .environment(store)
            .environment(auth)
            .preferredColorScheme(.dark)
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
            .onChange(of: auth.state) { _, newState in
                switch newState {
                case .signedIn(let userID):
                    Task { await store.attach(userID: userID) }
                case .signedOut:
                    store.detach()
                case .loading:
                    break
                }
            }
        }
    }
}
