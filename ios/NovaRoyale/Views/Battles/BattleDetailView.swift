import SwiftUI

struct BattleDetailView: View {
    let battle: BattleRecord
    @Environment(\.dismiss) private var dismiss
    @Environment(AppLanguage.self) private var language

    private var tint: Color {
        battle.outcome == .victory ? RoyalDS.Color.victory : RoyalDS.Color.defeat
    }

    private var panelKind: RoyalDS.PanelKind {
        battle.outcome == .victory ? .success : .danger
    }

    private var trophyText: String {
        battle.trophyChange >= 0 ? "+\(battle.trophyChange)" : "\(battle.trophyChange)"
    }

    var body: some View {
        ZStack {
            RoyalBackgroundV2()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(RoyalDS.Color.cyan)
                                .padding(10)
                                .background {
                                    Circle()
                                        .fill(Color.black.opacity(0.35))
                                        .overlay(Circle().stroke(RoyalDS.Color.cyan.opacity(0.4), lineWidth: 1))
                                }
                        }
                        Spacer()
                        BattleResultBadge(outcome: battle.outcome)
                    }

                    vsSection
                    metricsGrid

                    if let deck = battle.deckCardNames, !deck.isEmpty {
                        deckSection(deck)
                    }
                }
                .padding(14)
                .padding(.bottom, 28)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var vsSection: some View {
        RoyalPanelV2(kind: panelKind, cornerRadius: RoyalDS.Radius.xl) {
            VStack(spacing: 18) {
                Text(trophyText)
                    .font(RoyalFont.display(56))
                    .foregroundStyle(tint)
                    .shadow(color: RoyalDS.Color.stroke, radius: 0, x: 2, y: 0)
                    .shadow(color: RoyalDS.Color.stroke, radius: 0, x: -2, y: 0)
                    .shadow(color: tint.opacity(0.75), radius: 14, y: 2)

                RoyalText(
                    text: L10n.t(battle.outcome == .victory ? "battles.detail.won" : "battles.detail.lost", language),
                    size: 20,
                    color: tint
                )

                HStack(spacing: 20) {
                    playerColumn(name: L10n.t("battles.you", language), subtitle: L10n.t("app.name", language))
                    RoyalText(text: "VS", size: 22, color: RoyalDS.Color.gold)
                    playerColumn(name: battle.opponentName, subtitle: L10n.t("battles.opponent", language))
                }

                if let crowns = battle.crowns, let opp = battle.opponentCrowns {
                    Text("Crowns \(crowns) – \(opp)")
                        .font(RoyalFont.ui(16, weight: .bold))
                        .foregroundStyle(RoyalDS.Color.textPrimary)
                }
            }
        }
    }

    private func playerColumn(name: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            RoyalIconV2(systemName: "person.fill", size: 52, tint: RoyalDS.Color.cyan, kind: .blue)
            Text(name)
                .font(RoyalFont.ui(14, weight: .bold))
                .foregroundStyle(RoyalDS.Color.textPrimary)
                .lineLimit(1)
            Text(subtitle)
                .font(RoyalFont.ui(11, weight: .semibold))
                .foregroundStyle(RoyalDS.Color.textMuted)
        }
        .frame(maxWidth: .infinity)
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: L10n.t("home.trophies", language), value: trophyText, symbol: "trophy.fill", tint: tint, style: panelKind)
            StatCard(title: L10n.t("battles.detail.mode", language), value: battle.mode, symbol: "flag.fill", tint: RoyalDS.Color.electric, style: .blue)
            StatCard(title: L10n.t("battles.detail.when", language), value: battle.relativeTime, symbol: "clock.fill", tint: RoyalDS.Color.cyan, style: .primary)
            if let duration = battle.durationSeconds {
                StatCard(title: L10n.t("battles.detail.duration", language), value: formatDuration(duration), symbol: "timer", tint: RoyalDS.Color.purple, style: .purple)
            }
        }
    }

    private func deckSection(_ cards: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            RoyalText(text: L10n.t("battles.detail.deck", language), size: 18, color: RoyalDS.Color.gold)
            Text(L10n.t("battles.detail.deck.subtitle", language))
                .font(RoyalFont.ui(12, weight: .semibold))
                .foregroundStyle(RoyalDS.Color.textMuted)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(cards, id: \.self) { name in
                    VStack(spacing: 6) {
                        RoyalCardArt(
                            assetName: name,
                            remoteURL: ClashRoyaleIconCatalog.mediumURL(forCardNamed: name),
                            size: CGSize(width: 56, height: 72),
                            cornerRadius: 10
                        )
                        Text(name)
                            .font(RoyalFont.ui(10, weight: .bold))
                            .foregroundStyle(RoyalDS.Color.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
            }
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
