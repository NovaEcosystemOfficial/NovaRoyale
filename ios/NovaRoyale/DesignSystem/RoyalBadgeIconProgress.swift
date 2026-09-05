import SwiftUI

struct RoyalBadgeV2: View {
    enum Kind {
        case gold
        case blue
        case purple
        case victory
        case defeat
        case level
    }

    let text: String
    var kind: Kind = .gold
    var symbol: String? = nil

    private var fill: LinearGradient {
        switch kind {
        case .gold: return RoyalLighting.goldFace
        case .blue: return RoyalLighting.blueFace
        case .purple:
            return LinearGradient(colors: [RoyalDS.Color.purple, RoyalDS.Color.epic], startPoint: .top, endPoint: .bottom)
        case .victory:
            return LinearGradient(colors: [RoyalDS.Color.victory, Color(red: 0.08, green: 0.45, blue: 0.2)], startPoint: .top, endPoint: .bottom)
        case .defeat:
            return LinearGradient(colors: [RoyalDS.Color.defeat, Color(red: 0.5, green: 0.08, blue: 0.12)], startPoint: .top, endPoint: .bottom)
        case .level:
            return LinearGradient(colors: [RoyalDS.Color.purple, Color(red: 0.35, green: 0.12, blue: 0.65)], startPoint: .top, endPoint: .bottom)
        }
    }

    private var textColor: Color {
        switch kind {
        case .gold: return Color(red: 0.25, green: 0.12, blue: 0.02)
        default: return .white
        }
    }

    var body: some View {
        HStack(spacing: 5) {
            if let symbol {
                Image(systemName: symbol)
                    .font(.system(size: 11, weight: .black))
            }
            Text(text)
                .font(RoyalFont.ui(12, weight: .black))
        }
        .foregroundStyle(textColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(Color.black.opacity(0.4))
                .offset(y: 2)
            Capsule()
                .fill(fill)
                .overlay(
                    Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
        }
        .shadow(color: Color.black.opacity(0.35), radius: 3, y: 2)
    }
}

/// Framed game icon — metallic bezel around a symbol/placeholder.
struct RoyalIconV2: View {
    let systemName: String
    var size: CGFloat = 54
    var tint: Color = RoyalDS.Color.gold
    var kind: RoyalDS.PanelKind = .blue

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.45))
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
                    RoyalTexture.Sheen()
                        .clipShape(Circle())
                }
                .overlay(
                    Circle().stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.8), tint, Color.black.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                )
                .shadow(color: tint.opacity(0.45), radius: 8)

            Image(systemName: systemName)
                .font(.system(size: size * 0.38, weight: .black))
                .foregroundStyle(tint)
                .shadow(color: tint.opacity(0.7), radius: 6)
        }
        .accessibilityHidden(true)
    }
}

struct RoyalProgressV2: View {
    let progress: Double
    var tint: Color = RoyalDS.Color.gold
    var height: CGFloat = 18
    var showShine: Bool = true

    @State private var animated = 0.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geo in
            let width = max(height, geo.size.width * animated)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.black.opacity(0.55), Color.black.opacity(0.35)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1.2))
                    .overlay(Capsule().stroke(Color.black.opacity(0.35), lineWidth: 2).padding(1))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.95), tint, tint.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width)
                    .overlay(alignment: .top) {
                        if showShine {
                            Capsule()
                                .fill(Color.white.opacity(0.5))
                                .frame(height: height * 0.3)
                                .padding(.horizontal, 7)
                                .padding(.top, 2)
                        }
                    }
                    .shadow(color: tint.opacity(0.7), radius: 8)
            }
        }
        .frame(height: height)
        .onAppear { animate(to: progress) }
        .onChange(of: progress) { _, newValue in animate(to: newValue) }
        .accessibilityLabel("Progress \(Int(progress * 100)) percent")
    }

    private func animate(to value: Double) {
        let target = min(max(value, 0), 1)
        if reduceMotion {
            animated = target
        } else {
            withAnimation(RoyalMotionV2.progress) { animated = target }
        }
    }
}
