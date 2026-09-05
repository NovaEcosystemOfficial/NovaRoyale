import SwiftUI

struct CardsView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(AppLanguage.self) private var language
    @Namespace private var cardNamespace
    @State private var viewModel: CardsViewModel?
    @State private var appear = false
    @State private var selectedCard: CardItem?

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ZStack {
                RoyalBackgroundV2()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            RoyalText(text: L10n.t("cards.title", language), size: 26, color: RoyalDS.Color.gold)
                            Text(L10n.t("cards.subtitle", language))
                                .font(RoyalFont.ui(13, weight: .semibold))
                                .foregroundStyle(RoyalDS.Color.textMuted)
                        }
                        .staggeredAppear(index: 0, isVisible: appear)

                        if let cards = viewModel?.cards, !cards.isEmpty {
                            collectionSummary(cards)
                                .staggeredAppear(index: 1, isVisible: appear)
                        }

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(Array((viewModel?.cards ?? []).enumerated()), id: \.element.id) { index, card in
                                CardCollectionItem(card: card, namespace: cardNamespace) {
                                    selectedCard = card
                                }
                                .staggeredAppear(index: min(index, 24) + 2, isVisible: appear)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .padding(.bottom, RoyalSpace.tabBarClearance)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $selectedCard) { card in
                CardDetailView(card: card, namespace: cardNamespace)
            }
        }
        .task {
            if viewModel == nil {
                viewModel = CardsViewModel(service: services.clashRoyale)
            }
            await viewModel?.load()
            withAnimation(RoyalMotionV2.appear) { appear = true }
        }
    }

    private func collectionSummary(_ cards: [CardItem]) -> some View {
        let legendary = cards.filter { $0.rarity == .legendary || $0.rarity == .champion }.count
        return RoyalPanelV2(kind: .purple, cornerRadius: RoyalDS.Radius.md, padding: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    RoyalText(text: L10n.format("cards.count", language, cards.count), size: 18)
                    Text(L10n.format("cards.legendary_plus", language, legendary))
                        .font(RoyalFont.ui(12, weight: .bold))
                        .foregroundStyle(RoyalDS.Color.gold)
                }
                Spacer()
                Image(systemName: "rectangle.portrait.on.rectangle.portrait.fill")
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(RoyalDS.Color.purple)
                    .shadow(color: RoyalDS.Color.purple.opacity(0.7), radius: 10)
            }
        }
    }
}
