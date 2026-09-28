//
//  MovieRail.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 12/01/26.
//

import Foundation

/// Settings for one horizontal row ("rail") of posters.
///
/// To add a rail to Home, add one line to `homeScreen`. No other file changes.
struct MovieRail: Hashable {
    let title: String
    let source: MovieListSource

    /// `false` hides the title row, e.g. on the details screen, which has its
    /// own tab header above the rail.
    let showsHeader: Bool
    let showsSeeAll: Bool
    let showsPosterTitle: Bool
}

extension MovieRail {

    /// The rails on the Home screen, top to bottom.
    static let homeScreen: [MovieRail] = [
        MovieRail(title: "Trending", source: .trending, showsHeader: true, showsSeeAll: true, showsPosterTitle: false),
        MovieRail(title: "Popular Movies", source: .popular, showsHeader: true, showsSeeAll: true, showsPosterTitle: true),
        MovieRail(title: "Top Rated", source: .topRated, showsHeader: true, showsSeeAll: true, showsPosterTitle: true),
        MovieRail(title: "Upcoming", source: .upcoming, showsHeader: true, showsSeeAll: false, showsPosterTitle: false),
        MovieRail(title: "Popular TV Shows", source: .popularTVShows, showsHeader: true, showsSeeAll: true, showsPosterTitle: true)
    ]

    /// The "More Like This" rail on the details screen.
    static func moreLikeThis(movieID: Int, mediaType: MediaType) -> MovieRail {
        MovieRail(
            title: "More Like This",
            source: .similar(movieID: movieID, mediaType: mediaType),
            showsHeader: false,
            showsSeeAll: false,
            showsPosterTitle: true
        )
    }
}
