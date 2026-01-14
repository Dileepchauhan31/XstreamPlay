//
//  Font+Theme.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 13/01/26.
//

import Foundation
import UIKit

// MARK: - Lato Font Family
extension UIFont {

    static func latoRegular(size: CGFloat) -> UIFont {
        UIFont(name: "Lato-Regular", size: size)
        ?? .systemFont(ofSize: size)
    }

    static func latoBold(size: CGFloat) -> UIFont {
        UIFont(name: "Lato-Bold", size: size)
        ?? .systemFont(ofSize: size, weight: .bold)
    }

    static func latoBlack(size: CGFloat) -> UIFont {
        UIFont(name: "Lato-Black", size: size)
        ?? .systemFont(ofSize: size, weight: .heavy)
    }

    static func latoLight(size: CGFloat) -> UIFont {
        UIFont(name: "Lato-Light", size: size)
        ?? .systemFont(ofSize: size, weight: .light)
    }

    static func latoThin(size: CGFloat) -> UIFont {
        UIFont(name: "Lato-Thin", size: size)
        ?? .systemFont(ofSize: size, weight: .thin)
    }

    static func latoItalic(size: CGFloat) -> UIFont {
        UIFont(name: "Lato-Italic", size: size)
        ?? .italicSystemFont(ofSize: size)
    }

    static func latoBoldItalic(size: CGFloat) -> UIFont {
        UIFont(name: "Lato-BoldItalic", size: size)
        ?? .systemFont(ofSize: size, weight: .bold).withItalic()
    }

    static func latoBlackItalic(size: CGFloat) -> UIFont {
        UIFont(name: "Lato-BlackItalic", size: size)
        ?? .systemFont(ofSize: size, weight: .heavy).withItalic()
    }

    static func latoLightItalic(size: CGFloat) -> UIFont {
        UIFont(name: "Lato-LightItalic", size: size)
        ?? .systemFont(ofSize: size, weight: .light).withItalic()
    }

    static func latoThinItalic(size: CGFloat) -> UIFont {
        UIFont(name: "Lato-ThinItalic", size: size)
        ?? .systemFont(ofSize: size, weight: .thin).withItalic()
    }
}

// MARK: - UIFont Italic Helper (REQUIRED)
private extension UIFont {

    func withItalic() -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(.traitItalic) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
