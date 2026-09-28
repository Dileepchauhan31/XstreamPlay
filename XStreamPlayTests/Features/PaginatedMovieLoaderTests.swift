//
//  PaginatedMovieLoaderTests.swift
//  XStreamPlayTests
//
//  Created by Dileep chauhan on 28/09/26.
//

import XCTest
@testable import XStreamPlay

/// The paging rules shared by Home rails, See All and More Like This.
@MainActor
final class PaginatedMovieLoaderTests: XCTestCase {

    func test_loadNextPage_afterTheLastPage_doesNotCallTheRepository() async {
        let repository = MockMovieRepository()
        repository.pages = [
            1: .success(.stub(ids: [1, 2], nextPage: 2)),
            2: .success(.stub(ids: [3], nextPage: nil))
        ]
        let loader = PaginatedMovieLoader(source: .popular, repository: repository)

        await loader.loadNextPage()
        await loader.loadNextPage()
        await loader.loadNextPage() // past the end: must not hit the network

        XCTAssertEqual(loader.movies.map(\.id), [1, 2, 3])
        XCTAssertEqual(repository.requestedPages, [1, 2])
        XCTAssertFalse(loader.hasMorePages)
    }

    func test_loadNextPage_whenUnauthorized_stopsPaginatingAndExplainsWhy() async {
        let repository = MockMovieRepository()
        repository.pages = [1: .failure(APIError.unauthorized)]
        let loader = PaginatedMovieLoader(source: .popular, repository: repository)

        await loader.loadNextPage()
        await loader.loadNextPage()

        XCTAssertEqual(loader.errorMessage, APIError.unauthorized.userMessage)
        XCTAssertFalse(loader.hasMorePages)
        XCTAssertEqual(repository.requestedPages, [1], "A 401 won't fix itself, so don't ask again")
    }

    func test_loadNextPage_whenOffline_allowsTheSamePageAgain() async {
        let repository = MockMovieRepository()
        repository.pages = [1: .failure(APIError.transport(code: .notConnectedToInternet))]
        let loader = PaginatedMovieLoader(source: .popular, repository: repository)

        await loader.loadNextPage()
        XCTAssertTrue(loader.hasMorePages)

        repository.pages = [1: .success(.stub(ids: [7], nextPage: nil))]
        await loader.loadNextPage()

        XCTAssertEqual(loader.movies.map(\.id), [7])
        XCTAssertNil(loader.errorMessage)
        XCTAssertEqual(repository.requestedPages, [1, 1])
    }

    func test_loadMoreIfNeeded_farFromTheEnd_waits() async {
        let repository = MockMovieRepository()
        repository.pages = [
            1: .success(.stub(ids: Array(1...20), nextPage: 2)),
            2: .success(.stub(ids: [21], nextPage: nil))
        ]
        let loader = PaginatedMovieLoader(source: .popular, repository: repository)
        await loader.loadNextPage()

        await loader.loadMoreIfNeeded(displayedIndex: 3)
        XCTAssertEqual(repository.requestedPages, [1], "Item 4 of 20 is nowhere near the end")

        await loader.loadMoreIfNeeded(displayedIndex: 16)
        XCTAssertEqual(repository.requestedPages, [1, 2])
    }
}
