import Foundation
import Observation

@MainActor
@Observable
final class ServiceContainer {
    let clashRoyale: any ClashRoyaleServing

    init(clashRoyale: any ClashRoyaleServing) {
        self.clashRoyale = clashRoyale
    }
}
