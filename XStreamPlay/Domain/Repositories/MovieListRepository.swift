//
//  MovieListRepository.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// Loads paginated lists of titles.
///
/// View models depend on this protocol, never on a concrete class.
/// - In the app: `TMDBMovieRepository`.
/// - In tests: `MockMovieRepository`.
protocol MovieListRepository {
    func fetchMovies(from source: MovieListSource, page: Int) async throws -> MoviePage
}
