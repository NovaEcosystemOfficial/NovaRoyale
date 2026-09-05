import Foundation
import Observation

@MainActor
@Observable
final class PlayerViewModel {
    private let service: any ClashRoyaleServing
    var player: PlayerProfile?
    var isLoading = false

    init(service: any ClashRoyaleServing) {
        self.service = service
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        player = try? await service.getPlayer()
    }
}
