import SwiftUI
import FirebaseCore

@main
struct NovaRoyaleApp: App {
    @State private var services: ServiceContainer
    @State private var session: SessionController
    @State private var language = AppLanguage.shared

    init() {
        FirebaseApp.configure()
        let container = ServiceContainer(clashRoyale: FirebaseClashRoyaleService())
        _services = State(initialValue: container)
        _session = State(initialValue: SessionController(services: container))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(services)
                .environment(session)
                .environment(language)
                .preferredColorScheme(.dark)
                .royalLocalized(language)
                .onAppear {
                    RoyalFont.registerIfNeeded()
                }
        }
    }
}
