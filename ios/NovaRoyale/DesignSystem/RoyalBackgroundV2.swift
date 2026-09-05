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

/// Procedural arena diorama placeholder (no proprietary art).
struct RoyalArenaHeroPlaceholder: View {
    var arenaName: String = "Arena 4"
    var trophies: Int = 1040

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.black.opacity(0.4))
                .offset(y: 8)
                .blur(radius: 2)

            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.18, green: 0.42, blue: 0.22),
                            Color(red: 0.10, green: 0.28, blue: 0.18),
                            Color(red: 0.12, green: 0.22, blue: 0.38)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    // Mini towers + path
                    HStack(spacing: 28) {
                        tower
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(red: 0.45, green: 0.32, blue: 0.16))
                                .frame(width: 70, height: 18)
                            Image(systemName: "shield.lefthalf.filled")
                                .font(.system(size: 34, weight: .black))
                                .foregroundStyle(RoyalDS.Color.gold)
                                .shadow(color: RoyalDS.Color.gold.opacity(0.7), radius: 10)
                            RoyalText(text: arenaName.uppercased(), size: 16, color: RoyalDS.Color.gold, strokeWidth: 1.2)
                        }
                        tower
                    }
                }
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

    private var tower: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 4)
                .fill(RoyalDS.Color.metal)
                .frame(width: 22, height: 10)
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [RoyalDS.Color.metal.opacity(0.7), RoyalDS.Color.metalDark],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 30, height: 58)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
        }
    }
}
