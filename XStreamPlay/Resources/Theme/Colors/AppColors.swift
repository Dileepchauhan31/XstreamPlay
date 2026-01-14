//
//  AppColors.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 13/01/26.
//

import UIKit

struct AppColors {

    static var appBackground: UIColor {
        UIColor(named: "AppBackground") ?? .systemBackground
    }

    static var surface: UIColor {
        UIColor(named: "Surface") ?? .secondarySystemBackground
    }

    static var tabBarBackground: UIColor {
        UIColor(named: "TabBarBackground") ?? .systemBackground
    }

    static var textPrimary: UIColor {
        UIColor(named: "TextPrimary") ?? .label
    }
}
