//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Mikhail Macnev on 30.04.2021.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> ()) -> FeedImageDataLoaderTask
}
