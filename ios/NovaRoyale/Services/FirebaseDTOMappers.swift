import Foundation

enum PlayerDTOMapper {
    static func profile(from payload: [String: Any]) throws -> PlayerProfile {
        guard let player = payload["player"] as? [String: Any] else {
            throw ClashRoyaleServiceError.underlying("Missing player payload.")
        }

        let tag = string(player["tag"]) ?? ""
        let name = string(player["name"]) ?? "Player"
        let trophies = int(player["trophies"])
        let best = int(player["bestTrophies"], fallback: trophies)
        let level = int(player["expLevel"], fallback: 1)
        let wins = int(player["wins"])
        let losses = int(player["losses"])
        let battles = int(player["battleCount"], fallback: wins + losses)
        let arena = string(player["arenaName"]) ?? "Arena"
        let clan = string(player["clanName"])
        let id = tag.replacingOccurrences(of: "#", with: "")

        return PlayerProfile(
            id: id.isEmpty ? UUID().uuidString : id,
            name: name,
            tag: tag.hasPrefix("#") ? tag : "#\(tag)",
            trophies: trophies,
            bestTrophies: best,
            arenaName: arena,
            level: level,
            wins: wins,
            losses: losses,
            battleCount: battles,
            clanName: clan
        )
    }

    static func cards(from payload: [String: Any]) throws -> [CardItem] {
        guard let player = payload["player"] as? [String: Any] else { return [] }
        let raw = player["raw"] as? [String: Any]
        let list = (raw?["cards"] as? [[String: Any]]) ?? []
        return list.enumerated().compactMap { index, card in
            guard let name = string(card["name"]) else { return nil }
            let level = int(card["level"], fallback: 1)
            let maxLevel = int(card["maxLevel"], fallback: max(level, 14))
            let rarity = CardRarity(rawValue: (string(card["rarity"]) ?? "common").lowercased()) ?? .common
            let id = int(card["id"])
            var iconURL: URL?
            if let urls = card["iconUrls"] as? [String: Any],
               let medium = string(urls["medium"]) {
                iconURL = URL(string: medium)
            } else {
                iconURL = ClashRoyaleIconCatalog.mediumURL(forCardNamed: name)
            }
            return CardItem(
                id: id > 0 ? "\(id)" : "card-\(index)-\(name)",
                name: name,
                rarity: rarity,
                level: level,
                maxLevel: maxLevel,
                progress: Double(level) / Double(max(maxLevel, 1)),
                iconURL: iconURL
            )
        }
    }

    private static func string(_ value: Any?) -> String? {
        if let s = value as? String { return s }
        if let n = value as? NSNumber { return n.stringValue }
        return nil
    }

    private static func int(_ value: Any?, fallback: Int = 0) -> Int {
        if let i = value as? Int { return i }
        if let n = value as? NSNumber { return n.intValue }
        if let s = value as? String, let i = Int(s) { return i }
        return fallback
    }
}

enum BattleDTOMapper {
    static func records(from payload: [String: Any], formatter: RelativeDateTimeFormatter) throws -> [BattleRecord] {
        let battles = (payload["battles"] as? [[String: Any]]) ?? []
        return battles.enumerated().compactMap { index, battle in
            let raw = (battle["raw"] as? [String: Any]) ?? battle
            let type = string(raw["type"]) ?? string(battle["type"]) ?? "Battle"
            let battleTime = string(raw["battleTime"]) ?? string(battle["battleTime"]) ?? ""
            let team = (raw["team"] as? [[String: Any]])?.first
            let opponent = (raw["opponent"] as? [[String: Any]])?.first

            let myCrowns = int(team?["crowns"])
            let oppCrowns = int(opponent?["crowns"])
            let outcome: BattleOutcome = myCrowns >= oppCrowns ? .victory : .defeat
            let trophyChange = int(team?["trophyChange"])
            let opponentName = string(opponent?["name"]) ?? "Opponent"
            let mode = string((raw["gameMode"] as? [String: Any])?["name"]) ?? type
            let deck = ((team?["cards"] as? [[String: Any]]) ?? []).compactMap { string($0["name"]) }
            let date = parseBattleTime(battleTime)
            let relative = date.map { formatter.localizedString(for: $0, relativeTo: Date()) } ?? battleTime
            let duration: Int? = nil

            return BattleRecord(
                id: "\(battleTime)-\(index)",
                outcome: outcome,
                opponentName: opponentName,
                trophyChange: trophyChange,
                mode: mode,
                relativeTime: relative,
                crowns: myCrowns,
                opponentCrowns: oppCrowns,
                durationSeconds: duration,
                deckCardNames: deck.isEmpty ? nil : deck
            )
        }
    }

    /// Clash Royale battleTime: `20240315T184512.000Z`
    private static func parseBattleTime(_ value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd'T'HHmmss.SSS'Z'"
        if let date = formatter.date(from: value) { return date }
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return formatter.date(from: value)
    }

    private static func string(_ value: Any?) -> String? {
        value as? String
    }

    private static func int(_ value: Any?, fallback: Int = 0) -> Int {
        if let i = value as? Int { return i }
        if let n = value as? NSNumber { return n.intValue }
        return fallback
    }
}

enum ChestDTOMapper {
    static func items(from payload: [String: Any]) throws -> [ChestItem] {
        let list = (payload["items"] as? [[String: Any]]) ?? []
        return list.map { item in
            let index = int(item["index"])
            let name = (item["name"] as? String) ?? "Chest"
            let kind = ChestKind.from(apiName: name)
            return ChestItem(
                id: "chest-\(index)-\(name)",
                kind: kind,
                position: index + 1,
                unlockHours: max(1, (index + 1) * 3),
                rewardPreview: name
            )
        }
    }

    private static func int(_ value: Any?, fallback: Int = 0) -> Int {
        if let i = value as? Int { return i }
        if let n = value as? NSNumber { return n.intValue }
        return fallback
    }
}

extension ChestKind {
    static func from(apiName: String) -> ChestKind {
        let lower = apiName.lowercased()
        if lower.contains("legendary") { return .legendary }
        if lower.contains("magical") || lower.contains("epic") { return .magical }
        if lower.contains("gold") { return .golden }
        if lower.contains("silver") { return .silver }
        return .wooden
    }
}
