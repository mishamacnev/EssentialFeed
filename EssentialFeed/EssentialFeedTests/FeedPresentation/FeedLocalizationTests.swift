//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Mikhail Macnev on 04.05.2021.
//

import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        
        assertLocalizedKeyAndValuesExists(in:  bundle, table)
    }
    
}
