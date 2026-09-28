//
//  AppEnvironment.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// Server addresses and the access token, read from `Info.plist`.
///
/// Where the values come from:
/// `Secrets.xcconfig` (git-ignored) → `Configurations/XStreamPlay.xcconfig`
/// → `Info.plist` (`$(TMDB_ACCESS_TOKEN)` …) → here.
///
/// A missing value never crashes the app. It is logged, and requests then
/// fail with `APIError.unauthorized`.
struct AppEnvironment {

    let apiBaseURL: URL
    let imageBaseURL: URL
    let accessToken: String

    // MARK: - Info.plist keys

    private enum InfoKey {
        static let apiHost = "TMDBAPIHost"
        static let imageHost = "TMDBImageHost"
        static let accessToken = "TMDBAccessToken"
    }

    private enum Default {
        static let apiHost = "api.themoviedb.org"
        static let imageHost = "image.tmdb.org"
    }

    // MARK: - Loading

    static func load(from bundle: Bundle = .main) -> AppEnvironment {
        let apiHost = value(for: InfoKey.apiHost, in: bundle) ?? Default.apiHost
        let imageHost = value(for: InfoKey.imageHost, in: bundle) ?? Default.imageHost
        let token = value(for: InfoKey.accessToken, in: bundle) ?? ""

        if token.isEmpty || token.hasPrefix("PASTE_") {
            Log.app.error("TMDB_ACCESS_TOKEN is not set. Copy Secrets.example.xcconfig to Secrets.xcconfig and add your token.")
        }

        return AppEnvironment(
            apiBaseURL: makeURL(host: apiHost, path: "/3", fallbackHost: Default.apiHost),
            imageBaseURL: makeURL(host: imageHost, path: "/t/p", fallbackHost: Default.imageHost),
            accessToken: token.hasPrefix("PASTE_") ? "" : token
        )
    }

    // MARK: - Private

    /// Reads a string from Info.plist. An empty string or an unexpanded
    /// `$(VARIABLE)` counts as missing.
    private static func value(for key: String, in bundle: Bundle) -> String? {
        guard let raw = bundle.object(forInfoDictionaryKey: key) as? String else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.hasPrefix("$(") else { return nil }
        return trimmed
    }

    private static func makeURL(host: String, path: String, fallbackHost: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path

        if let url = components.url {
            return url
        }
        Log.app.error("Invalid host '\(host)' in configuration, using \(fallbackHost).")
        components.host = fallbackHost
        // Built from constants, so this cannot fail.
        return components.url ?? URL(fileURLWithPath: "/")
    }
}
