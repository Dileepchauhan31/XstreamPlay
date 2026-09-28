//
//  MovieListSource.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// Which list of titles to load (Trending, Popular, …).
///
/// Screens only say WHICH list they want. The repository decides the URL.
enum MovieListSource: Hashable, Sendable {
    case trending
    case popular
    case topRated
    case upcoming
    case popularTVShows
    case similar(movieID: Int, mediaType: MediaType)

    /// What kind of titles this list contains, for items whose JSON does not
    /// say (`movie/popular` results have no `media_type` field).
    var mediaType: MediaType {
        switch self {
        case .trending, .popular, .topRated, .upcoming:
            return .movie
        case .popularTVShows:
            return .tv
        case .similar(_, let mediaType):
            return mediaType
        }
    }
}
