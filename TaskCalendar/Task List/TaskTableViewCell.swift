//
//  TaskTableViewCell.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/3/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import UIKit

protocol TaskTableViewCellDelegate: class {
    func taskTableViewCell(_ cell: TaskTableViewCell, didTapCompletionButton button: UIButton)
}

class TaskTableViewCell: UITableViewCell {

    static let identifier = "TaskTableViewCell"

    weak var delegate: TaskTableViewCellDelegate? = nil

    let completionButton = UIButton(type: UIButtonType.roundedRect)
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let dueDateLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        completionButton.backgroundColor = UIColor.clear
        completionButton.layer.cornerRadius = 4
        completionButton.layer.borderWidth = 2
        completionButton.layer.borderColor = UIColor.lightGray.cgColor
        completionButton.addTarget(self, action: #selector(didTapCompletionButton(sender:)), for: .touchUpInside)

        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        dueDateLabel.font = UIFont.preferredFont(forTextStyle: .callout)

        let titleStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStackView.axis = .vertical
        titleStackView.alignment = .leading
        titleStackView.distribution = .fillEqually

        let cellStackView = UIStackView(arrangedSubviews: [completionButton, titleStackView, dueDateLabel])
        cellStackView.axis = .horizontal
        cellStackView.alignment = .center
        cellStackView.distribution = .fill
        cellStackView.spacing = 14
        cellStackView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(cellStackView)

        NSLayoutConstraint.activate([
            completionButton.widthAnchor.constraint(equalToConstant: 20),
            completionButton.heightAnchor.constraint(equalToConstant: 20),
        ])

        cellStackView.constrain(within: self, constant: 14)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    @objc func didTapCompletionButton(sender: UIButton) {
        self.delegate?.taskTableViewCell(self, didTapCompletionButton: sender)
    }
}
