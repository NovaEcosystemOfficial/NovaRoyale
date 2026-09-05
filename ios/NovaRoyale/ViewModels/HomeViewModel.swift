import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    private let service: any ClashRoyaleServing

    var player: PlayerProfile?
    var battles: [BattleRecord] = []
    var isLoading = false
    var errorMessage: String?
    var hasAppeared = false

    init(service: any ClashRoyaleServing) {
        self.service = service
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let playerTask = service.getPlayer()
            async let battlesTask = service.getBattleLog()
            player = try await playerTask
            battles = Array(try await battlesTask.prefix(4))
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
