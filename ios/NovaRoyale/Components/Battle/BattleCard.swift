import SwiftUI

struct BattleResultBadge: View {
    let outcome: BattleOutcome
    @Environment(AppLanguage.self) private var language

    var body: some View {
        let tint = outcome == .victory ? RoyalDS.Color.victory : RoyalDS.Color.defeat
        let key = outcome == .victory ? "battles.victory" : "battles.defeat"
        Text(L10n.t(key, language))
            .font(RoyalFont.ui(11, weight: .black))
            .foregroundStyle(.black.opacity(0.85))
            .padding(.horizontal, 11)
            .padding(.vertical, 5)
            .background {
                Capsule()
                    .fill(tint)
                    .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1))
                    .shadow(color: tint.opacity(0.7), radius: 8, y: 2)
            }
    }
}

struct BattleCard: View {
    let battle: BattleRecord
    var onTap: (() -> Void)?

    private var tint: Color {
        battle.outcome == .victory ? RoyalDS.Color.victory : RoyalDS.Color.defeat
    }

    private var style: RoyalDS.PanelKind {
        battle.outcome == .victory ? .success : .danger
    }

    private var trophyText: String {
        battle.trophyChange >= 0 ? "+\(battle.trophyChange)" : "\(battle.trophyChange)"
    }

    var body: some View {
        RoyalHapticButton {
            onTap?()
        } label: {
            RoyalPanelV2(kind: style, cornerRadius: RoyalDS.Radius.md) {
                HStack(spacing: 14) {
                    RoyalIconV2(
                        systemName: battle.outcome == .victory ? "checkmark.seal.fill" : "xmark.octagon.fill",
                        size: 48,
                        tint: tint,
                        kind: style
                    )

                    VStack(alignment: .leading, spacing: 5) {
                        BattleResultBadge(outcome: battle.outcome)
                        RoyalText(text: battle.opponentName, size: 18, strokeWidth: 1.2)
                        Text("\(battle.mode) · \(battle.relativeTime)")
                            .font(RoyalFont.ui(12, weight: .semibold))
                            .foregroundStyle(RoyalDS.Color.textMuted)
                        if let crowns = battle.crowns, let opp = battle.opponentCrowns {
                            Text("👑 \(crowns)–\(opp)")
                                .font(RoyalFont.ui(12, weight: .bold))
                                .foregroundStyle(RoyalDS.Color.gold.opacity(0.9))
                        }
                    }

                    Spacer(minLength: 4)

                    Text(trophyText)
                        .font(RoyalFont.display(34))
                        .foregroundStyle(tint)
                        .shadow(color: RoyalDS.Color.stroke, radius: 0, x: 1.5, y: 0)
                        .shadow(color: RoyalDS.Color.stroke, radius: 0, x: -1.5, y: 0)
                        .shadow(color: tint.opacity(0.7), radius: 10, y: 2)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct QuickActionCard: View {
    let title: String
    let symbol: String
    let tint: Color
    var kind: RoyalDS.PanelKind = .primary
    let action: () -> Void

    var body: some View {
        RoyalHapticButton(action: action) {
            RoyalPanelV2(kind: kind, cornerRadius: RoyalDS.Radius.md, padding: 14, showQuilt: false) {
                VStack(spacing: 12) {
                    RoyalIconV2(systemName: symbol, size: 48, tint: tint, kind: kind)
                    RoyalText(text: title, size: 15, strokeWidth: 1.1)
                }
                .frame(maxWidth: .infinity, minHeight: 108)
            }
        }
        .accessibilityLabel(title)
    }
}
