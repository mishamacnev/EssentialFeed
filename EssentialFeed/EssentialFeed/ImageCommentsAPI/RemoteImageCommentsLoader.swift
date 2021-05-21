//
//  RemoteImageCommentsLoader.swift
//  EssentialFeedAPI
//
//  Created by Mikhail Macnev on 18.05.2021.
//

import Foundation
import EssentialFeed

public final class RemoteImageCommentsLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = Swift.Result<[ImageComment], Swift.Error>
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> ()) {
        client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .failure(_):
                completion(.failure(Error.connectivity))
            case let .success((data, response)):
                completion(RemoteImageCommentsLoader.map(data, from: response))
            }
        })
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try ImageCommentsMapper.map(data, response: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
