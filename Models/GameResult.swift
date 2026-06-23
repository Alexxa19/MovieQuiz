import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
}

extension GameResult: Comparable {
    static func < (lhs: GameResult, rhs: GameResult) -> Bool {
        lhs.correct < rhs.correct
    }
}
