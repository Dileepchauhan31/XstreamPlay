//
//  NetworkManager.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 12/01/26.
//

import Foundation
import Combine

// MARK: - HTTP Method
public enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
    case patch   = "PATCH"
}

// MARK: - Network Error
public enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingFailed
    case serverError(Int)
    case unknown(Error)
}

// MARK: - NetworkManager
public final class NetworkManager {

    public static let shared = NetworkManager()
    private init() {}

    public func request<T: Decodable>(
        url: String,
        method: HTTPMethod,
        headers: [String: String]? = nil,
        body: Encodable? = nil
    ) -> AnyPublisher<T, NetworkError> {

        guard let url = URL(string: url) else {
            print("Invalid URL:", url)
            return Fail(error: .invalidURL)
                .eraseToAnyPublisher()
        }

        //  REQUEST LOG
        print("REQUEST URL:", url.absoluteString)
        print("METHOD:", method.rawValue)
        if let headers = headers {
            print("HEADERS:", headers)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(TMDBConfig.bearerToken)", forHTTPHeaderField: "Authorization")

        headers?.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                print("BODY:", String(data: request.httpBody!, encoding: .utf8) ?? "")
            } catch {
                print("BODY ENCODING ERROR:", error)
                return Fail(error: .unknown(error))
                    .eraseToAnyPublisher()
            }
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output -> Data in

                guard let response = output.response as? HTTPURLResponse else {
                    print("No HTTP Response")
                    throw NetworkError.noData
                }

                // RESPONSE LOG
                print("⬅️ STATUS CODE:", response.statusCode)

                if let json = String(data: output.data, encoding: .utf8) {
                    print("RAW RESPONSE:\n", json)
                }

                guard (200...299).contains(response.statusCode) else {
                    print("SERVER ERROR:", response.statusCode)
                    throw NetworkError.serverError(response.statusCode)
                }

                return output.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in

                //  ERROR LOG
                if let decodingError = error as? DecodingError {
                    print("DECODING ERROR:", decodingError)
                    return .decodingFailed
                }

                if let networkError = error as? NetworkError {
                    print("NETWORK ERROR:", networkError)
                    return networkError
                }

                print("UNKNOWN ERROR:", error)
                return .unknown(error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

