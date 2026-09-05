import SwiftUI

/// Clash-style battle banner / stendardo behind player identity.
/// Shape + layers match game grammar; artwork is original/procedural (or drop-in PNG).
struct RoyalPlayerBanner: View {
    let playerName: String
    var playerTag: String = ""
    var level: Int = 1
    var trophies: Int = 0
    var clanName: String? = nil
    /// Favorite / showcase cards for bottom badge slots (max 2).
    var bannerCardNames: [String] = ["Knight", "Witch"]
    var height: CGFloat = 148

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                bannerFace
                landscapeDecoration
                nameOverlay
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipShape(BannerRibbonShape())
            .overlay {
                BannerRibbonShape()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.65),
                                RoyalDS.Color.gold.opacity(0.85),
                                Color(red: 0.35, green: 0.22, blue: 0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
            }
            .shadow(color: .black.opacity(0.45), radius: 10, y: 6)
            .shadow(color: RoyalDS.Color.gold.opacity(0.2), radius: 12, y: 2)

            // Badges hang slightly under the banner edge
            badgeRow
                .offset(y: -16)
                .padding(.horizontal, 10)
        }
        .padding(.bottom, 4)
    }

    // MARK: - Banner face

    @ViewBuilder
    private var bannerFace: some View {
        if let art = RoyalAssets.image(named: RoyalAssets.Banner.playerDefault) {
            art
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            proceduralLandscape
        }
    }

    /// Original landscape placeholder (sky / grass) — replace with PNG later.
    private var proceduralLandscape: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.45, green: 0.78, blue: 0.98),
                    Color(red: 0.28, green: 0.62, blue: 0.95),
                    Color(red: 0.55, green: 0.82, blue: 0.45),
                    Color(red: 0.22, green: 0.55, blue: 0.22)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Soft clouds
            HStack {
                cloudBlob.offset(x: 20, y: -28)
                Spacer()
                cloudBlob.scaleEffect(0.75).offset(x: -40, y: -18)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 10)

            // Grass ridge
            VStack {
                Spacer()
                Ellipse()
                    .fill(Color(red: 0.18, green: 0.48, blue: 0.18).opacity(0.55))
                    .frame(height: 36)
                    .offset(y: 10)
            }
        }
    }

    private var cloudBlob: some View {
        HStack(spacing: -8) {
            Circle().fill(Color.white.opacity(0.85)).frame(width: 34, height: 34)
            Circle().fill(Color.white.opacity(0.9)).frame(width: 44, height: 44)
            Circle().fill(Color.white.opacity(0.8)).frame(width: 28, height: 28)
        }
        .blur(radius: 0.5)
        .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
    }

    /// Right-side ornament (original emblem — not CR art).
    private var landscapeDecoration: some View {
        HStack {
            Spacer()
            ZStack {
                // Wooden ring target (geometric original)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.95, green: 0.25, blue: 0.22),
                                Color(red: 0.95, green: 0.92, blue: 0.88),
                                Color(red: 0.9, green: 0.2, blue: 0.18),
                                Color(red: 0.95, green: 0.92, blue: 0.88),
                                Color(red: 0.85, green: 0.15, blue: 0.12)
                            ],
                            center: .center,
                            startRadius: 2,
                            endRadius: 42
                        )
                    )
                    .frame(width: 78, height: 78)
                    .overlay(
                        Circle()
                            .stroke(Color(red: 0.45, green: 0.28, blue: 0.12), lineWidth: 5)
                    )
                    .shadow(color: .black.opacity(0.35), radius: 6, y: 3)

                // Arrow accents (SF Symbol, stylized)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(Color(red: 0.85, green: 0.15, blue: 0.15))
                    .rotationEffect(.degrees(-35))
                    .offset(x: -6, y: 4)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(Color(red: 0.75, green: 0.12, blue: 0.12))
                    .rotationEffect(.degrees(-55))
                    .offset(x: 10, y: -8)
            }
            .padding(.trailing, 36)
            .padding(.bottom, 18)
        }
        .allowsHitTesting(false)
    }

    private var nameOverlay: some View {
        HStack(alignment: .center, spacing: 10) {
            RoyalPlayerAvatarArt(
                cardName: bannerCardNames.first,
                monogram: playerName,
                size: 46
            )

            VStack(alignment: .leading, spacing: 3) {
                RoyalText(text: playerName, size: 24, strokeWidth: 1.8)
                if !playerTag.isEmpty {
                    Text(playerTag)
                        .font(RoyalFont.ui(12, weight: .bold))
                        .foregroundStyle(Color.white)
                        .shadow(color: .black.opacity(0.55), radius: 1, y: 1)
                }
                if let clanName {
                    Text(clanName)
                        .font(RoyalFont.ui(11, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.45), radius: 1, y: 1)
                }
            }

            Spacer(minLength: 70)

            VStack(alignment: .trailing, spacing: 2) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(RoyalDS.Color.gold)
                    .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
                RoyalNumber(value: trophies, size: 24)
            }
        }
        .padding(.leading, 12)
        .padding(.trailing, 28)
        .padding(.bottom, 28)
        .padding(.top, 10)
        .background {
            // Soft left scrim so name stays readable on bright landscapes
            LinearGradient(
                colors: [Color.black.opacity(0.35), Color.black.opacity(0.08), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .allowsHitTesting(false)
        }
    }

    // MARK: - Badge row

    private var badgeRow: some View {
        let cards = Array(bannerCardNames.prefix(2))
        return HStack(spacing: 10) {
            if cards.indices.contains(0) {
                bannerCardBadge(name: cards[0], rarityIndex: 0)
            }
            levelWingBadge
            if cards.indices.contains(1) {
                bannerCardBadge(name: cards[1], rarityIndex: 1)
            }
            crownSlot
            Spacer(minLength: 0)
        }
    }

    private func bannerCardBadge(name: String, rarityIndex: Int) -> some View {
        let rarity = RoyalCardRarity.allCases[rarityIndex % RoyalCardRarity.allCases.count]
        return VStack(spacing: 2) {
            RoyalCardArt(
                assetName: name,
                remoteURL: ClashRoyaleIconCatalog.mediumURL(forCardNamed: name),
                rarityTint: rarity.tint,
                rarityFill: rarity.fill,
                size: CGSize(width: 40, height: 50),
                cornerRadius: 7
            )
            Image(systemName: "star.fill")
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(RoyalDS.Color.gold)
                .shadow(color: .black.opacity(0.4), radius: 1, y: 1)
        }
        .padding(5)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.2, green: 0.45, blue: 0.85), Color(red: 0.1, green: 0.25, blue: 0.55)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.white.opacity(0.45), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.35), radius: 4, y: 3)
        }
    }

    private var levelWingBadge: some View {
        ZStack {
            // Winged hex
            Image(systemName: "hexagon.fill")
                .font(.system(size: 46, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: [RoyalDS.Color.purple, RoyalDS.Color.epic],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: RoyalDS.Color.purple.opacity(0.6), radius: 6, y: 2)

            HStack(spacing: 0) {
                Image(systemName: "arrowtriangle.left.fill")
                    .font(.system(size: 10, weight: .black))
                Spacer().frame(width: 34)
                Image(systemName: "arrowtriangle.right.fill")
                    .font(.system(size: 10, weight: .black))
            }
            .foregroundStyle(RoyalDS.Color.metal)
            .offset(y: 2)

            Text("\(level)")
                .font(RoyalFont.display(22))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.55), radius: 1, y: 1)
        }
        .frame(width: 56, height: 56)
    }

    private var crownSlot: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(RoyalLighting.goldFace)
                .frame(width: 44, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.35), radius: 4, y: 3)

            Image(systemName: "crown.fill")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color(red: 0.35, green: 0.22, blue: 0.08))
        }
    }
}

// MARK: - Swallowtail ribbon shape

struct BannerRibbonShape: Shape {
    /// Depth of the V-notch on the right (0–1 of height).
    var notchDepth: CGFloat = 0.28

    func path(in rect: CGRect) -> Path {
        let r: CGFloat = 14
        let notchX = rect.maxX - rect.height * notchDepth
        var path = Path()

        path.move(to: CGPoint(x: rect.minX + r, y: rect.minY))
        path.addLine(to: CGPoint(x: notchX, y: rect.minY))
        // Top edge into swallowtail tip
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: notchX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - r),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + r, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.closeSubpath()
        return path
    }
}
