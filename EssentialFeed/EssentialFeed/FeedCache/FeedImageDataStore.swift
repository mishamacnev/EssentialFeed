//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Mikhail Macnev on 09.05.2021.
//

import Foundation

public protocol FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}
