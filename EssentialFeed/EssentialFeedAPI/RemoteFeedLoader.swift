//
//  FeedApi.swift
//  EssentialFeed
//
//  Created by Mihail on 01.04.2021.
//

import Foundation
import EssentialFeed

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
    convenience init(client: HTTPClient, url: URL) {
        self.init(client: client, url: url, mapper: FeedItemsMapper.map)
    }
}
