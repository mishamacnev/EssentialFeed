//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Mikhail Macnev on 09.05.2021.
//

import XCTest
import EssentialFeed

struct FeedImageViewModel{
    let description: String?
    let location: String?
    let image: Any?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}

protocol FeedImageView {
    func display(_ model: FeedImageViewModel)
}

final class FeedImagePresenter {
    private let view: FeedImageView
    
    init(view: FeedImageView) {
        self.view = view
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(
                        description: model.description,
                        location: model.location,
                        image: nil,
                        isLoading: true,
                        shouldRetry: false)
        )
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(FeedImageViewModel(
                        description: model.description,
                        location: model.location,
                        image: nil,
                        isLoading: false,
                        shouldRetry: true)
        )
    }
}

class FeedImagePresenterTests: XCTestCase {
    func test_init_hasNotMessagesOnInit() {
        let view = ViewSpy()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoadingImageData_displaysLoadingImage() {
        let (sut, view) = makeSUT()
        let image = uniqueImage()
        sut.didStartLoadingImageData(for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageDataWithError_displaysStopLoadingAndShouldRetry() {
        let (sut, view) = makeSUT()
        let image = uniqueImage()
        sut.didFinishLoadingImageData(with: anyNSError(), for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackMemoryLeak(for: sut, file: file, line: line)
        trackMemoryLeak(for: view, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: FeedImageView {
        private(set) var messages = [FeedImageViewModel]()
        
        func display(_ model: FeedImageViewModel) {
            messages.append(model)
        }
    }
}
