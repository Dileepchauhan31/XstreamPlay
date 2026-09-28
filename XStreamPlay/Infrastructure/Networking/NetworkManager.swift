//
//  NetworkManager.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 12/01/26.
//

import Foundation
import Combine

/// Transitional Combine facade over the legacy absolute-URL call style.
///
/// - Important: This type is **scheduled for deletion**. New code must depend on
///   `APIClient` and build requests from `Endpoint`, not pass URL strings around.
///   It survives only so the existing view models keep compiling while they are
///   migrated one at a time.
///
/// What changed here in Week 1:
/// - The bearer token now comes from `AppEnvironment`, not a source literal.
/// - `print()` of every raw response body is gone, replaced by OSLog at debug level.
/// - Errors map onto the shared `APIError` set instead of a parallel enum.
///
/// - TODO: Remove once Home, SeeAll and MovieDetails use `APIClient`.
final class NetworkManager {

    static let shared = NetworkManager()

    private let session: URLSession
    private let accessToken: String

    /// Legacy models (`Model_Result`, `Model_MovieDetails`, …) declare explicit
    /// snake_case `CodingKeys`, so they must be decoded **without**
    /// `.convertFromSnakeCase`. New DTOs use `JSONDecoder.tmdb` instead.
    private let legacyDecoder = JSONDecoder()

    init(session: URLSession = .shared, accessToken: String = AppEnvironment.tmdbAccessToken) {
        self.session = session
        self.accessToken = accessToken
    }

    func request<T: Decodable>(
        url urlString: String,
        method: HTTPMethod,
        headers: [String: String]? = nil,
        body: Encodable? = nil
    ) -> AnyPublisher<T, APIError> {

        guard let url = URL(string: urlString) else {
            return Fail(error: .invalidURL(urlString)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        if let body {
            do {
                request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                return Fail(error: .unknown(description: "Request body could not be encoded"))
                    .eraseToAnyPublisher()
            }
        }

        Log.network.debug("→ \(method.rawValue, privacy: .public) \(url.path, privacy: .public)")

        return session.dataTaskPublisher(for: request)
            .tryMap { output -> Data in
                guard let http = output.response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }

                Log.network.debug("← \(http.statusCode, privacy: .public) \(url.path, privacy: .public)")

                guard (200...299).contains(http.statusCode) else {
                    throw APIError(status: http.statusCode, headers: http.allHeaderFields)
                }
                return output.data
            }
            .decode(type: T.self, decoder: legacyDecoder)
            .mapError { APIError(from: $0) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
