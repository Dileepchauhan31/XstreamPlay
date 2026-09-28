//
//  MovieDetails.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// Everything the details screen needs to know about one title.
///
/// Built by the repository from the API response. Fields are non-optional
/// where there is a sensible empty value (no overview, no genres), so view
/// code never has to unwrap.
struct MovieDetails: Equatable, Sendable {
    let id: Int
    let title: String
    let overview: String
    let genres: [String]

    /// Four-digit year, or `nil` when TMDB has no date.
    let releaseYear: String?
    let isAdult: Bool

    /// English names of the audio languages, e.g. `["English", "Hindi"]`.
    let spokenLanguages: [String]
    let heroImageURL: URL?
}
