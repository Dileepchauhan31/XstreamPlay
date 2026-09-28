//
//  MovieDTO.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 01/09/26.
//

import Foundation

/// One item in any TMDB list — a movie, a show, or a person in a `search/multi`
/// result.
///
/// Replaces `Model_Result`. Three things changed and each is deliberate:
///
/// 1. **No hand-written `init(from:)`.** Forty lines of `decodeIfPresent` that
///    the synthesised initialiser produces for free.
/// 2. **No `CodingKeys` block.** `JSONDecoder.tmdb` uses
///    `.convertFromSnakeCase`, so `poster_path` maps to `posterPath`
///    automatically. Note that this makes `genre_ids` become `genreIds` — the
///    strategy is mechanical, so the property is spelled that way rather than
///    the more idiomatic `genreIDs`.
/// 3. **`id` is non-optional.** An item without an identifier is not something
///    the app can display or navigate to; letting it decode and then failing at
///    a `?? 0` call site is worse than failing here.
struct MovieDTO: Decodable, Hashable, Identifiable {

    let id: Int

    // Movies use `title`/`releaseDate`; TV uses `name`/`firstAirDate`.
    let title: String?
    let name: String?
    let originalTitle: String?
    let originalName: String?

    let overview: String?
    let posterPath: String?
    let backdropPath: String?

    let releaseDate: String?
    let firstAirDate: String?

    let genreIds: [Int]?
    let voteAverage: Double?
    let voteCount: Int?
    let popularity: Double?
    let originalLanguage: String?
    let mediaType: String?
    let adult: Bool?
}

// MARK: - Display helpers

extension MovieDTO {

    /// The title to show, whichever media type this is.
    var displayTitle: String {
        title ?? name ?? originalTitle ?? originalName ?? "Untitled"
    }

    /// The four-digit year, or `nil` when TMDB sends an empty date string.
    var year: String? {
        let raw = releaseDate ?? firstAirDate
        guard let raw, raw.count >= 4 else { return nil }
        return String(raw.prefix(4))
    }

    /// Rating formatted for a badge, e.g. `"8.4"`. `nil` when unrated, so the
    /// badge can be hidden rather than showing `0.0`.
    var formattedRating: String? {
        guard let voteAverage, voteAverage > 0 else { return nil }
        return String(format: "%.1f", voteAverage)
    }

    var posterURL: URL? { TMDBImage.poster(posterPath) }
    var backdropURL: URL? { TMDBImage.backdrop(backdropPath) }

    /// Whether this row is a person rather than a title, in a multi-search result.
    var isPerson: Bool { mediaType == "person" }
}
