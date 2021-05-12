
import XCTest
import EssentialFeed
import EssentialApp

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {
    
    func test_load_deliversImageOnLoaderSuccess() {
        let data = anyData()
        let sut = makeSUT(loaderResult: .success(data))
        
        expect(sut, toCompleteWith: .success(data))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let sut = makeSUT(loaderResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    func test_load_cachesLoadedImageOnLoaderSuccess() {
        let cache = CacheSpy()
        let data = anyData()
        let url = anyURL()
        let sut = makeSUT(loaderResult: .success(anyData()), cache: cache)
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(cache.messages, [.save(data, url)], "Expected to cache loaded image on success")
    }
    
    func test_load_doesNotCacheOnLoaderFailure() {
        let cache = CacheSpy()
        let url = anyURL()
        let sut = makeSUT(loaderResult: .failure(anyNSError()), cache: cache)
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertTrue(cache.messages.isEmpty, "Expected not to cache image on load error")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(loaderResult: FeedImageDataLoader.Result, cache: CacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoader {
        let loader = LoaderStub(result: loaderResult)
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private class CacheSpy: FeedImageDataCache {
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save(Data, URL)
        }
        
        func save(_ data: Data, for url: URL, completion: @escaping (FeedImageDataCache.Result) -> Void) {
            messages.append(.save(data, url))
            completion(.success(()))
        }
    }
    
    private class LoaderStub: FeedImageDataLoader {
        private let result: FeedImageDataLoader.Result
        
        init(result: FeedImageDataLoader.Result) {
            self.result = result
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> ()) -> FeedImageDataLoaderTask {
            let task = LoadImageDataTaskSub(completion)
            task.complete(with: result)
            return task
        }
    }
    
    private class LoadImageDataTaskSub: FeedImageDataLoaderTask {
        private let completion: ((FeedImageDataLoader.Result) -> Void)
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion(result)
        }
        
        func cancel() {
            
        }
    }
}
