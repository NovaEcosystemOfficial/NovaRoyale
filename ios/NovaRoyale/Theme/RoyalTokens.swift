import SwiftUI

enum RoyalColor {
    static let deepNavy = Color(red: 0.02, green: 0.04, blue: 0.12)
    static let darkNavy = Color(red: 0.05, green: 0.08, blue: 0.20)
    static let royalBlue = Color(red: 0.10, green: 0.22, blue: 0.52)
    static let electricBlue = Color(red: 0.22, green: 0.52, blue: 1.0)
    static let cyan = Color(red: 0.35, green: 0.90, blue: 1.0)
    static let purple = Color(red: 0.62, green: 0.30, blue: 0.98)
    static let epicPurple = Color(red: 0.48, green: 0.18, blue: 0.78)
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.28)
    static let goldDeep = Color(red: 0.88, green: 0.52, blue: 0.06)
    static let legendaryGold = Color(red: 1.0, green: 0.92, blue: 0.45)
    static let victoryGreen = Color(red: 0.20, green: 0.90, blue: 0.42)
    static let defeatRed = Color(red: 0.98, green: 0.22, blue: 0.30)
    static let metalLight = Color(red: 0.72, green: 0.82, blue: 0.95)
    static let metalDark = Color(red: 0.18, green: 0.28, blue: 0.45)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.78)
    static let textMuted = Color.white.opacity(0.50)

    static let arenaSky = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.10, blue: 0.28),
            Color(red: 0.08, green: 0.06, blue: 0.22),
            Color(red: 0.03, green: 0.12, blue: 0.20)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let goldGradient = LinearGradient(
        colors: [legendaryGold, gold, goldDeep],
        startPoint: .top,
        endPoint: .bottom
    )

    static let bluePanelFill = LinearGradient(
        colors: [
            Color(red: 0.14, green: 0.28, blue: 0.62),
            Color(red: 0.08, green: 0.16, blue: 0.38),
            Color(red: 0.05, green: 0.10, blue: 0.26)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let goldPanelFill = LinearGradient(
        colors: [
            Color(red: 0.55, green: 0.38, blue: 0.08),
            Color(red: 0.28, green: 0.18, blue: 0.05),
            Color(red: 0.18, green: 0.12, blue: 0.04)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let purplePanelFill = LinearGradient(
        colors: [
            Color(red: 0.38, green: 0.18, blue: 0.62),
            Color(red: 0.22, green: 0.10, blue: 0.40),
            Color(red: 0.12, green: 0.06, blue: 0.24)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let successPanelFill = LinearGradient(
        colors: [
            Color(red: 0.08, green: 0.42, blue: 0.24),
            Color(red: 0.04, green: 0.24, blue: 0.14),
            Color(red: 0.03, green: 0.14, blue: 0.10)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let dangerPanelFill = LinearGradient(
        colors: [
            Color(red: 0.52, green: 0.12, blue: 0.18),
            Color(red: 0.30, green: 0.06, blue: 0.10),
            Color(red: 0.16, green: 0.04, blue: 0.08)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static func rarity(_ rarity: CardRarity) -> Color {
        switch rarity {
        case .common: return cyan
        case .rare: return Color(red: 1.0, green: 0.55, blue: 0.16)
        case .epic: return purple
        case .legendary: return gold
        case .champion: return defeatRed
        }
    }

    static func rarityFill(_ rarity: CardRarity) -> LinearGradient {
        switch rarity {
        case .common:
            return LinearGradient(colors: [Color(red: 0.12, green: 0.32, blue: 0.48), Color(red: 0.06, green: 0.14, blue: 0.24)], startPoint: .top, endPoint: .bottom)
        case .rare:
            return LinearGradient(colors: [Color(red: 0.55, green: 0.28, blue: 0.08), Color(red: 0.24, green: 0.12, blue: 0.04)], startPoint: .top, endPoint: .bottom)
        case .epic:
            return purplePanelFill
        case .legendary:
            return goldPanelFill
        case .champion:
            return LinearGradient(colors: [Color(red: 0.55, green: 0.12, blue: 0.18), Color(red: 0.20, green: 0.05, blue: 0.10)], startPoint: .top, endPoint: .bottom)
        }
    }
}

enum RoyalSpace {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 10
    static let md: CGFloat = 16
    static let lg: CGFloat = 22
    static let xl: CGFloat = 28
    static let tabBarClearance: CGFloat = 100
}

enum RoyalRadius {
    static let sm: CGFloat = 16
    static let md: CGFloat = 22
    static let lg: CGFloat = 28
    static let xl: CGFloat = 34
}

enum RoyalPanelStyle {
    case primary
    case gold
    case blue
    case purple
    case success
    case danger

    var fill: LinearGradient {
        switch self {
        case .primary, .blue: return RoyalColor.bluePanelFill
        case .gold: return RoyalColor.goldPanelFill
        case .purple: return RoyalColor.purplePanelFill
        case .success: return RoyalColor.successPanelFill
        case .danger: return RoyalColor.dangerPanelFill
        }
    }

    var rim: Color {
        switch self {
        case .primary, .blue: return RoyalColor.metalLight
        case .gold: return RoyalColor.gold
        case .purple: return RoyalColor.purple
        case .success: return RoyalColor.victoryGreen
        case .danger: return RoyalColor.defeatRed
        }
    }

    var glow: Color {
        switch self {
        case .primary, .blue: return RoyalColor.electricBlue
        case .gold: return RoyalColor.gold
        case .purple: return RoyalColor.purple
        case .success: return RoyalColor.victoryGreen
        case .danger: return RoyalColor.defeatRed
        }
    }
}
