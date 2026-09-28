//
//  AppDIContainer.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import UIKit

/// Creates every service and screen in the app, and connects them.
///
/// This is the ONLY place that creates real services such as
/// `URLSessionAPIClient`. Every other class gets what it needs through `init`.
///
/// - Want to replace a service? Change one line here.
/// - Want to know what a screen needs? Read its `make…` function below.
@MainActor
final class AppDIContainer {

    private let environment: AppEnvironment

    init(environment: AppEnvironment) {
        self.environment = environment
    }

    // MARK: - Shared services (one instance each, created on first use)

    private lazy var apiClient: APIClient = URLSessionAPIClient(
        baseURL: environment.apiBaseURL,
        accessToken: environment.accessToken
    )

    private lazy var movieRepository = TMDBMovieRepository(
        apiClient: apiClient,
        images: TMDBImageURLBuilder(baseURL: environment.imageBaseURL)
    )

    private lazy var haptics: HapticFeedbackProviding = UIKitHapticFeedbackProvider()

    // MARK: - Screens

    func makeSplashViewController(onFinish: @escaping () -> Void) -> VideoSplashViewController {
        let videoURL = Bundle.main.url(forResource: "splashVideo", withExtension: "mp4")

        return Storyboard.splash.instance.instantiate { coder in
            VideoSplashViewController(coder: coder, videoURL: videoURL, onFinish: onFinish)
        }
    }

    func makeHomeViewController(router: HomeViewController.Router) -> HomeViewController {
        let viewModel = HomeViewModel(rails: MovieRail.homeScreen, repository: movieRepository)
        let haptics = self.haptics

        return Storyboard.home.instance.instantiate { coder in
            HomeViewController(coder: coder, viewModel: viewModel, router: router, haptics: haptics)
        }
    }

    func makeSeeAllViewController(
        title: String,
        source: MovieListSource,
        router: SeeAllViewController.Router
    ) -> SeeAllViewController {
        let viewModel = SeeAllViewModel(title: title, source: source, repository: movieRepository)
        let haptics = self.haptics

        return Storyboard.seeAll.instance.instantiate { coder in
            SeeAllViewController(coder: coder, viewModel: viewModel, router: router, haptics: haptics)
        }
    }

    func makeMovieDetailsViewController(
        for movie: Movie,
        router: MovieDetailsViewController.Router
    ) -> MovieDetailsViewController {
        let viewModel = MovieDetailsViewModel(
            movieID: movie.id,
            mediaType: movie.mediaType,
            detailsRepository: movieRepository,
            listRepository: movieRepository
        )
        let haptics = self.haptics

        return Storyboard.movieDetails.instance.instantiate { coder in
            MovieDetailsViewController(coder: coder, viewModel: viewModel, router: router, haptics: haptics)
        }
    }
}
