//
//  StoryboardIdentifiable.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 14/01/26.
//


import UIKit

protocol StoryboardIdentifiable {
    static var storyboardID: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardID: String {
        String(describing: self)
    }
}
