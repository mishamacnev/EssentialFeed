//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Mikhail Macnev on 02.05.2021.
//

import Foundation

struct FeedImageViewModel<Image>{
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}
