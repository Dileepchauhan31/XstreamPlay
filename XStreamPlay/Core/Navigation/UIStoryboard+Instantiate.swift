//
//  UIStoryboard+Instantiate.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 15/01/26.
//

import UIKit

extension UIStoryboard {

    func instantiate<T: UIViewController & StoryboardIdentifiable>() -> T {
        guard let vc = instantiateViewController(
            withIdentifier: T.storyboardID
        ) as? T else {
            fatalError("Could not instantiate \(T.storyboardID)")
        }
        return vc
    }
}



