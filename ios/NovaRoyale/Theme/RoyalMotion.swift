import SwiftUI

enum RoyalMotion {
    static let snappy = Animation.spring(response: 0.32, dampingFraction: 0.72)
    static let soft = Animation.spring(response: 0.55, dampingFraction: 0.82)
    static let tab = Animation.spring(response: 0.38, dampingFraction: 0.7)
    static let number = Animation.easeOut(duration: 0.9)

    @MainActor
    static func run(_ animation: Animation, reduceMotion: Bool, _ body: () -> Void) {
        if reduceMotion {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction, body)
        } else {
            withAnimation(animation, body)
        }
    }
}

struct StaggeredAppear: ViewModifier {
    let index: Int
    let isVisible: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : (reduceMotion ? 0 : 22))
            .scaleEffect(isVisible || reduceMotion ? 1 : 0.96)
            .animation(
                reduceMotion ? nil : RoyalMotion.soft.delay(Double(index) * 0.06),
                value: isVisible
            )
    }
}

extension View {
    func staggeredAppear(index: Int, isVisible: Bool) -> some View {
        modifier(StaggeredAppear(index: index, isVisible: isVisible))
    }
}
