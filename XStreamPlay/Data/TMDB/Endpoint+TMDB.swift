//
//  Endpoint+TMDB.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// Every TMDB request the app makes, in one place.
///
/// Paths are relative to `AppEnvironment.apiBaseURL` (`https://api.themoviedb.org/3`).
/// To call a new TMDB API, add a factory here and use it from `TMDBMovieRepository`.
extension Endpoint {

    // MARK: - Lists

    static func trendingMovies(page: Int) -> Endpoint {
        Endpoint(path: "trending/movie/week", queryItems: pageQuery(page))
    }

    static func popularMovies(page: Int) -> Endpoint {
        Endpoint(path: "movie/popular", queryItems: pageQuery(page))
    }

    static func topRatedMovies(page: Int) -> Endpoint {
        Endpoint(path: "movie/top_rated", queryItems: pageQuery(page))
    }

    static func upcomingMovies(page: Int) -> Endpoint {
        Endpoint(path: "movie/upcoming", queryItems: pageQuery(page))
    }

    static func popularTVShows(page: Int) -> Endpoint {
        Endpoint(path: "tv/popular", queryItems: pageQuery(page))
    }

    static func similarMovies(movieID: Int, page: Int) -> Endpoint {
        Endpoint(path: "movie/\(movieID)/similar", queryItems: pageQuery(page))
    }

    static func similarTVShows(showID: Int, page: Int) -> Endpoint {
        Endpoint(path: "tv/\(showID)/similar", queryItems: pageQuery(page))
    }

    // MARK: - Details

    static func movieDetails(movieID: Int) -> Endpoint {
        Endpoint(path: "movie/\(movieID)")
    }

    static func tvShowDetails(showID: Int) -> Endpoint {
        Endpoint(path: "tv/\(showID)")
    }

    // MARK: - Private

    private static func pageQuery(_ page: Int) -> [URLQueryItem] {
        [URLQueryItem(name: "page", value: String(page))]
    }
}
