import SwiftUI

enum AppTab: Hashable, CaseIterable {
    case home
    case battles
    case cards
    case stats
    case profile

    var titleKey: String {
        switch self {
        case .home: return "tab.home"
        case .battles: return "tab.battles"
        case .cards: return "tab.cards"
        case .stats: return "tab.stats"
        case .profile: return "tab.profile"
        }
    }

    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .battles: return "bolt.shield.fill"
        case .cards: return "rectangle.portrait.on.rectangle.portrait.fill"
        case .stats: return "chart.bar.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

struct MainTabView: View {
    @Environment(AppLanguage.self) private var language
    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView(selectedTab: $selectedTab)
                case .battles:
                    BattlesView()
                case .cards:
                    CardsView()
                case .stats:
                    StatsView()
                case .profile:
                    PlayerProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            RoyalTabBarV2(selection: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .id(language.code.rawValue)
    }
}
