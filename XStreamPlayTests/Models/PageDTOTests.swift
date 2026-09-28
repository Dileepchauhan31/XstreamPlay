//
//  PageDTOTests.swift
//  XStreamPlayTests
//
//  Created by Dileep chauhan on 01/09/26.
//

import XCTest
@testable import XStreamPlay

final class PageDTOTests: XCTestCase {

    private let decoder = JSONDecoder.convertingSnakeCase

    func test_decode_middlePage_hasANextPage() throws {
        let page = try decoder.decode(PageDTO<MovieDTO>.self, from: Data(Fixtures.moviePage.utf8))

        XCTAssertEqual(page.results.map(\.id), [550, 680])
        XCTAssertEqual(page.nextPage, 2)
    }

    func test_decode_lastPage_hasNoNextPage() throws {
        let page = try decoder.decode(PageDTO<MovieDTO>.self, from: Data(Fixtures.lastMoviePage.utf8))

        XCTAssertTrue(page.isLastPage)
        XCTAssertNil(page.nextPage)
    }

    func test_decode_whenResultsAreMissing_givesAnEmptyLastPage() throws {
        let page = try decoder.decode(PageDTO<MovieDTO>.self, from: Data("{}".utf8))

        XCTAssertTrue(page.results.isEmpty)
        XCTAssertNil(page.nextPage)
    }
}
