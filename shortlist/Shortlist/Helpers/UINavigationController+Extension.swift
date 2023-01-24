//
//  UINavigationController+Extension.swift
//  Shortlist
//
//  Created by Dustin Bergman on 1/23/23.
//

import UIKit

extension UINavigationController {
    // Remove back button text
    open override func viewWillLayoutSubviews() {
        navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
