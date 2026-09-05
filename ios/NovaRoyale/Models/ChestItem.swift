import Foundation

enum ChestKind: String, Equatable, Sendable {
    case wooden
    case silver
    case golden
    case magical
    case legendary

    var displayName: String {
        switch self {
        case .wooden: return "Wooden Chest"
        case .silver: return "Silver Chest"
        case .golden: return "Golden Chest"
        case .magical: return "Magical Chest"
        case .legendary: return "Legendary Chest"
        }
    }

    var symbolName: String {
        switch self {
        case .wooden: return "shippingbox.fill"
        case .silver: return "archivebox.fill"
        case .golden: return "gift.fill"
        case .magical: return "sparkles"
        case .legendary: return "crown.fill"
        }
    }
}

struct ChestItem: Identifiable, Equatable, Sendable {
    let id: String
    let kind: ChestKind
    let position: Int
    let unlockHours: Int
    let rewardPreview: String
}
