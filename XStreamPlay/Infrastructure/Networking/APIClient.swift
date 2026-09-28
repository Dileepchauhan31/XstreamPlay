//
//  APIClient.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 01/09/26.
//

import Foundation

/// The seam between the app and the network.
///
/// Everything above this protocol depends on the abstraction; only
/// `URLSessionAPIClient` depends on `URLSession`. That single indirection is
/// what makes the rest of the app unit-testable — a test injects a stub
/// conforming to `APIClient` and never touches the network.
protocol APIClient {

    /// Sends one endpoint and decodes the response body.
    func send<Response: Decodable>(_ endpoint: Endpoint, as type: Response.Type) async throws -> Response
}

extension APIClient {

    /// Type-inferred convenience, so call sites read
    /// `let page: PageDTO<MovieDTO> = try await client.send(.trending())`.
    func send<Response: Decodable>(_ endpoint: Endpoint) async throws -> Response {
        try await send(endpoint, as: Response.self)
    }
}

// MARK: - Decoder

extension JSONDecoder {

    /// The decoder used by `APIClient` and the new `*DTO` types.
    ///
    /// - Warning: `.convertFromSnakeCase` transforms the *incoming JSON key*
    ///   before matching it against `CodingKeys`. That means a DTO must declare
    ///   `genreIds`, not `genre_ids` — and it means the legacy `Model_*` types,
    ///   whose `CodingKeys` spell out snake_case raw values, must keep using a
    ///   plain decoder. Both live side by side until the migration finishes.
    static let tmdb: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
