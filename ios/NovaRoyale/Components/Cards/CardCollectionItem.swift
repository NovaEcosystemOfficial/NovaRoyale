import SwiftUI

struct RarityBadge: View {
    let rarity: CardRarity

    var body: some View {
        Text(rarity.displayName.uppercased())
            .font(RoyalTypography.caption(10))
            .foregroundStyle(rarity == .legendary || rarity == .common ? .black.opacity(0.8) : .white)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background {
                Capsule()
                    .fill(RoyalColor.rarity(rarity))
                    .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1))
                    .shadow(color: RoyalColor.rarity(rarity).opacity(0.55), radius: 6, y: 2)
            }
    }
}

struct CardArtworkPlaceholder: View {
    let rarity: CardRarity
    var size: CGFloat = 72

    var body: some View {
        let tint = RoyalColor.rarity(rarity)
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.black.opacity(0.4))
                .frame(width: size + 4, height: size * 1.25 + 4)
                .offset(y: 3)

            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(RoyalColor.rarityFill(rarity))
                .frame(width: size, height: size * 1.25)
                .overlay {
                    // Inner ornate frame
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        .padding(5)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [tint, Color.white.opacity(0.5), tint.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: rarity == .champion || rarity == .legendary ? 3 : 2
                        )
                )
                .shadow(color: tint.opacity(0.55), radius: rarity == .legendary || rarity == .champion ? 14 : 8)

            VStack(spacing: 6) {
                Image(systemName: symbol(for: rarity))
                    .font(.system(size: size * 0.32, weight: .black))
                    .foregroundStyle(.white)
                    .shadow(color: tint.opacity(0.8), radius: 6)
                if rarity == .champion {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(RoyalColor.gold)
                }
            }
        }
        .accessibilityHidden(true)
    }

    private func symbol(for rarity: CardRarity) -> String {
        switch rarity {
        case .common: return "person.fill"
        case .rare: return "flame.fill"
        case .epic: return "sparkles"
        case .legendary: return "crown.fill"
        case .champion: return "star.circle.fill"
        }
    }
}

struct CardCollectionItem: View {
    let card: CardItem
    var namespace: Namespace.ID?
    var onTap: (() -> Void)?

    var body: some View {
        let tint = RoyalColor.rarity(card.rarity)
        let style: RoyalPanelStyle = {
            switch card.rarity {
            case .common: return .blue
            case .rare: return .gold
            case .epic: return .purple
            case .legendary: return .gold
            case .champion: return .danger
            }
        }()

        HapticButton { onTap?() } label: {
            RoyalPanel(style: style, cornerRadius: RoyalRadius.md, padding: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        RoyalCardArt(card: card, size: CGSize(width: 54, height: 68))
                            .modifier(OptionalMatchedGeometry(id: card.id, namespace: namespace))

                        Spacer(minLength: 4)
                        RarityBadge(rarity: card.rarity)
                    }

                    Text(card.name)
                        .font(RoyalTypography.title(16))
                        .foregroundStyle(RoyalColor.textPrimary)
                        .lineLimit(1)

                    Text("LVL \(card.level)/\(card.maxLevel)")
                        .font(RoyalTypography.caption())
                        .foregroundStyle(RoyalColor.textMuted)

                    RoyalProgressBar(progress: card.progress, tint: tint, height: 12)
                }
                .frame(maxWidth: .infinity, minHeight: 158, alignment: .topLeading)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(card.name), \(card.rarity.displayName), level \(card.level) of \(card.maxLevel)")
    }
}

private struct OptionalMatchedGeometry: ViewModifier {
    let id: String
    let namespace: Namespace.ID?

    func body(content: Content) -> some View {
        if let namespace {
            content.matchedGeometryEffect(id: id, in: namespace)
        } else {
            content
        }
    }
}
