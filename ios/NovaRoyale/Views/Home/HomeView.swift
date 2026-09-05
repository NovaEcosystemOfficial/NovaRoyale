import SwiftUI

struct HomeView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(AppLanguage.self) private var language
    @Binding var selectedTab: AppTab
    @State private var viewModel: HomeViewModel?
    @State private var appear = false
    @State private var selectedBattle: BattleRecord?
    @State private var showChests = false

    var body: some View {
        NavigationStack {
            ZStack {
                RoyalBackgroundV2()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        header
                            .staggeredAppear(index: 0, isVisible: appear)

                        if let player = viewModel?.player {
                            RoyalPlayerBanner(
                                playerName: player.name,
                                playerTag: player.tag,
                                level: player.level,
                                trophies: player.trophies,
                                clanName: player.clanName,
                                bannerCardNames: ["Knight", "Witch", "Prince"]
                            )
                            .staggeredAppear(index: 1, isVisible: appear)

                            arenaHero(player)
                                .staggeredAppear(index: 2, isVisible: appear)
                        } else if viewModel?.isLoading == true {
                            RoundedRectangle(cornerRadius: RoyalDS.Radius.xl)
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 280)
                                .royalShimmer(true)
                        }

                        RoyalButtonV2(
                            title: L10n.t("home.battle_cta", language),
                            subtitle: L10n.t("home.battle_cta.subtitle", language),
                            symbol: "bolt.fill",
                            kind: .battle,
                            height: 72
                        ) {
                            selectedTab = .battles
                        }
                        .staggeredAppear(index: 3, isVisible: appear)

                        quickAccess
                            .staggeredAppear(index: 4, isVisible: appear)

                        latestBattle
                            .staggeredAppear(index: 5, isVisible: appear)
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
            .sheet(isPresented: $showChests) {
                ChestsView()
                    .environment(language)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = HomeViewModel(service: services.clashRoyale)
            }
            await viewModel?.load()
            withAnimation(RoyalMotionV2.appear) { appear = true }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                RoyalText(text: L10n.t("app.name", language), size: 28, color: RoyalDS.Color.gold, strokeWidth: 2)
                Text(L10n.t("app.subtitle", language))
                    .font(RoyalFont.ui(12, weight: .semibold))
                    .foregroundStyle(RoyalDS.Color.cyan)
            }
            Spacer()
            RoyalBadgeV2(text: L10n.t("status.online", language).uppercased(), kind: .victory, symbol: "circle.fill")
        }
    }

    private func arenaHero(_ player: PlayerProfile) -> some View {
        let info = ArenaProgressInfo.from(trophies: player.trophies, arenaName: player.arenaName)
        return RoyalPanelV2(kind: .gold, cornerRadius: RoyalDS.Radius.xl, padding: 14) {
            VStack(spacing: 12) {
                RoyalArenaHeroPlaceholder(arenaName: player.arenaName, trophies: player.trophies)
                HStack {
                    RoyalText(text: L10n.t("home.progression", language), size: 16, color: RoyalDS.Color.gold)
                    Spacer()
                    if let next = info.nextArena, let remaining = info.trophiesToNext {
                        Text(L10n.format("home.to_next_arena", language, remaining, next))
                            .font(RoyalFont.ui(12, weight: .bold))
                            .foregroundStyle(RoyalDS.Color.textMuted)
                    }
                }
                RoyalProgressV2(progress: info.progress, tint: RoyalDS.Color.gold, height: 16)
            }
        }
    }

    private var quickAccess: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoyalText(text: L10n.t("home.quick_access", language), size: 18, color: RoyalDS.Color.gold)
            Text(L10n.t("home.quick_access.subtitle", language))
                .font(RoyalFont.ui(12, weight: .semibold))
                .foregroundStyle(RoyalDS.Color.textMuted)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                quickTile(L10n.t("tab.battles", language), "bolt.shield.fill", .danger) { selectedTab = .battles }
                quickTile(L10n.t("tab.cards", language), "rectangle.portrait.on.rectangle.portrait.fill", .purple) { selectedTab = .cards }
                quickTile(L10n.t("tab.stats", language), "chart.bar.fill", .blue) { selectedTab = .stats }
                quickTile(L10n.t("home.chests", language), "gift.fill", .gold) { showChests = true }
            }
        }
    }

    private func quickTile(_ title: String, _ symbol: String, _ kind: RoyalDS.PanelKind, action: @escaping () -> Void) -> some View {
        RoyalHapticButton(action: action) {
            RoyalPanelV2(kind: kind, cornerRadius: RoyalDS.Radius.md, padding: 10, showQuilt: false) {
                VStack(spacing: 8) {
                    RoyalIconV2(systemName: symbol, size: 42, tint: kind.rim, kind: kind)
                    RoyalText(text: title, size: 13, strokeWidth: 1.1)
                }
                .frame(maxWidth: .infinity, minHeight: 92)
            }
        }
    }

    private var latestBattle: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    RoyalText(text: L10n.t("home.latest_battle", language), size: 18, color: RoyalDS.Color.gold)
                    Text(L10n.t("home.latest_battle.subtitle", language))
                        .font(RoyalFont.ui(12, weight: .semibold))
                        .foregroundStyle(RoyalDS.Color.textMuted)
                }
                Spacer()
                Button(L10n.t("home.all", language)) { selectedTab = .battles }
                    .font(RoyalFont.ui(13, weight: .bold))
                    .foregroundStyle(RoyalDS.Color.cyan)
            }

            if let battle = viewModel?.battles.first {
                BattleCard(battle: battle) { selectedBattle = battle }
            } else if viewModel?.isLoading == false {
                Text(L10n.t("home.no_battles", language))
                    .font(RoyalFont.ui(14, weight: .semibold))
                    .foregroundStyle(RoyalDS.Color.textMuted)
            }
        }
    }
}
