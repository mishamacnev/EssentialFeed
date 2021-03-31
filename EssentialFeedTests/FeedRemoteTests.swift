//
//  FeedRemoteTests.swift
//  EssentialFeedTests
//
//  Created by Mikhail Macnev on 31.03.2021.
//

import XCTest
@testable import EssentialFeed

class FeedRemoteTests: XCTestCase {
    
    func test_HHTPClientNotInvoke() {
        let client = HTTPClientSpy()
        
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_HHTPClientInvokeWithUrl() {
        let client = HTTPClientSpy()
        client.get(from: URL(string: "https://url.com")!)
        XCTAssertNotNil(client.requestedUrl)
    }
    
    func test_requestsDataFromUrl() {
        let url = URL(string: "https://url-3.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        
        XCTAssertEqual(client.requestedUrl, url)
    }
    
    func test_doesNotRequestsDataFromUrl() {
        let (_, client) = makeSUT(url: URL(string: "https://url-2.com")!)
        
        XCTAssertNil(client.requestedUrl)
    }
    
    private class HTTPClientSpy: HTTPClient {
        func get(from url: URL) {
            requestedUrl = url
        }
        
        var requestedUrl: URL?
    }
    
    private func makeSUT(url: URL = URL(string: "https://url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
}
protocol HTTPClient {
    func get(from url: URL)
}

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}


