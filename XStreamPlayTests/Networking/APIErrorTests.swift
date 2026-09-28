//
//  APIErrorTests.swift
//  XStreamPlayTests
//
//  Created by Dileep chauhan on 28/09/26.
//

import XCTest
@testable import XStreamPlay

final class APIErrorTests: XCTestCase {

    func test_initStatusCode_mapsCommonCodes() {
        XCTAssertEqual(APIError(statusCode: 401), .unauthorized)
        XCTAssertEqual(APIError(statusCode: 404), .notFound)
        XCTAssertEqual(APIError(statusCode: 429), .rateLimited)
        XCTAssertEqual(APIError(statusCode: 503), .server(statusCode: 503))
        XCTAssertEqual(APIError(statusCode: 418), .unexpectedStatus(statusCode: 418))
    }

    func test_initFromError_withURLError_keepsTheCode() {
        XCTAssertEqual(APIError(from: URLError(.timedOut)), .transport(code: .timedOut))
        XCTAssertEqual(APIError(from: URLError(.cancelled)), .cancelled)
    }

    func test_isRetryable_onlyForErrorsThatCanFixThemselves() {
        XCTAssertTrue(APIError.transport(code: .notConnectedToInternet).isRetryable)
        XCTAssertTrue(APIError.server(statusCode: 500).isRetryable)
        XCTAssertFalse(APIError.unauthorized.isRetryable)
        XCTAssertFalse(APIError.notFound.isRetryable)
        XCTAssertFalse(APIError.decoding.isRetryable)
    }
}
