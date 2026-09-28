//
//  URLSessionAPIClient.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 01/09/26.
//

import Foundation

/// The one type in the app that knows `URLSession` exists.
///
/// Constructed once at the composition root and injected downward. It holds no
/// global state and has no `shared` instance, so a test can create as many
/// independently-configured clients as it needs.
final class URLSessionAPIClient: APIClient {

    private let session: URLSession
    private let baseURL: URL
    private let accessToken: String
    private let decoder: JSONDecoder

    /// - Parameters:
    ///   - session: Injected so tests can pass a session backed by `StubURLProtocol`.
    ///   - baseURL: Injected so tests never depend on `AppEnvironment`.
    init(
        session: URLSession = .shared,
        baseURL: URL = AppEnvironment.apiBaseURL,
        accessToken: String = AppEnvironment.tmdbAccessToken,
        decoder: JSONDecoder = .tmdb
    ) {
        self.session = session
        self.baseURL = baseURL
        self.accessToken = accessToken
        self.decoder = decoder
    }

    func send<Response: Decodable>(_ endpoint: Endpoint, as type: Response.Type) async throws -> Response {
        let request = try endpoint.urlRequest(baseURL: baseURL, accessToken: accessToken)

        Log.network.debug("→ \(endpoint.method.rawValue, privacy: .public) /\(endpoint.path, privacy: .public)")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            Log.network.error("✕ transport failure on /\(endpoint.path, privacy: .public): \(error.code.rawValue)")
            throw APIError.transport(code: error.code)
        } catch {
            throw APIError.unknown(description: String(describing: error))
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        Log.network.debug("← \(http.statusCode, privacy: .public) /\(endpoint.path, privacy: .public) \(data.count, privacy: .public)B")

        guard (200...299).contains(http.statusCode) else {
            let error = APIError(status: http.statusCode, headers: http.allHeaderFields)
            Log.network.error("✕ \(http.statusCode, privacy: .public) on /\(endpoint.path, privacy: .public)")
            throw error
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch let error as DecodingError {
            let mapped = APIError(from: error)
            Log.network.error("✕ decode \(String(describing: Response.self), privacy: .public): \(mapped.userMessage, privacy: .public)")
            throw mapped
        } catch {
            throw APIError.unknown(description: String(describing: error))
        }
    }
}
