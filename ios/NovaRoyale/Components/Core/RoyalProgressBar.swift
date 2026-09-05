import SwiftUI

struct RoyalProgressBar: View {
    let progress: Double
    var tint: Color = RoyalColor.gold
    var height: CGFloat = 16

    @State private var animated = 0.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geo in
            let width = max(height, geo.size.width * animated)
            ZStack(alignment: .leading) {
                // Track well
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.black.opacity(0.55), Color.black.opacity(0.35)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )

                // Fill
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
                        Capsule()
                            .fill(Color.white.opacity(0.45))
                            .frame(height: height * 0.28)
                            .padding(.horizontal, 6)
                            .padding(.top, 2)
                    }
                    .shadow(color: tint.opacity(0.65), radius: 8, y: 0)
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
            withAnimation(.spring(response: 0.75, dampingFraction: 0.78)) {
                animated = target
            }
        }
    }
}
