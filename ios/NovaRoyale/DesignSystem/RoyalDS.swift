import SwiftUI

/// Royal Design System V2 — aggressive game-UI material language.
enum RoyalDS {
    enum Color {
        static let deepNavy = SwiftUI.Color(red: 0.03, green: 0.06, blue: 0.16)
        static let stone = SwiftUI.Color(red: 0.12, green: 0.16, blue: 0.28)
        static let panelBlue = SwiftUI.Color(red: 0.12, green: 0.38, blue: 0.78)
        static let panelBlueDeep = SwiftUI.Color(red: 0.06, green: 0.22, blue: 0.52)
        static let quiltLight = SwiftUI.Color(red: 0.22, green: 0.52, blue: 0.92)
        static let quiltDark = SwiftUI.Color(red: 0.10, green: 0.32, blue: 0.68)
        static let electric = SwiftUI.Color(red: 0.30, green: 0.72, blue: 1.0)
        static let cyan = SwiftUI.Color(red: 0.40, green: 0.92, blue: 1.0)
        static let purple = SwiftUI.Color(red: 0.58, green: 0.28, blue: 0.92)
        static let epic = SwiftUI.Color(red: 0.42, green: 0.14, blue: 0.72)
        static let gold = SwiftUI.Color(red: 1.0, green: 0.84, blue: 0.18)
        static let goldDeep = SwiftUI.Color(red: 0.92, green: 0.55, blue: 0.05)
        static let goldRim = SwiftUI.Color(red: 0.98, green: 0.78, blue: 0.22)
        static let ctaYellow = SwiftUI.Color(red: 1.0, green: 0.86, blue: 0.12)
        static let ctaOrange = SwiftUI.Color(red: 1.0, green: 0.58, blue: 0.08)
        static let victory = SwiftUI.Color(red: 0.22, green: 0.88, blue: 0.38)
        static let defeat = SwiftUI.Color(red: 0.96, green: 0.20, blue: 0.28)
        static let gem = SwiftUI.Color(red: 0.18, green: 0.82, blue: 0.42)
        static let metal = SwiftUI.Color(red: 0.72, green: 0.82, blue: 0.95)
        static let metalDark = SwiftUI.Color(red: 0.22, green: 0.30, blue: 0.48)
        static let text = SwiftUI.Color.white
        static let textPrimary = SwiftUI.Color.white
        static let textMuted = SwiftUI.Color.white.opacity(0.72)
        static let textSecondary = SwiftUI.Color.white.opacity(0.78)
        static let stroke = SwiftUI.Color(red: 0.08, green: 0.10, blue: 0.18)
    }

    enum Space {
        static let xs: CGFloat = 6
        static let sm: CGFloat = 10
        static let md: CGFloat = 14
        static let lg: CGFloat = 20
        static let xl: CGFloat = 28
    }

    enum Radius {
        static let sm: CGFloat = 14
        static let md: CGFloat = 18
        static let lg: CGFloat = 24
        static let xl: CGFloat = 30
        static let pill: CGFloat = 999
    }

    enum PanelKind {
        case primary
        case blue
        case gold
        case purple
        case stone
        case success
        case danger

        var fillTop: SwiftUI.Color {
            switch self {
            case .primary, .blue: return Color.quiltLight
            case .gold: return SwiftUI.Color(red: 0.72, green: 0.52, blue: 0.12)
            case .purple: return SwiftUI.Color(red: 0.52, green: 0.28, blue: 0.82)
            case .stone: return Color.stone
            case .success: return SwiftUI.Color(red: 0.16, green: 0.55, blue: 0.28)
            case .danger: return SwiftUI.Color(red: 0.62, green: 0.16, blue: 0.22)
            }
        }

        var fillBottom: SwiftUI.Color {
            switch self {
            case .primary, .blue: return Color.panelBlueDeep
            case .gold: return SwiftUI.Color(red: 0.32, green: 0.18, blue: 0.04)
            case .purple: return Color.epic
            case .stone: return Color.deepNavy
            case .success: return SwiftUI.Color(red: 0.05, green: 0.22, blue: 0.12)
            case .danger: return SwiftUI.Color(red: 0.22, green: 0.05, blue: 0.08)
            }
        }

        var rim: SwiftUI.Color {
            switch self {
            case .primary, .blue: return Color.metal
            case .gold: return Color.goldRim
            case .purple: return Color.purple
            case .stone: return Color.metalDark
            case .success: return Color.victory
            case .danger: return Color.defeat
            }
        }

        var glow: SwiftUI.Color { rim }
    }
}
