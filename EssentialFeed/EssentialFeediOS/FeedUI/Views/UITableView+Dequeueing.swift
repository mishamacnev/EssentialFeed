//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Mikhail Macnev on 03.05.2021.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
