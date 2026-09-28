//
//  URLSessionAPIClientTests.swift
//  XStreamPlayTests
//
//  Created by Dileep chauhan on 28/09/26.
//

import XCTest
@testable import XStreamPlay

/// Runs the real client against `StubURLProtocol`: real request building,
/// real status handling, real decoding, no real network.
final class URLSessionAPIClientTests: XCTestCase {

    override func setUp() {
        super.setUp()
        StubURLProtocol.reset()
    }

    override func tearDown() {
        StubURLProtocol.reset()
        super.tearDown()
    }

    func test_send_always_putsTheTokenInTheAuthorizationHeaderNotTheURL() async throws {
        StubURLProtocol.respond(with: .json(Fixtures.moviePage))

        let _: PageDTO<MovieDTO> = try await makeClient().send(.popularMovies(page: 1))

        let request = try XCTUnwrap(StubURLProtocol.capturedRequests.first)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer test-token")
        XCTAssertFalse(request.url?.absoluteString.contains("test-token") ?? true)
    }

    func test_send_withSnakeCaseJSON_decodesCamelCaseProperties() async throws {
        StubURLProtocol.respond(with: .json(Fixtures.moviePage))

        let page: PageDTO<MovieDTO> = try await makeClient().send(.popularMovies(page: 1))

        XCTAssertEqual(page.totalPages, 3)
        XCTAssertEqual(page.results.first?.posterPath, "/fight-club.jpg")
    }

    func test_send_when401_throwsUnauthorized() async {
        StubURLProtocol.respond(with: .status(401))

        await assertThrows(.unauthorized)
    }

    func test_send_when500_throwsServerError() async {
        StubURLProtocol.respond(with: .status(500))

        await assertThrows(.server(statusCode: 500))
    }

    func test_send_whenJSONIsInvalid_throwsDecoding() async {
        StubURLProtocol.respond(with: .json("{ not json"))

        await assertThrows(.decoding)
    }

    func test_send_whenOffline_throwsTransportError() async {
        StubURLProtocol.respond(with: .failure(.notConnectedToInternet))

        await assertThrows(.transport(code: .notConnectedToInternet))
    }

    func test_send_withoutToken_failsWithoutCallingTheServer() async {
        StubURLProtocol.respond(with: .json(Fixtures.moviePage))

        await assertThrows(.unauthorized, client: makeClient(accessToken: ""))
        XCTAssertTrue(StubURLProtocol.capturedRequests.isEmpty)
    }

    // MARK: - Helpers

    private func makeClient(accessToken: String = "test-token") -> URLSessionAPIClient {
        URLSessionAPIClient(
            session: StubURLProtocol.makeSession(),
            baseURL: Fixtures.apiBaseURL,
            accessToken: accessToken
        )
    }

    private func assertThrows(
        _ expected: APIError,
        client: URLSessionAPIClient? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            let _: PageDTO<MovieDTO> = try await (client ?? makeClient()).send(.popularMovies(page: 1))
            XCTFail("Expected \(expected), but the request succeeded", file: file, line: line)
        } catch {
            XCTAssertEqual(error as? APIError, expected, file: file, line: line)
        }
    }
}
