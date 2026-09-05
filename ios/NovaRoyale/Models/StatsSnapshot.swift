import Foundation

struct StatsSnapshot: Equatable, Sendable {
    let wins: Int
    let losses: Int
    let currentTrophies: Int
    let bestTrophies: Int
    let trophyHistory: [Int]
    let currentStreak: Int
    let longestStreak: Int

    var winRatePercent: Int {
        let total = wins + losses
        guard total > 0 else { return 0 }
        return Int((Double(wins) / Double(total) * 100).rounded())
    }

    var battleCount: Int { wins + losses }
}
