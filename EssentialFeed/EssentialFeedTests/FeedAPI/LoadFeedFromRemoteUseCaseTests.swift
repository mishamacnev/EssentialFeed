//
//  FeedRemoteTests.swift
//  EssentialFeedTests
//
//  Created by Mikhail Macnev on 31.03.2021.
//

import XCTest
import EssentialFeed

class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    
    func test_HHTPClientInvokeWithUrl() {
        let client = HTTPClientSpy()
        client.get(from: URL(string: "https://url.com")!, completion: { _ in })
        XCTAssertFalse(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromUrl() {
        let url = URL(string: "https://url-3.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in
            
        }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataTwiceFromUrl() {
        let url = URL(string: "https://url-3.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_init_doesNotRequestsDataFromUrl() {
        let (_, client) = makeSUT(url: URL(string: "https://url-2.com")!)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestFail() {
        let (sut, client) = makeSUT()
        let clentError = NSError(domain: "Test", code: 0)
        
        expect(sut, toCompleteWith: failure(RemoteFeedLoader.Error.connectivity)) {
            client.complete(with: clentError, at: 0)
        }
    }
    
    func test_load_requestNon200ResponseFail() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(RemoteFeedLoader.Error.invalidData)) {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliverErrorOn200ResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(RemoteFeedLoader.Error.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliverNoItems200ResponseWithEmptyJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliverItems200ResponseWithJSON() {
        let (sut, client) = makeSUT()
        
        
        let item1 = makeItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "https://any.com")!)
        let item2 = makeItem(id: UUID(), description: "some description", location: "some location", imageURL: URL(string: "https://any2.com")!)
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items)) {
            
            let json = makeItemsJSON([item1.json, item2.json])
            
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    func test_load_doesNotDeliverResultsAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://any.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(client: client, url: url)
        
        var capturedResults: [RemoteFeedLoader.Result] = []
        sut?.load { result in
            capturedResults.append(result)
        }
        
        sut = nil
        
        let json = makeItemsJSON([])
        client.complete(withStatusCode: 200, data: json)
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeItem(id: UUID, description: String?, location: String?, imageURL: URL) -> (model: FeedImage, json: [String: Any] ) {
        let model = FeedImage(
            id: id,
            description: description,
            location: location,
            url: imageURL
        )
        
        let json = [
            "id": model.id.uuidString,
            "description": model.description,
            "location": model.location,
            "image": model.url.absoluteString,
        ].compactMapValues { $0 }
        
        return (model: model, json: json)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
        return json
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> (), file: StaticString = #filePath, line: UInt = #line) {
        
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead",file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(url: URL = URL(string: "https://url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        
        trackMemoryLeak(for: client, file: file, line: line)
        trackMemoryLeak(for: sut, file: file, line: line)
        
        return (sut, client)
    }
}



