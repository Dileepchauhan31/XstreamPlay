//
//  AppAlert.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 21/01/26.
//

import Foundation
import UIKit

enum AlertType {
    case error
    case success
    case warning
    case info
}

final class AppAlert {
    
    static func show(
        on viewController: UIViewController,
        title: String? = "Something went wrong",
        message: String? = "An unexpected error occurred. Please try again.",
        type: AlertType = .error,
        showRetry: Bool = false,
        retryHandler: (() -> Void)? = nil,
        okHandler: (() -> Void)? = nil ) {
        
        let alert = UIAlertController(title: title,message: message,preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            okHandler?()}
        alert.addAction(okAction)
        
        if showRetry {
            let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
                retryHandler?()
            }
            alert.addAction(retryAction)
        }
        
        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }
}
