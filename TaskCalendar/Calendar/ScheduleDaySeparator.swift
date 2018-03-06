//
//  ScheduleDaySeparator.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/5/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import UIKit

class ScheduleDaySeparator: UICollectionReusableView {

    let dayLabel = UILabel()
    let dateLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.dayLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dayLabel.textColor = UIColor.black

        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.textColor = UIColor.black

        self.addSubview(self.dayLabel)
        self.addSubview(self.dateLabel)

        NSLayoutConstraint.activate([
            self.dayLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 60),
            self.dayLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            self.dateLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            self.dateLabel.lastBaselineAnchor.constraint(equalTo: self.dayLabel.lastBaselineAnchor, constant: 0),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
