//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Mihail on 03.04.2021.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> ())
}
