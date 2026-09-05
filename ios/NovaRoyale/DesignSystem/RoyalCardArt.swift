import SwiftUI

/// Card art resolver: local PNG → official API icon URL → geometric placeholder.
struct RoyalCardArt: View {
    var assetId: String?
    var assetName: String?
    var remoteURL: URL?
    var rarityTint: Color = RoyalDS.Color.cyan
    var rarityFill: LinearGradient = RoyalLighting.blueFace
    var size: CGSize = CGSize(width: 54, height: 70)
    var cornerRadius: CGFloat = 12
    var placeholderSymbol: String = "person.fill"

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.black.opacity(0.4))
                .frame(width: size.width + 3, height: size.height + 3)
                .offset(y: 2)

            Group {
                if let local = localImage {
                    local
                        .resizable()
                        .scaledToFill()
                } else if let remoteURL {
                    AsyncImage(url: remoteURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            placeholder
                        case .empty:
                            placeholder
                                .overlay { ProgressView().tint(.white) }
                        @unknown default:
                            placeholder
                        }
                    }
                } else {
                    placeholder
                }
            }
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [rarityTint, Color.white.opacity(0.5), rarityTint.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: rarityTint.opacity(0.45), radius: 8)
        }
        .accessibilityHidden(true)
    }

    private var localImage: Image? {
        if let assetId, let img = RoyalAssets.image(named: RoyalAssets.Card.artwork(id: assetId)) {
            return img
        }
        if let assetName, let img = RoyalAssets.image(named: RoyalAssets.Card.artwork(name: assetName)) {
            return img
        }
        return nil
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(rarityFill)
            Image(systemName: placeholderSymbol)
                .font(.system(size: min(size.width, size.height) * 0.32, weight: .black))
                .foregroundStyle(.white)
                .shadow(color: rarityTint.opacity(0.7), radius: 4)
        }
    }
}

extension RoyalCardArt {
    init(card: CardItem, size: CGSize = CGSize(width: 54, height: 70)) {
        let rarity = RoyalCardRarity(rawValue: card.rarity.rawValue) ?? .common
        self.init(
            assetId: card.id,
            assetName: card.name,
            remoteURL: card.iconURL,
            rarityTint: rarity.tint,
            rarityFill: rarity.fill,
            size: size,
            cornerRadius: size.width > 80 ? 16 : 12,
            placeholderSymbol: "person.fill"
        )
    }
}
