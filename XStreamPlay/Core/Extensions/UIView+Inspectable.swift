//
//  UIView+Inspectable.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 13/01/26.
//

import UIKit

// MARK: - Interface Builder helpers

/// Corner radius and border settings you can set in the Attributes inspector.
/// The `ib` prefix marks them as Interface Builder properties.
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
