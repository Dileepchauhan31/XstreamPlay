//
//  MovieDetailsViewModel.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 20/01/26.
//

import Foundation
import Combine

final class MovieDetailsViewModel {
    
    // MARK: - Published Properties (UI Observes These)
    @Published var movieDetails: Model_MovieDetails?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - API Call
    func fetchMovieDetails(movieId: Int) {
        isLoading = true
        errorMessage = nil
        
        let url = "https://api.themoviedb.org/3/movie/\(movieId)"
        
        NetworkManager.shared.request(url: url,method: .get)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case let .failure(error) = completion {
                    self.errorMessage = error.userMessage
                }
            } receiveValue: { [weak self] (response: Model_MovieDetails) in
                self?.movieDetails = response
            }
            .store(in: &cancellables)
    }
}
