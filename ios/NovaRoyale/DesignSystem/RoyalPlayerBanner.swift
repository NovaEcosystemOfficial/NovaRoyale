import SwiftUI

/// Player identity stendardo: banner + floating cards (local PNG or official API icons).
struct RoyalPlayerBanner: View {
    let playerName: String
    var playerTag: String = ""
    var level: Int = 1
    var trophies: Int = 0
    var clanName: String? = nil
    /// Card names for floating art on the banner (resolved via catalog / API icons).
    var bannerCardNames: [String] = ["Knight", "Witch", "Prince"]
    var height: CGFloat = 132

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            bannerArtwork
            floatingCards
            scrim
            identity
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.55),
                            RoyalDS.Color.gold.opacity(0.7),
                            RoyalDS.Color.metalDark
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.4
                )
        )
        .shadow(color: RoyalDS.Color.electric.opacity(0.25), radius: 10, y: 4)
    }

    @ViewBuilder
    private var bannerArtwork: some View {
        if let art = RoyalAssets.image(named: RoyalAssets.Banner.playerDefault) {
            art
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            proceduralBanner
        }
    }

    private var proceduralBanner: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.18, green: 0.42, blue: 0.78),
                    Color(red: 0.10, green: 0.22, blue: 0.48),
                    Color(red: 0.28, green: 0.14, blue: 0.42)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RoyalTexture.Quilted(
                light: Color.white.opacity(0.12),
                dark: Color.black.opacity(0.15),
                cell: 18,
                opacity: 0.35
            )
            HStack {
                Spacer()
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 64, weight: .black))
                    .foregroundStyle(Color.white.opacity(0.08))
                    .padding(.trailing, 16)
            }
        }
    }

    private var floatingCards: some View {
        let names = Array(bannerCardNames.prefix(3))
        return HStack(spacing: -18) {
            ForEach(Array(names.enumerated()), id: \.offset) { index, name in
                let rarity = RoyalCardRarity.allCases[index % RoyalCardRarity.allCases.count]
                RoyalCardArt(
                    assetName: name,
                    remoteURL: ClashRoyaleIconCatalog.mediumURL(forCardNamed: name),
                    rarityTint: rarity.tint,
                    rarityFill: rarity.fill,
                    size: CGSize(width: 44, height: 58),
                    cornerRadius: 8
                )
                .rotationEffect(.degrees(index == 0 ? -8 : (index == 1 ? 4 : -2)))
                .offset(y: index == 1 ? -6 : 4)
                .zIndex(Double(3 - index))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .padding(.top, 10)
        .padding(.trailing, 12)
        .allowsHitTesting(false)
    }

    private var scrim: some View {
        LinearGradient(
            colors: [.clear, Color.black.opacity(0.55), Color.black.opacity(0.72)],
            startPoint: .top,
            endPoint: .bottom
        )
        .allowsHitTesting(false)
    }

    private var identity: some View {
        HStack(alignment: .bottom, spacing: 10) {
            RoyalIconV2(systemName: "person.fill", size: 48, tint: RoyalDS.Color.cyan, kind: .blue)

            VStack(alignment: .leading, spacing: 2) {
                RoyalText(text: playerName, size: 24, strokeWidth: 1.6)
                if !playerTag.isEmpty {
                    Text(playerTag)
                        .font(RoyalFont.ui(12, weight: .bold))
                        .foregroundStyle(RoyalDS.Color.cyan)
                }
                if let clanName {
                    Text(clanName)
                        .font(RoyalFont.ui(11, weight: .semibold))
                        .foregroundStyle(RoyalDS.Color.textMuted)
                }
                HStack(spacing: 6) {
                    RoyalBadgeV2(text: "LVL \(level)", kind: .level)
                }
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 2) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(RoyalDS.Color.gold)
                RoyalNumber(value: trophies, size: 26)
            }
        }
        .padding(12)
    }
}
