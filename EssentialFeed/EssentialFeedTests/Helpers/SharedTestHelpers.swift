//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Mikhail Macnev on 17.04.2021.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 1)
}

func anyURL() -> URL {
    return URL(string: "https://any.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}
