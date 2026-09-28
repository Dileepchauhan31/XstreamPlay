//
//  APIClientTests.swift
//  XStreamPlayTests
//
//  Created by Dileep chauhan on 01/09/26.
//

import XCTest
@testable import XStreamPlay

/// Exercises the real `URLSession` code path with a stubbed transport.
///
/// Every one of these ran against a live TMDB endpoint would be slow, flaky and
/// dependent on a token. Here they are deterministic and cover the failure
/// modes that are otherwise almost impossible to reproduce on demand — 429,
/// 500, a dropped connection, a shape change in the payload.
final class APIClientTests: XCTestCase {

    private var client: URLSessionAPIClient!

    override func setUp() {
        super.setUp()
        StubURLProtocol.reset()

        guard let baseURL = URL(string: "https://api.themoviedb.org/3") else {
            return XCTFail("Could not build the test base URL")
        }

        client = URLSessionAPIClient(
            session: StubURLProtocol.makeSession(),
            baseURL: baseURL,
            accessToken: "test-token-123"
        )
    }

    override func tearDown() {
        StubURLProtocol.reset()
        client = nil
        super.tearDown()
    }

    // MARK: - Happy path

    func test_send_decodesASuccessfulResponse() async throws {
        StubURLProtocol.respond(with: .json(Fixtures.moviePage))

        let page: PageDTO<MovieDTO> = try await client.send(.movies(list: .popular))

        XCTAssertEqual(page.page, 1)
        XCTAssertEqual(page.totalPages, 42)
        XCTAssertEqual(page.results.count, 2)
        XCTAssertEqual(page.results.first?.displayTitle, "Fight Club")
    }

    func test_send_attachesTheBearerTokenToTheOutgoingRequest() async throws {
        StubURLProtocol.respond(with: .json(Fixtures.moviePage))

        let _: PageDTO<MovieDTO> = try await client.send(.movies(list: .popular))

        let sent = try XCTUnwrap(StubURLProtocol.capturedRequests.first)
        XCTAssertEqual(sent.value(forHTTPHeaderField: "Authorization"), "Bearer test-token-123")
    }

    // MARK: - Status code mapping

    func test_send_maps401ToUnauthorized() async {
        StubURLProtocol.respond(with: .json(Fixtures.unauthorised, status: 401))
        await assertThrows(.unauthorized)
    }

    func test_send_maps404ToNotFound() async {
        StubURLProtocol.respond(with: .json("{}", status: 404))
        await assertThrows(.notFound)
    }

    func test_send_maps429ToRateLimitedAndReadsRetryAfter() async {
        StubURLProtocol.handler = { _ in
            StubURLProtocol.Stub(
                statusCode: 429,
                data: Data("{}".utf8),
                headers: ["Retry-After": "12"]
            )
        }
        await assertThrows(.rateLimited(retryAfter: 12))
    }

    func test_send_maps500ToServerError() async {
        StubURLProtocol.respond(with: .json("{}", status: 500))
        await assertThrows(.server(status: 500))
    }

    // MARK: - Transport and decoding

    func test_send_mapsAConnectionFailureToTransport() async {
        StubURLProtocol.respond(with: .failure(URLError(.notConnectedToInternet)))
        await assertThrows(.transport(code: .notConnectedToInternet))
    }

    func test_send_mapsAShapeChangeToDecoding() async {
        StubURLProtocol.respond(with: .json(Fixtures.malformedMoviePage))

        do {
            let _: PageDTO<MovieDTO> = try await client.send(.movies(list: .popular))
            XCTFail("Expected a decoding failure")
        } catch let error as APIError {
            guard case .decoding(let description) = error else {
                return XCTFail("Expected .decoding, got \(error)")
            }
            XCTAssertTrue(description.contains("id"), "The message should name the offending key. Got: \(description)")
        } catch {
            XCTFail("Expected APIError, got \(error)")
        }
    }

    // MARK: - Retry policy

    func test_isRetryable_isTrueOnlyWhenAnotherAttemptCouldSucceed() {
        XCTAssertTrue(APIError.transport(code: .timedOut).isRetryable)
        XCTAssertTrue(APIError.rateLimited(retryAfter: nil).isRetryable)
        XCTAssertTrue(APIError.server(status: 503).isRetryable)

        XCTAssertFalse(APIError.unauthorized.isRetryable)
        XCTAssertFalse(APIError.notFound.isRetryable)
        XCTAssertFalse(APIError.decoding(description: "x").isRetryable)
        XCTAssertFalse(APIError.server(status: 400).isRetryable)
    }

    // MARK: - Helper

    private func assertThrows(
        _ expected: APIError,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            let _: PageDTO<MovieDTO> = try await client.send(.movies(list: .popular))
            XCTFail("Expected \(expected) but the call succeeded", file: file, line: line)
        } catch let error as APIError {
            XCTAssertEqual(error, expected, file: file, line: line)
        } catch {
            XCTFail("Expected APIError, got \(error)", file: file, line: line)
        }
    }
}
