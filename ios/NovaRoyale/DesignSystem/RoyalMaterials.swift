import SwiftUI

enum RoyalTexture {
    /// Quilted diamond lattice used inside panels (Clash-like padded material).
    struct Quilted: View {
        var light: Color = RoyalDS.Color.quiltLight
        var dark: Color = RoyalDS.Color.quiltDark
        var cell: CGFloat = 22
        var opacity: Double = 0.55

        var body: some View {
            Canvas { context, size in
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(dark))

                let cols = Int(size.width / cell) + 3
                let rows = Int(size.height / cell) + 3
                for row in 0..<rows {
                    for col in 0..<cols {
                        let x = CGFloat(col) * cell - cell * 0.5
                        let y = CGFloat(row) * cell - cell * 0.5
                        var diamond = Path()
                        diamond.move(to: CGPoint(x: x + cell * 0.5, y: y))
                        diamond.addLine(to: CGPoint(x: x + cell, y: y + cell * 0.5))
                        diamond.addLine(to: CGPoint(x: x + cell * 0.5, y: y + cell))
                        diamond.addLine(to: CGPoint(x: x, y: y + cell * 0.5))
                        diamond.closeSubpath()

                        let bright = (row + col).isMultiple(of: 2)
                        context.fill(
                            diamond,
                            with: .color((bright ? light : dark).opacity(opacity))
                        )
                        context.stroke(
                            diamond,
                            with: .color(Color.white.opacity(0.06)),
                            lineWidth: 0.6
                        )
                    }
                }
            }
            .allowsHitTesting(false)
        }
    }

    /// Subtle noise grit for stone/metal surfaces.
    struct Noise: View {
        var intensity: Double = 0.08

        var body: some View {
            Canvas { context, size in
                let count = Int((size.width * size.height) / 900)
                for i in 0..<count {
                    let x = CGFloat((i * 73) % max(Int(size.width), 1))
                    let y = CGFloat((i * 191) % max(Int(size.height), 1))
                    let rect = CGRect(x: x, y: y, width: 1.4, height: 1.4)
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(Color.white.opacity(intensity * ((i % 3 == 0) ? 1 : 0.45)))
                    )
                }
            }
            .blendMode(.overlay)
            .allowsHitTesting(false)
        }
    }

    /// Soft top specular sheen.
    struct Sheen: View {
        var body: some View {
            LinearGradient(
                colors: [
                    Color.white.opacity(0.28),
                    Color.white.opacity(0.05),
                    Color.clear,
                    Color.black.opacity(0.18)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.overlay)
            .allowsHitTesting(false)
        }
    }
}

enum RoyalLighting {
    static let topHighlight = LinearGradient(
        colors: [Color.white.opacity(0.55), Color.white.opacity(0.08), .clear],
        startPoint: .top,
        endPoint: .bottom
    )

    static let metalRim = LinearGradient(
        colors: [
            Color.white.opacity(0.85),
            RoyalDS.Color.goldRim.opacity(0.75),
            RoyalDS.Color.metalDark.opacity(0.9)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let goldFace = LinearGradient(
        colors: [
            RoyalDS.Color.ctaYellow,
            RoyalDS.Color.gold,
            RoyalDS.Color.ctaOrange
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let blueFace = LinearGradient(
        colors: [
            RoyalDS.Color.quiltLight,
            RoyalDS.Color.panelBlue,
            RoyalDS.Color.panelBlueDeep
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

enum RoyalShadow {
    static func depth(_ color: Color = .black, lift: CGFloat = 1) -> some ViewModifier {
        DepthShadow(color: color, lift: lift)
    }

    static func glow(_ color: Color, radius: CGFloat = 12) -> some ViewModifier {
        GlowShadow(color: color, radius: radius)
    }
}

struct DepthShadow: ViewModifier {
    var color: Color = .black
    var lift: CGFloat = 1

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.55 * lift), radius: 2 * lift, x: 0, y: 3 * lift)
            .shadow(color: color.opacity(0.28 * lift), radius: 10 * lift, x: 0, y: 8 * lift)
    }
}

struct GlowShadow: ViewModifier {
    var color: Color
    var radius: CGFloat = 12

    func body(content: Content) -> some View {
        content.shadow(color: color.opacity(0.45), radius: radius, x: 0, y: 0)
    }
}

extension View {
    func royalDepth(_ lift: CGFloat = 1) -> some View {
        modifier(DepthShadow(lift: lift))
    }

    func royalGlow(_ color: Color, radius: CGFloat = 12) -> some View {
        modifier(GlowShadow(color: color, radius: radius))
    }
}

enum RoyalMotionV2 {
    static let press = Animation.interactiveSpring(response: 0.26, dampingFraction: 0.55)
    static let appear = Animation.spring(response: 0.48, dampingFraction: 0.78)
    static let snappy = Animation.spring(response: 0.32, dampingFraction: 0.7)
    static let progress = Animation.spring(response: 0.7, dampingFraction: 0.8)
    static let tab = Animation.spring(response: 0.36, dampingFraction: 0.68)
}

struct RoyalPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .offset(y: configuration.isPressed ? 3 : 0)
            .brightness(configuration.isPressed ? -0.08 : 0)
            .animation(RoyalMotionV2.press, value: configuration.isPressed)
    }
}
