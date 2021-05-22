//
//  RemoteImageCommentsLoader.swift
//  EssentialFeedAPI
//
//  Created by Mikhail Macnev on 18.05.2021.
//

import Foundation
import EssentialFeed

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(client: HTTPClient, url: URL) {
        self.init(client: client, url: url, mapper: ImageCommentsMapper.map)
    }
}
