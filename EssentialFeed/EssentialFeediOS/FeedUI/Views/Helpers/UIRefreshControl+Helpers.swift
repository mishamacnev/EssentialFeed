//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Mikhail Macnev on 07.05.2021.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
