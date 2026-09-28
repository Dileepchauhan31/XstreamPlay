//
//  TMDBMovieRepository.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// The only type that knows titles come from TMDB.
///
/// Its whole job: domain request → `Endpoint` → `APIClient` → DTO → domain
/// entity. It holds no state, so `AppDIContainer` shares one instance.
///
/// The `APIClient` comes in through `init` (constructor injection). That is
/// what lets `TMDBMovieRepositoryTests` run it against a stubbed network.
final class TMDBMovieRepository: MovieListRepository, MovieDetailsRepository {

    private let apiClient: APIClient
    private let images: TMDBImageURLBuilder

    init(apiClient: APIClient, images: TMDBImageURLBuilder = TMDBImageURLBuilder()) {
        self.apiClient = apiClient
        self.images = images
    }

    // MARK: - MovieListRepository

    func fetchMovies(from source: MovieListSource, page: Int) async throws -> MoviePage {
        let response: PageDTO<MovieDTO> = try await apiClient.send(endpoint(for: source, page: page))

        let movies = response.results.map {
            Movie(dto: $0, fallbackMediaType: source.mediaType, images: images)
        }
        return MoviePage(movies: movies, nextPage: response.nextPage)
    }

    // MARK: - MovieDetailsRepository

    func fetchDetails(id: Int, mediaType: MediaType) async throws -> MovieDetails {
        let endpoint: Endpoint
        switch mediaType {
        case .movie:
            endpoint = .movieDetails(movieID: id)
        case .tv:
            endpoint = .tvShowDetails(showID: id)
        }

        let dto: MovieDetailsDTO = try await apiClient.send(endpoint)
        return MovieDetails(dto: dto, images: images)
    }

    // MARK: - Private

    /// Private on purpose: nothing outside the Data layer should know which
    /// TMDB path backs a list.
    private func endpoint(for source: MovieListSource, page: Int) -> Endpoint {
        switch source {
        case .trending:
            return .trendingMovies(page: page)
        case .popular:
            return .popularMovies(page: page)
        case .topRated:
            return .topRatedMovies(page: page)
        case .upcoming:
            return .upcomingMovies(page: page)
        case .popularTVShows:
            return .popularTVShows(page: page)
        case .similar(let movieID, .movie):
            return .similarMovies(movieID: movieID, page: page)
        case .similar(let showID, .tv):
            return .similarTVShows(showID: showID, page: page)
        }
    }
}
