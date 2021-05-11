//
//  EssentialAppTests+Helpers.swift
//  EssentialAppTests
//
//  Created by Mikhail Macnev on 10.05.2021.
//

import XCTest
import EssentialFeed

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should be nil. Memory leak!", file: file, line: line)
        }
    }
}


func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 1)
}

func uniqueFeed() -> [FeedImage] {
    [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "http://any-url.com")!)]
}
