import Foundation

/// Presentation helper derived from trophy count (not an API call).
struct ArenaProgressInfo: Equatable, Sendable {
    let currentArena: String
    let nextArena: String?
    let progress: Double
    let trophiesToNext: Int?

    static func from(trophies: Int, arenaName: String) -> ArenaProgressInfo {
        let brackets: [(Int, String)] = [
            (0, "Arena 1"),
            (300, "Arena 2"),
            (600, "Arena 3"),
            (1000, "Arena 4"),
            (1300, "Arena 5"),
            (1600, "Arena 6"),
            (2000, "Arena 7"),
            (2300, "Arena 8"),
            (2600, "Arena 9"),
            (3000, "Arena 10"),
            (3400, "Arena 11"),
            (3800, "Arena 12"),
            (4200, "Arena 13"),
            (4600, "Arena 14"),
            (5000, "Arena 15")
        ]

        var currentIndex = 0
        for (index, bracket) in brackets.enumerated() where trophies >= bracket.0 {
            currentIndex = index
        }

        let current = arenaName.isEmpty ? brackets[currentIndex].1 : arenaName
        let nextIndex = currentIndex + 1
        guard nextIndex < brackets.count else {
            return ArenaProgressInfo(currentArena: current, nextArena: nil, progress: 1, trophiesToNext: nil)
        }

        let floor = brackets[currentIndex].0
        let ceiling = brackets[nextIndex].0
        let span = max(ceiling - floor, 1)
        let progress = min(max(Double(trophies - floor) / Double(span), 0), 1)
        return ArenaProgressInfo(
            currentArena: current,
            nextArena: brackets[nextIndex].1,
            progress: progress,
            trophiesToNext: max(ceiling - trophies, 0)
        )
    }
}
