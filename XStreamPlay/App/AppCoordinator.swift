//
//  AppCoordinator.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import UIKit

/// Decides what fills the window: the splash first, then the main flow.
///
/// This replaces the splash screen reaching into `UIApplication` to find a
/// window and replace its root. The coordinator already owns the window, so no
/// lookup is needed.
@MainActor
final class AppCoordinator: Coordinator {

    private let window: UIWindow
    private let container: AppDIContainer

    /// Kept alive here; a coordinator nobody holds would be deallocated and
    /// every screen's `router` (a weak reference) would become `nil`.
    private var movieFlowCoordinator: MovieFlowCoordinator?

    init(window: UIWindow, container: AppDIContainer) {
        self.window = window
        self.container = container
    }

    func start() {
        window.rootViewController = container.makeSplashViewController { [weak self] in
            self?.showMainFlow()
        }
        window.makeKeyAndVisible()
    }

    private func showMainFlow() {
        let navigationController = UINavigationController()
        let coordinator = MovieFlowCoordinator(navigationController: navigationController, container: container)
        movieFlowCoordinator = coordinator
        coordinator.start()

        window.rootViewController = navigationController
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
}
