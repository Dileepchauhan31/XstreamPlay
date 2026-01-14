//
//  Storyboard.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 14/01/26.
//

import UIKit

enum Storyboard: String {
    case main = "Main"
    case home = "Home"

    var instance: UIStoryboard {
        UIStoryboard(name: rawValue, bundle: nil)
    }
}

