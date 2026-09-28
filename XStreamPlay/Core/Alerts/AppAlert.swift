//
//  AppAlert.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 21/01/26.
//

import UIKit

/// Shows a standard alert with OK and an optional Retry button.
///
///     AppAlert.show(on: self, message: errorMessage) { [weak self] in self?.reload() }
@MainActor
enum AppAlert {

    /// - Parameter retryHandler: when not `nil`, a Retry button is added and
    ///   calls it.
    static func show(
        on viewController: UIViewController,
        title: String = "Something went wrong",
        message: String,
        retryHandler: (() -> Void)? = nil
    ) {
        // Don't stack alerts: one failing rail per section would show five.
        guard viewController.presentedViewController == nil else { return }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))

        if let retryHandler {
            alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in retryHandler() })
        }
        viewController.present(alert, animated: true)
    }
}
