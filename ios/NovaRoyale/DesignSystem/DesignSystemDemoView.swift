import SwiftUI

/// Reference screen kept for design QA (optional entry from Profile later).
struct DesignSystemDemoView: View {
    var onEnterApp: (() -> Void)?

    @State private var tab: AppTab = .home
    @State private var appear = false
    @State private var showModal = false
    @State private var language = AppLanguage.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            RoyalBackgroundV2()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    header
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 16)

                    playerStrip
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 18)

                    RoyalPlayerBanner(
                        playerName: "Fabio",
                        playerTag: "#29G9Q92RL",
                        level: 9,
                        trophies: 1040,
                        clanName: "RoyalCompanion",
                        bannerCardNames: ["Knight", "Witch", "Prince"]
                    )
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 18)

                    arenaBlock
                        .opacity(appear ? 1 : 0)
                        .scaleEffect(appear ? 1 : 0.96)

                    RoyalButtonV2(
                        title: "BATTLE",
                        subtitle: "Demo CTA · 0/10 crowns",
                        symbol: "bolt.fill",
                        kind: .battle,
                        height: 72
                    ) {
                        showModal = true
                    }
                    .opacity(appear ? 1 : 0)

                    quickAccess
                        .opacity(appear ? 1 : 0)

                    cardsRow
                        .opacity(appear ? 1 : 0)

                    statsRow
                        .opacity(appear ? 1 : 0)

                    buttonsRow
                        .opacity(appear ? 1 : 0)

                    if let onEnterApp {
                        RoyalButtonV2(title: "ENTER APP", subtitle: "Back to live screens", kind: .blue, height: 56, action: onEnterApp)
                    }

                    Text("Design System V2 · Demo")
                        .font(RoyalFont.ui(11, weight: .semibold))
                        .foregroundStyle(RoyalDS.Color.textMuted)
                        .padding(.bottom, 110)
                }
                .padding(.horizontal, 14)
                .padding(.top, 8)
            }

            RoyalTabBarV2(selection: $tab)

            if showModal {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .onTapGesture { showModal = false }

                RoyalModalV2(title: "ROYAL PANEL", onClose: { showModal = false }) {
                    VStack(spacing: 14) {
                        RoyalDividerV2()
                        RoyalText(text: "Trophy Road", size: 20, color: RoyalDS.Color.gold)
                        RoyalInset {
                            HStack {
                                RoyalIconV2(systemName: "trophy.fill", size: 48, tint: RoyalDS.Color.gold)
                                VStack(alignment: .leading, spacing: 4) {
                                    RoyalText(text: "Arena 4", size: 18)
                                    Text("260 to next arena")
                                        .font(RoyalFont.ui(12, weight: .bold))
                                        .foregroundStyle(RoyalDS.Color.cyan)
                                    RoyalProgressV2(progress: 0.62, tint: RoyalDS.Color.gold, height: 14)
                                }
                            }
                        }
                        RoyalButtonV2(title: "CONTINUE", kind: .gold, height: 52) {
                            showModal = false
                        }
                    }
                    .padding(.top, 12)
                }
                .padding(.horizontal, 18)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .environment(language)
        .animation(RoyalMotionV2.appear, value: showModal)
        .onAppear {
            RoyalFont.registerIfNeeded()
            withAnimation(RoyalMotionV2.appear) { appear = true }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                RoyalText(text: "RoyalCompanion", size: 30, color: RoyalDS.Color.gold, strokeWidth: 2)
                Text("Your Clash Royale Companion")
                    .font(RoyalFont.ui(12, weight: .semibold))
                    .foregroundStyle(RoyalDS.Color.cyan)
            }
            Spacer()
            RoyalBadgeV2(text: "ONLINE", kind: .victory, symbol: "circle.fill")
        }
    }

    private var playerStrip: some View {
        RoyalPanelV2(kind: .blue, cornerRadius: RoyalDS.Radius.lg) {
            HStack(spacing: 12) {
                RoyalIconV2(systemName: "person.fill", size: 56, tint: RoyalDS.Color.cyan, kind: .blue)
                VStack(alignment: .leading, spacing: 4) {
                    RoyalText(text: "Fabio", size: 24)
                    Text("#29G9Q92RL")
                        .font(RoyalFont.ui(13, weight: .bold))
                        .foregroundStyle(RoyalDS.Color.cyan)
                    HStack(spacing: 8) {
                        RoyalBadgeV2(text: "LVL 9", kind: .level)
                        RoyalBadgeV2(text: "Arena 4", kind: .blue, symbol: "shield.fill")
                    }
                }
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 2) {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(RoyalDS.Color.gold)
                    RoyalNumber(value: 1040, size: 30)
                }
            }
        }
    }

    private var arenaBlock: some View {
        RoyalPanelV2(kind: .gold, cornerRadius: RoyalDS.Radius.xl, padding: 14) {
            VStack(spacing: 12) {
                RoyalArenaHeroPlaceholder(arenaName: "Arena 4", trophies: 1040)
                HStack {
                    RoyalText(text: "Progression", size: 16, color: RoyalDS.Color.gold)
                    Spacer()
                    Text("260 to Arena 5")
                        .font(RoyalFont.ui(12, weight: .bold))
                        .foregroundStyle(RoyalDS.Color.textMuted)
                }
                RoyalProgressV2(progress: 0.62, tint: RoyalDS.Color.gold, height: 16)
            }
        }
    }

    private var quickAccess: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoyalText(text: "Quick Access", size: 18, color: RoyalDS.Color.gold)
            HStack(spacing: 10) {
                quickTile("Battles", "bolt.shield.fill", .danger)
                quickTile("Cards", "rectangle.portrait.on.rectangle.portrait.fill", .purple)
                quickTile("Stats", "chart.bar.fill", .blue)
                quickTile("Chests", "gift.fill", .gold)
            }
        }
    }

    private func quickTile(_ title: String, _ symbol: String, _ kind: RoyalDS.PanelKind) -> some View {
        RoyalPanelV2(kind: kind, cornerRadius: RoyalDS.Radius.md, padding: 10, showQuilt: false) {
            VStack(spacing: 8) {
                RoyalIconV2(systemName: symbol, size: 40, tint: kind.rim, kind: kind)
                RoyalText(text: title, size: 12, strokeWidth: 1)
            }
            .frame(maxWidth: .infinity, minHeight: 86)
        }
    }

    private var cardsRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoyalText(text: "Collectible Cards", size: 18, color: RoyalDS.Color.gold)
            HStack(spacing: 10) {
                RoyalCardV2(name: "Knight", rarity: .common, level: 11, maxLevel: 14, progress: 0.72)
                RoyalCardV2(name: "Witch", rarity: .epic, level: 6, maxLevel: 9, progress: 0.54, symbol: "sparkles")
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            RoyalInset {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Wins")
                        .font(RoyalFont.ui(11, weight: .bold))
                        .foregroundStyle(RoyalDS.Color.cyan)
                    RoyalNumber(value: 286, size: 32, style: .victory)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            RoyalInset {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Win Rate")
                        .font(RoyalFont.ui(11, weight: .bold))
                        .foregroundStyle(RoyalDS.Color.cyan)
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        RoyalNumber(value: 57, size: 32, style: .cyan)
                        RoyalText(text: "%", size: 18, color: RoyalDS.Color.cyan)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var buttonsRow: some View {
        HStack(spacing: 10) {
            RoyalButtonV2(title: "GOLD", kind: .gold, height: 48) {}
            RoyalButtonV2(title: "BLUE", kind: .blue, height: 48) {}
            RoyalButtonV2(title: "EPIC", kind: .purple, height: 48) {}
        }
    }
}
