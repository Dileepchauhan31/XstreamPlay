//
//  MoviePage.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// One page of titles, plus where to continue from.
struct MoviePage: Equatable, Sendable {
    let movies: [Movie]

    /// The page to request next, or `nil` when the list has ended.
    let nextPage: Int?
}
