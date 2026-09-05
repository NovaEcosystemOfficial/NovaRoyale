import Foundation
@preconcurrency import FirebaseAuth
import FirebaseFunctions

/// Live Clash Royale data via Firebase Auth + Callable Functions (`europe-west1`).
final class FirebaseClashRoyaleService: ClashRoyaleServing, @unchecked Sendable {
    private let functions: Functions
    private let relativeFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f
    }()

    init(region: String = "europe-west1") {
        self.functions = Functions.functions(region: region)
    }

    func syncPlayer(tag: String) async throws -> PlayerProfile {
        let data = try await call("syncPlayer", data: [
            "playerTag": tag,
            "forceRefresh": true
        ])
        return try PlayerDTOMapper.profile(from: data)
    }

    func getPlayer() async throws -> PlayerProfile {
        let data = try await call("getPlayer", data: [:])
        return try PlayerDTOMapper.profile(from: data)
    }

    func getBattleLog() async throws -> [BattleRecord] {
        let data = try await call("getBattleLog", data: [:])
        return try BattleDTOMapper.records(from: data, formatter: relativeFormatter)
    }

    func getUpcomingChests() async throws -> [ChestItem] {
        let data = try await call("getUpcomingChests", data: [:])
        return try ChestDTOMapper.items(from: data)
    }

    func getCards() async throws -> [CardItem] {
        // Prefer cards embedded on the synced player payload when present.
        let data = try await call("getPlayer", data: [:])
        if let cards = try? PlayerDTOMapper.cards(from: data), !cards.isEmpty {
            return cards
        }
        // Fallback: official CDN catalog until a dedicated cards callable exists.
        return ClashRoyaleIconCatalog.allCardNames.enumerated().map { index, name in
            CardItem(
                id: "catalog-\(index)-\(name)",
                name: name,
                rarity: .common,
                level: 1,
                maxLevel: 14,
                progress: 0,
                iconURL: ClashRoyaleIconCatalog.mediumURL(forCardNamed: name)
            )
        }
    }

    func getStats() async throws -> StatsSnapshot {
        async let playerTask = getPlayer()
        async let battlesTask = getBattleLog()
        let player = try await playerTask
        let battles = (try? await battlesTask) ?? []

        var streak = 0
        var longest = 0
        var running = 0
        for battle in battles {
            if battle.outcome == .victory {
                running += 1
                longest = max(longest, running)
            } else {
                running = 0
            }
        }
        for battle in battles {
            if battle.outcome == .victory { streak += 1 } else { break }
        }

        var history: [Int] = []
        var cursor = player.trophies
        history.append(cursor)
        for battle in battles.prefix(12) {
            cursor -= battle.trophyChange
            history.insert(max(0, cursor), at: 0)
        }

        return StatsSnapshot(
            wins: player.wins,
            losses: player.losses,
            currentTrophies: player.trophies,
            bestTrophies: player.bestTrophies,
            trophyHistory: history,
            currentStreak: streak,
            longestStreak: max(longest, streak)
        )
    }

    // MARK: - Callable

    private func call(_ name: String, data: [String: Any]) async throws -> [String: Any] {
        do {
            let result = try await functions.httpsCallable(name).call(data)
            guard let payload = result.data as? [String: Any] else {
                throw ClashRoyaleServiceError.underlying("Invalid response from \(name).")
            }
            return payload
        } catch {
            throw mapError(error)
        }
    }

    private func mapError(_ error: Error) -> ClashRoyaleServiceError {
        let ns = error as NSError
        let code = FunctionsErrorCode(rawValue: ns.code)

        let parts = [
            ns.userInfo[NSLocalizedDescriptionKey] as? String,
            ns.userInfo[NSLocalizedFailureReasonErrorKey] as? String,
            ns.userInfo["details"] as? String
        ]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }

        // Deduplicate ("INTERNAL INTERNAL")
        var seen = Set<String>()
        let message = parts.filter { seen.insert($0.lowercased()).inserted }.joined(separator: " ")
        let lower = (message.isEmpty ? ns.localizedDescription : message).lowercased()

        // First launch: linked tag missing → onboarding (not a connection failure).
        if code == .failedPrecondition
            || lower.contains("no player tag linked")
            || lower.contains("failed-precondition")
            || lower.contains("failed_precondition") {
            return .notLinked
        }

        switch code {
        case .invalidArgument:
            return .invalidTag
        case .notFound:
            return .notFound
        case .resourceExhausted:
            return .rateLimited
        case .unauthenticated:
            return .unauthenticated
        case .unavailable:
            return .unavailable
        default:
            return .underlying(message.isEmpty ? ns.localizedDescription : message)
        }
    }
}

// MARK: - Auth helper

enum FirebaseAuthSession {
    @MainActor
    static func ensureSignedIn() async throws {
        if Auth.auth().currentUser != nil { return }
        _ = try await Auth.auth().signInAnonymously()
    }
}
