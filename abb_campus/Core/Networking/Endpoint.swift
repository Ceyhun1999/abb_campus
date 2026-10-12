import Foundation

protocol Endpoint {

    var baseUrl: String { get }

    var path: String { get }

    var method: HTTPMethod { get }

    var headers: [String: String]? { get }
    
    var queryItems: [URLQueryItem]? { get }

    var httpBody: (any Encodable)? { get }

    var multipartForm: MultipartFormData? { get }

    /// Requests that need the signed-in user's token get it from the network service.
    var requiresAuthorization: Bool { get }
}

extension Endpoint {
    var baseUrl: String {
        APIConfiguration.baseURL
    }

    var headers: [String: String]? {
        nil
    }

    var queryItems: [URLQueryItem]? {
        nil
    }

    var httpBody: (any Encodable)? {
        nil
    }

    var multipartForm: MultipartFormData? {
        nil
    }

    var requiresAuthorization: Bool {
        false
    }
}

extension Endpoint {

    func makeRequest() throws -> URLRequest {
     
        guard var components = URLComponents(string: baseUrl) else {
            throw NetworkError.invalidURL
        }
        
        components.path = path

        components.queryItems = queryItems?.isEmpty == true ? nil : queryItems

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)

        request.httpMethod = method.rawValue

        headers?.forEach { key, value in
            request.setValue(
                value,
                forHTTPHeaderField: key
            )
        }

        if let multipartForm {
            request.setValue(
                multipartForm.contentType,
                forHTTPHeaderField: HTTPHeader.contentType
            )
            request.httpBody = multipartForm.finalized()
        } else if let httpBody {
            do {
                request.httpBody = try JSONEncoder().encode(httpBody)
            } catch {
                throw NetworkError.encodingError
            }
        }

        return request
    }
}
