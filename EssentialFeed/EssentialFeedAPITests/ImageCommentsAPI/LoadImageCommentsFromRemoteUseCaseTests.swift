
import XCTest
import EssentialFeed
import EssentialFeedAPI

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
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
        
        expect(sut, toCompleteWith: failure(RemoteImageCommentsLoader.Error.connectivity)) {
            client.complete(with: clentError, at: 0)
        }
    }
    
    func test_load_requestNon2xxResponseFail() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 150, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(RemoteImageCommentsLoader.Error.invalidData)) {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliverErrorOn2xxResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        let samples = [200, 201, 202, 250, 299]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(RemoteImageCommentsLoader.Error.invalidData)) {
                let invalidJSON = Data("invalid json".utf8)
                client.complete(withStatusCode: code, data: invalidJSON, at: index)
            }
        }
    }
    
    func test_load_deliverNoItems2xxResponseWithEmptyJSON() {
        let (sut, client) = makeSUT()
        
        let samples = [200, 201, 202, 250, 299]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success([])) {
                let emptyListJSON = makeItemsJSON([])
                client.complete(withStatusCode: code, data: emptyListJSON, at: index)
            }
        }
    }
    
    func test_load_deliverItems2xxResponseWithJSON() {
        let (sut, client) = makeSUT()
        
        
        let item1 = makeItem(
            id: UUID(),
            message: "a message",
            createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            username: "a username"
        )
        let item2 = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            username: "another username")
        
        let items = [item1.model, item2.model]
        
        let samples = [200, 201, 202, 250, 299]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success(items)) {
                let json = makeItemsJSON([item1.json, item2.json])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_doesNotDeliverResultsAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://any.com")!
        let client = HTTPClientSpy()
        var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(client: client, url: url)
        
        var capturedResults: [RemoteImageCommentsLoader.Result] = []
        sut?.load { result in
            capturedResults.append(result)
        }
        
        sut = nil
        
        let json = makeItemsJSON([])
        client.complete(withStatusCode: 200, data: json)
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any] ) {
        let model = ImageComment(
            id: id,
            message: message,
            createdAt: createdAt.date,
            username: username
        )
        
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": username
            ]
        ]
        
        return (model: model, json: json)
    }
    
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        return .failure(error)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
        return json
    }
    
    private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWith expectedResult: RemoteImageCommentsLoader.Result, when action: () -> (), file: StaticString = #filePath, line: UInt = #line) {
        
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead",file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(url: URL = URL(string: "https://url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (RemoteImageCommentsLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(client: client, url: url)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
}