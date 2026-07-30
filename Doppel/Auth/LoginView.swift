import SwiftUI
import AuthenticationServices

/// The very first thing anyone sees. Kept to exactly what it needs: a mark,
/// one line of copy, and the two ways in. Apple's button has to stay one of
/// its HIG-mandated styles (can't be arbitrarily restyled), so `.white` was
/// picked to match the flat, high-contrast pill language the rest of the
/// app already uses -- the custom Google button then mirrors that same
/// shape/weight so the two read as one matched pair, not two different
/// button systems glued together.
struct LoginView: View {
    @Environment(AuthService.self) private var auth

    var body: some View {
        ZStack {
            DoppelColor.void.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: DoppelSpacing.sm) {
                    Text("BAMBOO")
                        .font(DoppelFont.display(38))
                        .foregroundStyle(DoppelColor.textPrimary)

                    Text("Your digital twin, saved to you.\nSign in to keep it that way.")
                        .multilineTextAlignment(.center)
                        .font(DoppelFont.body(15))
                        .foregroundStyle(DoppelColor.textSecondary)
                        .lineSpacing(4)
                }

                Spacer()

                VStack(spacing: DoppelSpacing.sm) {
                    SignInWithAppleButton(.continue) { request in
                        request.requestedScopes = [.fullName]
                    } onCompletion: { result in
                        auth.completeAppleSignIn(result)
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 54)
                    .clipShape(Capsule())

                    Button {
                        auth.signInWithGoogle()
                    } label: {
                        HStack(spacing: DoppelSpacing.sm) {
                            Image("GoogleLogo")
                                .resizable()
                                .frame(width: 18, height: 18)
                            Text("Continue with Google")
                                .font(DoppelFont.bodyBold(15))
                        }
                        .foregroundStyle(DoppelColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            Capsule()
                                .fill(DoppelColor.surfaceElevated)
                                .overlay(Capsule().stroke(DoppelColor.hairline, lineWidth: 1.5))
                        )
                    }
                    .buttonStyle(PressableStyle())
                }
                .disabled(auth.isWorking)
                .opacity(auth.isWorking ? 0.5 : 1)
            }
            .padding(.horizontal, DoppelSpacing.lg)
            .padding(.bottom, DoppelSpacing.xl)

            if auth.isWorking {
                ProgressView()
                    .tint(DoppelColor.textPrimary)
            }
        }
        .alert(
            "Sign-in failed",
            isPresented: Binding(
                get: { auth.errorMessage != nil },
                set: { isPresented in if !isPresented { auth.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(auth.errorMessage ?? "")
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    LoginView()
        .environment(AuthService())
}
