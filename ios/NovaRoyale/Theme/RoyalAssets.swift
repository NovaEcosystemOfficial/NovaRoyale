import SwiftUI

/// Central asset keys — drop PNGs into Assets.xcassets with these names; UI never hardcodes files.
enum RoyalAssets {
    enum Background {
        static let arenaNight = "BackgroundAssets/ArenaNight"
        static let vignette = "BackgroundAssets/Vignette"
    }

    /// Player profile stendardo / banner behind name (Clash-like identity strip).
    enum Banner {
        static let playerDefault = "BannerAssets/PlayerBanner"
        static func player(id: String) -> String { "BannerAssets/Player_\(sanitized(id))" }
    }

    enum Arena {
        static func artwork(named name: String) -> String {
            "ArenaAssets/\(sanitized(name))"
        }
    }

    enum Card {
        /// Prefer stable ids: CardAssets/Knight, CardAssets/Witch, …
        static func artwork(id: String) -> String { "CardAssets/\(sanitized(id))" }
        static func artwork(name: String) -> String { "CardAssets/\(sanitized(name))" }
    }

    enum Badge {
        static let trophy = "BadgeAssets/Trophy"
        static let level = "BadgeAssets/Level"
        static let victory = "BadgeAssets/Victory"
        static let defeat = "BadgeAssets/Defeat"
        static let crown = "BadgeAssets/Crown"
    }

    enum Icon {
        static let battles = "IconAssets/Battles"
        static let cards = "IconAssets/Cards"
        static let stats = "IconAssets/Stats"
        static let chests = "IconAssets/Chests"
        static let home = "IconAssets/Home"
        static let profile = "IconAssets/Profile"
    }

    static func image(named name: String) -> Image? {
        #if canImport(UIKit)
        if UIImage(named: name) != nil { return Image(name) }
        // Fallback without namespace prefix if asset was added flat
        if let short = name.split(separator: "/").last,
           UIImage(named: String(short)) != nil {
            return Image(String(short))
        }
        #endif
        return nil
    }

    static func uiImage(named name: String) -> UIImage? {
        #if canImport(UIKit)
        if let img = UIImage(named: name) { return img }
        if let short = name.split(separator: "/").last {
            return UIImage(named: String(short))
        }
        #endif
        return nil
    }

    private static func sanitized(_ value: String) -> String {
        value
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "/", with: "_")
    }
}
