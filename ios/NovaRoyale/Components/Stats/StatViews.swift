import SwiftUI
import Charts

struct StatCard: View {
    let title: String
    let value: String
    var symbol: String?
    var tint: Color = RoyalDS.Color.electric
    var style: RoyalDS.PanelKind = .primary

    var body: some View {
        RoyalPanelV2(kind: style, cornerRadius: RoyalDS.Radius.md) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    if let symbol {
                        Image(systemName: symbol)
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(tint)
                            .shadow(color: tint.opacity(0.6), radius: 6)
                    }
                    Spacer(minLength: 0)
                }
                Text(value)
                    .font(RoyalFont.display(26))
                    .foregroundStyle(tint)
                    .shadow(color: RoyalDS.Color.stroke.opacity(0.8), radius: 0, x: 1, y: 0)
                    .shadow(color: tint.opacity(0.4), radius: 8, y: 2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(RoyalFont.ui(12, weight: .bold))
                    .foregroundStyle(RoyalDS.Color.textMuted)
            }
            .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
        }
    }
}

struct WinRateView: View {
    let percent: Int
    @Environment(AppLanguage.self) private var language

    var body: some View {
        RoyalPanelV2(kind: .blue, cornerRadius: RoyalDS.Radius.lg) {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.t("stats.win_rate", language))
                    .font(RoyalFont.ui(12, weight: .bold))
                    .foregroundStyle(RoyalDS.Color.cyan)
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    RoyalNumber(value: percent, size: 42, style: .cyan)
                    RoyalText(text: "%", size: 20, color: RoyalDS.Color.cyan)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct TrophyChart: View {
    let history: [Int]
    @Environment(AppLanguage.self) private var language
    @State private var appear = false
    @State private var selectedIndex: Int?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        RoyalPanelV2(kind: .gold, cornerRadius: RoyalDS.Radius.lg) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        RoyalText(text: L10n.t("stats.trophy_trend", language), size: 18, color: RoyalDS.Color.gold)
                        Text(L10n.t("stats.ladder_progression", language))
                            .font(RoyalFont.ui(12, weight: .semibold))
                            .foregroundStyle(RoyalDS.Color.textMuted)
                    }
                    Spacer()
                    if let selectedIndex, history.indices.contains(selectedIndex) {
                        RoyalNumber(value: history[selectedIndex], size: 22)
                    }
                }

                Chart {
                    ForEach(Array(history.enumerated()), id: \.offset) { index, value in
                        AreaMark(
                            x: .value("Match", index),
                            y: .value("Trophies", appear ? value : (history.first ?? 0))
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [RoyalDS.Color.gold.opacity(0.45), RoyalDS.Color.gold.opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        LineMark(
                            x: .value("Match", index),
                            y: .value("Trophies", appear ? value : (history.first ?? 0))
                        )
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                        .foregroundStyle(RoyalDS.Color.gold)

                        PointMark(
                            x: .value("Match", index),
                            y: .value("Trophies", appear ? value : (history.first ?? 0))
                        )
                        .symbolSize(selectedIndex == index ? 90 : 48)
                        .foregroundStyle(selectedIndex == index ? Color.white : RoyalDS.Color.gold)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                            .foregroundStyle(Color.white.opacity(0.08))
                        AxisValueLabel()
                            .foregroundStyle(RoyalDS.Color.textMuted)
                    }
                }
                .chartXAxis(.hidden)
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let frame = geo[proxy.plotAreaFrame]
                                        let x = value.location.x - frame.origin.x
                                        if let index: Int = proxy.value(atX: x) {
                                            selectedIndex = min(max(index, 0), history.count - 1)
                                        }
                                    }
                            )
                    }
                }
                .frame(height: 190)
            }
        }
        .onAppear {
            if reduceMotion { appear = true }
            else { withAnimation(RoyalMotionV2.appear.delay(0.1)) { appear = true } }
        }
    }
}
