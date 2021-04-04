//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Mikhail Macnev on 04.04.2021.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_failsOnWrongURL() {
        
        let url = anyURL()
        
        let exp = expectation(description: "wait observe")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let error = anyNSError()
        XCTAssertEqual((resultError(data: nil, response: nil, error: error)! as NSError).domain, error.domain)
        XCTAssertEqual((resultError(data: nil, response: nil, error: error)! as NSError).code, error.code)
    }
    
    func test_getFromURL_failsOnAllInvalidRequests() {
        XCTAssertNotNil(resultError(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultError(data: nil, response: anyNonHTTPResponse(), error: nil))
        XCTAssertNotNil(resultError(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultError(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultError(data: nil, response: anyNonHTTPResponse(), error: anyNSError()))
        XCTAssertNotNil(resultError(data: nil, response: anyValidHTTPResponse(), error: anyNSError()))
        XCTAssertNotNil(resultError(data: anyData(), response: anyNonHTTPResponse(), error: anyNSError()))
        XCTAssertNotNil(resultError(data: anyData(), response: anyValidHTTPResponse(), error: anyNSError()))
        XCTAssertNotNil(resultError(data: anyData(), response: anyNonHTTPResponse(), error: nil))
    }
    
    func test_getFromURL_succedOnValidData() {
        let data = anyData()
        let response = anyValidHTTPResponse()
        let recievedValues = resultValues(data: data, response: response, error: nil)
        
        XCTAssertEqual(recievedValues?.data, data)
        XCTAssertEqual(recievedValues?.response.statusCode, response.statusCode)
        XCTAssertEqual(recievedValues?.response.url, response.url)
    }
    
    func test_getFromURL_succedWithEmptyDataOnHTTPResponseWithNilData() {
      
        let response = anyValidHTTPResponse()
        
        let recievedValues = resultValues(data: Data(), response: response, error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(recievedValues?.data, emptyData)
        XCTAssertEqual(recievedValues?.response.statusCode, response.statusCode)
        XCTAssertEqual(recievedValues?.response.url, response.url)
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
    
    private func anyData() -> Data  {
        return Data("any data".utf8)
    }
    
    private func anyNonHTTPResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyValidHTTPResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func resultError(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("unexpect behavior, expected \(result) instead")
            return nil
        }
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "wait for load")
        
        var receivedResult: HTTPClientResult!
        
        sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func resultValues(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .success(data, response):
            return (data: data, response: response)
        default:
            XCTFail("unexpect behavior, got \(result)")
            return nil
        }
    }
    
    // MARK: - Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackMemoryLeak(for: sut, file: file, line: line)
        return sut
    }
    
    private class URLProtocolStub: URLProtocol {
       
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stub else {
                return
            }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
    }

}
