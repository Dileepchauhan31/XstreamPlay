//
//  XStreamPlayTests.swift
//  XStreamPlayTests
//
//  Created by Dileep chauhan on 12/01/26.
//

import XCTest
@testable import XStreamPlay

/// Cross-cutting tests that do not belong to one subsystem.
///
/// Suite layout:
///   Support/     — StubURLProtocol, Fixtures
///   Networking/  — EndpointTests, APIClientTests
///   Models/      — MovieDTODecodingTests
final class XStreamPlayTests: XCTestCase {

    /// Error copy is part of the product. It should say what happened and what
    /// the person can do — never a raw status code, never an apology.
    func test_everyErrorHasUserFacingCopy() {
        let allErrors: [APIError] = [
            .invalidURL("movie/popular"),
            .transport(code: .notConnectedToInternet),
            .invalidResponse,
            .unauthorized,
            .notFound,
            .rateLimited(retryAfter: 5),
            .server(status: 503),
            .decoding(description: "Missing key 'id'"),
            .unknown(description: "?")
        ]

        for error in allErrors {
            let message = error.userMessage
            XCTAssertFalse(message.isEmpty, "\(error) has no user message")
            XCTAssertFalse(message.lowercased().contains("sorry"), "\(error): don't apologise, explain")
            XCTAssertFalse(message.contains("Optional("), "\(error): raw debug output leaked into copy")
        }
    }

    func test_httpStatusCodesMapOntoTypedErrors() {
        XCTAssertEqual(APIError(status: 401), .unauthorized)
        XCTAssertEqual(APIError(status: 403), .unauthorized)
        XCTAssertEqual(APIError(status: 404), .notFound)
        XCTAssertEqual(APIError(status: 500), .server(status: 500))
        XCTAssertEqual(APIError(status: 429, headers: ["Retry-After": "30"]), .rateLimited(retryAfter: 30))
        XCTAssertEqual(APIError(status: 429), .rateLimited(retryAfter: nil))
    }

    func test_suggestedRetryDelayIsReadFromTheServer() {
        XCTAssertEqual(APIError.rateLimited(retryAfter: 12).suggestedRetryDelay, 12)
        XCTAssertNil(APIError.server(status: 500).suggestedRetryDelay)
    }
}
