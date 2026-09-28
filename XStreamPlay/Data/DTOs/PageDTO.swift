//
//  PageDTO.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 01/09/26.
//

import Foundation

/// TMDB's paginated envelope, generic over its items.
///
/// Missing keys fall back to defaults instead of throwing: an empty rail is a
/// normal state, not a crash.
struct PageDTO<Item: Decodable>: Decodable {

    let page: Int
    let results: [Item]
    let totalPages: Int
    let totalResults: Int

    init(page: Int = 1, results: [Item] = [], totalPages: Int = 1, totalResults: Int = 0) {
        self.page = page
        self.results = results
        self.totalPages = totalPages
        self.totalResults = totalResults
    }

    /// Written by hand because this type has its own `init(from:)`.
    /// Camel case on purpose: the decoder turns `total_pages` into
    /// `totalPages` before matching these keys.
    private enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages
        case totalResults
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        page = try container.decodeIfPresent(Int.self, forKey: .page) ?? 1
        results = try container.decodeIfPresent([Item].self, forKey: .results) ?? []
        totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages) ?? 1
        totalResults = try container.decodeIfPresent(Int.self, forKey: .totalResults) ?? 0
    }

    /// Uses the server's `total_pages`, not "did the last page come back empty".
    var isLastPage: Bool { page >= totalPages || results.isEmpty }

    /// The page to request next, or `nil` at the end of the list.
    var nextPage: Int? { isLastPage ? nil : page + 1 }
}

extension PageDTO: Equatable where Item: Equatable {}
