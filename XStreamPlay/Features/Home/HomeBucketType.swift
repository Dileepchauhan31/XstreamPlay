//
//  HomeBucketType.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 12/01/26.
//

import Foundation

/// - Note: This enum is a temporary bridge. In Week 3 it is replaced by a
///   config-driven rail engine where a rail is described by JSON — a render
///   style plus a data source — so product can add a row without an app release.
///   Until then it at least no longer leaks credentials into the query string.
enum HomeBucketType: CaseIterable {

    case trending, popular, topRated, upcoming, tvShows, moreLikeThis

    var title: String {
        switch self {
        case .trending:     return "Trending Now"
        case .popular:      return "Popular Movies"
        case .topRated:     return "Top Rated"
        case .upcoming:     return "Upcoming"
        case .tvShows:      return "Popular TV Shows"
        case .moreLikeThis: return "More Like This"
        }
    }

    /// - Important: The access token used to be interpolated here as
    ///   `api_key=…`. It now travels in the `Authorization` header set by
    ///   `NetworkManager`, so it can no longer end up in a server log, a proxy
    ///   log or a crash report.
    func endpoint(page: Int, id: Int = 0) -> String {
        "\(TMDBConfig.baseURL)/\(path(id: id))?page=\(page)"
    }

    private func path(id: Int) -> String {
        switch self {
        case .trending:     return "trending/movie/week"
        case .popular:      return "movie/popular"
        case .topRated:     return "movie/top_rated"
        case .upcoming:     return "movie/upcoming"
        case .tvShows:      return "tv/popular"
        case .moreLikeThis: return "movie/\(id)/similar"
        }
    }
}
