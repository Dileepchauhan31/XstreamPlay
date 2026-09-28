//
//  Log.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 01/09/26.
//

import Foundation
import OSLog

/// Structured, category-based logging built on OSLog.
///
/// Replaces `print()` throughout the app. Three reasons this matters:
///
/// 1. **It is free in release builds.** `Logger.debug` is compiled out of the
///    hot path unless a debugger or Console.app is attached, whereas `print`
///    formats and writes a string on every call, including in production.
/// 2. **Privacy is explicit.** Interpolated values are redacted by default;
///    anything public must be marked so deliberately. A token can never leak
///    into a device log by accident.
/// 3. **It is filterable.** Console.app and `log stream` can filter by
///    subsystem and category, so network traffic can be isolated from UI noise.
enum Log {

    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.xstreamplay"

    /// Requests, responses, status codes, decoding failures.
    static let network = Logger(subsystem: subsystem, category: "network")

    /// View lifecycle, navigation, user-initiated actions.
    static let ui = Logger(subsystem: subsystem, category: "ui")

    /// Core Data, caches, disk access.
    static let persistence = Logger(subsystem: subsystem, category: "persistence")

    /// App launch, configuration, anything cross-cutting.
    static let app = Logger(subsystem: subsystem, category: "app")

    /// Image loading and cache hits/misses.
    static let images = Logger(subsystem: subsystem, category: "images")
}
