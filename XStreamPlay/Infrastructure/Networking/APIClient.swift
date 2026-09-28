//
//  APIClient.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// Sends an `Endpoint` and decodes the JSON response.
///
/// Repositories depend on this protocol, not on `URLSession`, so tests can
/// swap the transport (see `StubURLProtocol` in the test target).
protocol APIClient {
    func send<Response: Decodable>(_ endpoint: Endpoint) async throws -> Response
}
