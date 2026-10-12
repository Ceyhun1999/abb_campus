import Foundation

struct MessageResponse: Decodable {
    let success: Bool
    let message: String?
}
