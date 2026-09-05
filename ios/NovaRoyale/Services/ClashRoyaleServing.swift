import Foundation

/// Abstract service layer. Views depend on this protocol, never on Firebase or Clash Royale directly.
protocol ClashRoyaleServing: Sendable {
    func getPlayer() async throws -> PlayerProfile
    func getBattleLog() async throws -> [BattleRecord]
    func getCards() async throws -> [CardItem]
    func getStats() async throws -> StatsSnapshot
    func getUpcomingChests() async throws -> [ChestItem]
}
