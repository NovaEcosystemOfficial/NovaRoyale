import SwiftUI

struct CardDetailView: View {
    let card: CardItem
    var namespace: Namespace.ID?
    @Environment(\.dismiss) private var dismiss
    @Environment(AppLanguage.self) private var language

    private var tint: Color {
        (RoyalCardRarity(rawValue: card.rarity.rawValue) ?? .common).tint
    }

    private var panelKind: RoyalDS.PanelKind {
        switch card.rarity {
        case .common: return .blue
        case .rare: return .gold
        case .epic: return .purple
        case .legendary: return .gold
        case .champion: return .danger
        }
    }

    var body: some View {
        ZStack {
            RoyalBackgroundV2()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
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
                        RarityBadge(rarity: card.rarity)
                    }

                    RoyalPanelV2(kind: panelKind, cornerRadius: RoyalDS.Radius.xl) {
                        VStack(spacing: 18) {
                            if let namespace {
                                RoyalCardArt(card: card, size: CGSize(width: 120, height: 156))
                                    .matchedGeometryEffect(id: card.id, in: namespace)
                            } else {
                                RoyalCardArt(card: card, size: CGSize(width: 120, height: 156))
                            }

                            RoyalText(text: card.name, size: 32, strokeWidth: 1.8)

                            Text("Level \(card.level) / \(card.maxLevel)")
                                .font(RoyalFont.ui(16, weight: .bold))
                                .foregroundStyle(RoyalDS.Color.textSecondary)

                            VStack(alignment: .leading, spacing: 8) {
                                Text(L10n.t("cards.upgrade", language))
                                    .font(RoyalFont.ui(12, weight: .bold))
                                    .foregroundStyle(RoyalDS.Color.textMuted)
                                RoyalProgressV2(progress: card.progress, tint: tint, height: 16)
                                Text("\(Int(card.progress * 100))%")
                                    .font(RoyalFont.ui(12, weight: .bold))
                                    .foregroundStyle(tint)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    RoyalPanelV2(kind: .primary, cornerRadius: RoyalDS.Radius.lg) {
                        VStack(alignment: .leading, spacing: 8) {
                            RoyalText(text: L10n.t("cards.collection_notes", language), size: 16)
                            Text(L10n.t("cards.collection_notes.body", language))
                                .font(RoyalFont.ui(13, weight: .semibold))
                                .foregroundStyle(RoyalDS.Color.textMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(14)
                .padding(.bottom, 28)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}
