//
//  Utilities.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/4/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import UIKit

extension UIView {
    func constrain(within other: UIView, constant: CGFloat) {
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: constant),
            self.topAnchor.constraint(equalTo: other.topAnchor, constant: constant),
            self.trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: -constant),
            self.bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -constant)
        ])
    }
}
