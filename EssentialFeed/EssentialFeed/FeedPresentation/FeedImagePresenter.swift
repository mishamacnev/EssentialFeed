//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Mikhail Macnev on 09.05.2021.
//

import Foundation

public final class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: image.description,
            location: image.location
        )
    }
}
