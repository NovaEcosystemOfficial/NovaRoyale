import SwiftUI

struct RoyalTabBarV2: View {
    @Binding var selection: AppTab
    @Environment(AppLanguage.self) private var language

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabItem(tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background { barChrome }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    private func tabItem(_ tab: AppTab) -> some View {
        let selected = selection == tab
        return Button {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            withAnimation(RoyalMotionV2.tab) { selection = tab }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: tab.symbol)
                    .font(.system(size: selected ? 22 : 16, weight: .black))
                    .offset(y: selected ? -4 : 0)
                    .foregroundStyle(selected ? RoyalDS.Color.gold : RoyalDS.Color.textMuted)
                    .shadow(color: selected ? RoyalDS.Color.gold.opacity(0.9) : .clear, radius: 8)

                Text(L10n.t(tab.titleKey, language))
                    .font(RoyalFont.ui(10, weight: .bold))
                    .foregroundStyle(selected ? RoyalDS.Color.gold : RoyalDS.Color.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background {
                if selected {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [RoyalDS.Color.gold.opacity(0.35), RoyalDS.Color.gold.opacity(0.08)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(Capsule().stroke(RoyalDS.Color.gold.opacity(0.55), lineWidth: 1.4))
                        .shadow(color: RoyalDS.Color.gold.opacity(0.35), radius: 8)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.t(tab.titleKey, language))
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var barChrome: some View {
        ZStack {
            Capsule()
                .fill(Color.black.opacity(0.6))
                .offset(y: 5)
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.14, green: 0.22, blue: 0.42),
                            Color(red: 0.05, green: 0.08, blue: 0.18)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            Capsule()
                .stroke(RoyalLighting.metalRim, lineWidth: 2.4)
            Capsule()
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                .padding(2)
            RoyalTexture.Noise(intensity: 0.06)
                .clipShape(Capsule())
        }
        .shadow(color: RoyalDS.Color.electric.opacity(0.25), radius: 14, y: 6)
    }
}
