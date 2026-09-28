//
//  MovieDetailsDTO.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// The JSON returned by `movie/{id}` and `tv/{id}`.
///
/// Movies and TV shows name a few fields differently (`title` / `name`,
/// `release_date` / `first_air_date`). Both are optional here; the mapper
/// picks whichever is present.
struct MovieDetailsDTO: Decodable, Equatable {

    struct Genre: Decodable, Equatable {
        let id: Int
        let name: String?
    }

    struct SpokenLanguage: Decodable, Equatable {
        let englishName: String?
        let name: String?
    }

    let id: Int

    let title: String?
    let name: String?

    let overview: String?
    let posterPath: String?
    let backdropPath: String?

    let releaseDate: String?
    let firstAirDate: String?

    let adult: Bool?
    let genres: [Genre]?
    let spokenLanguages: [SpokenLanguage]?
}
