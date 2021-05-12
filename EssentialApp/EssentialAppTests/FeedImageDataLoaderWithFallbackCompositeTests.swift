//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Mikhail Macnev on 10.05.2021.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase, FeedImageDataLoaderTestCase {
    
    func test_load_deliversPrimaryImageOnPrimaryLoaderResult() {
        let primaryData = anyData()
        let fallbackData = anyData()
        let sut = makeSUT(primaryResut: .success(primaryData), fallbackResult: .success(fallbackData))
        
        expect(sut, toCompleteWith: .success(primaryData))
    }
    
    func test_load_deliversFallbackImageOnPrimaryLoaderFailure() {
        let fallbackData = anyData()
        let sut = makeSUT(primaryResut: .failure(anyNSError()), fallbackResult: .success(fallbackData))
        
        expect(sut, toCompleteWith: .success(fallbackData))
    }
    
    func test_load_deliversErrorOnBothPrimaryAndFallbackFailures() {
        let sut = makeSUT(primaryResut: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        expect(sut, toCompleteWith: .failure(anyNSError()))
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
}
