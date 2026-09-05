import SwiftUI

struct BattlesView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(AppLanguage.self) private var language
    @State private var viewModel: BattlesViewModel?
    @State private var appear = false
    @State private var selectedBattle: BattleRecord?

    var body: some View {
        NavigationStack {
            ZStack {
                RoyalBackgroundV2()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            RoyalText(text: L10n.t("battles.title", language), size: 26, color: RoyalDS.Color.gold)
                            Text(L10n.t("battles.subtitle", language))
                                .font(RoyalFont.ui(13, weight: .semibold))
                                .foregroundStyle(RoyalDS.Color.textMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .staggeredAppear(index: 0, isVisible: appear)

                        if let battles = viewModel?.battles, !battles.isEmpty {
                            summaryStrip(battles)
                                .staggeredAppear(index: 1, isVisible: appear)
                        }

                        ForEach(Array((viewModel?.battles ?? []).enumerated()), id: \.element.id) { index, battle in
                            BattleCard(battle: battle) {
                                selectedBattle = battle
                            }
                            .staggeredAppear(index: min(index, 12) + 2, isVisible: appear)
                        }

                        if viewModel?.battles.isEmpty == true, viewModel?.isLoading == false {
                            RoyalPanelV2(kind: .primary) {
                                Text(L10n.t("battles.empty", language))
                                    .font(RoyalFont.ui(15, weight: .semibold))
                                    .foregroundStyle(RoyalDS.Color.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .padding(.bottom, RoyalSpace.tabBarClearance)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedBattle) { battle in
                BattleDetailView(battle: battle)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = BattlesViewModel(service: services.clashRoyale)
            }
            await viewModel?.load()
            withAnimation(RoyalMotionV2.appear) { appear = true }
        }
    }

    private func summaryStrip(_ battles: [BattleRecord]) -> some View {
        let wins = battles.filter { $0.outcome == .victory }.count
        let losses = battles.count - wins
        return HStack(spacing: 10) {
            RoyalPanelV2(kind: .success, cornerRadius: RoyalDS.Radius.md, padding: 12) {
                VStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(RoyalDS.Color.victory)
                        .shadow(color: RoyalDS.Color.victory.opacity(0.6), radius: 6)
                    RoyalNumber(value: wins, size: 28, style: .victory)
                    Text(L10n.t("battles.wins", language))
                        .font(RoyalFont.ui(11, weight: .bold))
                        .foregroundStyle(RoyalDS.Color.textMuted)
                }
                .frame(maxWidth: .infinity)
            }
            RoyalPanelV2(kind: .danger, cornerRadius: RoyalDS.Radius.md, padding: 12) {
                VStack(spacing: 6) {
                    Image(systemName: "xmark.octagon.fill")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(RoyalDS.Color.defeat)
                        .shadow(color: RoyalDS.Color.defeat.opacity(0.6), radius: 6)
                    RoyalNumber(value: losses, size: 28, style: .defeat)
                    Text(L10n.t("battles.losses", language))
                        .font(RoyalFont.ui(11, weight: .bold))
                        .foregroundStyle(RoyalDS.Color.textMuted)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
