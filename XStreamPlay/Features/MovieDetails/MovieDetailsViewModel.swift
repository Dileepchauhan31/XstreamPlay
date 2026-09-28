//
//  MovieDetailsViewModel.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 20/01/26.
//

import Combine
import Foundation

/// State for the details screen: the title's details plus a More Like This rail.
@MainActor
final class MovieDetailsViewModel {

    // MARK: - Output

    @Published private(set) var content: MovieDetailsContent?
    @Published private(set) var moreLikeThis: MovieRailContent
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    // MARK: - Dependencies

    private let movieID: Int
    private let mediaType: MediaType
    private let detailsRepository: MovieDetailsRepository
    private let similarLoader: PaginatedMovieLoader

    // MARK: - Init

    init(
        movieID: Int,
        mediaType: MediaType,
        detailsRepository: MovieDetailsRepository,
        listRepository: MovieListRepository
    ) {
        self.movieID = movieID
        self.mediaType = mediaType
        self.detailsRepository = detailsRepository

        let rail = MovieRail.moreLikeThis(movieID: movieID, mediaType: mediaType)
        self.moreLikeThis = MovieRailContent(rail: rail, movies: [])
        self.similarLoader = PaginatedMovieLoader(source: rail.source, repository: listRepository)
    }

    // MARK: - Loading

    /// Loads the details and the first page of similar titles at the same
    /// time. Also used for Retry.
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        async let similarTitles: Void = loadSimilarIfNeeded()

        do {
            let details = try await detailsRepository.fetchDetails(id: movieID, mediaType: mediaType)
            content = Self.makeContent(from: details)
        } catch {
            let apiError = APIError(from: error)
            if apiError != .cancelled {
                errorMessage = apiError.userMessage
            }
        }

        await similarTitles
    }

    /// Call when a poster in More Like This is about to appear.
    func loadMoreSimilarIfNeeded(displayedIndex: Int) async {
        await similarLoader.loadMoreIfNeeded(displayedIndex: displayedIndex)
        publishSimilarTitles()
    }

    // MARK: - Formatting

    /// Pure function: same input, same output. Tested directly in
    /// `MovieDetailsViewModelTests`.
    static func makeContent(from details: MovieDetails) -> MovieDetailsContent {
        var subtitleParts = [String]()
        if !details.genres.isEmpty {
            subtitleParts.append(details.genres.joined(separator: " • "))
        }
        subtitleParts.append(details.releaseYear ?? "N/A")
        subtitleParts.append(details.isAdult ? "18+" : "U/A")

        let audioLanguages = details.spokenLanguages.isEmpty
            ? nil
            : "Audio Available in: " + details.spokenLanguages.joined(separator: ", ")

        return MovieDetailsContent(
            title: details.title,
            subtitle: subtitleParts.joined(separator: " • "),
            overview: details.overview,
            audioLanguages: audioLanguages,
            heroImageURL: details.heroImageURL
        )
    }

    // MARK: - Private

    private func loadSimilarIfNeeded() async {
        guard similarLoader.movies.isEmpty else { return }
        await similarLoader.loadNextPage()
        publishSimilarTitles()
    }

    private func publishSimilarTitles() {
        guard moreLikeThis.movies != similarLoader.movies else { return }
        moreLikeThis.movies = similarLoader.movies
    }
}
