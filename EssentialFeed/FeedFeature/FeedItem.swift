//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Mikhail Macnev on 31.03.2021.
//

import Foundation

struct FeedItem {
    let id: UUID
    let description: String?
    let location: String?
    let imageUrl: URL
}
