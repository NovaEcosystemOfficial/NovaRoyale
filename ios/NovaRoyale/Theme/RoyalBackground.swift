import SwiftUI

struct RoyalBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var drift: CGFloat = 0

    var body: some View {
        ZStack {
            RoyalColor.arenaSky
                .ignoresSafeArea()

            // Atmospheric arena lighting
            RadialGradient(
                colors: [RoyalColor.electricBlue.opacity(0.32), .clear],
                center: UnitPoint(x: 0.15, y: 0.08),
                startRadius: 10,
                endRadius: 380
            )
            .offset(x: drift)
            .ignoresSafeArea()

            RadialGradient(
                colors: [RoyalColor.purple.opacity(0.24), .clear],
                center: UnitPoint(x: 0.9, y: 0.2),
                startRadius: 8,
                endRadius: 320
            )
            .offset(x: -drift)
            .ignoresSafeArea()

            RadialGradient(
                colors: [RoyalColor.gold.opacity(0.12), .clear],
                center: UnitPoint(x: 0.5, y: 1.05),
                startRadius: 20,
                endRadius: 360
            )
            .ignoresSafeArea()

            // Vignette
            RadialGradient(
                colors: [.clear, Color.black.opacity(0.55)],
                center: .center,
                startRadius: 120,
                endRadius: 520
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // Soft noise-like dots (cheap texture)
            GeometryReader { geo in
                Canvas { context, size in
                    for i in 0..<40 {
                        let x = CGFloat((i * 47) % Int(size.width))
                        let y = CGFloat((i * 97) % Int(size.height))
                        let rect = CGRect(x: x, y: y, width: 1.2, height: 1.2)
                        context.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(0.04)))
                    }
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            if !reduceMotion {
                ParticleLayer(intensity: 0.4)
                    .opacity(0.5)
            }
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                drift = 16
            }
        }
    }
}
