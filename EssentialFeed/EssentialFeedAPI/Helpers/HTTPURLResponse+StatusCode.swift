//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Mikhail Macnev on 09.05.2021.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
