//
//  HapticFeedbackProviding.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 13/01/26.
//

import Foundation

/// Plays a haptic tap.
///
/// A protocol instead of a static call, so screens get it through `init` and
/// tests can pass a fake that records calls instead of buzzing the device.
protocol HapticFeedbackProviding {
    func play(_ feedback: HapticFeedback)
}
