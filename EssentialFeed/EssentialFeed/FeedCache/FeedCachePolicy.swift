//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Mikhail Macnev on 17.04.2021.
//

import Foundation

internal final class FeedCachePolicy {
    private init() {}
    private static let calendar = Calendar(identifier: .gregorian)
    
    private static var maxAgeCacheInDays: Int {
        return 7
    }
    
    internal static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxAge = calendar.date(byAdding: .day, value: maxAgeCacheInDays, to: timestamp) else {
            return false
        }
        return date < maxAge
    }
}
