//
//  UIView+Animations.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 13/01/26.
//

import UIKit

extension UIView {

    func pop() {
        UIView.animate(withDuration: 0.12,
                       animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.18, delay: 0.13,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0.8,
                           animations: {
                self.transform = .identity
            })
        }
    }

    func press() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
    }

    func releasePress() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
}

