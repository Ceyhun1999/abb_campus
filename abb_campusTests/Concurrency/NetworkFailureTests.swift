import Foundation
import Testing
@testable import abb_campus

/// Answers every request of the session with a prepared response or error.
nonisolated final class StubURLProtocol: URLProtocol {

    nonisolated(unsafe) static var handler: ((URLRequest) -> Result<(Int, Data), URLError>)?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            return
        }

        switch handler(request) {
        case .success(let (status, data)):
            let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        case .failure(let error):
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

@MainActor
@Suite("Unstable networking", .serialized)
struct NetworkFailureTests {

    private func service(_ handler: @escaping (URLRequest) -> Result<(Int, Data), URLError>) -> DefaultEmployeeDashboardService {
        StubURLProtocol.handler = handler
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        let tokens = TokenStore()
        tokens.token = "token"
        return DefaultEmployeeDashboardService(
            networkService: DefaultNetworkService(session: URLSession(configuration: configuration), tokenProvider: tokens)
        )
    }

    private func message(for handler: @escaping (URLRequest) -> Result<(Int, Data), URLError>) async -> String? {
        do {
            _ = try await service(handler).fetchDashboard()
            return nil
        } catch {
            return error.localizedDescription
        }
    }

    @Test("HTTP 500 with a JSON message shows that message")
    func serverErrorWithMessage() async {
        let body = Data(#"{"success": false, "message": "Server müvəqqəti əlçatan deyil."}"#.utf8)
        #expect(await message { _ in .success((500, body)) } == "Server müvəqqəti əlçatan deyil.")
    }

    @Test("HTTP 500 with an HTML page shows a generic server error")
    func serverErrorWithHTML() async {
        #expect(await message { _ in .success((500, Data("<html>Oops</html>".utf8))) } == "Server xətası: 500")
    }

    @Test("A timeout shows a clear message")
    func timeout() async {
        #expect(await message { _ in .failure(URLError(.timedOut)) } == "Server cavab vermir. Bir az sonra yenidən cəhd edin.")
    }

    @Test("Offline shows the no-connection message")
    func offline() async {
        #expect(await message { _ in .failure(URLError(.notConnectedToInternet)) } == "İnternet bağlantısı yoxdur.")
    }

    @Test("A response that can't be decoded shows a decoding error")
    func decodingFailure() async {
        #expect(await message { _ in .success((200, Data(#"{"unexpected": true}"#.utf8))) } == "Məlumat oxunarkən xəta baş verdi.")
    }

    @Test("A cancelled request becomes CancellationError, not an error message")
    func cancelled() async {
        do {
            _ = try await service { _ in .failure(URLError(.cancelled)) }.fetchDashboard()
            Issue.record("Expected an error")
        } catch {
            #expect(error is CancellationError)
        }
    }

    @Test("Retry after a failure succeeds")
    func retryAfterFailure() async throws {
        let attempts = Counter()
        let body = try #require(try? JSONSerialization.data(withJSONObject: [
            "success": true,
            "data": ["studentsCount": 3, "activeStudentsCount": 2, "newStudentsThisMonth": 1, "teachersCount": 1,
                     "groupsCount": 1, "activeGroupsCount": 1, "announcementsCount": 0, "recentAnnouncements": []]
        ]))
        let service = service { _ in
            attempts.value += 1
            return attempts.value == 1 ? .failure(URLError(.networkConnectionLost)) : .success((200, body))
        }
        let sut = EmployeeHomeViewModel(
            authenticationState: AuthenticationState(secureStorage: MockSecureStorage(), authService: MockAuthService()),
            dashboardService: service
        )

        await sut.load()
        #expect(sut.state.errorMessage == "İnternet bağlantısı yoxdur.")

        await sut.load()
        #expect(sut.state.value?.studentsCount == 3)
    }
}

final class Counter: @unchecked Sendable {
    var value = 0
}
