//
//  Storyboard.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 14/01/26.
//

import UIKit

/// Every storyboard in the app. One storyboard per feature, named after its
/// folder in `Features/`.
enum Storyboard: String {
    case splash = "Splash"
    case home = "Home"
    case seeAll = "SeeAll"
    case movieDetails = "MovieDetails"

    var instance: UIStoryboard {
        UIStoryboard(name: rawValue, bundle: nil)
    }
}
