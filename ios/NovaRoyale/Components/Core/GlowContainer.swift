import SwiftUI

/// Game-like beveled panel — the core Royal UI surface.
struct RoyalPanel<Content: View>: View {
    var style: RoyalPanelStyle = .primary
    var cornerRadius: CGFloat = RoyalRadius.lg
    var padding: CGFloat = RoyalSpace.md
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background {
                ZStack {
                    // Outer depth shadow plate
                    RoundedRectangle(cornerRadius: cornerRadius + 2, style: .continuous)
                        .fill(Color.black.opacity(0.55))
                        .offset(y: 5)
                        .blur(radius: 1)

                    // Main beveled body
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(style.fill)

                    // Subtle diagonal texture sheen
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.14),
                                    Color.clear,
                                    Color.black.opacity(0.18)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.overlay)

                    // Inner top highlight (bevel)
                    RoundedRectangle(cornerRadius: cornerRadius - 2, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.55),
                                    Color.white.opacity(0.08),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )
                        .padding(3)

                    // Metallic outer rim
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    style.rim.opacity(0.95),
                                    style.rim.opacity(0.35),
                                    Color.black.opacity(0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.2
                        )
                }
                .shadow(color: style.glow.opacity(0.28), radius: 14, y: 6)
                .shadow(color: Color.black.opacity(0.45), radius: 12, y: 10)
            }
    }
}

/// Physical 3D game button.
struct RoyalButton: View {
    enum Kind {
        case gold
        case blue
        case purple
        case red
        case green

        var fill: LinearGradient {
            switch self {
            case .gold: return RoyalColor.goldGradient
            case .blue:
                return LinearGradient(
                    colors: [RoyalColor.electricBlue, RoyalColor.royalBlue],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .purple:
                return LinearGradient(
                    colors: [RoyalColor.purple, RoyalColor.epicPurple],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .red:
                return LinearGradient(
                    colors: [RoyalColor.defeatRed, Color(red: 0.55, green: 0.08, blue: 0.12)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .green:
                return LinearGradient(
                    colors: [RoyalColor.victoryGreen, Color(red: 0.08, green: 0.45, blue: 0.22)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }

        var rim: Color {
            switch self {
            case .gold: return RoyalColor.legendaryGold
            case .blue: return RoyalColor.cyan
            case .purple: return RoyalColor.purple
            case .red: return RoyalColor.defeatRed
            case .green: return RoyalColor.victoryGreen
            }
        }
    }

    let title: String
    var symbol: String?
    var kind: Kind = .gold
    let action: () -> Void

    var body: some View {
        HapticButton(action: action) {
            HStack(spacing: 8) {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 16, weight: .black))
                }
                Text(title)
                    .font(RoyalTypography.body(15))
            }
            .foregroundStyle(kind == .gold ? Color.black.opacity(0.85) : Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background {
                ZStack {
                    Capsule()
                        .fill(Color.black.opacity(0.45))
                        .offset(y: 4)
                    Capsule()
                        .fill(kind.fill)
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.7), kind.rim.opacity(0.4), Color.black.opacity(0.4)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 2
                        )
                    Capsule()
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                        .padding(.top, 2)
                        .padding(.horizontal, 8)
                        .frame(height: 10)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .allowsHitTesting(false)
                }
            }
            .shadow(color: kind.rim.opacity(0.4), radius: 10, y: 4)
        }
    }
}

struct GamePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .offset(y: configuration.isPressed ? 2 : 0)
            .brightness(configuration.isPressed ? -0.06 : 0)
            .animation(.interactiveSpring(response: 0.28, dampingFraction: 0.55), value: configuration.isPressed)
    }
}

struct HapticButton<Label: View>: View {
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
        .buttonStyle(GamePressStyle())
    }
}

// Back-compat alias used by older call sites during migration
typealias GlowContainer = RoyalPanelCompat

struct RoyalPanelCompat<Content: View>: View {
    var glow: Color = RoyalColor.electricBlue
    var cornerRadius: CGFloat = RoyalRadius.lg
    @ViewBuilder var content: () -> Content

    var body: some View {
        let style: RoyalPanelStyle = {
            if glow == RoyalColor.gold { return .gold }
            if glow == RoyalColor.purple { return .purple }
            if glow == RoyalColor.victoryGreen { return .success }
            if glow == RoyalColor.defeatRed { return .danger }
            return .primary
        }()
        RoyalPanel(style: style, cornerRadius: cornerRadius, content: content)
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var body: some View { RoyalButton(title: title, kind: .gold, action: action) }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var body: some View { RoyalButton(title: title, kind: .blue, action: action) }
}
