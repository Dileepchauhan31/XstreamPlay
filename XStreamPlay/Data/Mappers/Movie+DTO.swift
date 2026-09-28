//
//  Movie+DTO.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

// DTO → domain conversion for list items.
//
// DTOs mirror TMDB's JSON; domain entities are shaped for the app. If TMDB
// renames a field, only the DTO and this file change — no screen does.

extension Movie {

    /// - Parameter fallbackMediaType: used when the JSON has no `media_type`
    ///   (only trending and search results include it).
    init(dto: MovieDTO, fallbackMediaType: MediaType, images: TMDBImageURLBuilder) {
        let mediaType = dto.mediaType.flatMap(MediaType.init(rawValue:)) ?? fallbackMediaType
        let title = dto.title ?? dto.name ?? dto.originalTitle ?? dto.originalName ?? "Untitled"

        self.init(
            id: dto.id,
            title: title,
            mediaType: mediaType,
            posterURL: images.url(for: dto.posterPath, size: .w500)
        )
    }
}
