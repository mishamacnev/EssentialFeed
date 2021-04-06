//
//  XCTestCase+MemoryLeakTrack.swift
//  EssentialFeedTests
//
//  Created by Mikhail Macnev on 04.04.2021.
//

import XCTest

extension XCTestCase {
    func trackMemoryLeak(for instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should be nil. Memory leak!", file: file, line: line)
        }
    }
}
