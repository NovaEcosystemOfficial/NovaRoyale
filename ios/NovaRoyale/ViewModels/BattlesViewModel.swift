import Foundation
import Observation

@MainActor
@Observable
final class BattlesViewModel {
    private let service: any ClashRoyaleServing
    var battles: [BattleRecord] = []
    var isLoading = false

    init(service: any ClashRoyaleServing) {
        self.service = service
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        battles = (try? await service.getBattleLog()) ?? []
    }
}
