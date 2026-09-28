//
//  MovieDetailsViewModelTests.swift
//  XStreamPlayTests
//
//  Created by Dileep chauhan on 28/09/26.
//

import XCTest
@testable import XStreamPlay

@MainActor
final class MovieDetailsViewModelTests: XCTestCase {

    // MARK: - Formatting

    func test_makeContent_withAllFields_joinsGenresYearAndRating() {
        let content = MovieDetailsViewModel.makeContent(from: .stub())

        XCTAssertEqual(content.subtitle, "Drama • Thriller • 1999 • U/A")
        XCTAssertEqual(content.audioLanguages, "Audio Available in: English, French")
    }

    func test_makeContent_withoutGenresOrDate_fallsBackToNA() {
        let content = MovieDetailsViewModel.makeContent(from: .stub(genres: [], releaseYear: nil, isAdult: true))

        XCTAssertEqual(content.subtitle, "N/A • 18+")
    }

    func test_makeContent_withoutLanguages_hasNoAudioLine() {
        let content = MovieDetailsViewModel.makeContent(from: .stub(spokenLanguages: []))

        XCTAssertNil(content.audioLanguages)
    }

    // MARK: - Loading

    func test_load_tvShow_fetchesTheShowAndItsSimilarShows() async {
        let repository = MockMovieRepository()
        repository.detailsResult = .success(.stub())
        repository.pages = [1: .success(.stub(ids: [10, 11], nextPage: nil))]
        let viewModel = makeViewModel(movieID: 1399, mediaType: .tv, repository: repository)

        await viewModel.load()

        XCTAssertEqual(viewModel.content?.title, "Fight Club")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(repository.requestedDetails.first?.id, 1399)
        XCTAssertEqual(repository.requestedDetails.first?.mediaType, .tv)
        // Regression: this rail used to request `movie/0/similar`.
        XCTAssertEqual(repository.requestedSources, [.similar(movieID: 1399, mediaType: .tv)])
        XCTAssertEqual(viewModel.moreLikeThis.movies.map(\.id), [10, 11])
    }

    func test_load_whenDetailsFail_exposesAUserFacingMessage() async {
        let repository = MockMovieRepository()
        repository.detailsResult = .failure(APIError.notFound)
        let viewModel = makeViewModel(repository: repository)

        await viewModel.load()

        XCTAssertNil(viewModel.content)
        XCTAssertEqual(viewModel.errorMessage, APIError.notFound.userMessage)
    }

    // MARK: - Helpers

    private func makeViewModel(
        movieID: Int = 550,
        mediaType: MediaType = .movie,
        repository: MockMovieRepository
    ) -> MovieDetailsViewModel {
        MovieDetailsViewModel(
            movieID: movieID,
            mediaType: mediaType,
            detailsRepository: repository,
            listRepository: repository
        )
    }
}
