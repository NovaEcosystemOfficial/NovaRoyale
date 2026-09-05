import Foundation
import Observation

@MainActor
@Observable
final class SessionController {
    enum Phase: Equatable {
        case booting
        case needsLink
        case ready
        case failed(String)
    }

    private(set) var phase: Phase = .booting
    private(set) var linkedTag: String?
    var lastError: String?

    private let services: ServiceContainer
    private let tagStorageKey = "royalcompanion.linkedPlayerTag"

    init(services: ServiceContainer) {
        self.services = services
        linkedTag = UserDefaults.standard.string(forKey: tagStorageKey)
    }

    func bootstrap() async {
        phase = .booting
        lastError = nil
        do {
            try await FirebaseAuthSession.ensureSignedIn()
            let player = try await services.clashRoyale.getPlayer()
            persist(tag: player.tag)
            phase = .ready
        } catch let error as ClashRoyaleServiceError {
            switch error {
            case .notLinked:
                clearTag()
                phase = .needsLink
            case .unauthenticated:
                phase = .failed(error.localizedDescription)
            default:
                let message = error.localizedDescription
                if linkedTag != nil {
                    phase = .ready
                    lastError = message
                } else {
                    // Prefer onboarding when backend only says “not linked yet”
                    if message.localizedCaseInsensitiveContains("tag")
                        || message.localizedCaseInsensitiveContains("precondition") {
                        clearTag()
                        phase = .needsLink
                    } else {
                        phase = .failed(message)
                    }
                }
            }
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            if message.localizedCaseInsensitiveContains("No player tag linked")
                || message.localizedCaseInsensitiveContains("failed-precondition")
                || message.localizedCaseInsensitiveContains("failed_precondition") {
                clearTag()
                phase = .needsLink
            } else if linkedTag != nil {
                phase = .ready
                lastError = message
            } else {
                phase = .failed(message)
            }
        }
    }

    func linkPlayer(tag: String) async throws {
        lastError = nil
        try await FirebaseAuthSession.ensureSignedIn()
        let player = try await services.clashRoyale.syncPlayer(tag: tag)
        persist(tag: player.tag)
        phase = .ready
    }

    func changePlayerTag(_ tag: String) async throws {
        try await linkPlayer(tag: tag)
    }

    func unlinkLocally() {
        clearTag()
        phase = .needsLink
    }

    private func persist(tag: String) {
        linkedTag = tag
        UserDefaults.standard.set(tag, forKey: tagStorageKey)
    }

    private func clearTag() {
        linkedTag = nil
        UserDefaults.standard.removeObject(forKey: tagStorageKey)
    }
}
