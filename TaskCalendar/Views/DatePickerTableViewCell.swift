//
//  DatePickerTableViewCell.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/4/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import UIKit

class DatePickerTableViewCell: UITableViewCell {

    let dateLabel = UILabel()
    let datePicker = UIDatePicker()

    let dateFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d' at 'h:mm a"
        return dateFormatter
    }()

    var date: Date {
        get {
            return self.datePicker.date
        }
        set {
            self.datePicker.date = newValue
            self.dateLabel.text = dateFormatter.string(from: newValue)
        }
    }

    var isExpanded = false {
        didSet {
            self.datePicker.isHidden = !isExpanded
        }
    }

    convenience init() {
        self.init(style: .default, reuseIdentifier: nil)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.date = Date()
        self.datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        self.datePicker.isHidden = !self.isExpanded
        self.datePicker.datePickerMode = .dateAndTime

        let stackView = UIStackView(arrangedSubviews: [self.dateLabel, self.datePicker])
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

    @objc func dateChanged(_ sender: UIDatePicker) {
        self.date = datePicker.date
    }
}
