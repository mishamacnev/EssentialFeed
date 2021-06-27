//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Mikhail Macnev on 30.04.2021.
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
