//
//  MediaType.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// Is this title a movie or a TV show?
/// TMDB uses different URLs for each (`movie/{id}` and `tv/{id}`).
enum MediaType: String, Hashable, Sendable {
    case movie
    case tv
}
