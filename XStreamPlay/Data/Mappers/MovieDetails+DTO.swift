//
//  MovieDetails+DTO.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

// DTO → domain conversion for the details screen.

extension MovieDetails {

    init(dto: MovieDetailsDTO, images: TMDBImageURLBuilder) {
        let rawDate = dto.releaseDate ?? dto.firstAirDate
        let year = rawDate.flatMap { $0.count >= 4 ? String($0.prefix(4)) : nil }

        self.init(
            id: dto.id,
            title: dto.title ?? dto.name ?? "Untitled",
            overview: dto.overview ?? "",
            genres: dto.genres?.compactMap(\.name) ?? [],
            releaseYear: year,
            isAdult: dto.adult ?? false,
            spokenLanguages: dto.spokenLanguages?.compactMap { $0.englishName ?? $0.name } ?? [],
            heroImageURL: images.url(for: dto.posterPath, size: .hero)
        )
    }
}
