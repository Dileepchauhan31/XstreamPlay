//
//  HomeBucketViewModel.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 12/01/26.
//

import Foundation
import Combine
import UIKit

final class HomeBucketViewModel {

    let type: HomeBucketType
    let title: String
    let showSeeAll: Bool
//    let cellHeight: CGFloat
    let showPosterTitle: Bool

    @Published private(set) var movies: [Movie] = []

    // MARK: - Pagination
    private var page = 1
    private var isLoading = false
    private var canLoadMore = true

    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        type: HomeBucketType,
        title: String,
        showSeeAll: Bool = true,
//        cellHeight: CGFloat = 190,
        showPosterTitle: Bool = false
    ) {
        self.type = type
        self.title = title
        self.showSeeAll = showSeeAll
//        self.cellHeight = cellHeight
        self.showPosterTitle = showPosterTitle
    }

    // MARK: - API

    func fetchNextPage() {
        guard !isLoading, canLoadMore else { return }
        isLoading = true

        NetworkManager.shared
            .request(
                url: type.endpoint(page: page),
                method: .get
            )
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure = completion {
                        self?.canLoadMore = false
                    }
                },
                receiveValue: { [weak self] (response: TMDBListResponse<Movie>) in
                    guard let self else { return }

                    self.page += 1
                    self.canLoadMore = !response.results.isEmpty
                    self.movies.append(contentsOf: response.results)
                }
            )
            .store(in: &cancellables)
    }
}
