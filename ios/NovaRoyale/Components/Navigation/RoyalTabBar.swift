import SwiftUI

struct RoyalTabBar: View {
    @Binding var selection: AppTab

    private let items: [(AppTab, String, String)] = [
        (.home, "Home", "house.fill"),
        (.battles, "Battles", "bolt.shield.fill"),
        (.cards, "Cards", "rectangle.portrait.on.rectangle.portrait.fill"),
        (.stats, "Stats", "chart.bar.fill"),
        (.profile, "Profile", "person.crop.circle.fill")
    ]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(items, id: \.0) { tab, title, symbol in
                tabButton(tab: tab, title: title, symbol: symbol)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background {
            ZStack {
                Capsule()
                    .fill(Color.black.opacity(0.55))
                    .offset(y: 4)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.12, green: 0.22, blue: 0.48),
                                Color(red: 0.06, green: 0.10, blue: 0.26)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [RoyalColor.metalLight.opacity(0.8), RoyalColor.gold.opacity(0.45), RoyalColor.metalDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                Capsule()
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    .padding(2)
            }
            .shadow(color: RoyalColor.electricBlue.opacity(0.35), radius: 16, y: 6)
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }

    private func tabButton(tab: AppTab, title: String, symbol: String) -> some View {
        let selected = selection == tab
        return Button {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            withAnimation(RoyalMotion.tab) { selection = tab }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: symbol)
                    .font(.system(size: selected ? 19 : 15, weight: .black))
                    .scaleEffect(selected ? 1.15 : 1)
                    .shadow(color: selected ? RoyalColor.gold.opacity(0.9) : .clear, radius: 8)
                Text(title)
                    .font(RoyalTypography.caption(10))
            }
            .foregroundStyle(selected ? RoyalColor.gold : RoyalColor.textMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background {
                if selected {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [RoyalColor.gold.opacity(0.35), RoyalColor.gold.opacity(0.12)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(Capsule().stroke(RoyalColor.gold.opacity(0.55), lineWidth: 1.2))
                        .shadow(color: RoyalColor.gold.opacity(0.35), radius: 8)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
