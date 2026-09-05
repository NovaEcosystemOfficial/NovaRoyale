import Foundation

enum BattleOutcome: String, Equatable, Sendable {
    case victory
    case defeat
}

struct BattleRecord: Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let outcome: BattleOutcome
    let opponentName: String
    let trophyChange: Int
    let mode: String
    let relativeTime: String
    let crowns: Int?
    let opponentCrowns: Int?
    let durationSeconds: Int?
    let deckCardNames: [String]?
}
