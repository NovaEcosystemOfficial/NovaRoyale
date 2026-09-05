import Foundation

enum CardRarity: String, CaseIterable, Equatable, Sendable {
    case common
    case rare
    case epic
    case legendary
    case champion

    var displayName: String {
        rawValue.capitalized
    }
}

struct CardItem: Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let name: String
    let rarity: CardRarity
    let level: Int
    let maxLevel: Int
    let progress: Double
    /// Official API `iconUrls.medium` when available (CDN display only).
    let iconURL: URL?

    init(
        id: String,
        name: String,
        rarity: CardRarity,
        level: Int,
        maxLevel: Int,
        progress: Double,
        iconURL: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.rarity = rarity
        self.level = level
        self.maxLevel = maxLevel
        self.progress = progress
        self.iconURL = iconURL ?? ClashRoyaleIconCatalog.mediumURL(forCardNamed: name)
    }
}
