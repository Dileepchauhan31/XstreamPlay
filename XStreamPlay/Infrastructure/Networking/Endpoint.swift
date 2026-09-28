//
//  Endpoint.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// A value that describes one HTTP request: path, method, query and headers.
///
/// An `Endpoint` knows nothing about a server. `URLSessionAPIClient` joins it
/// with a base URL and the auth header. The TMDB-specific factories
/// (`.popularMovies(page:)`, `.movieDetails(id:)` …) live in the Data layer,
/// in `Endpoint+TMDB.swift`.
struct Endpoint: Equatable {

    /// Relative to the API base URL, without a leading slash, e.g. `"movie/550"`.
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    let headers: [String: String]

    init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:]
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
    }

    /// Builds the `URLRequest`. Uses `URLComponents`, never string
    /// interpolation, so query values are always escaped correctly.
    func makeURLRequest(baseURL: URL) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let finalURL = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        return request
    }
}
