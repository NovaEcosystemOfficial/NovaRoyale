import SwiftUI

/// Physical beveled game panel with quilt texture, rim, inner highlight.
struct RoyalPanelV2<Content: View>: View {
    var kind: RoyalDS.PanelKind = .blue
    var cornerRadius: CGFloat = RoyalDS.Radius.lg
    var padding: CGFloat = RoyalDS.Space.md
    var showQuilt: Bool = true
    var rimWidth: CGFloat = 3.2
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background { panelBody }
            .royalDepth(1.1)
            .royalGlow(kind.glow, radius: 10)
    }

    private var panelBody: some View {
        ZStack {
            // Drop plate
            RoundedRectangle(cornerRadius: cornerRadius + 2, style: .continuous)
                .fill(Color.black.opacity(0.55))
                .offset(y: 6)

            // Face fill
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [kind.fillTop, kind.fillBottom],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            if showQuilt {
                RoyalTexture.Quilted(
                    light: kind.fillTop.opacity(0.9),
                    dark: kind.fillBottom.opacity(0.95),
                    cell: 20,
                    opacity: 0.45
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .opacity(0.85)
            }

            RoyalTexture.Sheen()
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))

            RoyalTexture.Noise(intensity: 0.05)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))

            // Inner recess
            RoundedRectangle(cornerRadius: cornerRadius - 3, style: .continuous)
                .stroke(Color.black.opacity(0.28), lineWidth: 2)
                .padding(4)
                .blendMode(.multiply)

            // Top bevel highlight
            RoundedRectangle(cornerRadius: cornerRadius - 2, style: .continuous)
                .stroke(RoyalLighting.topHighlight, lineWidth: 1.6)
                .padding(3)

            // Outer metallic/gold rim
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.75),
                            kind.rim,
                            kind.rim.opacity(0.45),
                            Color.black.opacity(0.55)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: rimWidth
                )
        }
    }
}

/// Recessed inset well (stats slots, resource trays).
struct RoyalInset<Content: View>: View {
    var cornerRadius: CGFloat = RoyalDS.Radius.md
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.45),
                                Color.black.opacity(0.28)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(RoyalDS.Color.electric.opacity(0.55), lineWidth: 1.5)
                    )
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            .padding(.top, 1)
                            .frame(height: 8)
                            .allowsHitTesting(false)
                    }
            }
    }
}
