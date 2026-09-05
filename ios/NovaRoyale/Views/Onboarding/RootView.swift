import SwiftUI

struct RootView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(AppLanguage.self) private var language
    @Environment(SessionController.self) private var session

    var body: some View {
        Group {
            switch session.phase {
            case .booting:
                bootScreen
            case .needsLink:
                OnboardingLinkView()
            case .ready:
                MainTabView()
            case .failed(let message):
                failureScreen(message)
            }
        }
        .task {
            if session.phase == .booting {
                await session.bootstrap()
            }
        }
    }

    private var bootScreen: some View {
        ZStack {
            RoyalBackgroundV2()
            VStack(spacing: 16) {
                RoyalText(text: L10n.t("app.name", language), size: 32, color: RoyalDS.Color.gold)
                ProgressView()
                    .tint(RoyalDS.Color.gold)
                Text(L10n.t("common.loading", language))
                    .font(RoyalFont.ui(14, weight: .semibold))
                    .foregroundStyle(RoyalDS.Color.textMuted)
            }
        }
    }

    private func failureScreen(_ message: String) -> some View {
        ZStack {
            RoyalBackgroundV2()
            VStack(spacing: 16) {
                RoyalText(text: L10n.t("session.error.title", language), size: 24, color: RoyalDS.Color.gold)
                Text(message)
                    .font(RoyalFont.ui(14, weight: .semibold))
                    .foregroundStyle(RoyalDS.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                RoyalButtonV2(title: L10n.t("session.retry", language), symbol: "arrow.clockwise", kind: .gold) {
                    Task { await session.bootstrap() }
                }
                .padding(.horizontal, 40)
            }
        }
    }
}
