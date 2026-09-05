import Foundation

struct MockClashRoyaleService: ClashRoyaleServing {
    private let linkedTagKey = "royalcompanion.mockLinkedTag"

    func syncPlayer(tag: String) async throws -> PlayerProfile {
        try await Task.sleep(for: .milliseconds(200))
        let normalized = tag.hasPrefix("#") ? tag.uppercased() : "#\(tag.uppercased())"
        UserDefaults.standard.set(normalized, forKey: linkedTagKey)
        let profile = try await basePlayer()
        return PlayerProfile(
            id: normalized.replacingOccurrences(of: "#", with: ""),
            name: profile.name,
            tag: normalized,
            trophies: profile.trophies,
            bestTrophies: profile.bestTrophies,
            arenaName: profile.arenaName,
            level: profile.level,
            wins: profile.wins,
            losses: profile.losses,
            battleCount: profile.battleCount,
            clanName: "Nova Clan"
        )
    }

    func getPlayer() async throws -> PlayerProfile {
        try await Task.sleep(for: .milliseconds(320))
        guard UserDefaults.standard.string(forKey: linkedTagKey) != nil
                || ProcessInfo.processInfo.arguments.contains("-UITestingMockLinked") else {
            // First launch of mock: auto-link demo tag so UI still works without Firebase.
            // When using SessionController with Firebase, this path is unused.
            throw ClashRoyaleServiceError.notLinked
        }
        return try await basePlayer()
    }

    private func basePlayer() async throws -> PlayerProfile {
        let tag = UserDefaults.standard.string(forKey: linkedTagKey) ?? "#29G9Q92RL"
        return PlayerProfile(
            id: tag.replacingOccurrences(of: "#", with: ""),
            name: "Fabio",
            tag: tag,
            trophies: 1040,
            bestTrophies: 1185,
            arenaName: "Arena 4",
            level: 9,
            wins: 286,
            losses: 214,
            battleCount: 500,
            clanName: "Nova Clan"
        )
    }

    func getBattleLog() async throws -> [BattleRecord] {
        try await Task.sleep(for: .milliseconds(260))
        return [
            BattleRecord(
                id: "b1", outcome: .victory, opponentName: "NovaKnight", trophyChange: 28,
                mode: "Ladder", relativeTime: "12m ago", crowns: 3, opponentCrowns: 1,
                durationSeconds: 168, deckCardNames: ["Knight", "Archers", "Giant", "Fireball", "Witch", "Prince", "Zap", "Cannon"]
            ),
            BattleRecord(
                id: "b2", outcome: .defeat, opponentName: "SkyRaider", trophyChange: -26,
                mode: "Ladder", relativeTime: "41m ago", crowns: 0, opponentCrowns: 2,
                durationSeconds: 142, deckCardNames: ["Knight", "Archers", "Giant", "Fireball", "Witch", "Prince", "Zap", "Cannon"]
            ),
            BattleRecord(
                id: "b3", outcome: .victory, opponentName: "GoldSpark", trophyChange: 30,
                mode: "Party Mode", relativeTime: "1h ago", crowns: 2, opponentCrowns: 0,
                durationSeconds: 155, deckCardNames: nil
            ),
            BattleRecord(
                id: "b4", outcome: .victory, opponentName: "RiverFox", trophyChange: 27,
                mode: "Ladder", relativeTime: "2h ago", crowns: 1, opponentCrowns: 0,
                durationSeconds: 180, deckCardNames: ["Giant", "Witch", "Fireball", "Archers", "Knight", "Prince", "Zap", "Cannon"]
            ),
            BattleRecord(
                id: "b5", outcome: .defeat, opponentName: "CrystalWolf", trophyChange: -29,
                mode: "Challenge", relativeTime: "3h ago", crowns: 1, opponentCrowns: 3,
                durationSeconds: 190, deckCardNames: nil
            ),
            BattleRecord(
                id: "b6", outcome: .victory, opponentName: "ThunderBee", trophyChange: 31,
                mode: "Ladder", relativeTime: "5h ago", crowns: 2, opponentCrowns: 1,
                durationSeconds: 160, deckCardNames: ["Knight", "Archers", "Giant", "Fireball", "Witch", "Prince", "Zap", "Cannon"]
            )
        ]
    }

