import Foundation

struct PlayerProfile: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let tag: String
    let trophies: Int
    let bestTrophies: Int
    let arenaName: String
    let level: Int
    let wins: Int
    let losses: Int
    let battleCount: Int
    var clanName: String? = nil

    var winRate: Double {
        let total = wins + losses
        guard total > 0 else { return 0 }
        return Double(wins) / Double(total)
    }

    var winRatePercent: Int {
        Int((winRate * 100).rounded())
    }
}
