//
//  HomeViewModel.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 12/01/26.
//

import Combine
import Foundation

/// State for the Home screen: one rail of titles per `MovieRail`.
///
/// Knows only the `MovieListRepository` protocol, never TMDB, URLs or UIKit.
@MainActor
final class HomeViewModel {

    // MARK: - Output

    /// One entry per rail, in display order.
    @Published private(set) var rails: [MovieRailContent]

    /// Set when a rail fails to load. One message for the whole screen, so a
    /// dropped connection doesn't produce five alerts.
    @Published private(set) var errorMessage: String?

    // MARK: - Dependencies

    /// One loader per rail, same order as `rails`.
    private let loaders: [PaginatedMovieLoader]

    // MARK: - Init

    init(rails: [MovieRail], repository: MovieListRepository) {
        self.rails = rails.map { MovieRailContent(rail: $0, movies: []) }
        self.loaders = rails.map { PaginatedMovieLoader(source: $0.source, repository: repository) }
    }

    // MARK: - Loading

    /// Loads the first page of every rail that is still empty, all at once.
    /// Also used for Retry: rails that already have titles are left alone.
    func load() async {
        errorMessage = nil

        await withTaskGroup(of: Int.self) { group in
            for (index, loader) in loaders.enumerated() where loader.movies.isEmpty {
                group.addTask {
                    await loader.loadNextPage()
                    return index
                }
            }
            // Show each rail as soon as it arrives, not when the slowest one does.
            for await index in group {
                updateRail(at: index)
            }
        }

        errorMessage = loaders.compactMap { $0.errorMessage }.first
    }

    /// Call when a poster in a rail is about to appear.
    func loadMoreIfNeeded(railIndex: Int, displayedIndex: Int) async {
        guard loaders.indices.contains(railIndex) else { return }
        await loaders[railIndex].loadMoreIfNeeded(displayedIndex: displayedIndex)
        updateRail(at: railIndex)
    }

    // MARK: - Private

    private func updateRail(at index: Int) {
        let movies = loaders[index].movies
        guard rails[index].movies != movies else { return }
        rails[index].movies = movies
    }
}
