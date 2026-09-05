import SwiftUI

struct RoyalBackgroundV2: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var drift: CGFloat = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.10, blue: 0.28),
                    Color(red: 0.07, green: 0.05, blue: 0.20),
                    Color(red: 0.03, green: 0.10, blue: 0.18)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RoyalTexture.Quilted(
                light: Color(red: 0.12, green: 0.28, blue: 0.55),
                dark: Color(red: 0.05, green: 0.12, blue: 0.28),
                cell: 36,
                opacity: 0.35
            )
            .opacity(0.4)
            .ignoresSafeArea()
            .allowsHitTesting(false)

            RadialGradient(
                colors: [RoyalDS.Color.electric.opacity(0.28), .clear],
                center: UnitPoint(x: 0.2, y: 0.05),
                startRadius: 10,
                endRadius: 360
            )
            .offset(x: drift)
            .ignoresSafeArea()

            RadialGradient(
                colors: [RoyalDS.Color.purple.opacity(0.22), .clear],
                center: UnitPoint(x: 0.9, y: 0.18),
                startRadius: 8,
                endRadius: 300
            )
            .offset(x: -drift)
            .ignoresSafeArea()

            RadialGradient(
                colors: [RoyalDS.Color.gold.opacity(0.12), .clear],
                center: UnitPoint(x: 0.5, y: 1.05),
                startRadius: 20,
                endRadius: 340
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [.clear, Color.black.opacity(0.55)],
                center: .center,
                startRadius: 140,
                endRadius: 520
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            if !reduceMotion {
                ParticleLayer(intensity: 0.35)
                    .opacity(0.45)
            }
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 11).repeatForever(autoreverses: true)) {
                drift = 14
            }
        }
    }
}

/// Procedural arena diorama (original art; drop PNG into ArenaAssets to replace).
struct RoyalArenaHeroPlaceholder: View {
    var arenaName: String = "Arena 4"
    var trophies: Int = 1040

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.black.opacity(0.4))
                .offset(y: 8)
                .blur(radius: 2)

            Group {
                if let art = RoyalAssets.image(named: RoyalAssets.Arena.artwork(named: arenaName)) {
                    art
                        .resizable()
                        .scaledToFill()
                } else {
                    arenaDiorama
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [RoyalDS.Color.gold, RoyalDS.Color.metal, RoyalDS.Color.goldDeep],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
            )
            .shadow(color: RoyalDS.Color.gold.opacity(0.3), radius: 16)

            VStack {
                Spacer()
                HStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(RoyalDS.Color.gold)
                    RoyalNumber(value: trophies, size: 28)
                }
                .padding(.bottom, 14)
            }
        }
        .frame(height: 180)
    }

    private var arenaDiorama: some View {
        ZStack {
            // Sky → hills → ground
            LinearGradient(
                colors: [
                    Color(red: 0.35, green: 0.62, blue: 0.92),
                    Color(red: 0.22, green: 0.55, blue: 0.35),
                    Color(red: 0.14, green: 0.38, blue: 0.22),
                    Color(red: 0.28, green: 0.22, blue: 0.14)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Soft clouds
            HStack {
                Capsule().fill(Color.white.opacity(0.55)).frame(width: 54, height: 16).offset(y: -48)
                Spacer()
                Capsule().fill(Color.white.opacity(0.4)).frame(width: 40, height: 12).offset(y: -58)
            }
            .padding(.horizontal, 24)

            // Dirt path
            Ellipse()
                .fill(Color(red: 0.48, green: 0.36, blue: 0.2).opacity(0.85))
                .frame(width: 110, height: 36)
                .offset(y: 28)

            HStack(alignment: .bottom, spacing: 18) {
                RoyalArenaTower(height: 64, accent: RoyalDS.Color.defeat)
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [RoyalDS.Color.gold.opacity(0.95), RoyalDS.Color.goldDeep],
                                    center: .center,
                                    startRadius: 2,
                                    endRadius: 28
                                )
                            )
                            .frame(width: 52, height: 52)
                            .overlay(
                                Circle().stroke(Color.white.opacity(0.45), lineWidth: 2)
                            )
                            .shadow(color: RoyalDS.Color.gold.opacity(0.65), radius: 10)
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(Color(red: 0.28, green: 0.14, blue: 0.04))
                    }
                    RoyalText(text: arenaName.uppercased(), size: 15, color: RoyalDS.Color.gold, strokeWidth: 1.2)
                }
                .offset(y: -6)
                RoyalArenaTower(height: 64, accent: RoyalDS.Color.cyan)
            }
            .padding(.bottom, 36)
        }
    }
}
