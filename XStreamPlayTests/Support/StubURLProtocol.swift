//
//  StubURLProtocol.swift
//  XStreamPlayTests
//
//  Created by Dileep chauhan on 01/09/26.
//

import Foundation

/// Intercepts every request made through a session configured with it and
/// answers from a handler the test supplies.
///
/// This is how the networking layer is tested without a network, a mocking
/// library, or a `#if DEBUG` branch in production code. `URLProtocol` is a
/// URL Loading System extension point Apple designed for exactly this, so the
/// code under test is the real `URLSession` path — not a parallel fake one.
final class StubURLProtocol: URLProtocol {

    /// What to answer with.
    struct Stub {
        var statusCode: Int = 200
        var data: Data = Data()
        var headers: [String: String] = ["Content-Type": "application/json"]
        var error: Error?

        static func json(_ string: String, status: Int = 200) -> Stub {
            Stub(statusCode: status, data: Data(string.utf8))
        }

        static func failure(_ error: Error) -> Stub {
            Stub(error: error)
        }
    }

    /// Set by the test to decide what each request receives.
    static var handler: ((URLRequest) throws -> Stub)?

    /// Every request that reached the transport, in order. Lets a test assert
    /// on headers and URLs without a separate spy.
    private(set) static var capturedRequests: [URLRequest] = []

    // MARK: - Test lifecycle

    /// Call from `tearDown` so state never leaks between tests.
    static func reset() {
        handler = nil
        capturedRequests = []
    }

    /// A session that routes all traffic through this protocol.
    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    /// Convenience for the common case of "always answer with this body".
    static func respond(with stub: Stub) {
        handler = { _ in stub }
    }

    // MARK: - URLProtocol

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.capturedRequests.append(request)

        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.resourceUnavailable))
            return
        }

        do {
            let stub = try handler(request)

            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
                return
            }

            guard let url = request.url,
                  let response = HTTPURLResponse(
                    url: url,
                    statusCode: stub.statusCode,
                    httpVersion: "HTTP/1.1",
                    headerFields: stub.headers
                  ) else {
                client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
                return
            }

            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: stub.data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // Nothing to cancel: responses are delivered synchronously.
    }
}
