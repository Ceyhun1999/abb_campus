import Foundation

struct APIResponse<Value: Decodable>: Decodable {
    let success: Bool
    let message: String?
    let data: Value
}

struct PaginatedResponse<Item: Decodable>: Decodable {
    let success: Bool
    let data: [Item]
    let meta: PaginationMeta
}

struct PaginationMeta: Decodable {
    let currentPage: Int
    let lastPage: Int
    let perPage: Int
    let total: Int
}
