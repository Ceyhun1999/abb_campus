import Foundation

struct Endpoint {

    let path: String
    let method: HTTPMethod

    var queryItems: [URLQueryItem] = []
    var headers: [String: String] = [:]
    var body: Data?

    func makeRequest(baseURL: URL) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL,
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }

        components.path += path

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)

        request.httpMethod = method.rawValue
        request.httpBody = body

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        if body != nil {
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )
        }

        headers.forEach { key, value in
            request.setValue(
                value,
                forHTTPHeaderField: key
            )
        }

        return request
    }
}
