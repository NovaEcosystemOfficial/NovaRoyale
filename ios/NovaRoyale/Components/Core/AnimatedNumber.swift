import SwiftUI

struct AnimatedNumber: View {
    let value: Int
    var fontSize: CGFloat = 48
    var style: NumberStyle = .gold

    enum NumberStyle {
        case gold
        case plain(Color)
    }

    @State private var displayed = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Text(displayed, format: .number)
            .font(RoyalTypography.number(fontSize))
            .foregroundStyle(foreground)
            .shadow(color: styleShadow, radius: 8, y: 2)
            .contentTransition(.numericText())
            .onAppear { animate() }
            .onChange(of: value) { _, _ in animate() }
            .accessibilityLabel("\(value)")
    }

    private var foreground: AnyShapeStyle {
        switch style {
        case .gold: return AnyShapeStyle(RoyalColor.goldGradient)
        case .plain(let color): return AnyShapeStyle(color)
        }
    }

    private var styleShadow: Color {
        switch style {
        case .gold: return RoyalColor.gold.opacity(0.45)
        case .plain(let color): return color.opacity(0.35)
        }
    }

    private func animate() {
        if reduceMotion {
            displayed = value
            return
        }
        displayed = 0
        let steps = min(max(value, 1), 48)
        let increment = max(1, value / steps)
        Task { @MainActor in
            var current = 0
            while current < value {
                try? await Task.sleep(for: .milliseconds(16))
                current = min(current + increment, value)
                withAnimation(.easeOut(duration: 0.04)) { displayed = current }
            }
            displayed = value
        }
    }
}

struct ParticleLayer: View {
    var intensity: Double = 0.5

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 24)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let count = Int(14 * intensity)
                for i in 0..<count {
                    let seed = Double(i) * 17.13
                    let x = (sin(t * 0.12 + seed) * 0.5 + 0.5) * size.width
                    let y = (cos(t * 0.09 + seed * 1.3) * 0.5 + 0.5) * size.height
                    let rect = CGRect(x: x, y: y, width: 2.5, height: 2.5)
                    context.fill(Path(ellipseIn: rect), with: .color(RoyalColor.cyan.opacity(0.28)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct ShimmerOverlay: ViewModifier {
    @State private var phase: CGFloat = -1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                if !reduceMotion {
                    LinearGradient(
                        colors: [.clear, Color.white.opacity(0.22), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .offset(x: phase * 240)
                    .blendMode(.plusLighter)
                }
            }
            .mask(content)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                    phase = 1.2
                }
            }
    }
}

extension View {
    func royalShimmer(_ active: Bool = true) -> some View {
        Group {
            if active { modifier(ShimmerOverlay()) } else { self }
        }
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(RoyalTypography.title(22))
                .foregroundStyle(RoyalColor.textPrimary)
                .shadow(color: RoyalColor.electricBlue.opacity(0.35), radius: 6, y: 1)
            if let subtitle {
                Text(subtitle)
                    .font(RoyalTypography.caption())
                    .foregroundStyle(RoyalColor.textMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
