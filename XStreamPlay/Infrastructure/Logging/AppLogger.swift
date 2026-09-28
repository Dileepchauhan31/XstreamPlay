//
//  AppLogger.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation
import os.log

/// A small wrapper around `OSLog` that works on iOS 13
/// (`os.Logger` needs iOS 14). Get one from `Log`, don't create your own.
struct AppLogger {

    private let log: OSLog

    init(subsystem: String = Bundle.main.bundleIdentifier ?? "XStreamPlay", category: String) {
        log = OSLog(subsystem: subsystem, category: category)
    }

    /// Details that help while developing. Not stored on the device.
    func debug(_ message: String) {
        os_log("%{public}@", log: log, type: .debug, message)
    }

    func info(_ message: String) {
        os_log("%{public}@", log: log, type: .info, message)
    }

    /// Something failed. Stored on the device, so keep it free of secrets.
    func error(_ message: String) {
        os_log("%{public}@", log: log, type: .error, message)
    }
}
