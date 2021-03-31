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
        client.get(from: URL(string: "https://url.com")!)
        XCTAssertFalse(client.requestedUrls.isEmpty)
    }
    
    func test_load_requestsDataFromUrl() {
        let url = URL(string: "https://url-3.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        
        XCTAssertEqual(client.requestedUrls, [url])
    }
    
    func test_load_requestsDataTwiceFromUrl() {
        let url = URL(string: "https://url-3.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedUrls, [url, url])
    }
    
    func test_init_doesNotRequestsDataFromUrl() {
        let (_, client) = makeSUT(url: URL(string: "https://url-2.com")!)
        
        XCTAssertTrue(client.requestedUrls.isEmpty)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedUrls = [URL]()
        
        func get(from url: URL) {
            requestedUrls.append(url)
        }
    }
    
    private func makeSUT(url: URL = URL(string: "https://url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
}



