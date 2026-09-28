//
//  PaginatedMovieLoader.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// Loads a list one page at a time (page 1, page 2, …).
///
/// Home rails, See All and More Like This all use this class, so the paging
/// rules are written once. `@MainActor`: all state changes happen on the main
/// thread, so screens can read the results directly.
@MainActor
final class PaginatedMovieLoader {

    // MARK: - Output

    private(set) var movies: [Movie] = []

    /// The last failure, or `nil`. Cleared when the next request starts.
    private(set) var error: APIError?

    /// User-facing text for `error`.
    var errorMessage: String? { error?.userMessage }

    private(set) var isLoading = false

    var hasMorePages: Bool { nextPage != nil }

    // MARK: - Dependencies

    private let source: MovieListSource
    private let repository: MovieListRepository

    // MARK: - State

    private var nextPage: Int? = 1

    // MARK: - Init

    init(source: MovieListSource, repository: MovieListRepository) {
        self.source = source
        self.repository = repository
    }

    // MARK: - Loading

    /// Fetches the next page. Safe to call as often as you like: it does
    /// nothing while a request is running or after the last page.
    func loadNextPage() async {
        guard !isLoading, let page = nextPage else { return }

        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let result = try await repository.fetchMovies(from: source, page: page)
            movies.append(contentsOf: result.movies)
            nextPage = result.nextPage
        } catch {
            let apiError = APIError(from: error)
            // A cancelled request is not a failure the user needs to see.
            guard apiError != .cancelled else { return }

            self.error = apiError
            // A dropped connection or a 5xx may work next time; a 401 or 404 won't.
            if !apiError.isRetryable {
                nextPage = nil
            }
            Log.network.error("Loading \(source) page \(page) failed: \(apiError)")
        }
    }

    /// Call when a cell is about to appear. Starts the next page a few items
    /// before the end, so scrolling doesn't hit a blank edge.
    func loadMoreIfNeeded(displayedIndex: Int, prefetchDistance: Int = 5) async {
        guard displayedIndex >= movies.count - prefetchDistance else { return }
        await loadNextPage()
    }
}
