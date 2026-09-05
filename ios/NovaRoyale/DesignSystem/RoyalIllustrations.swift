import SwiftUI

/// Circular player avatar: favorite card art when available, else crowned monogram.
struct RoyalPlayerAvatarArt: View {
    var cardName: String? = nil
    var monogram: String = "?"
    var size: CGFloat = 46

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.45))
                .frame(width: size + 6, height: size + 6)
                .offset(y: 3)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.25, green: 0.45, blue: 0.85),
                            Color(red: 0.12, green: 0.22, blue: 0.55)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size, height: size)
                .overlay { content.clipShape(Circle()) }
                .overlay(
                    Circle().stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.85), RoyalDS.Color.gold, Color.black.opacity(0.45)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2.5
                    )
                )
                .shadow(color: RoyalDS.Color.cyan.opacity(0.4), radius: 8)
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var content: some View {
        if let cardName, !cardName.isEmpty {
            RoyalCardArt(
                assetName: cardName,
                remoteURL: ClashRoyaleIconCatalog.mediumURL(forCardNamed: cardName),
                rarityTint: RoyalDS.Color.gold,
                rarityFill: RoyalLighting.blueFace,
                size: CGSize(width: size, height: size),
                cornerRadius: 0,
                placeholderSymbol: "crown.fill"
            )
            .scaleEffect(1.15)
        } else {
            ZStack {
                Text(String(monogram.prefix(1)).uppercased())
                    .font(RoyalFont.display(size * 0.42))
                    .foregroundStyle(.white)
                Image(systemName: "crown.fill")
                    .font(.system(size: size * 0.22, weight: .black))
                    .foregroundStyle(RoyalDS.Color.gold)
                    .offset(y: -size * 0.32)
            }
        }
    }
}

/// Leading art for battle rows: deck card when known, else mode emblem.
struct RoyalBattleLeadingArt: View {
    let battle: BattleRecord
    var size: CGFloat = 48

    private var tint: Color {
        battle.outcome == .victory ? RoyalDS.Color.victory : RoyalDS.Color.defeat
    }

    private var kind: RoyalDS.PanelKind {
        battle.outcome == .victory ? .success : .danger
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let card = battle.deckCardNames?.first {
                cardAvatar(named: card)
            } else {
                RoyalIconV2(systemName: modeSymbol, size: size, tint: tint, kind: kind)
            }

            outcomePip
                .offset(x: 2, y: 2)
        }
    }

    private func cardAvatar(named name: String) -> some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.4))
                .frame(width: size + 6, height: size + 6)
                .offset(y: 3)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [kind.fillTop, kind.fillBottom],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size, height: size)
                .overlay {
                    RoyalCardArt(
                        assetName: name,
                        remoteURL: ClashRoyaleIconCatalog.mediumURL(forCardNamed: name),
                        rarityTint: tint,
                        rarityFill: LinearGradient(
                            colors: [kind.fillTop, kind.fillBottom],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        size: CGSize(width: size * 0.92, height: size * 0.92),
                        cornerRadius: 0,
                        placeholderSymbol: modeSymbol
                    )
                    .clipShape(Circle())
                }
                .overlay(
                    Circle().stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.75), tint, Color.black.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2.5
                    )
                )
                .shadow(color: tint.opacity(0.45), radius: 8)
        }
    }

    private var outcomePip: some View {
        Image(systemName: battle.outcome == .victory ? "checkmark.circle.fill" : "xmark.circle.fill")
            .font(.system(size: 16, weight: .black))
            .foregroundStyle(tint)
            .background(Circle().fill(Color.black.opacity(0.55)).padding(-2))
            .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
    }

    private var modeSymbol: String {
        let mode = battle.mode.lowercased()
        if mode.contains("party") { return "person.2.fill" }
        if mode.contains("challenge") || mode.contains("sfida") { return "flag.fill" }
        if mode.contains("tournament") || mode.contains("torneo") { return "rosette" }
        return "trophy.fill"
    }
}

/// Framed achievement medallion for profile emblems.
struct RoyalEmblemMedallion: View {
    let symbol: String
    let title: String
    var tint: Color = RoyalDS.Color.gold
    var kind: RoyalDS.PanelKind = .gold

    var body: some View {
        RoyalPanelV2(kind: kind, cornerRadius: RoyalDS.Radius.md, padding: 10, showQuilt: false) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [tint.opacity(0.55), Color.black.opacity(0.35)],
                                center: .center,
                                startRadius: 2,
                                endRadius: 28
                            )
                        )
                        .frame(width: 46, height: 46)
                        .overlay(
                            Circle().stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.7), tint, Color.black.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2.5
                            )
                        )
                        .shadow(color: tint.opacity(0.55), radius: 8)

                    Image(systemName: symbol)
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(tint)
                        .shadow(color: tint.opacity(0.8), radius: 6)
                }
                Text(title)
                    .font(RoyalFont.ui(11, weight: .bold))
                    .foregroundStyle(RoyalDS.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 78)
        }
    }
}

/// Stone tower for arena diorama (original geometry, not proprietary art).
struct RoyalArenaTower: View {
    var height: CGFloat = 72
    var accent: Color = RoyalDS.Color.gold

    private let stoneTop = Color(red: 0.62, green: 0.52, blue: 0.38)
    private let stoneMid = Color(red: 0.42, green: 0.34, blue: 0.24)
    private let stoneDark = Color(red: 0.28, green: 0.22, blue: 0.15)

    var body: some View {
        VStack(spacing: 0) {
            // Banner pennant
            ZStack(alignment: .top) {
                Capsule()
                    .fill(stoneDark)
                    .frame(width: 4, height: 16)
                Path { path in
                    path.move(to: CGPoint(x: 4, y: 2))
                    path.addLine(to: CGPoint(x: 18, y: 8))
                    path.addLine(to: CGPoint(x: 4, y: 14))
                    path.closeSubpath()
                }
                .fill(accent)
                .frame(width: 20, height: 16)
                .offset(x: 8, y: 2)
            }
            .frame(height: 16)

            // Crenellations
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(stoneTop)
                        .frame(width: 9, height: 8)
                }
            }

            // Keep
            ZStack {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [stoneTop, stoneMid, stoneDark],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 34, height: height)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.35), radius: 4, y: 3)

                VStack(spacing: 8) {
                    window
                    window
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.black.opacity(0.45))
                        .frame(width: 10, height: 14)
                        .offset(y: 4)
                }
            }

            // Plinth
            RoundedRectangle(cornerRadius: 3)
                .fill(stoneDark)
                .frame(width: 42, height: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        }
    }

    private var window: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    colors: [Color(red: 0.55, green: 0.85, blue: 1.0).opacity(0.85), Color(red: 0.15, green: 0.35, blue: 0.55)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 8, height: 10)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.black.opacity(0.35), lineWidth: 0.8)
            )
    }
}
