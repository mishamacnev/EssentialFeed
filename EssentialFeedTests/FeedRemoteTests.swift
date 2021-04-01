//
//  FeedRemoteTests.swift
//  EssentialFeedTests
//
//  Created by Mikhail Macnev on 31.03.2021.
//

import XCTest
import EssentialFeed

class FeedRemoteTests: XCTestCase {
    
    func test_HHTPClientInvokeWithUrl() {
        let client = HTTPClientSpy()
        client.get(from: URL(string: "https://url.com")!, completion: { _ in })
        XCTAssertFalse(client.requestedUrls.isEmpty)
    }
    
    func test_load_requestsDataFromUrl() {
        let url = URL(string: "https://url-3.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in
            
        }
        
        XCTAssertEqual(client.requestedUrls, [url])
    }
    
    func test_load_requestsDataTwiceFromUrl() {
        let url = URL(string: "https://url-3.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedUrls, [url, url])
    }
    
    func test_init_doesNotRequestsDataFromUrl() {
        let (_, client) = makeSUT(url: URL(string: "https://url-2.com")!)
        
        XCTAssertTrue(client.requestedUrls.isEmpty)
    }
    
    func test_load_requestFail() {
        let (sut, client) = makeSUT()
        let clentError = NSError(domain: "Test", code: 0)
        
        
        var capturedErrors: [RemoteFeedLoader.Error] = []
        sut.load { error in
            capturedErrors.append(error)
        }
        
        
        client.complete(with: clentError, at: 0)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_requestNon200ResponseFail() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            var capturedErrors: [RemoteFeedLoader.Error] = []
            sut.load { error in
                capturedErrors.append(error)
            }
            
            client.complete(withStatusCode: code, at: index)
            
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> ())]()
        
        var requestedUrls: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> ()) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedUrls[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(response))
        }
    }
    
    private func makeSUT(url: URL = URL(string: "https://url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
}



