//
//  AppEnvironment.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 01/09/26.
//

import Foundation

/// Single source of truth for build-time configuration.
///
/// Values flow: `Secrets.xcconfig` → `Info.plist` (via `$(VAR)` substitution) → here.
///
/// The point of the indirection is that **no credential is ever written in a
/// source file**, so no credential can ever be committed. `Secrets.xcconfig` is
/// git-ignored; `Secrets.example.xcconfig` documents its shape for anyone
/// cloning the repository.
///
/// A missing value is a programmer error, not a runtime condition — the app
/// traps immediately with a message that says exactly how to fix it, rather
/// than shipping and failing later with an opaque 401.
enum AppEnvironment {

    // MARK: - Keys

    enum Key: String {
        case tmdbAccessToken = "TMDB_ACCESS_TOKEN"
        case tmdbAPIHost     = "TMDB_API_HOST"
        case tmdbImageHost   = "TMDB_IMAGE_HOST"
    }

    // MARK: - Values

    /// TMDB v4 Read Access Token, sent as `Authorization: Bearer <token>`.
    static let tmdbAccessToken: String = value(for: .tmdbAccessToken)

    /// Root of the TMDB REST API, e.g. `https://api.themoviedb.org/3`.
    static let apiBaseURL: URL = url(scheme: "https", host: value(for: .tmdbAPIHost), path: "/3")

    /// Root of the TMDB image CDN, e.g. `https://image.tmdb.org/t/p`.
    static let imageBaseURL: URL = url(scheme: "https", host: value(for: .tmdbImageHost), path: "/t/p")

    // MARK: - Test detection

    /// True when running inside XCTest. Used to keep configuration lookups from
    /// trapping in test bundles that have no host application.
    static var isRunningTests: Bool {
        NSClassFromString("XCTestCase") != nil
    }

    // MARK: - Lookup

    private static func value(for key: Key) -> String {
        // 1. Process environment wins — lets CI inject secrets without a file.
        if let injected = ProcessInfo.processInfo.environment[key.rawValue],
           !injected.isEmpty {
            return injected
        }

        // 2. Info.plist, populated from Secrets.xcconfig at build time.
        let raw = Bundle.main.object(forInfoDictionaryKey: key.rawValue) as? String
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // An unsubstituted "$(VAR)" means the xcconfig was never wired up.
        if !trimmed.isEmpty, !trimmed.hasPrefix("$("), !trimmed.hasPrefix("PASTE_") {
            return trimmed
        }

        // 3. Unit tests run without a host app; return a harmless placeholder so
        //    that merely touching this type never crashes a test run. Tests that
        //    exercise networking inject their own values explicitly.
        if isRunningTests {
            return placeholder(for: key)
        }

        fatalError(setupInstructions(for: key))
    }

    private static func placeholder(for key: Key) -> String {
        switch key {
        case .tmdbAccessToken: return "test-token"
        case .tmdbAPIHost:     return "api.themoviedb.org"
        case .tmdbImageHost:   return "image.tmdb.org"
        }
    }

    private static func url(scheme: String, host: String, path: String) -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path

        guard let url = components.url else {
            fatalError("AppEnvironment: '\(host)' is not a valid host for \(scheme)://\(host)\(path)")
        }
        return url
    }

    private static func setupInstructions(for key: Key) -> String {
        """

        ────────────────────────────────────────────────────────────────────
        Missing configuration value: \(key.rawValue)

        One-time setup:

          1. cp Secrets.example.xcconfig Secrets.xcconfig
          2. Open Secrets.xcconfig and paste your TMDB v4 Read Access Token.
          3. In Xcode: select the XStreamPlay *project* (blue icon) → Info tab
             → Configurations → expand Debug and Release → set the project-level
             "Based on Configuration File" to `Secrets`.
          4. Product → Clean Build Folder (⇧⌘K), then run again.

        Secrets.xcconfig is git-ignored on purpose. Never commit it.
        ────────────────────────────────────────────────────────────────────

        """
    }
}
