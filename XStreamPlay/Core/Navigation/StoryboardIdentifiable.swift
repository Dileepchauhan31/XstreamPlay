//
//  StoryboardIdentifiable.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 14/01/26.
//

import UIKit

/// A view controller whose Storyboard ID equals its class name.
///
/// In Interface Builder, set the scene's Storyboard ID to the class name
/// (e.g. `HomeViewController`).
protocol StoryboardIdentifiable {
    static var storyboardID: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardID: String {
        String(describing: self)
    }
}
