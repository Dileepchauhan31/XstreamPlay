//
//  PageDTO.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 01/09/26.
//

import Foundation

/// TMDB's paginated envelope, generic over its payload.
///
/// One type replaces `TMDBListResponse`, a would-be `TVListResponse`, a
/// would-be `PersonListResponse`, and every other list wrapper.
///
/// Decoding is deliberately forgiving about *structure* and strict about
/// *content*: a missing `results` key yields an empty page rather than throwing,
/// because an empty rail is a normal product state, not an error. Everything
/// else is defaulted so a shape change at TMDB degrades a rail instead of
/// crashing a screen.
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        page         = try container.decodeIfPresent(Int.self, forKey: .page) ?? 1
        results      = try container.decodeIfPresent([Item].self, forKey: .results) ?? []
        totalPages   = try container.decodeIfPresent(Int.self, forKey: .totalPages) ?? 1
        totalResults = try container.decodeIfPresent(Int.self, forKey: .totalResults) ?? 0
    }

    /// True when there is nothing further to fetch — the condition pagination
    /// should test, rather than "did the last page come back empty".
    var isLastPage: Bool { page >= totalPages || results.isEmpty }

    /// The page number to request next, or `nil` at the end of the list.
    var nextPage: Int? { isLastPage ? nil : page + 1 }
}

extension PageDTO: Equatable where Item: Equatable {}
