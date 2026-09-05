import SwiftUI

enum RoyalCardRarity: String, CaseIterable {
    case common, rare, epic, legendary, champion

    var tint: Color {
        switch self {
        case .common: return RoyalDS.Color.cyan
        case .rare: return Color(red: 1.0, green: 0.55, blue: 0.16)
        case .epic: return RoyalDS.Color.purple
        case .legendary: return RoyalDS.Color.gold
        case .champion: return RoyalDS.Color.defeat
        }
    }

    var fill: LinearGradient {
        switch self {
        case .common:
            return LinearGradient(colors: [Color(red: 0.18, green: 0.4, blue: 0.58), Color(red: 0.06, green: 0.14, blue: 0.26)], startPoint: .top, endPoint: .bottom)
        case .rare:
            return LinearGradient(colors: [Color(red: 0.62, green: 0.34, blue: 0.08), Color(red: 0.26, green: 0.12, blue: 0.04)], startPoint: .top, endPoint: .bottom)
        case .epic:
            return LinearGradient(colors: [RoyalDS.Color.purple, RoyalDS.Color.epic], startPoint: .top, endPoint: .bottom)
        case .legendary:
            return LinearGradient(colors: [RoyalDS.Color.gold, RoyalDS.Color.goldDeep], startPoint: .top, endPoint: .bottom)
        case .champion:
            return LinearGradient(colors: [RoyalDS.Color.defeat, Color(red: 0.35, green: 0.05, blue: 0.1)], startPoint: .top, endPoint: .bottom)
        }
    }

    var label: String { rawValue.capitalized }
}

/// Collectible card shell — local PNG / API icon / placeholder.
struct RoyalCardV2: View {
    let name: String
    var rarity: RoyalCardRarity = .rare
    var level: Int = 9
    var maxLevel: Int = 12
    var progress: Double = 0.55
    var symbol: String = "person.fill"
    var iconURL: URL? = nil
    var assetId: String? = nil
    var onTap: (() -> Void)?

    init(
        name: String,
        rarity: RoyalCardRarity = .rare,
        level: Int = 9,
        maxLevel: Int = 12,
        progress: Double = 0.55,
        symbol: String = "person.fill",
        iconURL: URL? = nil,
        assetId: String? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.name = name
        self.rarity = rarity
        self.level = level
        self.maxLevel = maxLevel
        self.progress = progress
        self.symbol = symbol
        self.iconURL = iconURL ?? ClashRoyaleIconCatalog.mediumURL(forCardNamed: name)
        self.assetId = assetId
        self.onTap = onTap
    }

    init(card: CardItem, onTap: (() -> Void)? = nil) {
        self.name = card.name
        self.rarity = RoyalCardRarity(rawValue: card.rarity.rawValue) ?? .common
        self.level = card.level
        self.maxLevel = card.maxLevel
        self.progress = card.progress
        self.symbol = "person.fill"
        self.iconURL = card.iconURL
        self.assetId = card.id
        self.onTap = onTap
    }

    var body: some View {
        RoyalHapticButton {
            onTap?()
        } label: {
            RoyalPanelV2(kind: panelKind, cornerRadius: RoyalDS.Radius.md, padding: 12, showQuilt: false) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        RoyalCardArt(
                            assetId: assetId,
                            assetName: name,
                            remoteURL: iconURL,
                            rarityTint: rarity.tint,
                            rarityFill: rarity.fill,
                            size: CGSize(width: 54, height: 70),
                            placeholderSymbol: symbol
                        )
                        Spacer(minLength: 4)
                        RoyalBadgeV2(text: rarity.label.uppercased(), kind: badgeKind)
                    }

                    RoyalText(text: name, size: 18, strokeWidth: 1.3)

                    Text("LVL \(level)/\(maxLevel)")
                        .font(RoyalFont.ui(12, weight: .bold))
                        .foregroundStyle(RoyalDS.Color.textMuted)

                    RoyalProgressV2(progress: progress, tint: rarity.tint, height: 12)
                }
                .frame(maxWidth: .infinity, minHeight: 168, alignment: .topLeading)
            }
        }
    }

    private var panelKind: RoyalDS.PanelKind {
        switch rarity {
        case .common: return .blue
        case .rare: return .gold
        case .epic: return .purple
        case .legendary: return .gold
        case .champion: return .danger
        }
    }

    private var badgeKind: RoyalBadgeV2.Kind {
        switch rarity {
        case .common: return .blue
        case .rare: return .gold
        case .epic: return .purple
        case .legendary: return .gold
        case .champion: return .defeat
        }
    }
}
