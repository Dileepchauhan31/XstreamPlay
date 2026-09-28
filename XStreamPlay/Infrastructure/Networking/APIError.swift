//
//  APIError.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// Every way a request can fail, as one closed list.
///
/// The UI shows `userMessage` and never a raw `Error`. Pagination uses
/// `isRetryable` to decide whether asking again could help.
enum APIError: Error, Equatable {
    case invalidURL
    /// No connection, timeout, DNS failure … (anything `URLSession` reports).
    case transport(code: URLError.Code)
    case unauthorized
    case notFound
    case rateLimited
    case server(statusCode: Int)
    case unexpectedStatus(statusCode: Int)
    case decoding
    case cancelled
    case unknown

    /// Converts any error thrown by the networking stack into an `APIError`.
    init(from error: Error) {
        switch error {
        case let apiError as APIError:
            self = apiError
        case is CancellationError:
            self = .cancelled
        case let urlError as URLError where urlError.code == .cancelled:
            self = .cancelled
        case let urlError as URLError:
            self = .transport(code: urlError.code)
        case is DecodingError:
            self = .decoding
        default:
            self = .unknown
        }
    }

    /// Maps a non-2xx HTTP status code to an error.
    init(statusCode: Int) {
        switch statusCode {
        case 401, 403:
            self = .unauthorized
        case 404:
            self = .notFound
        case 429:
            self = .rateLimited
        case 500...599:
            self = .server(statusCode: statusCode)
        default:
            self = .unexpectedStatus(statusCode: statusCode)
        }
    }

    /// Text that is safe to show to the user.
    var userMessage: String {
        switch self {
        case .transport(code: .notConnectedToInternet), .transport(code: .networkConnectionLost):
            return "You're offline. Check your connection and try again."
        case .transport(code: .timedOut):
            return "The request took too long. Please try again."
        case .transport:
            return "We couldn't reach the server. Please try again."
        case .unauthorized:
            return "We couldn't sign in to the movie service."
        case .notFound:
            return "This title is no longer available."
        case .rateLimited:
            return "Too many requests. Please wait a moment and try again."
        case .server:
            return "The server is having trouble. Please try again later."
        case .invalidURL, .unexpectedStatus, .decoding, .unknown:
            return "Something went wrong. Please try again."
        case .cancelled:
            return ""
        }
    }

    /// `true` when the same request might succeed later
    /// (dropped connection, timeout, 5xx, 429). A 401 or 404 will not.
    var isRetryable: Bool {
        switch self {
        case .transport, .rateLimited, .server, .cancelled:
            return true
        case .invalidURL, .unauthorized, .notFound, .unexpectedStatus, .decoding, .unknown:
            return false
        }
    }
}
