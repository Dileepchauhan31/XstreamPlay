//
//  Endpoint.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 01/09/26.
//

import Foundation

// MARK: - HTTPMethod

enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
}

// MARK: - Endpoint

/// A transport-agnostic description of one request.
///
/// An `Endpoint` is a *value*, not a call: it knows a path, a method and some
/// query items, and nothing about `URLSession`, authentication or decoding.
/// That separation is what makes the API surface testable — `EndpointTests`
/// asserts on the URL that gets built without a single byte crossing a socket.
///
/// Query values are carried as `URLQueryItem` rather than string interpolation
/// so that percent-encoding is handled once, correctly, by `URLComponents`.
struct Endpoint {

    let path: String
    var method: HTTPMethod = .get
    var query: [URLQueryItem] = []
    var headers: [String: String] = [:]
    var body: Data?

    /// Builds the concrete request.
    ///
    /// - Note: The access token goes in the `Authorization` header, never in the
    ///   query string. Query strings end up in server logs, proxy logs and
    ///   crash reports; headers generally do not.
    func urlRequest(baseURL: URL, accessToken: String) throws -> URLRequest {
        let full = baseURL.appendingPathComponent(path)

        guard var components = URLComponents(url: full, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL(path)
        }
        components.queryItems = query.isEmpty ? nil : query

        guard let url = components.url else {
            throw APIError.invalidURL(path)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }

        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return request
    }
}

// MARK: - Query convenience

extension Array where Element == URLQueryItem {

    /// Appends a query item only when the value is non-nil and non-empty,
    /// so optional parameters never produce `?region=` in the URL.
    mutating func appendIfPresent(_ name: String, _ value: CustomStringConvertible?) {
        guard let value else { return }
        let string = String(describing: value)
        guard !string.isEmpty else { return }
        append(URLQueryItem(name: name, value: string))
    }
}
