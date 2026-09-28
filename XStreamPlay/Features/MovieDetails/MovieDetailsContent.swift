//
//  MovieDetailsContent.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// The details screen's text, already formatted for display.
///
/// Built by `MovieDetailsViewModel.makeContent(from:)`, so cells only assign
/// strings to labels and never format anything themselves.
struct MovieDetailsContent: Equatable {
    let title: String
    /// e.g. `"Drama • Thriller • 1999 • U/A"`
    let subtitle: String
    let overview: String
    /// e.g. `"Audio Available in: English, Hindi"`, or `nil` when unknown.
    let audioLanguages: String?
    let heroImageURL: URL?
}
