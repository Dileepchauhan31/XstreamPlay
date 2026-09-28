//
//  Fixtures.swift
//  XStreamPlayTests
//
//  Created by Dileep chauhan on 01/09/26.
//

import Foundation

/// Real TMDB response shapes, trimmed to what the app reads.
///
/// Kept as literals rather than bundled files so a test failure points at the
/// exact bytes that produced it without a second file to open.
enum Fixtures {

    /// A `/movie/popular` page, two results, second one deliberately sparse to
    /// prove the DTO tolerates missing optional fields.
    static let moviePage = """
    {
      "page": 1,
      "results": [
        {
          "adult": false,
          "backdrop_path": "/backdrop1.jpg",
          "genre_ids": [28, 12, 878],
          "id": 550,
          "original_language": "en",
          "original_title": "Fight Club",
          "overview": "A ticking-time-bomb insomniac.",
          "popularity": 61.4,
          "poster_path": "/poster1.jpg",
          "release_date": "1999-10-15",
          "title": "Fight Club",
          "video": false,
          "vote_average": 8.438,
          "vote_count": 27154
        },
        {
          "id": 680,
          "title": "Pulp Fiction"
        }
      ],
      "total_pages": 42,
      "total_results": 831
    }
    """

    /// The final page of a list — `page` equals `total_pages`.
    static let lastMoviePage = """
    {
      "page": 42,
      "results": [{ "id": 13, "title": "Forrest Gump" }],
      "total_pages": 42,
      "total_results": 831
    }
    """

    /// A response with no `results` key at all. A rail with nothing in it is a
    /// normal product state, so this must decode rather than throw.
    static let pageWithoutResults = """
    { "page": 1, "total_pages": 1, "total_results": 0 }
    """

    /// `id` is a string where an Int is expected — the shape-change case.
    static let malformedMoviePage = """
    { "page": 1, "results": [{ "id": "not-a-number", "title": "Broken" }] }
    """

    /// TMDB's error envelope.
    static let unauthorised = """
    { "status_code": 7, "status_message": "Invalid API key.", "success": false }
    """
}
