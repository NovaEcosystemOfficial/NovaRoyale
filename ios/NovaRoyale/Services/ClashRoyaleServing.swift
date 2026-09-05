import Foundation

enum ClashRoyaleServiceError: LocalizedError, Equatable {
    case notLinked
    case invalidTag
    case notFound
    case rateLimited
    case unauthenticated
    case unavailable
    case underlying(String)

    var errorDescription: String? {
        switch self {
        case .notLinked:
            return "No player tag linked."
        case .invalidTag:
            return "Invalid player tag."
        case .notFound:
            return "Player not found."
        case .rateLimited:
            return "Too many requests. Try again shortly."
        case .unauthenticated:
            return "Sign-in required."
        case .unavailable:
            return "Service temporarily unavailable."
        case .underlying(let message):
            return message
        }
    }
}

/// Abstract service layer. Views depend on this protocol, never on Firebase or Clash Royale directly.
protocol ClashRoyaleServing: Sendable {
    func getPlayer() async throws -> PlayerProfile
    func getBattleLog() async throws -> [BattleRecord]
    func getCards() async throws -> [CardItem]
    func getStats() async throws -> StatsSnapshot
    func getUpcomingChests() async throws -> [ChestItem]
    /// Links `#TAG` to the current user and syncs profile from Clash Royale.
    func syncPlayer(tag: String) async throws -> PlayerProfile
}
