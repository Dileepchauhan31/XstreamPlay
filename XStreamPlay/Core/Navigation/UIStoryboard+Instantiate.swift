//
//  UIStoryboard+Instantiate.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 15/01/26.
//

import UIKit

extension UIStoryboard {

    /// Creates a storyboard screen through your own initializer, so it gets its
    /// dependencies in `init` (constructor injection):
    ///
    ///     Storyboard.home.instance.instantiate { coder in
    ///         HomeViewController(coder: coder, viewModel: viewModel, router: router, haptics: haptics)
    ///     }
    ///
    /// Only `AppDIContainer` should call this.
    func instantiate<ViewController: UIViewController & StoryboardIdentifiable>(
        creator: @escaping (NSCoder) -> ViewController?
    ) -> ViewController {
        instantiateViewController(identifier: ViewController.storyboardID, creator: creator)
    }
}
