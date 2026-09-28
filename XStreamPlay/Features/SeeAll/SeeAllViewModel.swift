//
//  SeeAllViewModel.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 15/01/26.
//

import Combine
import Foundation

/// State for the See All grid: every title in one list, loaded page by page.
@MainActor
final class SeeAllViewModel {

    // MARK: - Output

    let title: String
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let loader: PaginatedMovieLoader

    // MARK: - Init

    init(title: String, source: MovieListSource, repository: MovieListRepository) {
        self.title = title
        self.loader = PaginatedMovieLoader(source: source, repository: repository)
    }

    // MARK: - Loading

    /// First load and Retry.
    func loadNextPage() async {
        errorMessage = nil
        await loader.loadNextPage()
        publishLoaderState()
    }

    /// Call when a cell is about to appear.
    func loadMoreIfNeeded(displayedIndex: Int) async {
        await loader.loadMoreIfNeeded(displayedIndex: displayedIndex)
        publishLoaderState()
    }

    // MARK: - Private

    private func publishLoaderState() {
        if movies != loader.movies {
            movies = loader.movies
        }
        // Only publish a change, so scrolling past a failed page doesn't
        // show the same alert again and again.
        if errorMessage != loader.errorMessage {
            errorMessage = loader.errorMessage
        }
    }
}
