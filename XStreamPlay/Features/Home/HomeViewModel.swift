//
//  HomeViewModel.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 12/01/26.
//

import Foundation
import Combine
import UIKit

final class HomeViewModel {

    // MARK: - Public

    let buckets: [HomeBucketViewModel]

    // MARK: - Init

    init() {
        buckets = HomeViewModel.createBuckets()
    }

    // MARK: - Private

    private static func createBuckets() -> [HomeBucketViewModel] {
        HomeBucketType.allCases.map { type in
            switch type {
            case .trending:
                return HomeBucketViewModel(
                    type: type,
                    title: "Trending",
                    showSeeAll: true,
//                    cellHeight: 190,
                    showPosterTitle: false
                )
            case .popular:
                return HomeBucketViewModel(
                    type: type,
                    title: "Popular Movies",
                    showSeeAll: true,
//                    cellHeight: 230,
                    showPosterTitle: true
                )
            case .upcoming:
                return HomeBucketViewModel(
                    type: type,
                    title: "Upcoming",
                    showSeeAll: false,
//                    cellHeight: 190,
                    showPosterTitle: false
                )
            case .topRated:
                return HomeBucketViewModel(
                    type: type,
                    title: "Top Rated",
                    showSeeAll: true,
//                    cellHeight: 230,
                    showPosterTitle: true
                )
            case .tvShows:
                return HomeBucketViewModel(
                    type: type,
                    title: "Top Rated TVshows",
                    showSeeAll: true,
//                    cellHeight: 230,
                    showPosterTitle: true
                )
            }
        }
    }
}
