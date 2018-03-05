//
//  TextFieldTableViewCell.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/4/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {

    let textField = UITextField()

    convenience init() {
        self.init(style: .default, reuseIdentifier: nil)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.textField.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.textField)

        self.textField.constrain(within: self, constant: 10)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
