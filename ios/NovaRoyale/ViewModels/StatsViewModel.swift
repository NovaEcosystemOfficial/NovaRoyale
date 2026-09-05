import Foundation
import Observation

@MainActor
@Observable
final class StatsViewModel {
    private let service: any ClashRoyaleServing
    var stats: StatsSnapshot?
    var isLoading = false

    init(service: any ClashRoyaleServing) {
        self.service = service
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        stats = try? await service.getStats()
    }
}
