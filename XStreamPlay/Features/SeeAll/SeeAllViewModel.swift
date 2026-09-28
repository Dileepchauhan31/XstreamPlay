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

    @Published private(set) var movies: [Model_Result] = []
    @Published private(set) var errorMessage: String?

    // MARK: - Pagination

    private var page = 1
    private var isLoading = false
    private var canLoadMore = true

    // MARK: - Combine

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(title: String, endpointProvider: @escaping (Int) -> String) {
        self.title = title
        self.endpointProvider = endpointProvider
    }

    // MARK: - API

    func fetchNextPage() {
        guard !isLoading, canLoadMore else { return }

        isLoading = true
        errorMessage = nil

        NetworkManager.shared
            .request(url: endpointProvider(page), method: .get)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    self.isLoading = false

                    if case .failure(let error) = completion {
                        // Stop paginating on an unrecoverable failure, but allow
                        // another attempt when a retry could plausibly succeed.
                        self.canLoadMore = error.isRetryable
                        self.errorMessage = error.userMessage
                        Log.network.error("SeeAll '\(self.title, privacy: .public)' page failed")
                    }
                },
                receiveValue: { [weak self] (response: TMDBListResponse) in
                    guard let self else { return }

                    // Previously `response.results!` — a guaranteed crash on any
                    // empty or malformed page.
                    let newItems = response.results ?? []

                    self.page += 1
                    self.canLoadMore = !newItems.isEmpty
                    self.movies.append(contentsOf: newItems)
                }
            )
            .store(in: &cancellables)
    }
}
