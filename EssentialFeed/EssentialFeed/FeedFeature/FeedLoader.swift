//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Mikhail Macnev on 31.03.2021.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (Result) -> ())
}
