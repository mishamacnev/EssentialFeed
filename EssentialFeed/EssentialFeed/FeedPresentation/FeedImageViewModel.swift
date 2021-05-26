//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Mikhail Macnev on 09.05.2021.
//

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?
    
    public var hasLocation: Bool {
        location != nil
    }
}
