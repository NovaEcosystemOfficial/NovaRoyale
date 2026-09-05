import Foundation
import Observation

@MainActor
@Observable
final class CardsViewModel {
    private let service: any ClashRoyaleServing
    var cards: [CardItem] = []
    var isLoading = false

    init(service: any ClashRoyaleServing) {
        self.service = service
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        cards = (try? await service.getCards()) ?? []
    }
}
