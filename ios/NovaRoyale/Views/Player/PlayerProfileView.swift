import SwiftUI

struct PlayerProfileView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(AppLanguage.self) private var language
    @Environment(SessionController.self) private var session
    @State private var viewModel: PlayerViewModel?
    @State private var appear = false

    var body: some View {
        ZStack {
            RoyalBackgroundV2()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 4) {
                        RoyalText(text: L10n.t("profile.title", language), size: 26, color: RoyalDS.Color.gold)
                        Text(L10n.t("profile.subtitle", language))
                            .font(RoyalFont.ui(13, weight: .semibold))
                            .foregroundStyle(RoyalDS.Color.textMuted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .staggeredAppear(index: 0, isVisible: appear)

                    if let player = viewModel?.player {
                        RoyalPlayerBanner(
                            playerName: player.name,
                            playerTag: player.tag,
                            level: player.level,
                            trophies: player.trophies,
                            clanName: player.clanName,
                            bannerCardNames: ["Princess", "Ice Wizard", "Mega Knight"]
                        )
                        .staggeredAppear(index: 1, isVisible: appear)

                        RoyalArenaHeroPlaceholder(arenaName: player.arenaName, trophies: player.trophies)
                            .staggeredAppear(index: 2, isVisible: appear)

                        battleRecord(player)
                            .staggeredAppear(index: 3, isVisible: appear)

                        changeTagSection
                            .staggeredAppear(index: 4, isVisible: appear)

                        languageSection
                            .staggeredAppear(index: 5, isVisible: appear)

                        emblemsSection
                            .staggeredAppear(index: 6, isVisible: appear)
                    } else {
                        RoundedRectangle(cornerRadius: RoyalDS.Radius.xl)
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 240)
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
                viewModel = PlayerViewModel(service: services.clashRoyale)
            }
            await viewModel?.load()
            withAnimation(RoyalMotionV2.appear) { appear = true }
        }
    }

    private func battleRecord(_ player: PlayerProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            RoyalText(text: L10n.t("profile.battle_record", language), size: 18, color: RoyalDS.Color.gold)
            Text(L10n.t("profile.battle_record.subtitle", language))
                .font(RoyalFont.ui(12, weight: .semibold))
                .foregroundStyle(RoyalDS.Color.textMuted)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(title: L10n.t("stats.wins", language), value: "\(player.wins)", symbol: "checkmark.seal.fill", tint: RoyalDS.Color.victory, style: .success)
                StatCard(title: L10n.t("stats.losses", language), value: "\(player.losses)", symbol: "xmark.octagon.fill", tint: RoyalDS.Color.defeat, style: .danger)
                StatCard(title: L10n.t("stats.win_rate", language), value: "\(player.winRatePercent)%", symbol: "chart.pie.fill", tint: RoyalDS.Color.cyan, style: .blue)
                StatCard(title: L10n.t("stats.best", language), value: "\(player.bestTrophies)", symbol: "crown.fill", tint: RoyalDS.Color.gold, style: .gold)
                StatCard(title: L10n.t("stats.battles", language), value: "\(player.battleCount)", symbol: "bolt.fill", tint: RoyalDS.Color.purple, style: .purple)
                StatCard(title: L10n.t("profile.level", language), value: "\(player.level)", symbol: "star.fill", tint: RoyalDS.Color.electric, style: .primary)
            }
        }
    }

    private var changeTagSection: some View {
        RoyalPanelV2(kind: .purple, cornerRadius: RoyalDS.Radius.lg) {
            VStack(alignment: .leading, spacing: 10) {
                RoyalText(text: L10n.t("profile.change_tag", language), size: 18, color: RoyalDS.Color.gold)
                Text(L10n.t("profile.change_tag.subtitle", language))
                    .font(RoyalFont.ui(12, weight: .semibold))
                    .foregroundStyle(RoyalDS.Color.textMuted)
                RoyalButtonV2(
                    title: L10n.t("profile.change_tag.cta", language),
                    symbol: "person.badge.key.fill",
                    kind: .purple,
                    height: 52
                ) {
                    session.unlinkLocally()
                }
            }
        }
    }

    private var languageSection: some View {
        RoyalPanelV2(kind: .blue, cornerRadius: RoyalDS.Radius.lg) {
            VStack(alignment: .leading, spacing: 12) {
                RoyalText(text: L10n.t("profile.language", language), size: 18, color: RoyalDS.Color.gold)
                Text(L10n.t("profile.language.subtitle", language))
                    .font(RoyalFont.ui(12, weight: .semibold))
                    .foregroundStyle(RoyalDS.Color.textMuted)

                HStack(spacing: 10) {
                    ForEach(AppLanguageCode.allCases) { code in
                        let selected = language.code == code
                        RoyalHapticButton {
                            withAnimation(RoyalMotionV2.snappy) {
                                language.code = code
                            }
                        } label: {
                            Text(code.displayName)
                                .font(RoyalFont.ui(14, weight: .black))
                                .foregroundStyle(selected ? Color(red: 0.25, green: 0.12, blue: 0.02) : .white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background {
                                    Capsule()
                                        .fill(selected ? RoyalLighting.goldFace : LinearGradient(colors: [Color.white.opacity(0.12), Color.white.opacity(0.06)], startPoint: .top, endPoint: .bottom))
                                        .overlay(Capsule().stroke(selected ? RoyalDS.Color.gold : Color.white.opacity(0.2), lineWidth: 1.5))
                                }
                        }
                    }
                }
            }
        }
    }

    private var emblemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoyalText(text: L10n.t("profile.emblems", language), size: 18, color: RoyalDS.Color.gold)
            Text(L10n.t("profile.emblems.subtitle", language))
                .font(RoyalFont.ui(12, weight: .semibold))
                .foregroundStyle(RoyalDS.Color.textMuted)
            HStack(spacing: 12) {
                RoyalEmblemMedallion(symbol: "trophy.fill", title: "Climber", tint: RoyalDS.Color.gold, kind: .gold)
                RoyalEmblemMedallion(symbol: "flame.fill", title: "Hot Streak", tint: RoyalDS.Color.defeat, kind: .danger)
                RoyalEmblemMedallion(symbol: "shield.fill", title: "Defender", tint: RoyalDS.Color.cyan, kind: .blue)
            }
        }
    }
}
