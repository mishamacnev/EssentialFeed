//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Mikhail Macnev on 26.05.2021.
//

import XCTest
import EssentialFeed

class ImageCommentsLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        assertLocalizedKeyAndValuesExists(in:  bundle, table)
    }
}
