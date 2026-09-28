//
//  StubURLProtocol.swift
//  XStreamPlayTests
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// A fake network. Every request made through `makeSession()` is recorded and
/// answered with the canned `Response`, so no test touches the real network.
///
///     StubURLProtocol.respond(with: .json(Fixtures.moviePage))
///     let client = URLSessionAPIClient(session: StubURLProtocol.makeSession(), …)
final class StubURLProtocol: URLProtocol {

    enum Response {
        case json(String, statusCode: Int = 200)
        case status(Int)
        case failure(URLError.Code)
    }

    // MARK: - Shared state (guarded by a lock: URLSession calls in from its own queue)

    private static let lock = NSLock()
    private static var response: Response = .status(404)
    private static var requests: [URLRequest] = []

    static var capturedRequests: [URLRequest] {
        lock.lock(); defer { lock.unlock() }
        return requests
    }

    static func respond(with response: Response) {
        lock.lock(); defer { lock.unlock() }
        self.response = response
    }

    static func reset() {
        lock.lock(); defer { lock.unlock() }
        response = .status(404)
        requests = []
    }

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    // MARK: - URLProtocol

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.lock.lock()
        Self.requests.append(request)
        let response = Self.response
        Self.lock.unlock()

        guard let url = request.url else { return }

        switch response {
        case .json(let body, let statusCode):
            send(statusCode: statusCode, body: Data(body.utf8), url: url)
        case .status(let statusCode):
            send(statusCode: statusCode, body: Data(), url: url)
        case .failure(let code):
            client?.urlProtocol(self, didFailWithError: URLError(code))
        }
    }

    override func stopLoading() {}

    // MARK: - Private

    private func send(statusCode: Int, body: Data, url: URL) {
        let httpResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: nil)
        if let httpResponse {
            client?.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
        }
        client?.urlProtocol(self, didLoad: body)
        client?.urlProtocolDidFinishLoading(self)
    }
}