    func getCards() async throws -> [CardItem] {
        try await Task.sleep(for: .milliseconds(280))
        // Full catalog from official API icon list (mock levels until Firebase sync).
        return ClashRoyaleIconCatalog.allCardNames.enumerated().map { index, name in
            let maxLevel = Self.inferredMaxLevel(for: name)
            let rarity = Self.inferredRarity(maxLevel: maxLevel)
            let seed = abs(name.hashValue)
            let level = max(1, min(maxLevel, 1 + seed % maxLevel))
            let progress = Double((seed % 90) + 5) / 100.0
            return CardItem(
                id: "card-\(index)-\(name)",
                name: name,
                rarity: rarity,
                level: level,
                maxLevel: maxLevel,
                progress: progress,
                iconURL: ClashRoyaleIconCatalog.mediumURL(forCardNamed: name)
            )
        }
    }

    func getStats() async throws -> StatsSnapshot {
        try await Task.sleep(for: .milliseconds(240))
        return StatsSnapshot(
            wins: 286,
            losses: 214,
            currentTrophies: 1040,
            bestTrophies: 1185,
            trophyHistory: [820, 860, 910, 880, 940, 990, 1010, 1040],
            currentStreak: 2,
            longestStreak: 8
        )
    }

    func getUpcomingChests() async throws -> [ChestItem] {
        try await Task.sleep(for: .milliseconds(260))
        return [
            ChestItem(id: "ch1", kind: .golden, position: 1, unlockHours: 3, rewardPreview: "120 Gold + Rare Card"),
            ChestItem(id: "ch2", kind: .silver, position: 2, unlockHours: 8, rewardPreview: "80 Gold + Common Cards"),
            ChestItem(id: "ch3", kind: .magical, position: 3, unlockHours: 12, rewardPreview: "Epic Card Chance"),
            ChestItem(id: "ch4", kind: .wooden, position: 4, unlockHours: 4, rewardPreview: "40 Gold + Commons"),
            ChestItem(id: "ch5", kind: .legendary, position: 5, unlockHours: 24, rewardPreview: "Legendary Card Chance")
        ]
    }

    /// Approximate rarity from classic CR max-level caps (until live player card payload is wired).
    private static func inferredMaxLevel(for name: String) -> Int {
        // Prefer values encoded in known champion set
        let champions: Set<String> = ["Skeleton King", "Archer Queen", "Golden Knight", "Mighty Miner", "Monk", "Little Prince"]
        if champions.contains(name) { return 4 }
        let legendaries: Set<String> = [
            "Princess", "Ice Wizard", "Miner", "Sparky", "Lava Hound", "Lumberjack", "Inferno Dragon",
            "Electro Wizard", "Night Witch", "Bandit", "Royal Ghost", "Ram Rider", "Fisherman",
            "Magic Archer", "Mother Witch", "Graveyard", "The Log"
        ]
        if legendaries.contains(name) { return 6 }
        let epics: Set<String> = [
            "Witch", "Prince", "Baby Dragon", "Skeleton Army", "Giant Skeleton", "Goblin Barrel",
            "Dark Prince", "Guards", "Balloon", "Freeze", "Poison", "Mirror", "Rage", "Clone",
            "Tornado", "Lightning", "Golem", "P.E.K.K.A", "Bowler", "Executioner", "Cannon Cart",
            "Goblin Giant", "Electro Dragon", "Hunter", "Dark Prince", "Wall Breakers", "Goblin Drill"
        ]
        if epics.contains(name) { return 9 }
        let rares: Set<String> = [
            "Giant", "Fireball", "Musketeer", "Mini P.E.K.K.A", "Valkyrie", "Hog Rider", "Wizard",
            "Bomb Tower", "Tombstone", "Furnace", "Goblin Hut", "Inferno Tower", "Battle Ram",
            "Dart Goblin", "Mega Minion", "Flying Machine", "Zappies", "Royal Hogs", "Elixir Golem",
            "Battle Healer", "Heal Spirit", "Earthquake", "Goblin Cage", "Three Musketeers"
        ]
        if rares.contains(name) { return 12 }
        return 14
    }

    private static func inferredRarity(maxLevel: Int) -> CardRarity {
        switch maxLevel {
        case ...4: return .champion
        case ...6: return .legendary
        case ...9: return .epic
        case ...12: return .rare
        default: return .common
        }
    }
}
