//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Mikhail Macnev on 10.05.2021.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> ()) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        return task
    }
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        func cancel() {
            wrapped?.cancel()
        }
    }
}

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_load_deliversPrimaryImageOnPrimaryLoaderResult() {
        let primaryData = anyData()
        let fallbackData = anyData()
        let sut = makeSUT(primaryResut: .success(primaryData), fallbackResult: .success(fallbackData))
        
        let _ = sut.loadImageData(from: anyURL()) { result in
            switch result {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, primaryData)
            case .failure:
                XCTFail("Expected successful result, got \(result) instead")
            }
        }
    }
    
    func test_load_deliversFallbackImageOnPrimaryLoaderFailure() {
        let fallbackData = anyData()
        let sut = makeSUT(primaryResut: .failure(anyNSError()), fallbackResult: .success(fallbackData))
        
        let _ = sut.loadImageData(from: anyURL()) { result in
            switch result {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, fallbackData)
            case .failure:
                XCTFail("Expected successful result, got \(result) instead")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(primaryResut: FeedImageDataLoader.Result, fallbackResult: FeedImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoader {
        let primaryLoader = LoaderStub(result: primaryResut)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
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
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func anyData() -> Data {
        Data("any data".utf8)
    }

}
