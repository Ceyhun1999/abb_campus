import Foundation

enum ScoreFormatting {

    /// 90 → "90", 75.5 → "75.5"
    static func text(_ score: Double) -> String {
        score.rounded() == score ? String(Int(score)) : String(format: "%.1f", score)
    }
}
