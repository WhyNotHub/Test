import SwiftUI

/// The bottom sheet where you edit your digital twin. Every option updates
/// `AvatarStore` immediately so the hero avatar on the home screen animates
/// into the change the moment you dismiss.
struct AvatarCustomizeView: View {
    @Environment(AvatarStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DoppelSpacing.xl) {
                    AvatarView(avatar: store.avatar)
                        .frame(width: 150, height: 150)
                        .padding(.top, DoppelSpacing.md)

                    VStack(alignment: .leading, spacing: DoppelSpacing.lg) {
                        TraitSection(title: "Skin") {
                            ForEach(SkinTone.allCases) { tone in
                                ColorSwatchButton(color: tone.color, isSelected: store.avatar.skinTone == tone) {
                                    store.avatar.skinTone = tone
                                }
                            }
                        }

                        TraitSection(title: "Hair Style") {
                            ForEach(HairStyle.allCases) { style in
                                AvatarPreviewChip(
                                    avatar: store.avatar.with(hairStyle: style),
                                    label: style.label,
                                    isSelected: store.avatar.hairStyle == style
                                ) { store.avatar.hairStyle = style }
                            }
                        }

                        TraitSection(title: "Hair Color") {
                            ForEach(HairColor.allCases) { color in
                                ColorSwatchButton(color: color.color, isSelected: store.avatar.hairColor == color) {
                                    store.avatar.hairColor = color
                                }
                            }
                        }

                        TraitSection(title: "Eyes") {
                            ForEach(EyeStyle.allCases) { style in
                                PillChip(label: style.label, isSelected: store.avatar.eyeStyle == style) {
                                    store.avatar.eyeStyle = style
                                }
                            }
                        }

                        TraitSection(title: "Mouth") {
                            ForEach(MouthStyle.allCases) { style in
                                PillChip(label: style.label, isSelected: store.avatar.mouthStyle == style) {
                                    store.avatar.mouthStyle = style
                                }
                            }
                        }

                        TraitSection(title: "Outfit") {
                            ForEach(OutfitStyle.allCases) { style in
                                AvatarPreviewChip(
                                    avatar: store.avatar.with(outfitStyle: style),
                                    label: style.label,
                                    isSelected: store.avatar.outfitStyle == style
                                ) { store.avatar.outfitStyle = style }
                            }
                        }

                        TraitSection(title: "Outfit Color") {
                            ForEach(OutfitColor.allCases) { color in
                                ColorSwatchButton(color: color.color, isSelected: store.avatar.outfitColor == color) {
                                    store.avatar.outfitColor = color
                                }
                            }
                        }

                        TraitSection(title: "Accessory") {
                            ForEach(Accessory.allCases) { accessory in
                                AvatarPreviewChip(
                                    avatar: store.avatar.with(accessory: accessory),
                                    label: accessory.label,
                                    isSelected: store.avatar.accessory == accessory
                                ) { store.avatar.accessory = accessory }
                            }
                        }

                        TraitSection(title: "Aura") {
                            ForEach(AuraPalette.allCases) { palette in
                                VStack(spacing: DoppelSpacing.xs) {
                                    ColorSwatchButton(
                                        color: palette.colors.first ?? DoppelColor.violet,
                                        isSelected: store.avatar.auraPalette == palette
                                    ) {
                                        store.avatar.auraPalette = palette
                                    }
                                    Text(palette.label)
                                        .font(DoppelFont.caption(11))
                                        .foregroundStyle(DoppelColor.textSecondary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DoppelSpacing.lg)
                    .padding(.bottom, DoppelSpacing.xxl)
                }
            }
            .background(DoppelColor.void.ignoresSafeArea())
            .navigationTitle("Customize")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    IconButton(systemName: "checkmark", filled: true) { dismiss() }
                }
                ToolbarItem(placement: .topBarLeading) {
                    IconButton(systemName: "arrow.counterclockwise") { store.resetAvatar() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    AvatarCustomizeView()
        .environment(AvatarStore())
}
