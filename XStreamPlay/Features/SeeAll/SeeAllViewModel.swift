//
//  SeeAllViewModel.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 15/01/26.
//

import Foundation
import Combine

final class SeeAllViewModel {

    // MARK: - Properties
    let title: String
    let endpointProvider: (Int) -> String

    @Published private(set) var movies: [Movie] = []

    // MARK: - Pagination
    private var page = 1
    private var isLoading = false
    private var canLoadMore = true

    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(
        title: String,
        endpointProvider: @escaping (Int) -> String
    ) {
        self.title = title
        self.endpointProvider = endpointProvider
    }

    // MARK: - API
    func fetchNextPage() {
        guard !isLoading, canLoadMore else { return }

        isLoading = true

        NetworkManager.shared
            .request(
                url: endpointProvider(page), // ✅ String
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
