//
//  TMDBImageURLBuilder.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// Builds TMDB image URLs such as `https://image.tmdb.org/t/p/w500/abc.jpg`.
///
/// Replaces the old `TMDBImageConfig` string constants that lived inside a
/// cell. Only the Data layer builds image URLs; screens receive a ready `URL`.
struct TMDBImageURLBuilder {

    /// Image widths TMDB serves. Smaller is faster; pick the smallest that
    /// still looks sharp.
    enum Size: String {
        case w185
        case w500
        case original
        /// Wide artwork used at the top of the details screen.
        case hero = "w1920_and_h1080_bestv2"
    }

    /// `https://image.tmdb.org/t/p`
    let baseURL: URL

    init(baseURL: URL = URL(string: "https://image.tmdb.org/t/p") ?? URL(fileURLWithPath: "/")) {
        self.baseURL = baseURL
    }

    /// - Parameter path: TMDB's file path, e.g. `"/abc.jpg"`. `nil` or empty
    ///   gives `nil`, so the view shows its placeholder.
    func url(for path: String?, size: Size) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        let fileName = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return baseURL
            .appendingPathComponent(size.rawValue)
            .appendingPathComponent(fileName)
    }
}
