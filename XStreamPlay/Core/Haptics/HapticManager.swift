//
//  HapticManager.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 13/01/26.
//

import UIKit

enum FeedbackType {
    case light
    case medium
    case heavy
    case selection
}

final class FeedbackManager {

    static func trigger(_ type: FeedbackType) {
        switch type {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
}

