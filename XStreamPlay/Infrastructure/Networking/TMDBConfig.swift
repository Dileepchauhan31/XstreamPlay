//
//  TMDBConfig.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 12/01/26.
//

import Foundation

/// Thin compatibility shim over `AppEnvironment`.
///
/// The credential that used to live here as a string literal is gone; nothing in
/// this file is a secret any more. Values resolve at runtime from
/// `Secrets.xcconfig` → `Info.plist` → `AppEnvironment`.
///
/// - TODO: Delete in Week 2. Call sites should build requests with `Endpoint`
///   and let `URLSessionAPIClient` supply the base URL and token.
enum TMDBConfig {

    /// e.g. `https://api.themoviedb.org/3`
    static var baseURL: String {
        AppEnvironment.apiBaseURL.absoluteString
    }

    /// TMDB v4 Read Access Token. Sent as a bearer header, never as a query item.
    static var bearerToken: String {
        AppEnvironment.tmdbAccessToken
    }
}
