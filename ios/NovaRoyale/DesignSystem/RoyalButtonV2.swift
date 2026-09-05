import SwiftUI

struct RoyalButtonV2: View {
    enum Kind {
        case battle   // massive yellow CTA
        case gold
        case blue
        case purple
        case danger

        var face: LinearGradient {
            switch self {
            case .battle, .gold: return RoyalLighting.goldFace
            case .blue: return RoyalLighting.blueFace
            case .purple:
                return LinearGradient(
                    colors: [RoyalDS.Color.purple, RoyalDS.Color.epic],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .danger:
                return LinearGradient(
                    colors: [RoyalDS.Color.defeat, Color(red: 0.55, green: 0.08, blue: 0.12)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }

        var rim: Color {
            switch self {
            case .battle, .gold: return RoyalDS.Color.goldDeep
            case .blue: return RoyalDS.Color.panelBlueDeep
            case .purple: return RoyalDS.Color.epic
            case .danger: return Color(red: 0.45, green: 0.05, blue: 0.1)
            }
        }

        var textColor: Color {
            switch self {
            case .battle, .gold: return Color(red: 0.25, green: 0.12, blue: 0.02)
            default: return .white
            }
        }
    }

    let title: String
    var subtitle: String? = nil
    var symbol: String? = nil
    var kind: Kind = .battle
    var height: CGFloat = 64
    let action: () -> Void

    var body: some View {
        Button(action: {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            #endif
            action()
        }) {
            ZStack {
                // Physical thickness
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(kind.rim)
                    .offset(y: 6)

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(kind.face)
                    .overlay {
                        RoyalTexture.Sheen()
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.75), kind.rim.opacity(0.5), Color.black.opacity(0.35)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 2.4
                            )
                    }
                    .overlay(alignment: .top) {
                        Capsule()
                            .fill(Color.white.opacity(0.35))
                            .frame(height: 6)
                            .padding(.horizontal, 18)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }

                VStack(spacing: 2) {
                    HStack(spacing: 8) {
                        if let symbol {
                            Image(systemName: symbol)
                                .font(.system(size: 20, weight: .black))
                        }
                        RoyalText(
                            text: title,
                            size: kind == .battle ? 28 : 20,
                            color: kind.textColor,
                            strokeColor: kind == .battle || kind == .gold
                                ? Color(red: 0.45, green: 0.22, blue: 0.02)
                                : RoyalDS.Color.stroke,
                            strokeWidth: kind == .battle ? 1.8 : 1.3
                        )
                    }
                    if let subtitle {
                        Text(subtitle)
                            .font(RoyalFont.ui(12, weight: .bold))
                            .foregroundStyle(kind.textColor.opacity(0.75))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .royalGlow(kind == .battle || kind == .gold ? RoyalDS.Color.gold : kind.rim, radius: 12)
        }
        .buttonStyle(RoyalPressStyle())
    }
}

struct RoyalHapticButton<Label: View>: View {
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button {
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
            action()
        } label: {
            label()
        }
        .buttonStyle(RoyalPressStyle())
    }
}
