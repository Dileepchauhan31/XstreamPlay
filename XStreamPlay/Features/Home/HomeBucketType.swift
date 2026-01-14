//
//  HomeBucketType.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 12/01/26.
//

import Foundation

enum HomeBucketType: CaseIterable {
    case trending, popular, topRated, upcoming, tvShows

    var title: String {
        switch self {
        case .trending: return "Trending Now"
        case .popular: return "Popular Movies"
        case .topRated: return "Top Rated"
        case .upcoming: return "Upcoming"
        case .tvShows: return "Popular TV Shows"
        }
    }

    func endpoint(page: Int) -> String {
        switch self {
        case .trending:
            return "\(TMDBConfig.baseURL)/trending/movie/week?api_key=\(TMDBConfig.apiKey)&page=\(page)"
        case .popular:
            return "\(TMDBConfig.baseURL)/movie/popular?api_key=\(TMDBConfig.apiKey)&page=\(page)"
        case .topRated:
            return "\(TMDBConfig.baseURL)/movie/top_rated?api_key=\(TMDBConfig.apiKey)&page=\(page)"
        case .upcoming:
            return "\(TMDBConfig.baseURL)/movie/upcoming?api_key=\(TMDBConfig.apiKey)&page=\(page)"
        case .tvShows:
            return "\(TMDBConfig.baseURL)/tv/popular?api_key=\(TMDBConfig.apiKey)&page=\(page)"
        }
    }
}

