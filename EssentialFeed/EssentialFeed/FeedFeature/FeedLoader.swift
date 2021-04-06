//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Mikhail Macnev on 31.03.2021.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> ())
}
