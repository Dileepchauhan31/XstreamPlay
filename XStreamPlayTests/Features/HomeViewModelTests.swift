//
//  HomeViewModelTests.swift
//  XStreamPlayTests
//
//  Created by Dileep chauhan on 28/09/26.
//

import XCTest
@testable import XStreamPlay

@MainActor
final class HomeViewModelTests: XCTestCase {

    func test_load_fillsEveryRailInOrder() async {
        let repository = MockMovieRepository()
        repository.pages = [1: .success(.stub(ids: [1, 2], nextPage: 2))]
        let viewModel = HomeViewModel(rails: MovieRail.homeScreen, repository: repository)

        await viewModel.load()

        XCTAssertEqual(viewModel.rails.map(\.rail), MovieRail.homeScreen)
        XCTAssertTrue(viewModel.rails.allSatisfy { $0.movies.map(\.id) == [1, 2] })
        XCTAssertEqual(Set(repository.requestedSources), Set(MovieRail.homeScreen.map(\.source)))
        XCTAssertNil(viewModel.errorMessage)
    }

    func test_load_whenOneRailFails_showsOneMessageAndRetriesOnlyThatRail() async {
        let repository = MockMovieRepository()
        repository.pages = [1: .success(.stub(ids: [1], nextPage: nil))]
        repository.errorsBySource = [.upcoming: APIError.transport(code: .timedOut)]
        let viewModel = HomeViewModel(rails: MovieRail.homeScreen, repository: repository)

        await viewModel.load()
        XCTAssertEqual(viewModel.errorMessage, APIError.transport(code: .timedOut).userMessage)

        repository.errorsBySource = [:]
        await viewModel.load() // Retry

        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(repository.requestedSources.filter { $0 == .upcoming }.count, 2)
        XCTAssertEqual(repository.requestedSources.filter { $0 == .popular }.count, 1, "Loaded rails are left alone")
    }
}
