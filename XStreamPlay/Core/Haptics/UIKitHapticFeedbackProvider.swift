//
//  UIKitHapticFeedbackProvider.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 13/01/26.
//

import UIKit

/// The real `HapticFeedbackProviding`, using UIKit's feedback generators.
/// Created once by `AppDIContainer`.
final class UIKitHapticFeedbackProvider: HapticFeedbackProviding {

    func play(_ feedback: HapticFeedback) {
        switch feedback {
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
