
import Foundation
import EssentialFeed

public final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> ()) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            if let data = try? result.get() {
                self?.cache.saveIngoringResult(data, for: url)
            }
            completion(result)
        }
    }
}

private extension FeedImageDataCache {
    func saveIngoringResult(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}
