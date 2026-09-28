//
//  Fixtures.swift
//  XStreamPlayTests
//
//  Created by Dileep chauhan on 28/09/26.
//

import Foundation

/// Sample TMDB JSON, trimmed to the fields the app reads.
enum Fixtures {

    /// The same base URL the app uses, without a force unwrap.
    static let apiBaseURL = URL(string: "https://api.themoviedb.org/3") ?? URL(fileURLWithPath: "/")

    /// Page 1 of 3 of a movie list.
    static let moviePage = """
    {
      "page": 1,
      "total_pages": 3,
      "total_results": 60,
      "results": [
        { "id": 550, "title": "Fight Club", "poster_path": "/fight-club.jpg" },
        { "id": 680, "title": "Pulp Fiction", "poster_path": null }
      ]
    }
    """

    /// The last page of a list.
    static let lastMoviePage = """
    {
      "page": 3,
      "total_pages": 3,
      "total_results": 60,
      "results": [ { "id": 13, "title": "Forrest Gump" } ]
    }
    """

    /// TV shows use `name` and `first_air_date` where movies use `title` and
    /// `release_date`.
    static let tvShowDetails = """
    {
      "id": 1399,
      "name": "Game of Thrones",
      "overview": "Seven noble families fight for control of Westeros.",
      "poster_path": "/got.jpg",
      "first_air_date": "2011-04-17",
      "adult": false,
      "genres": [{ "id": 18, "name": "Drama" }, { "id": 10765, "name": "Sci-Fi & Fantasy" }],
      "spoken_languages": [{ "english_name": "English", "iso_639_1": "en", "name": "English" }]
    }
    """
}
