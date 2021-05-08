//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Mikhail Macnev on 09.05.2021.
//

import XCTest

class FeedImagePresenterTests: XCTestCase {
    func test_init_hasNotMessagesOnInit() {
        let view = ViewSpy()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    private class ViewSpy {
        let messages = [Any]()
    }
}
