//
//  TMDBMovieRepositoryTests.swift
//  XStreamPlayTests
//
//  Created by Dileep chauhan on 28/09/26.
//

import XCTest
@testable import XStreamPlay

/// Runs the real repository + real `URLSessionAPIClient` against a stubbed
/// network, so the TMDB paths and the JSON → domain mapping are both covered.
final class TMDBMovieRepositoryTests: XCTestCase {

    override func setUp() {
        super.setUp()
        StubURLProtocol.reset()
    }

    override func tearDown() {
        StubURLProtocol.reset()
        super.tearDown()
    }

    // MARK: - Lists

    func test_fetchMovies_popular_mapsThePageAndTheNextPage() async throws {
        StubURLProtocol.respond(with: .json(Fixtures.moviePage))

        let page = try await makeRepository().fetchMovies(from: .popular, page: 1)

        XCTAssertEqual(page.movies.map(\.title), ["Fight Club", "Pulp Fiction"])
        XCTAssertEqual(page.movies.first?.mediaType, .movie)
        XCTAssertEqual(page.movies.first?.posterURL?.absoluteString, "https://image.tmdb.org/t/p/w500/fight-club.jpg")
        XCTAssertNil(page.movies.last?.posterURL)
        XCTAssertEqual(page.nextPage, 2)
    }

    func test_fetchMovies_popularTVShows_tagsItemsAsTV() async throws {
        StubURLProtocol.respond(with: .json(Fixtures.moviePage))

        let page = try await makeRepository().fetchMovies(from: .popularTVShows, page: 1)

        XCTAssertEqual(page.movies.first?.mediaType, .tv, "Otherwise tapping a show opens movie/{id}")
    }

    func test_fetchMovies_similarTVShows_requestsTheTVPath() async throws {
        StubURLProtocol.respond(with: .json(Fixtures.moviePage))

        _ = try await makeRepository().fetchMovies(from: .similar(movieID: 1399, mediaType: .tv), page: 2)

        let url = try XCTUnwrap(StubURLProtocol.capturedRequests.first?.url)
        XCTAssertEqual(url.path, "/3/tv/1399/similar")
        XCTAssertEqual(url.query, "page=2")
    }

    // MARK: - Details

    func test_fetchDetails_tvShow_decodesTVFieldNames() async throws {
        StubURLProtocol.respond(with: .json(Fixtures.tvShowDetails))

        let details = try await makeRepository().fetchDetails(id: 1399, mediaType: .tv)

        XCTAssertEqual(details.title, "Game of Thrones")
        XCTAssertEqual(details.releaseYear, "2011")
        XCTAssertEqual(details.genres, ["Drama", "Sci-Fi & Fantasy"])
        XCTAssertEqual(details.spokenLanguages, ["English"])

        let url = try XCTUnwrap(StubURLProtocol.capturedRequests.first?.url)
        XCTAssertEqual(url.path, "/3/tv/1399")
    }

    // MARK: - Helpers

    private func makeRepository() -> TMDBMovieRepository {
        let client = URLSessionAPIClient(
            session: StubURLProtocol.makeSession(),
            baseURL: Fixtures.apiBaseURL,
            accessToken: "test-token"
        )
        return TMDBMovieRepository(apiClient: client)
    }
}
