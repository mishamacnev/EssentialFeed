//
//  FeedApi.swift
//  EssentialFeed
//
//  Created by Mihail on 01.04.2021.
//

import Foundation

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity,
             invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> ()) {
        client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .failure(_):
                completion(.failure(.connectivity))
            case .success(let data, let response):
                completion(FeedItemsMapper.map(data, response: response))
            }
        })
    }
}
