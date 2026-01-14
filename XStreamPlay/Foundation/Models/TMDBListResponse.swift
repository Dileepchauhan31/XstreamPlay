//
//  TMDBListResponse.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 12/01/26.
//

import Foundation

struct TMDBListResponse<T: Decodable>: Decodable {
    let page: Int
    let results: [T]
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
    }
}
