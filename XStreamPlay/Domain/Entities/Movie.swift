//
//  Movie.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 12/01/26.
//

import Foundation

/// A movie or show shown in a rail or grid.
/// Plain data only: no JSON code and no UIKit code.
struct Movie: Hashable, Identifiable, Sendable {
    let id: Int
    let title: String
    let mediaType: MediaType
    let posterURL: URL?
}
