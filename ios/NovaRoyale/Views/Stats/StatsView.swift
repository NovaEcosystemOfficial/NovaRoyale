import SwiftUI

struct StatsView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(AppLanguage.self) private var language
    @State private var viewModel: StatsViewModel?
    @State private var appear = false

    var body: some View {
        ZStack {
            RoyalBackgroundV2()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        RoyalText(text: L10n.t("stats.title", language), size: 26, color: RoyalDS.Color.gold)
                        Text(L10n.t("stats.subtitle", language))
                            .font(RoyalFont.ui(13, weight: .semibold))
                            .foregroundStyle(RoyalDS.Color.textMuted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .staggeredAppear(index: 0, isVisible: appear)

                    if let stats = viewModel?.stats {
                        HStack(spacing: 12) {
                            RoyalPanelV2(kind: .gold, cornerRadius: RoyalDS.Radius.lg) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Label(L10n.t("stats.trophies", language), systemImage: "trophy.fill")
                                        .font(RoyalFont.ui(12, weight: .bold))
                                        .foregroundStyle(RoyalDS.Color.gold)
                                    RoyalNumber(value: stats.currentTrophies, size: 40)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .staggeredAppear(index: 1, isVisible: appear)

                            RoyalPanelV2(kind: .blue, cornerRadius: RoyalDS.Radius.lg) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Label(L10n.t("stats.win_rate", language), systemImage: "chart.pie.fill")
                                        .font(RoyalFont.ui(12, weight: .bold))
                                        .foregroundStyle(RoyalDS.Color.cyan)
                                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                                        RoyalNumber(value: stats.winRatePercent, size: 40, style: .cyan)
                                        RoyalText(text: "%", size: 18, color: RoyalDS.Color.cyan)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .staggeredAppear(index: 2, isVisible: appear)
                        }

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(title: L10n.t("stats.wins", language), value: "\(stats.wins)", symbol: "checkmark.seal.fill", tint: RoyalDS.Color.victory, style: .success)
                            StatCard(title: L10n.t("stats.losses", language), value: "\(stats.losses)", symbol: "xmark.octagon.fill", tint: RoyalDS.Color.defeat, style: .danger)
                            StatCard(title: L10n.t("stats.best", language), value: "\(stats.bestTrophies)", symbol: "crown.fill", tint: RoyalDS.Color.gold, style: .gold)
                            StatCard(title: L10n.t("stats.battles", language), value: "\(stats.battleCount)", symbol: "bolt.fill", tint: RoyalDS.Color.purple, style: .purple)
                            StatCard(title: L10n.t("stats.streak", language), value: "\(stats.currentStreak)", symbol: "flame.fill", tint: RoyalDS.Color.cyan, style: .blue)
                            StatCard(title: L10n.t("stats.best_streak", language), value: "\(stats.longestStreak)", symbol: "star.fill", tint: RoyalDS.Color.gold, style: .gold)
                        }
                        .staggeredAppear(index: 3, isVisible: appear)

                        TrophyChart(history: stats.trophyHistory)
                            .staggeredAppear(index: 4, isVisible: appear)
                    } else {
                        RoundedRectangle(cornerRadius: RoyalDS.Radius.lg)
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 280)
                            .royalShimmer(true)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 8)
                .padding(.bottom, RoyalSpace.tabBarClearance)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = StatsViewModel(service: services.clashRoyale)
            }
            await viewModel?.load()
            withAnimation(RoyalMotionV2.appear) { appear = true }
        }
    }
}
