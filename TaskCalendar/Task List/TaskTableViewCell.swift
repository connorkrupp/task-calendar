//
//  TaskTableViewCell.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/3/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    static let identifier = "TaskTableViewCell"

    let titleTextField = UITextField()
    let durationLabel = UILabel()
    let bodyTextView = UITextView()
    let datePicker = UIDatePicker()
    let durationPicker = UIPickerView()

    var isExpanded = false {
        didSet {
            self.bodyTextView.isHidden = !isExpanded
            self.datePicker.isHidden = !isExpanded
            self.durationPicker.isHidden = !isExpanded
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.bodyTextView.isHidden = !isExpanded
        self.datePicker.isHidden = !isExpanded
        self.durationPicker.isHidden = !isExpanded

        let titleStackView = UIStackView(arrangedSubviews: [titleTextField, durationLabel])
        titleStackView.axis = .horizontal
        titleStackView.alignment = .firstBaseline
        titleStackView.distribution = .equalSpacing

        let cellStackView = UIStackView(arrangedSubviews: [titleStackView, bodyTextView, datePicker, durationPicker])
        cellStackView.axis = .vertical
        cellStackView.alignment = .fill
        cellStackView.distribution = .fillEqually
        cellStackView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(cellStackView)

        cellStackView.constrain(within: self, constant: 20)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
