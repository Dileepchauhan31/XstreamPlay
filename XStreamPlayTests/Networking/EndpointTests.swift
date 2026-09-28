//
//  EndpointTests.swift
//  XStreamPlayTests
//
//  Created by Dileep chauhan on 28/09/26.
//

import XCTest
@testable import XStreamPlay

final class EndpointTests: XCTestCase {

    private let baseURL = Fixtures.apiBaseURL

    func test_makeURLRequest_withPageQuery_buildsTheFullURL() throws {
        let request = try Endpoint.popularMovies(page: 2).makeURLRequest(baseURL: baseURL)

        XCTAssertEqual(request.url?.absoluteString, "https://api.themoviedb.org/3/movie/popular?page=2")
        XCTAssertEqual(request.httpMethod, "GET")
    }

    func test_makeURLRequest_forDetails_hasNoQuery() throws {
        let request = try Endpoint.tvShowDetails(showID: 1399).makeURLRequest(baseURL: baseURL)

        XCTAssertEqual(request.url?.absoluteString, "https://api.themoviedb.org/3/tv/1399")
    }

    func test_makeURLRequest_withCustomHeader_setsTheHeader() throws {
        let endpoint = Endpoint(path: "configuration", headers: ["X-Test": "1"])

        let request = try endpoint.makeURLRequest(baseURL: baseURL)

        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Test"), "1")
    }
}
