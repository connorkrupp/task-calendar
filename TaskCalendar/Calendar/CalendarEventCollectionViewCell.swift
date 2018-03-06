//
//  CalendarEventCollectionViewCell.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/4/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import UIKit

class CalendarEventCollectionViewCell: UICollectionViewCell {

    let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let contentStackView = UIStackView(arrangedSubviews: [nameLabel])
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1

        self.nameLabel.adjustsFontForContentSizeCategory = true
        self.nameLabel.adjustsFontSizeToFitWidth = true

        self.addSubview(contentStackView)

        contentStackView.constrain(within: self, constant: 4)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
