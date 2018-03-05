//
//  TaskViewController.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/4/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import UIKit

class TaskViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 12
        }

        return 4
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(row) Hours"
        }

        return "\(row * 15) Minutes"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.updateDurationSelectedLabel()
    }

    func updateDurationSelectedLabel() {
        let hours = self.durationCell.picker.selectedRow(inComponent: 0)
        let minutes = self.durationCell.picker.selectedRow(inComponent: 1) * 15

        self.durationCell.selectedLabel.text = "\(hours) Hours \(minutes) Minutes"
    }

    // MARK: Callbacks

    var saveTask: ((Task) -> ())? = nil

    // MARK: Properties

    let task: Task

    let nameCell = TextFieldTableViewCell()
    let subtitleCell = TextFieldTableViewCell()
    let dateCell = DatePickerTableViewCell()
    let durationCell = PickerTableViewCell()
    let dueDateCell = DatePickerTableViewCell()

    let sections: [(name: String, cells: [UITableViewCell])]

    // MARK: Initializers

    init(task: Task = Task()) {
        self.task = task
        self.sections = [
            ("Info", [self.nameCell, self.subtitleCell]),
            ("Due Date", [self.dueDateCell]),
            ("Date & Duration", [self.dateCell, self.durationCell]),
        ]

        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: Lifecycle

    override func loadView() {
        super.loadView()

        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension

        self.nameCell.textField.text = task.name
        self.nameCell.textField.placeholder = "New Task"
        self.nameCell.selectionStyle = .none

        self.subtitleCell.textField.text = task.subtitle
        self.subtitleCell.textField.placeholder = "Subtitle"
        self.subtitleCell.selectionStyle = .none

        self.dueDateCell.datePicker.minuteInterval = 15
        self.dueDateCell.selectionStyle = .none

        self.dateCell.datePicker.minuteInterval = 15
        self.dateCell.selectionStyle = .none

        self.durationCell.picker.dataSource = self
        self.durationCell.picker.delegate = self
        self.durationCell.selectionStyle = .none

        if let workTime = task.workTime {
            self.dateCell.date = workTime.startDate
            self.durationCell.picker.selectRow(workTime.duration / 60, inComponent: 0, animated: false)
            self.durationCell.picker.selectRow((workTime.duration % 60) / 15, inComponent: 1, animated: false)
            self.updateDurationSelectedLabel()
        }

        if let dueDate = task.dueDate {
            self.dueDateCell.date = dueDate
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Task Details"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
    }

    @objc func save() {

        let hours = self.durationCell.picker.selectedRow(inComponent: 0)
        let minutes = self.durationCell.picker.selectedRow(inComponent: 1) * 15

        self.task.name = self.nameCell.textField.text
        self.task.subtitle = self.subtitleCell.textField.text
        self.task.dueDate = self.dueDateCell.date
        self.task.workTime = Task.WorkTimeInfo(startDate: self.dateCell.date, duration: hours * 60 + minutes)
        
        self.saveTask?(self.task)
    }

    // MARK: UITableViewController

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].cells.count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].name
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.sections[indexPath.section].cells[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)

        switch cell {
        case let cell as DatePickerTableViewCell:
            self.tableView.beginUpdates()
            cell.isExpanded = !cell.isExpanded
            self.tableView.endUpdates()
        case let cell as PickerTableViewCell:
            self.tableView.beginUpdates()
            cell.isExpanded = !cell.isExpanded
            self.tableView.endUpdates()
        case let cell as TextFieldTableViewCell:
            cell.textField.becomeFirstResponder()
        default:
            break
        }
    }
}
