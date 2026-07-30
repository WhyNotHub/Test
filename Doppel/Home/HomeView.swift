import SwiftUI

/// The main menu. A live, animated render of the user's digital twin sits
/// front and center — tapping it opens the customize sheet. Everything else
/// is intentionally out of the way.
struct HomeView: View {
    @Environment(AvatarStore.self) private var store

    @State private var showCustomize = false
    @State private var showSettings = false
    @State private var pendingRename = false
    @State private var showRename = false
    @State private var draftName = ""
    @State private var showComingSoon = false

    var body: some View {
        NavigationStack {
            ZStack {
                GlowBackground(colors: store.avatar.auraPalette.colors)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    topBar

                    DayStrip()
                        .padding(.top, DoppelSpacing.lg)

                    Spacer(minLength: DoppelSpacing.lg)

                    avatarHero

                    Spacer(minLength: DoppelSpacing.md)

                    nameBlock

                    Spacer()

                    PrimaryButton(title: "Enter Doppel") {
                        showComingSoon = true
                    }
                    .padding(.bottom, DoppelSpacing.xl)
                }
                .padding(.horizontal, DoppelSpacing.lg)
            }
            .navigationDestination(isPresented: $showComingSoon) {
                ComingSoonView()
            }
            .sheet(isPresented: $showCustomize) {
                AvatarCustomizeView()
                    .presentationDetents([.fraction(0.9)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(DoppelRadius.lg)
            }
            .sheet(isPresented: $showSettings, onDismiss: {
                guard pendingRename else { return }
                pendingRename = false
                draftName = store.userName
                showRename = true
            }) {
                SettingsSheet {
                    pendingRename = true
                    showSettings = false
                }
                .presentationDetents([.fraction(0.4)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(DoppelRadius.lg)
            }
            .alert("Rename your Doppel", isPresented: $showRename) {
                TextField("Your name", text: $draftName)
                Button("Save") {
                    let trimmed = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        store.userName = trimmed
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private var topBar: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(DoppelFont.headline(20))
                    .foregroundStyle(DoppelColor.textPrimary)

                Text(monthYearTitle)
                    .font(DoppelFont.bodyBold(12))
                    .foregroundStyle(DoppelColor.textSecondary)
                    .tracking(1.2)
            }

            Spacer()

            IconButton(systemName: "gearshape.fill") {
                showSettings = true
            }
        }
        .padding(.top, DoppelSpacing.sm)
    }

    /// Always today's actual date — deliberately not tied to the day strip's
    /// scroll position. The strip has its own independent highlight for
    /// "what you've scrolled to"; this header is a fixed orientation anchor.
    private var monthYearTitle: String {
        // Composed explicitly (rather than chaining one FormatStyle) so the
        // layout is exactly "Month Day Year" with no locale-inserted comma.
        let today = Date()
        let month = today.formatted(.dateTime.month(.wide))
        let day = today.formatted(.dateTime.day())
        let year = today.formatted(.dateTime.year())
        return "\(month) \(day) \(year)".uppercased()
    }

    private var avatarHero: some View {
        Button {
            showCustomize = true
        } label: {
            ZStack {
                AuraRing(colors: store.avatar.auraPalette.colors)
                AvatarView(avatar: store.avatar)
                    .frame(width: 230, height: 230)
            }
        }
        .buttonStyle(PressableStyle())
    }

    private var nameBlock: some View {
        Button {
            draftName = store.userName
            showRename = true
        } label: {
            HStack(spacing: DoppelSpacing.xs) {
                Text(store.userName)
                    .font(DoppelFont.title(34))
                    .foregroundStyle(DoppelColor.textPrimary)
                Image(systemName: "pencil")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(DoppelColor.textTertiary)
            }
        }
        .buttonStyle(PressableStyle())
    }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12: "Good morning"
        case 12..<17: "Good afternoon"
        case 17..<22: "Good evening"
        default: "Hey there"
        }
    }
}

struct SettingsSheet: View {
    @Environment(AvatarStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    var onRename: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("Rename Doppel", action: onRename)
                    Button("Reset Avatar", role: .destructive) {
                        store.resetAvatar()
                    }
                }
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(DoppelColor.textSecondary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(DoppelColor.void)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

/// Placeholder destination for the primary CTA — proves the navigation
/// architecture out without scope-creeping into the next feature.
struct ComingSoonView: View {
    var body: some View {
        ZStack {
            DoppelColor.void.ignoresSafeArea()

            VStack(spacing: DoppelSpacing.md) {
                Image(systemName: "sparkles")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(DoppelGradient.signature)

                Text("More of your world\nis on the way")
                    .multilineTextAlignment(.center)
                    .font(DoppelFont.headline(22))
                    .foregroundStyle(DoppelColor.textPrimary)

                Text("This is where Doppel keeps going.")
                    .font(DoppelFont.body(15))
                    .foregroundStyle(DoppelColor.textSecondary)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    HomeView()
        .environment(AvatarStore())
}
