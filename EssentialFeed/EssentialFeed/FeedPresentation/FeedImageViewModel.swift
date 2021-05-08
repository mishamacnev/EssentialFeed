//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Mikhail Macnev on 09.05.2021.
//

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        location != nil
    }
}
