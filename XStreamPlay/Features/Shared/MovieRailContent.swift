//
//  MovieRailContent.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// What a `MovieRailCell` displays: the rail's settings plus the titles
/// loaded so far.
///
/// A small value type, so the view controller can keep its own copy and
/// compare old and new to update only the rails that changed.
struct MovieRailContent: Equatable {
    let rail: MovieRail
    var movies: [Movie]
}
