import SwiftUI

struct RoyalHeader: View {
    var title: String = "RoyalCompanion"
    var subtitle: String = "Your Clash Royale Companion"
    var isOnline: Bool = true

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(RoyalTypography.display(30))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [RoyalColor.cyan, RoyalColor.legendaryGold, RoyalColor.gold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: RoyalColor.gold.opacity(0.45), radius: 10, y: 2)

                Text(subtitle)
                    .font(RoyalTypography.caption(12))
                    .foregroundStyle(RoyalColor.textMuted)

                OnlineIndicator(isOnline: isOnline)
            }
            Spacer()
            PlayerAvatar(name: "F", size: 48)
        }
        .accessibilityElement(children: .combine)
    }
}

struct OnlineIndicator: View {
    var isOnline: Bool

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isOnline ? RoyalColor.victoryGreen : RoyalColor.defeatRed)
                .frame(width: 9, height: 9)
                .shadow(color: (isOnline ? RoyalColor.victoryGreen : RoyalColor.defeatRed).opacity(0.9), radius: 5)
            Text(isOnline ? "Online" : "Offline")
                .font(RoyalTypography.caption(12))
                .foregroundStyle(RoyalColor.textSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background {
            Capsule()
                .fill(Color.black.opacity(0.35))
                .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
        }
    }
}

struct PlayerAvatar: View {
    let name: String
    var size: CGFloat = 64

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.45))
                .frame(width: size + 6, height: size + 6)
                .offset(y: 3)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [RoyalColor.electricBlue, RoyalColor.purple, RoyalColor.royalBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle().stroke(
                        LinearGradient(
                            colors: [RoyalColor.gold, RoyalColor.metalLight, RoyalColor.goldDeep],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 3
                    )
                )
                .shadow(color: RoyalColor.electricBlue.opacity(0.55), radius: 12)

            Text(String(name.prefix(1)).uppercased())
                .font(RoyalTypography.display(size * 0.42))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
        }
        .accessibilityHidden(true)
    }
}

struct LevelBadge: View {
    let level: Int

    var body: some View {
        Text("LVL \(level)")
            .font(RoyalTypography.caption(12))
            .foregroundStyle(.black.opacity(0.85))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                Capsule()
                    .fill(RoyalColor.goldGradient)
                    .overlay(Capsule().stroke(Color.white.opacity(0.45), lineWidth: 1))
                    .shadow(color: RoyalColor.gold.opacity(0.5), radius: 6, y: 2)
            }
    }
}

struct ArenaBadge: View {
    let name: String

    var body: some View {
        Label(name, systemImage: "shield.fill")
            .font(RoyalTypography.body(13))
            .foregroundStyle(RoyalColor.cyan)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background {
                Capsule()
                    .fill(Color.black.opacity(0.35))
                    .overlay(Capsule().stroke(RoyalColor.cyan.opacity(0.45), lineWidth: 1.2))
            }
    }
}

struct ArenaProgressView: View {
    let info: ArenaProgressInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(info.currentArena)
                    .font(RoyalTypography.body(13))
                    .foregroundStyle(RoyalColor.textSecondary)
                Spacer()
                if let next = info.nextArena, let remaining = info.trophiesToNext {
                    Text("\(remaining) to \(next)")
                        .font(RoyalTypography.caption(12))
                        .foregroundStyle(RoyalColor.gold.opacity(0.9))
                }
            }
            RoyalProgressBar(progress: info.progress, tint: RoyalColor.gold, height: 14)
        }
    }
}

struct TrophyDisplay: View {
    let trophies: Int
    var showLabel: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if showLabel {
                Label("Trophies", systemImage: "trophy.fill")
                    .font(RoyalTypography.caption())
                    .foregroundStyle(RoyalColor.gold)
            }
            AnimatedNumber(value: trophies, fontSize: 52)
        }
    }
}

/// Visual arena showcase panel.
struct RoyalArenaPanel: View {
    let player: PlayerProfile

    var body: some View {
        let info = ArenaProgressInfo.from(trophies: player.trophies, arenaName: player.arenaName)
        RoyalPanel(style: .gold, cornerRadius: RoyalRadius.xl) {
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.15, green: 0.35, blue: 0.20),
                                    Color(red: 0.08, green: 0.18, blue: 0.35),
                                    Color(red: 0.18, green: 0.12, blue: 0.08)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 110)
                        .overlay {
                            // Arena silhouette placeholder
                            HStack(spacing: 18) {
                                arenaTower
                                VStack(spacing: 6) {
                                    Image(systemName: "shield.lefthalf.filled")
                                        .font(.system(size: 36, weight: .black))
                                        .foregroundStyle(RoyalColor.gold)
                                        .shadow(color: RoyalColor.gold.opacity(0.7), radius: 10)
                                    Text(player.arenaName.uppercased())
                                        .font(RoyalTypography.title(16))
                                        .foregroundStyle(RoyalColor.legendaryGold)
                                }
                                arenaTower
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(RoyalColor.gold.opacity(0.55), lineWidth: 2)
                        )

                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(RoyalColor.gold)
                            AnimatedNumber(value: player.trophies, fontSize: 36)
                        }
                        .padding(.bottom, 8)
                    }
                    .frame(height: 110)
                }

                ArenaProgressView(info: info)
            }
        }
    }

    private var arenaTower: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [RoyalColor.metalLight.opacity(0.5), RoyalColor.metalDark],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 28, height: 54)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
    }
}
