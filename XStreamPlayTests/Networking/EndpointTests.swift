//
//  EndpointTests.swift
//  XStreamPlayTests
//
//  Created by Dileep chauhan on 01/09/26.
//

import XCTest
@testable import XStreamPlay

/// Endpoints are values, so they can be asserted on without any I/O at all.
/// These tests run in microseconds and catch the entire class of "the URL was
/// subtly wrong" bugs that otherwise only show up as an empty rail on device.
final class EndpointTests: XCTestCase {

    private let baseURL = URL(string: "https://api.themoviedb.org/3")
    private let token = "test-token-123"

    private func makeRequest(_ endpoint: Endpoint) throws -> URLRequest {
        let base = try XCTUnwrap(baseURL)
        return try endpoint.urlRequest(baseURL: base, accessToken: token)
    }

    // MARK: - URL construction

    func test_movieList_buildsExpectedPathAndQuery() throws {
        let request = try makeRequest(.movies(list: .topRated, page: 3))

        XCTAssertEqual(
            request.url?.absoluteString,
            "https://api.themoviedb.org/3/movie/top_rated?page=3"
        )
        XCTAssertEqual(request.httpMethod, "GET")
    }

    func test_trending_includesRegionOnlyWhenProvided() throws {
        let without = try makeRequest(.trending(window: .day, page: 1))
        XCTAssertEqual(without.url?.query, "page=1")

        let with = try makeRequest(.trending(window: .day, page: 1, region: "IN"))
        XCTAssertEqual(with.url?.query, "page=1&region=IN")
    }

    func test_discover_joinsGenreIDsWithCommas() throws {
        let request = try makeRequest(.discoverMovies(genreIDs: [28, 12], page: 2))
        let query = try XCTUnwrap(request.url?.query)

        XCTAssertTrue(query.contains("with_genres=28,12"), "Got: \(query)")
    }

    func test_search_percentEncodesSpacesInTheQueryText() throws {
        let request = try makeRequest(.searchMulti(query: "spider man", page: 1))
        let absolute = try XCTUnwrap(request.url?.absoluteString)

        XCTAssertFalse(absolute.contains(" "), "Spaces must be encoded. Got: \(absolute)")
        XCTAssertTrue(absolute.contains("query=spider%20man"), "Got: \(absolute)")
    }

    func test_search_excludesAdultResults() throws {
        let request = try makeRequest(.searchMulti(query: "batman"))
        let query = try XCTUnwrap(request.url?.query)

        XCTAssertTrue(query.contains("include_adult=false"), "Got: \(query)")
    }

    // MARK: - append_to_response

    func test_movieDetail_foldsEverySubResourceIntoOneRequest() throws {
        let request = try makeRequest(.movieDetail(id: 550))
        let query = try XCTUnwrap(request.url?.query?.removingPercentEncoding)

        for appendix in TMDBAppendix.detailScreen {
            XCTAssertTrue(
                query.contains(appendix.rawValue),
                "append_to_response is missing '\(appendix.rawValue)'. Got: \(query)"
            )
        }
    }

    func test_movieDetail_canRequestASubsetOfAppendices() throws {
        let request = try makeRequest(.movieDetail(id: 550, appending: [.videos, .credits]))
        let query = try XCTUnwrap(request.url?.query?.removingPercentEncoding)

        XCTAssertEqual(query, "append_to_response=videos,credits")
    }

    // MARK: - Authentication

    func test_accessToken_travelsInHeaderNotQueryString() throws {
        let request = try makeRequest(.movies(list: .popular))

        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(token)")

        let absolute = try XCTUnwrap(request.url?.absoluteString)
        XCTAssertFalse(
            absolute.contains(token),
            "The token must never reach the URL — query strings end up in server and proxy logs."
        )
        XCTAssertFalse(absolute.contains("api_key"))
    }

    func test_acceptHeader_isAlwaysJSON() throws {
        let request = try makeRequest(.popularTVShows())
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
    }

    // MARK: - Image URLs

    func test_posterURL_isBuiltAtTheRequestedSize() {
        let url = TMDBImage.poster("/abc123.jpg", size: .w342)
        XCTAssertEqual(url?.absoluteString, "https://image.tmdb.org/t/p/w342/abc123.jpg")
    }

    func test_posterURL_isNilWhenTMDBSendsNoPath() {
        XCTAssertNil(TMDBImage.poster(nil))
        XCTAssertNil(TMDBImage.poster(""))
    }
}
