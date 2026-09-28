//
//  Routing.swift
//  XStreamPlay
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

// Navigation requests a screen can make.
//
// A screen never pushes the next screen itself. It calls a router ("open the
// details for this movie") and `MovieFlowCoordinator` does the push. So all
// navigation code lives in one place, and screens don't know how other
// screens are built.
//
// This is the one file that holds more than one type: keep every routing
// protocol here so developers can see all the app's navigation at a glance.

/// Opens the details screen for a title.
@MainActor
protocol MovieDetailsRouting: AnyObject {
    func showMovieDetails(for movie: Movie)
}

/// Opens the full grid for a list ("See All").
@MainActor
protocol SeeAllRouting: AnyObject {
    func showSeeAll(title: String, source: MovieListSource)
}
