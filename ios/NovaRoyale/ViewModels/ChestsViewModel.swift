import Foundation
import Observation

@MainActor
@Observable
final class ChestsViewModel {
    private let service: any ClashRoyaleServing
    var chests: [ChestItem] = []
    var isLoading = false
    var openedChestID: String?
    var rewardText: String?

    init(service: any ClashRoyaleServing) {
        self.service = service
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        chests = (try? await service.getUpcomingChests()) ?? []
    }

    func openChest(_ chest: ChestItem) {
        openedChestID = chest.id
        rewardText = chest.rewardPreview
    }

    func dismissReward() {
        openedChestID = nil
        rewardText = nil
    }
}
