//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Mikhail Macnev on 08.05.2021.
//

import Foundation

public final class FeedPresenter {
    public static var title: String {
        NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view")
    }
}
