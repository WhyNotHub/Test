# Bamboo

Your digital self, front and center.

> Product name is **Bamboo** (formerly "Doppel" during early development).
> The Xcode project, scheme, source folder, bundle identifier and internal
> `Doppel*` type names (`DoppelColor`, `DoppelFont`, `DoppelAvatar`, etc.)
> still use the old name — renaming those is a much bigger, riskier change
> (touches the `.xcodeproj` file directly) and was deliberately left alone
> for now since it's invisible to anyone using the app. Everything a user
> actually sees says Bamboo.

Bamboo is an iOS app built around one idea: the home screen *is* your
digital twin — a fully custom, code-drawn character that represents you,
rendered live (not a static image), that you can reshape to look like you
and that quietly breathes and blinks while you look at it. Everything else
in the app starts from there.

## Design

- **Dark-first, ultra-minimal.** A near-black canvas, one signature
  violet → pink gradient, a lime accent used sparingly. No stock UI kit —
  every screen, control and icon in this repo is custom-built.
- **The avatar is not an image.** It's ~700 lines of SwiftUI `Shape` and
  primitive composition (circles, capsules, rounded rects, a couple of
  hand-built bezier paths) parameterized by a `DoppelAvatar` model — skin
  tone, hair style/color, eyes, mouth, outfit, accessories, aura color.
  That's what makes it fully custom and infinitely re-skinnable instead of
  a fixed illustration.
- **It feels alive.** Idle blink + breathing animation loop, a slowly
  rotating holographic aura ring, ambient drifting background glow.
- **Tap the avatar** to open the customize sheet and reshape your twin in
  real time. Tap your name to rename yourself.

## Getting started

Requires **Xcode 15.2+** and **iOS 17+** as the deployment target (uses the
`@Observable` / Observation framework).

1. Open `Doppel.xcodeproj` in Xcode.
2. Select the `Doppel` scheme and a simulator (or your device).
3. Set your own Team under **Signing & Capabilities** if running on a
   physical device (Automatic signing is already configured).
4. Run.

This project was generated outside of Xcode (no macOS toolchain was
available in the environment that built it), so **please do a first build
and fix up anything Xcode's own project-upgrade check flags** — the file
list, build settings and Info.plist keys were assembled by hand/script and
cross-validated, but an actual Xcode open/build is the real test. If the
`.xcodeproj` ever misbehaves, `project.yml` is kept in sync as a fallback:
install [XcodeGen](https://github.com/yonaskolb/XcodeGen)
(`brew install xcodegen`) and run `xcodegen generate` to regenerate a
clean project file from scratch.

## Project structure

```
Doppel/
├── App/                 App entry point + auth-state routing
├── DesignSystem/        Color, type, spacing tokens + shared view modifiers
├── Auth/                 SupabaseConfig, AuthService (Apple/Google sign-in), LoginView
├── Avatar/               DoppelAvatar model, AvatarStore (local + Supabase sync),
│                          the Shape-based renderer, and the customize sheet
├── Home/                 The main menu / home screen
├── Components/           Reusable buttons, backgrounds, trait pickers
└── Resources/             Assets.xcassets (app icon, accent color, Google logo)
```

The avatar and display name are cached locally via `UserDefaults` (JSON-encoded,
for instant load and offline use) and synced to Supabase once signed in, so
they follow you to a new device. See **Backend setup** below — this needs a
few things only you can do before sign-in actually works.

## Backend setup

Accounts (Sign in with Apple / Google) and cloud save run on
[Supabase](https://supabase.com). None of this can be done for you — it
needs your own accounts on Supabase's, Apple's, and Google's consoles. This
is the short version; ask if you want the fully detailed walkthrough again.

1. **Supabase project.** Create one at supabase.com. In the SQL Editor, run
   [`supabase/schema.sql`](supabase/schema.sql) once — it creates the
   `profiles` table, its Row Level Security policies, and the
   account-deletion function. From Settings → API, copy the Project URL and
   anon/publishable key into `Doppel/Auth/SupabaseConfig.swift` (it starts
   with placeholder values that are obviously not real).
2. **Sign in with Apple.** Requires an Apple Developer Program membership.
   In Xcode: target → Signing & Capabilities → **+ Capability** → "Sign in
   with Apple" (this generates the entitlement correctly on its own — don't
   hand-edit one). In Supabase: Authentication → Providers → enable Apple.
3. **Google Sign-In.** In Google Cloud Console, create an iOS OAuth client
   ID with this app's bundle ID, plus a Web OAuth client ID (Supabase's
   Google provider wants both). Put the iOS client ID into
   `Doppel/Info.plist`'s `GIDClientID` key and into the reversed-ID URL
   scheme right below it (both are placeholders right now). In Supabase:
   Authentication → Providers → Google → enable it, add both client IDs
   (comma-separated), and turn on **Skip nonce check** — the native iOS
   sign-in flow needs that specific toggle or it fails silently.
4. **Two Swift packages.** In Xcode: File → Add Package Dependencies →
   add `https://github.com/supabase/supabase-swift` (product: `Supabase`)
   and `https://github.com/google/GoogleSignIn-iOS` (product:
   `GoogleSignIn`), both on the Doppel target. `project.yml` already
   declares these for anyone who regenerates via XcodeGen instead.

## Notes / known follow-ups

- **iPhone, portrait only** for this first pass — iPad support and
  landscape are natural next steps if you want them.
- The launch screen currently uses Xcode's default blank/system
  background rather than a custom dark one (avoiding a hand-written
  `Info.plist` with a nested launch-screen color dict kept the project
  generation safer to hand-author). Worth revisiting for a fully seamless
  launch.
- App icon is a generated placeholder mark (a violet/pink/lime portal ring
  on near-black) matching the app's palette — swap in a final icon
  whenever you're ready.
- `PRODUCT_BUNDLE_IDENTIFIER` is set to `com.doppel.app` — change it to
  your own reverse-DNS identifier before shipping. If you change it
  *after* setting up Sign in with Apple / Google above, you'll need to
  update it in the Apple Developer portal and the Google OAuth client too
  — they're matched to this exact string.
- Account deletion (Settings → Delete Account) removes the Supabase user
  and their profile row, but doesn't yet revoke the underlying Apple/Google
  grant on their end — for a real App Store submission, Apple's guidelines
  expect you to also call Apple's token-revocation endpoint when someone
  who signed in with Apple deletes their account. Not wired up yet.

## What's next

The home screen and avatar system are the foundation — the `PrimaryButton`
on Home already pushes into a placeholder destination (`ComingSoonView`)
so the navigation architecture is ready for whatever you want to build
next.
