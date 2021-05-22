//
//  RemoteLoaderTests.swift
//  EssentialFeedAPITests
//
//  Created by Mikhail Macnev on 22.05.2021.
//

import XCTest
import EssentialFeed
import EssentialFeedAPI

class RemoteLoaderTests: XCTestCase {

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
        
        expect(sut, toCompleteWith: failure(.connectivity)) {
            client.complete(with: clentError, at: 0)
        }
    }
    
    func test_load_deliversErrorOnMapperError() {
        let (sut, client) = makeSUT(mapper: {_, _ in
            throw anyNSError()
        })
        
        expect(sut, toCompleteWith: failure(.invalidData)) {
            client.complete(withStatusCode: 200, data: anyData())
        }
    }
    
    func test_load_deliverMappedResource() {
        let resource = "a resource"
        let (sut, client) = makeSUT(mapper: { data, _ in
            String(data: data, encoding: .utf8)!
        })
        
        expect(sut, toCompleteWith: .success(resource)) {
            client.complete(withStatusCode: 200, data: Data(resource.utf8))
        }
    }
    
    func test_load_doesNotDeliverResultsAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://any.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader<String>? = RemoteLoader<String>(client: client, url: url, mapper: {_, _ in
            "any"
        })
        
        var capturedResults: [RemoteLoader<String>.Result] = []
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
    
    private func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
        return .failure(error)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
        return json
    }
    
    private func expect(_ sut: RemoteLoader<String>, toCompleteWith expectedResult: RemoteLoader<String>.Result, when action: () -> (), file: StaticString = #filePath, line: UInt = #line) {
        
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead",file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(
        url: URL = URL(string: "https://url.com")!,
        mapper: @escaping RemoteLoader<String>.Mapper = { _, _ in "any"},
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (RemoteLoader<String>, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLoader<String>(client: client, url: url, mapper: mapper)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }

}
