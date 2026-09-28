//
//  JSONDecoder+SnakeCase.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

extension JSONDecoder {

    /// The one decoder the app uses for API responses.
    ///
    /// `.convertFromSnakeCase` turns `poster_path` into `posterPath`, so DTOs
    /// need no `CodingKeys` and no hand-written `init(from:)`.
    static var convertingSnakeCase: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
