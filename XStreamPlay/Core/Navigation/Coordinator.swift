//
//  Coordinator.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// An object that owns a navigation flow: which screen shows first and what
/// happens when the user moves between screens.
///
/// View controllers never push or present each other. They call a router
/// protocol (see `Features/Shared/Routing.swift`) and a coordinator does it.
@MainActor
protocol Coordinator: AnyObject {
    func start()
}
