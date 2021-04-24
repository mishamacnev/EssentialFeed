//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Mikhail Macnev on 05.04.2021.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    private enum UnexpectedHTTPClientError: Swift.Error {
        case unexpected
    }
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { (data, response, error) in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedHTTPClientError.unexpected
                }
            })
        }.resume()
    }
}
