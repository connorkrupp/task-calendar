//
//  ScheduleHourSeparator.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/4/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import UIKit

class ScheduleHourSeparator: UICollectionReusableView {

    let hourLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let separator = UIView()
        separator.backgroundColor = UIColor.lightGray
        separator.translatesAutoresizingMaskIntoConstraints = false

        self.hourLabel.translatesAutoresizingMaskIntoConstraints = false
        self.hourLabel.textColor = UIColor.lightGray
        self.hourLabel.textAlignment = .right

        self.addSubview(separator)
        self.addSubview(self.hourLabel)

        NSLayoutConstraint.activate([
            self.hourLabel.widthAnchor.constraint(equalToConstant: 60),
            self.hourLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2),
            self.hourLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.leadingAnchor.constraint(equalTo: self.hourLabel.trailingAnchor, constant: 12),
            separator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            separator.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
