//
//  MovieDTODecodingTests.swift
//  XStreamPlayTests
//
//  Created by Dileep chauhan on 01/09/26.
//

import XCTest
@testable import XStreamPlay

/// Decoding is the boundary where a third-party API meets our types, so it is
/// the cheapest place to catch a breaking change — and the most expensive place
/// to be wrong, because a silently-nil field looks like a product bug, not a
/// parsing bug.
final class MovieDTODecodingTests: XCTestCase {

    private func decodePage(_ json: String) throws -> PageDTO<MovieDTO> {
        try JSONDecoder.tmdb.decode(PageDTO<MovieDTO>.self, from: Data(json.utf8))
    }

    // MARK: - Key conversion

    func test_snakeCaseKeysMapOntoCamelCaseProperties() throws {
        let movie = try XCTUnwrap(decodePage(Fixtures.moviePage).results.first)

        XCTAssertEqual(movie.id, 550)
        XCTAssertEqual(movie.posterPath, "/poster1.jpg")
        XCTAssertEqual(movie.backdropPath, "/backdrop1.jpg")
        XCTAssertEqual(movie.releaseDate, "1999-10-15")
        XCTAssertEqual(movie.originalLanguage, "en")
        XCTAssertEqual(movie.voteCount, 27154)
    }

    /// `.convertFromSnakeCase` turns `genre_ids` into `genreIds`, not `genreIDs`.
    /// This test exists so nobody "tidies up" the property name and silently
    /// breaks genre rails.
    func test_genreIDsDecodeDespiteTheAwkwardCasing() throws {
        let movie = try XCTUnwrap(decodePage(Fixtures.moviePage).results.first)
        XCTAssertEqual(movie.genreIds, [28, 12, 878])
    }

    // MARK: - Tolerance

    func test_aSparseItemStillDecodes() throws {
        let movie = try XCTUnwrap(decodePage(Fixtures.moviePage).results.last)

        XCTAssertEqual(movie.id, 680)
        XCTAssertEqual(movie.displayTitle, "Pulp Fiction")
        XCTAssertNil(movie.posterPath)
        XCTAssertNil(movie.voteAverage)
    }

    func test_aMissingResultsKeyYieldsAnEmptyPageRatherThanThrowing() throws {
        let page = try decodePage(Fixtures.pageWithoutResults)

        XCTAssertTrue(page.results.isEmpty)
        XCTAssertTrue(page.isLastPage)
        XCTAssertNil(page.nextPage)
    }

    // MARK: - Pagination

    func test_nextPageAdvancesUntilTheFinalPage() throws {
        let first = try decodePage(Fixtures.moviePage)
        XCTAssertEqual(first.nextPage, 2)
        XCTAssertFalse(first.isLastPage)

        let last = try decodePage(Fixtures.lastMoviePage)
        XCTAssertNil(last.nextPage)
        XCTAssertTrue(last.isLastPage)
    }

    // MARK: - Display helpers

    func test_displayHelpersFormatForTheUI() throws {
        let movie = try XCTUnwrap(decodePage(Fixtures.moviePage).results.first)

        XCTAssertEqual(movie.year, "1999")
        XCTAssertEqual(movie.formattedRating, "8.4")
        XCTAssertEqual(movie.posterURL?.lastPathComponent, "poster1.jpg")
    }

    func test_formattedRatingIsNilWhenUnrated() throws {
        let movie = try XCTUnwrap(decodePage(Fixtures.moviePage).results.last)
        XCTAssertNil(movie.formattedRating, "An unrated title should hide the badge, not show 0.0")
    }
}
