//
//  TaskListViewController.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/3/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import UIKit

class TaskListViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    let taskManager: TaskManager

    init(taskManager: TaskManager) {
        self.taskManager = taskManager

        super.init(style: .plain)

        self.tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.identifier)
        //self.tableView.rowHeight = 60 //UITableViewAutomaticDimension
        //self.tableView.estimatedRowHeight = 100
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))

        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    var selectedIndexPath: IndexPath? = nil
    var selectedTask: Task? {
        guard let indexPath = self.selectedIndexPath else { return nil }

        return self.taskManager.tasks[indexPath.row]
    }

    func setSelectedIndexPath(newIndexPath: IndexPath, isNewCell: Bool) {
        guard self.selectedIndexPath != newIndexPath else { return }

        var indexPathsToReload = [IndexPath]()
        var indexPathsToInsert = [IndexPath]()

        if let previousIndexPath = self.selectedIndexPath {
            indexPathsToReload.append(previousIndexPath)
        }

        if isNewCell {
            indexPathsToInsert.append(newIndexPath)
        } else {
            indexPathsToReload.append(newIndexPath)
        }

        self.selectedIndexPath = newIndexPath

        self.tableView.beginUpdates()
        self.tableView.insertRows(at: indexPathsToInsert, with: .automatic)
        self.tableView.reloadRows(at: indexPathsToReload, with: .automatic)
        self.tableView.endUpdates()
    }

    @objc func addTask() {
        let newIndexPath = IndexPath(row: self.taskManager.tasks.count, section: 0)

        self.taskManager.tasks.append(Task())
        self.setSelectedIndexPath(newIndexPath: newIndexPath, isNewCell: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskManager.tasks.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == self.selectedIndexPath {
            return 310
        } else {
            return 60
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.setSelectedIndexPath(newIndexPath: indexPath, isNewCell: false)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as? TaskTableViewCell else {
            fatalError("Unhandled cell class")
        }
        let task = self.taskManager.tasks[indexPath.row]
        let isExpanded = self.selectedIndexPath == indexPath

        cell.isExpanded = isExpanded
        cell.titleTextField.text = task.name ?? "New Task"

        let totalDuration = task.workTimes.reduce(0) { (res, info) -> Int in
            return res + info.duration
        }

        cell.durationLabel.text = "\(totalDuration) Minutes"
        cell.titleTextField.isUserInteractionEnabled = isExpanded

        cell.datePicker.minuteInterval = 5
        cell.datePicker.datePickerMode = .dateAndTime
        cell.datePicker.setDate(task.workTimes[0].startDate, animated: false)
        cell.datePicker.addTarget(self, action: #selector(didSelectDate), for: .valueChanged)

        cell.durationPicker.dataSource = self
        cell.durationPicker.delegate = self

        cell.durationPicker.selectRow(task.workTimes[0].duration / 60, inComponent: 0, animated: false)
        cell.durationPicker.selectRow((task.workTimes[0].duration % 60) / 15, inComponent: 1, animated: false)

        if cell.isExpanded {
            cell.titleTextField.becomeFirstResponder()
            cell.bodyTextView.text = task.body
        }

        return cell
    }

    @objc func didSelectDate(sender: UIDatePicker) {
        if let task = self.selectedTask {
            task.workTimes[0] = Task.WorkTimeInfo(startDate: sender.date, duration: task.workTimes[0].duration)
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let task = self.selectedTask, let indexPath = self.selectedIndexPath {
            let duration = pickerView.selectedRow(inComponent: 0) * 60 + pickerView.selectedRow(inComponent: 1) * 5

            task.workTimes[0] = Task.WorkTimeInfo(startDate: task.workTimes[0].startDate, duration: duration)

            let totalDuration = task.workTimes.reduce(0) { (res, info) -> Int in
                return res + info.duration
            }

            if let cell = self.tableView.cellForRow(at: indexPath) as? TaskTableViewCell {
                cell.durationLabel.text = "\(totalDuration) Minutes"
            }
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(row) Hours"
        }

        return "\(row * 5) Minutes"
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 8
        }

        return 12
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
}
