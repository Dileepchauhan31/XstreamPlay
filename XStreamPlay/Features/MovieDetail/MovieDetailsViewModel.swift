//
//  MovieDetailsViewModel.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 20/01/26.
//

import Foundation
import Combine

final class MovieDetailsViewModel {

    // MARK: - Published (UI observes these)

    @Published private(set) var movieDetails: Model_MovieDetails?
    @Published private(set) var moreLikeThis: TMDBListResponse?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Movie details

    /// - TODO: Week 4 replaces both calls below with a single request using
    ///   `Endpoint.movieDetail(id:)`, which folds videos, credits,
    ///   recommendations, images, certifications and watch providers into one
    ///   round trip via `append_to_response`.
    func fetchMovieDetails(movieId: Int) {
        isLoading = true
        errorMessage = nil

        NetworkManager.shared
            .request(url: "\(TMDBConfig.baseURL)/movie/\(movieId)", method: .get)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.userMessage
                        Log.network.error("Detail \(movieId, privacy: .public) failed")
                    }
                },
                receiveValue: { [weak self] (response: Model_MovieDetails) in
                    self?.movieDetails = response
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - More like this

    func fetchSimilarContent(movieId: Int, page: Int = 1) {
        NetworkManager.shared
            .request(url: "\(TMDBConfig.baseURL)/movie/\(movieId)/similar?page=\(page)", method: .get)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        // A missing "More like this" rail is not worth surfacing
                        // to the user — the rest of the screen is still valid.
                        Log.network.error("Similar titles for \(movieId, privacy: .public) failed")
                    }
                },
                receiveValue: { [weak self] (response: TMDBListResponse) in
                    self?.moreLikeThis = response
                }
            )
            .store(in: &cancellables)
    }
}
