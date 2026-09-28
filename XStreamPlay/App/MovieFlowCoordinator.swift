//
//  MovieFlowCoordinator.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import UIKit

/// Navigation for the browsing flow: Home → Details → See All → Details …
///
/// Every `push` in the app happens in this file. A screen asks for navigation
/// through `MovieDetailsRouting` / `SeeAllRouting`; this class answers by
/// asking `AppDIContainer` for the next screen and pushing it.
@MainActor
final class MovieFlowCoordinator: Coordinator {

    private let navigationController: UINavigationController
    private let container: AppDIContainer

    init(navigationController: UINavigationController, container: AppDIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        configureNavigationBar()
        let home = container.makeHomeViewController(router: self)
        prepare(home)
        navigationController.setViewControllers([home], animated: false)
    }

    // MARK: - Private

    /// Bar-wide style, set once. Screens change only their own
    /// `navigationItem`, never the shared bar.
    private func configureNavigationBar() {
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.tintColor = .white
    }

    /// Back buttons show only the chevron, without the previous screen's title.
    private func prepare(_ viewController: UIViewController) {
        if #available(iOS 14.0, *) {
            viewController.navigationItem.backButtonDisplayMode = .minimal
        } else {
            viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
    }

    private func push(_ viewController: UIViewController) {
        prepare(viewController)
        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - MovieDetailsRouting

extension MovieFlowCoordinator: MovieDetailsRouting {

    func showMovieDetails(for movie: Movie) {
        push(container.makeMovieDetailsViewController(for: movie, router: self))
    }
}

// MARK: - SeeAllRouting

extension MovieFlowCoordinator: SeeAllRouting {

    func showSeeAll(title: String, source: MovieListSource) {
        push(container.makeSeeAllViewController(title: title, source: source, router: self))
    }
}
