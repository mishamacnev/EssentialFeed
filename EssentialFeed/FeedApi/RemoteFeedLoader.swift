//
//  FeedApi.swift
//  EssentialFeed
//
//  Created by Mihail on 01.04.2021.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> ())
}

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity,
             invalidData
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> ()) {
        client.get(from: url, completion: { result in
            switch result {
            case .failure(_):
                completion(.connectivity)
            case .success(_):
                completion(.invalidData)
            }
        })
    }
}
