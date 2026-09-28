//
//  MovieDetailsRepository.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// Loads the full details of one title.
///
/// Kept separate from `MovieListRepository` (interface segregation): a screen
/// that only shows lists never sees this method.
protocol MovieDetailsRepository {
    func fetchDetails(id: Int, mediaType: MediaType) async throws -> MovieDetails
}
