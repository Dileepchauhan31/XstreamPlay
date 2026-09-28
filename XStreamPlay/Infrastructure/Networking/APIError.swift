//
//  APIError.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 01/09/26.
//

import Foundation

/// Every failure the networking layer can produce, as a closed set.
///
/// Modelling this as an enum rather than passing `Error` around means the call
/// site can exhaustively handle failure, and the retry policy can be derived
/// from the error itself instead of from a scattering of status-code checks.
///
/// `Equatable` is deliberate: it makes assertions in tests read as
/// `XCTAssertEqual(error, .unauthorized)` rather than string comparison.
enum APIError: Error, Equatable {

    /// The endpoint could not be turned into a valid URL.
    case invalidURL(String)

    /// The request never reached the server, or the connection dropped.
    case transport(code: URLError.Code)

    /// The response was not an `HTTPURLResponse`.
    case invalidResponse

    /// 401 — the TMDB access token is missing, malformed, or revoked.
    case unauthorized

    /// 404 — the resource does not exist.
    case notFound

    /// 429 — TMDB rate limit hit.
    case rateLimited(retryAfter: TimeInterval?)

    /// Any other non-2xx status.
    case server(status: Int)

    /// The body arrived but did not match the expected shape.
    case decoding(description: String)

    /// Anything genuinely unexpected.
    case unknown(description: String)
}

// MARK: - Construction

extension APIError {

    /// Maps an HTTP status code and its headers onto a typed error.
    init(status: Int, headers: [AnyHashable: Any] = [:]) {
        switch status {
        case 401, 403:
            self = .unauthorized
        case 404:
            self = .notFound
        case 429:
            let retryAfter = (headers["Retry-After"] as? String).flatMap(TimeInterval.init)
            self = .rateLimited(retryAfter: retryAfter)
        default:
            self = .server(status: status)
        }
    }

    /// Normalises an arbitrary `Error` from a Combine or async pipeline.
    init(from error: Error) {
        switch error {
        case let apiError as APIError:
            self = apiError
        case let urlError as URLError:
            self = .transport(code: urlError.code)
        case let decodingError as DecodingError:
            self = .decoding(description: decodingError.readableDescription)
        default:
            self = .unknown(description: String(describing: error))
        }
    }
}

// MARK: - Presentation

extension APIError {

    /// Copy safe to show a user. Says what went wrong and what they can do —
    /// never "Error 500" and never an apology.
    var userMessage: String {
        switch self {
        case .invalidURL:
            return "We couldn't build that request. Please try again."
        case .transport:
            return "You appear to be offline. Check your connection and retry."
        case .invalidResponse:
            return "We got an unexpected reply from the server. Please retry."
        case .unauthorized:
            return "This app isn't authorised to reach TMDB right now."
        case .notFound:
            return "We couldn't find that title."
        case .rateLimited:
            return "Too many requests. Give it a few seconds and try again."
        case .server(let status):
            return "TMDB is having trouble (\(status)). Please try again shortly."
        case .decoding:
            return "We couldn't read the response. Please retry."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }

    /// Whether an automatic retry has any chance of succeeding.
    /// Used by the retry policy and to decide whether to show a Retry button.
    var isRetryable: Bool {
        switch self {
        case .transport, .rateLimited, .invalidResponse:
            return true
        case .server(let status):
            return status >= 500
        case .invalidURL, .unauthorized, .notFound, .decoding, .unknown:
            return false
        }
    }

    /// How long to wait before retrying, when the server told us.
    var suggestedRetryDelay: TimeInterval? {
        if case .rateLimited(let retryAfter) = self { return retryAfter }
        return nil
    }
}

// MARK: - Diagnostics

private extension DecodingError {

    /// A one-line description that names the key path, so a decoding failure is
    /// actionable from a log line alone.
    var readableDescription: String {
        func path(_ context: Context) -> String {
            context.codingPath.map(\.stringValue).joined(separator: ".")
        }

        switch self {
        case .keyNotFound(let key, let context):
            return "Missing key '\(key.stringValue)' at \(path(context))"
        case .typeMismatch(let type, let context):
            return "Expected \(type) at \(path(context))"
        case .valueNotFound(let type, let context):
            return "Null value for \(type) at \(path(context))"
        case .dataCorrupted(let context):
            return "Corrupted data at \(path(context)): \(context.debugDescription)"
        @unknown default:
            return String(describing: self)
        }
    }
}

/// Compatibility alias so existing call sites keep compiling while the app
/// migrates from `NetworkManager` to `APIClient`.
/// - TODO: Remove in Week 2 once every view model uses `APIClient`.
typealias NetworkError = APIError
