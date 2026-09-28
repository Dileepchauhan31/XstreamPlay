//
//  SceneDelegate.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 12/01/26.
//

import UIKit

/// Creates the window and hands it to `AppCoordinator`.
///
/// This is where the app starts: `AppDIContainer` is built once here and
/// every screen and service comes from it.
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    /// Kept alive for as long as the scene exists.
    private var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let container = AppDIContainer(environment: .load())
        let coordinator = AppCoordinator(window: window, container: container)

        self.window = window
        self.appCoordinator = coordinator
        coordinator.start()
    }
}
