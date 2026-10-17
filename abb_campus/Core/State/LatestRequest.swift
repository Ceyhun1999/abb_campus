import Foundation

/// Numbers requests so a response that arrives after a newer request
/// started (or after a newer local change) can be ignored.
struct LatestRequest {

    private var current = 0

    mutating func start() -> Int {
        current += 1
        return current
    }

    func isCurrent(_ request: Int) -> Bool {
        request == current
    }
}
