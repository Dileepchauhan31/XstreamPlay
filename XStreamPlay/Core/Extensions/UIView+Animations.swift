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

//MARK: - radius and its colors 

extension UIView {

    @IBInspectable var ibCornerRadius: CGFloat {
        get {
            layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var ibBorderWidth: CGFloat {
        get {
            layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

  
    @IBInspectable var ibBorderColor: UIColor {
        get {
            UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }

    @IBInspectable var ibMakeCircle: Bool {
        get { false }
        set {
            if newValue {
                DispatchQueue.main.async {
                    self.layer.cornerRadius = self.bounds.height / 2
                    self.layer.masksToBounds = true
                }
            }
        }
    }
}
