//
//  PickerTableViewCell.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/4/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import UIKit

class PickerTableViewCell: UITableViewCell {

    let selectedLabel = UILabel()
    let picker = UIPickerView()

    var isExpanded = false {
        didSet {
            self.picker.isHidden = !isExpanded
        }
    }

    convenience init() {
        self.init(style: .default, reuseIdentifier: nil)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.picker.isHidden = !self.isExpanded

        let stackView = UIStackView(arrangedSubviews: [self.selectedLabel, self.picker])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 15.0
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill

        self.addSubview(stackView)

        stackView.constrain(within: self, constant: 10)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
