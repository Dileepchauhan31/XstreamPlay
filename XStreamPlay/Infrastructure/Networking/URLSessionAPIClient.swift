//
//  URLSessionAPIClient.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// The only type in the app that talks to `URLSession`.
///
/// Replaces the old `NetworkManager.shared` singleton. `AppDIContainer`
/// creates one instance and passes it to repositories through `init`.
final class URLSessionAPIClient: APIClient {

    private let session: URLSession
    private let baseURL: URL
    private let accessToken: String
    private let decoder: JSONDecoder

    init(
        session: URLSession = .shared,
        baseURL: URL,
        accessToken: String,
        decoder: JSONDecoder = .convertingSnakeCase
    ) {
        self.session = session
        self.baseURL = baseURL
        self.accessToken = accessToken
        self.decoder = decoder
    }

    func send<Response: Decodable>(_ endpoint: Endpoint) async throws -> Response {
        // A missing token can only give a 401, so fail fast with a clear log
        // instead of sending a request we know will be rejected.
        guard !accessToken.isEmpty else {
            Log.network.error("No TMDB access token. Add TMDB_ACCESS_TOKEN to Secrets.xcconfig.")
            throw APIError.unauthorized
        }

        var request = try endpoint.makeURLRequest(baseURL: baseURL)
        // Auth goes in a header, never in the query string: URLs end up in logs.
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        Log.network.debug("\(endpoint.method.rawValue) \(endpoint.path)")

        let data: Data
        let response: URLResponse
        do {
            let result = try await session.responseData(for: request)
            data = result.0
            response = result.1
        } catch {
            throw APIError(from: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            Log.network.error("\(endpoint.path) failed with status \(httpResponse.statusCode)")
            throw APIError(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            Log.network.error("Could not decode \(Response.self) from \(endpoint.path): \(error)")
            throw APIError.decoding
        }
    }
}

// MARK: - iOS 13/14 support

private extension URLSession {

    /// Uses `data(for:)` on iOS 15+. The app still supports iOS 13, so on older
    /// systems this wraps the callback API and forwards task cancellation.
    /// Delete the fallback once the deployment target is iOS 15.
    func responseData(for request: URLRequest) async throws -> (Data, URLResponse) {
        if #available(iOS 15.0, *) {
            return try await data(for: request)
        }

        let taskBox = DataTaskBox()

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let task = dataTask(with: request) { data, response, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if let data, let response {
                        continuation.resume(returning: (data, response))
                    } else {
                        continuation.resume(throwing: URLError(.badServerResponse))
                    }
                }
                taskBox.task = task
                task.resume()
            }
        } onCancel: {
            taskBox.task?.cancel()
        }
    }
}

/// Holds the running task so the cancellation handler can reach it.
private final class DataTaskBox: @unchecked Sendable {
    private let lock = NSLock()
    private var storedTask: URLSessionDataTask?

    var task: URLSessionDataTask? {
        get { lock.lock(); defer { lock.unlock() }; return storedTask }
        set { lock.lock(); defer { lock.unlock() }; storedTask = newValue }
    }
}
