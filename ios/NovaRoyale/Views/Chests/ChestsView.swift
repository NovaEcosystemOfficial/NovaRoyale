import SwiftUI

struct ChestsView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(AppLanguage.self) private var language
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ChestsViewModel?
    @State private var appear = false

    var body: some View {
        NavigationStack {
            ZStack {
                RoyalBackgroundV2()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            RoyalText(text: L10n.t("chests.title", language), size: 26, color: RoyalDS.Color.gold)
                            Text(L10n.t("chests.subtitle", language))
                                .font(RoyalFont.ui(13, weight: .semibold))
                                .foregroundStyle(RoyalDS.Color.textMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .staggeredAppear(index: 0, isVisible: appear)

                        ForEach(Array((viewModel?.chests ?? []).enumerated()), id: \.element.id) { index, chest in
                            RoyalPanelV2(kind: .gold, cornerRadius: RoyalDS.Radius.md) {
                                HStack(spacing: 14) {
                                    RoyalIconV2(systemName: chest.kind.symbolName, size: 50, tint: RoyalDS.Color.gold, kind: .gold)
                                    VStack(alignment: .leading, spacing: 4) {
                                        RoyalText(text: chest.kind.displayName, size: 16, strokeWidth: 1.2)
                                        Text("Slot #\(chest.position) · \(chest.unlockHours)h")
                                            .font(RoyalFont.ui(12, weight: .semibold))
                                            .foregroundStyle(RoyalDS.Color.textMuted)
                                        Text(chest.rewardPreview)
                                            .font(RoyalFont.ui(11, weight: .bold))
                                            .foregroundStyle(RoyalDS.Color.gold.opacity(0.9))
                                    }
                                    Spacer()
                                }
                            }
                            .staggeredAppear(index: index + 1, isVisible: appear)
                            .royalShimmer(index == 0)
                        }
                    }
                    .padding(14)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.t("chests.close", language)) { dismiss() }
                        .foregroundStyle(RoyalDS.Color.cyan)
                }
            }
        }
        .task {
            if viewModel == nil {
                viewModel = ChestsViewModel(service: services.clashRoyale)
            }
            await viewModel?.load()
            withAnimation(RoyalMotionV2.appear) { appear = true }
        }
    }
}
