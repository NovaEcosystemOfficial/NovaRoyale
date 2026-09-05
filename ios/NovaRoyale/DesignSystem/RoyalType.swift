import SwiftUI
import CoreText

enum RoyalFont {
    static let displayName = "Lilita One"
    static let fileName = "LilitaOne-Regular"

    /// Register bundled TTF (safe to call multiple times).
    @discardableResult
    static func registerIfNeeded() -> Bool {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "ttf")
                ?? Bundle.main.url(forResource: fileName, withExtension: "ttf", subdirectory: "Fonts")
                ?? Bundle.main.url(forResource: fileName, withExtension: "ttf", subdirectory: "Resources/Fonts")
        else { return false }

        var error: Unmanaged<CFError>?
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        return error == nil
    }

    static func display(_ size: CGFloat) -> Font {
        if UIFont(name: displayName, size: size) != nil {
            return .custom(displayName, size: size)
        }
        return .system(size: size, weight: .black, design: .rounded)
    }

    static func ui(_ size: CGFloat, weight: Font.Weight = .heavy) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

/// Game title / label with dark stroke + depth shadow.
struct RoyalText: View {
    let text: String
    var size: CGFloat = 22
    var color: Color = RoyalDS.Color.text
    var strokeColor: Color = RoyalDS.Color.stroke
    var strokeWidth: CGFloat = 1.6
    var useDisplayFont: Bool = true
    var tracking: CGFloat = 0.4

    var body: some View {
        Text(text)
            .font(useDisplayFont ? RoyalFont.display(size) : RoyalFont.ui(size))
            .tracking(tracking)
            .foregroundStyle(color)
            .shadow(color: strokeColor.opacity(0.95), radius: 0, x: strokeWidth, y: 0)
            .shadow(color: strokeColor.opacity(0.95), radius: 0, x: -strokeWidth, y: 0)
            .shadow(color: strokeColor.opacity(0.95), radius: 0, x: 0, y: strokeWidth)
            .shadow(color: strokeColor.opacity(0.95), radius: 0, x: 0, y: -strokeWidth)
            .shadow(color: strokeColor.opacity(0.7), radius: 0, x: strokeWidth * 0.7, y: strokeWidth * 0.7)
            .shadow(color: strokeColor.opacity(0.7), radius: 0, x: -strokeWidth * 0.7, y: strokeWidth * 0.7)
            .shadow(color: strokeColor.opacity(0.7), radius: 0, x: strokeWidth * 0.7, y: -strokeWidth * 0.7)
            .shadow(color: strokeColor.opacity(0.7), radius: 0, x: -strokeWidth * 0.7, y: -strokeWidth * 0.7)
            .shadow(color: Color.black.opacity(0.45), radius: 2, x: 0, y: 2)
    }
}

/// Resource / reward number — the hero numeric treatment.
struct RoyalNumber: View {
    let value: Int
    var size: CGFloat = 42
    var style: Style = .gold
    var animate: Bool = true

    enum Style {
        case gold
        case white
        case victory
        case defeat
        case cyan

        var fill: AnyShapeStyle {
            switch self {
            case .gold:
                return AnyShapeStyle(
                    LinearGradient(
                        colors: [RoyalDS.Color.ctaYellow, RoyalDS.Color.gold, RoyalDS.Color.goldDeep],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            case .white: return AnyShapeStyle(Color.white)
            case .victory: return AnyShapeStyle(RoyalDS.Color.victory)
            case .defeat: return AnyShapeStyle(RoyalDS.Color.defeat)
            case .cyan: return AnyShapeStyle(RoyalDS.Color.cyan)
            }
        }

        var glow: Color {
            switch self {
            case .gold: return RoyalDS.Color.gold
            case .white: return Color.white
            case .victory: return RoyalDS.Color.victory
            case .defeat: return RoyalDS.Color.defeat
            case .cyan: return RoyalDS.Color.cyan
            }
        }
    }

    @State private var displayed = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Text(displayed, format: .number)
            .font(RoyalFont.display(size))
            .foregroundStyle(style.fill)
            .shadow(color: RoyalDS.Color.stroke.opacity(0.95), radius: 0, x: 1.8, y: 0)
            .shadow(color: RoyalDS.Color.stroke.opacity(0.95), radius: 0, x: -1.8, y: 0)
            .shadow(color: RoyalDS.Color.stroke.opacity(0.95), radius: 0, x: 0, y: 1.8)
            .shadow(color: RoyalDS.Color.stroke.opacity(0.95), radius: 0, x: 0, y: -1.8)
            .shadow(color: RoyalDS.Color.stroke.opacity(0.8), radius: 0, x: 1.2, y: 1.2)
            .shadow(color: RoyalDS.Color.stroke.opacity(0.8), radius: 0, x: -1.2, y: 1.2)
            .shadow(color: Color.black.opacity(0.5), radius: 3, x: 0, y: 3)
            .shadow(color: style.glow.opacity(0.45), radius: 8, x: 0, y: 0)
            .contentTransition(.numericText())
            .onAppear { run() }
            .onChange(of: value) { _, _ in run() }
            .accessibilityLabel("\(value)")
    }

    private func run() {
        guard animate, !reduceMotion else {
            displayed = value
            return
        }
        displayed = 0
        let steps = min(max(abs(value), 1), 40)
        let direction = value >= 0 ? 1 : -1
        let target = abs(value)
        let increment = max(1, target / steps)
        Task { @MainActor in
            var current = 0
            while current < target {
                try? await Task.sleep(for: .milliseconds(16))
                current = min(current + increment, target)
                withAnimation(.easeOut(duration: 0.04)) {
                    displayed = current * direction
                }
            }
            displayed = value
        }
    }
}
