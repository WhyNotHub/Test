# Doppel

Your digital self, front and center.

Doppel is an iOS app built around one idea: the home screen *is* your
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
├── App/                 App entry point
├── DesignSystem/        Color, type, spacing tokens + shared view modifiers
├── Avatar/               DoppelAvatar model, AvatarStore (persistence),
│                          the Shape-based renderer, and the customize sheet
├── Home/                 The main menu / home screen
├── Components/           Reusable buttons, backgrounds, trait pickers
└── Resources/             Assets.xcassets (app icon, accent color)
```

The avatar and the user's display name persist locally via `UserDefaults`
(JSON-encoded) — no backend, no account, nothing to configure.

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
  your own reverse-DNS identifier before shipping.

## What's next

The home screen and avatar system are the foundation — the `PrimaryButton`
on Home already pushes into a placeholder destination (`ComingSoonView`)
so the navigation architecture is ready for whatever you want to build
next.
