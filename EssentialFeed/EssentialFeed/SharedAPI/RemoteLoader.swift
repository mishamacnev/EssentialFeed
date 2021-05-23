
import Foundation
import EssentialFeed

public final class RemoteLoader<Resource> {
    private let client: HTTPClient
    private let url: URL
    private let mapper: Mapper
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = Swift.Result<Resource, Swift.Error>
    public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
    
    public init(client: HTTPClient, url: URL, mapper: @escaping Mapper) {
        self.client = client
        self.url = url
        self.mapper = mapper
    }
    
    public func load(completion: @escaping (Result) -> ()) {
        client.get(from: url, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                completion(.failure(Error.connectivity))
            case let .success((data, response)):
                completion(self.map(data, from: response))
            }
        })
    }
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            return .success(try mapper(data, response))
        } catch {
            return .failure(Error.invalidData)
        }
    }
}
