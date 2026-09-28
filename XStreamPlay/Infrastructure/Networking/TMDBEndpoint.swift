//
//  TMDBEndpoint.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 01/09/26.
//

import Foundation

// MARK: - Supporting types

/// The curated movie lists TMDB exposes as their own paths.
enum TMDBMovieList: String {
    case popular
    case topRated   = "top_rated"
    case upcoming
    case nowPlaying = "now_playing"
}

/// The trending window TMDB supports.
enum TMDBTrendingWindow: String {
    case day
    case week
}

/// What a trending request covers.
enum TMDBMediaScope: String {
    case all
    case movie
    case tv
    case person
}

/// Sub-resources that can be folded into a single detail request.
///
/// This is the reason a detail screen costs one round trip instead of eight.
enum TMDBAppendix: String, CaseIterable {
    case videos
    case credits
    case recommendations
    case similar
    case images
    case reviews
    case releaseDates  = "release_dates"
    case watchProviders = "watch/providers"
    case externalIDs   = "external_ids"

    /// Everything the detail screen needs, in one request.
    static var detailScreen: [TMDBAppendix] { allCases }
}

// MARK: - Endpoint factories

extension Endpoint {

    // MARK: Lists

    static func trending(
        scope: TMDBMediaScope = .movie,
        window: TMDBTrendingWindow = .week,
        page: Int = 1,
        region: String? = nil
    ) -> Endpoint {
        var query = [URLQueryItem(name: "page", value: String(page))]
        query.appendIfPresent("region", region)
        return Endpoint(path: "trending/\(scope.rawValue)/\(window.rawValue)", query: query)
    }

    static func movies(list: TMDBMovieList, page: Int = 1, region: String? = nil) -> Endpoint {
        var query = [URLQueryItem(name: "page", value: String(page))]
        query.appendIfPresent("region", region)
        return Endpoint(path: "movie/\(list.rawValue)", query: query)
    }

    static func popularTVShows(page: Int = 1) -> Endpoint {
        Endpoint(path: "tv/popular", query: [URLQueryItem(name: "page", value: String(page))])
    }

    static func discoverMovies(
        genreIDs: [Int] = [],
        page: Int = 1,
        sortBy: String = "popularity.desc",
        language: String? = nil
    ) -> Endpoint {
        var query = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sort_by", value: sortBy)
        ]
        if !genreIDs.isEmpty {
            query.append(URLQueryItem(name: "with_genres", value: genreIDs.map(String.init).joined(separator: ",")))
        }
        query.appendIfPresent("with_original_language", language)
        return Endpoint(path: "discover/movie", query: query)
    }

    // MARK: Detail

    /// One request that returns the movie plus every sub-resource the detail
    /// screen renders.
    ///
    /// - Important: TMDB caps `append_to_response` at 20 sub-requests, which is
    ///   comfortably above what we ask for.
    static func movieDetail(
        id: Int,
        appending appendices: [TMDBAppendix] = TMDBAppendix.detailScreen,
        language: String? = nil
    ) -> Endpoint {
        var query: [URLQueryItem] = []
        if !appendices.isEmpty {
            query.append(URLQueryItem(
                name: "append_to_response",
                value: appendices.map(\.rawValue).joined(separator: ",")
            ))
        }
        query.appendIfPresent("language", language)
        return Endpoint(path: "movie/\(id)", query: query)
    }

    static func tvDetail(
        id: Int,
        appending appendices: [TMDBAppendix] = TMDBAppendix.detailScreen
    ) -> Endpoint {
        var query: [URLQueryItem] = []
        if !appendices.isEmpty {
            query.append(URLQueryItem(
                name: "append_to_response",
                value: appendices.map(\.rawValue).joined(separator: ",")
            ))
        }
        return Endpoint(path: "tv/\(id)", query: query)
    }

    // MARK: Related

    static func similarMovies(id: Int, page: Int = 1) -> Endpoint {
        Endpoint(path: "movie/\(id)/similar", query: [URLQueryItem(name: "page", value: String(page))])
    }

    static func recommendedMovies(id: Int, page: Int = 1) -> Endpoint {
        Endpoint(path: "movie/\(id)/recommendations", query: [URLQueryItem(name: "page", value: String(page))])
    }

    // MARK: Search

    static func searchMulti(query searchText: String, page: Int = 1) -> Endpoint {
        Endpoint(
            path: "search/multi",
            query: [
                URLQueryItem(name: "query", value: searchText),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "include_adult", value: "false")
            ]
        )
    }
}

// MARK: - Images

/// Builds TMDB image URLs at an explicit size.
///
/// Requesting `original` for a 110×160 poster cell wastes bandwidth and memory;
/// naming the size at the call site makes that cost visible.
enum TMDBImage {

    enum PosterSize: String {
        case w154, w185, w342, w500, original
    }

    enum BackdropSize: String {
        case w300, w780, w1280, original
    }

    enum ProfileSize: String {
        case w45, w185, h632, original
    }

    static func poster(_ path: String?, size: PosterSize = .w342) -> URL? {
        url(path, size: size.rawValue)
    }

    static func backdrop(_ path: String?, size: BackdropSize = .w780) -> URL? {
        url(path, size: size.rawValue)
    }

    static func profile(_ path: String?, size: ProfileSize = .w185) -> URL? {
        url(path, size: size.rawValue)
    }

    private static func url(_ path: String?, size: String) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        let normalised = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return AppEnvironment.imageBaseURL
            .appendingPathComponent(size)
            .appendingPathComponent(normalised)
    }
}
