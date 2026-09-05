import SwiftUI

@main
struct NovaRoyaleApp: App {
    @State private var services = ServiceContainer(clashRoyale: MockClashRoyaleService())
    @State private var language = AppLanguage.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(services)
                .environment(language)
                .preferredColorScheme(.dark)
                .royalLocalized(language)
                .onAppear {
                    RoyalFont.registerIfNeeded()
                }
        }
    }
}
