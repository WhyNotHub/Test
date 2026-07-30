import SwiftUI

@main
struct DoppelApp: App {
    @State private var store = AvatarStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(store)
                .preferredColorScheme(.dark)
        }
    }
}
