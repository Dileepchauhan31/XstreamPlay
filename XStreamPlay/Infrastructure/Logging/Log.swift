//
//  Log.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation
import os.log

/// The app's loggers, one per area. Use these instead of `print`.
///
///     Log.network.debug("GET movie/550")
///     Log.app.error("Missing TMDB_ACCESS_TOKEN")
///
/// Messages show in Xcode's console and in Console.app, filtered by category.
/// Never log tokens or other secrets.
enum Log {
    static let app = AppLogger(category: "app")
    static let network = AppLogger(category: "network")
    static let ui = AppLogger(category: "ui")
}
