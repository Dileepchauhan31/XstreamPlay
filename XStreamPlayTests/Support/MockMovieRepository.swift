//
//  MockMovieRepository.swift
//  XStreamPlayTests
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation
@testable import XStreamPlay

/// A hand-written fake for both repository protocols.
///
/// This is the pay-off of dependency injection: view models accept any
/// `MovieListRepository` / `MovieDetailsRepository`, so a test hands them this
/// object and decides exactly what "the network" returns.
///
/// Thread-safe, because view models call it from several tasks at once.
final class MockMovieRepository: MovieListRepository, MovieDetailsRepository, @unchecked Sendable {

    private let lock = NSLock()

    // MARK: - Canned responses

    private var _pages: [Int: Result<MoviePage, Error>] = [:]
    private var _errorsBySource: [MovieListSource: Error] = [:]
    private var _detailsResult: Result<MovieDetails, Error> = .failure(APIError.notFound)

    /// Response per page number. A page with no entry returns an empty last page.
    var pages: [Int: Result<MoviePage, Error>] {
        get { locked { _pages } }
        set { locked { _pages = newValue } }
    }

    /// Makes one list fail, whatever page is asked for.
    var errorsBySource: [MovieListSource: Error] {
        get { locked { _errorsBySource } }
        set { locked { _errorsBySource = newValue } }
    }

    var detailsResult: Result<MovieDetails, Error> {
        get { locked { _detailsResult } }
        set { locked { _detailsResult = newValue } }
    }

    // MARK: - Recorded calls

    private var _requestedPages: [Int] = []
    private var _requestedSources: [MovieListSource] = []
    private var _requestedDetails: [(id: Int, mediaType: MediaType)] = []

    var requestedPages: [Int] { locked { _requestedPages } }
    var requestedSources: [MovieListSource] { locked { _requestedSources } }
    var requestedDetails: [(id: Int, mediaType: MediaType)] { locked { _requestedDetails } }

    // MARK: - MovieListRepository

    func fetchMovies(from source: MovieListSource, page: Int) async throws -> MoviePage {
        let (error, result): (Error?, Result<MoviePage, Error>?) = locked {
            _requestedSources.append(source)
            _requestedPages.append(page)
            return (_errorsBySource[source], _pages[page])
        }
        if let error { throw error }
        return try result?.get() ?? MoviePage(movies: [], nextPage: nil)
    }

    // MARK: - MovieDetailsRepository

    func fetchDetails(id: Int, mediaType: MediaType) async throws -> MovieDetails {
        let result = locked { () -> Result<MovieDetails, Error> in
            _requestedDetails.append((id, mediaType))
            return _detailsResult
        }
        return try result.get()
    }

    // MARK: - Private

    private func locked<T>(_ work: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return work()
    }
}

// MARK: - Builders

extension MoviePage {

    static func stub(ids: [Int], nextPage: Int?) -> MoviePage {
        MoviePage(
            movies: ids.map { Movie(id: $0, title: "Movie \($0)", mediaType: .movie, posterURL: nil) },
            nextPage: nextPage
        )
    }
}

extension MovieDetails {

    static func stub(
        title: String = "Fight Club",
        genres: [String] = ["Drama", "Thriller"],
        releaseYear: String? = "1999",
        isAdult: Bool = false,
        spokenLanguages: [String] = ["English", "French"]
    ) -> MovieDetails {
        MovieDetails(
            id: 550,
            title: title,
            overview: "A ticking-time-bomb insomniac.",
            genres: genres,
            releaseYear: releaseYear,
            isAdult: isAdult,
            spokenLanguages: spokenLanguages,
            heroImageURL: nil
        )
    }
}
