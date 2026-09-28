//
//  MovieDTO.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 01/09/26.
//

import Foundation

/// One item in any TMDB list (a movie or a TV show), exactly as the JSON has it.
///
/// Decoded with `JSONDecoder.convertingSnakeCase`, so `poster_path` maps to
/// `posterPath` with no `CodingKeys`. Only the fields the app reads are listed;
/// extra JSON keys are ignored.
///
/// DTOs never leave the Data layer. `Movie(dto:…)` in `Movie+DTO.swift`
/// turns this into the domain `Movie`.
struct MovieDTO: Decodable, Equatable {

    let id: Int

    // Movies use `title`; TV shows use `name`.
    let title: String?
    let name: String?
    let originalTitle: String?
    let originalName: String?

    let posterPath: String?
    let backdropPath: String?

    /// Only trending and search results include this.
    let mediaType: String?
}
