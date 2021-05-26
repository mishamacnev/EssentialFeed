//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Mikhail Macnev on 09.05.2021.
//

import XCTest
import EssentialFeed

class FeedImagePresenterTests: XCTestCase {
    func test_map_createsViewModel() {
        let image = uniqueImage()
        
        let viewModel = FeedImagePresenter.map(image)
        
        XCTAssertEqual(viewModel.description, image.description)
        XCTAssertEqual(viewModel.location, image.location)
    }
}
