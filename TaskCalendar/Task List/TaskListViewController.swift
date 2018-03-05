//
//  TaskListViewController.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/3/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import UIKit

class TaskListViewController: UITableViewController, TaskManagerChangeObserver, TaskTableViewCellDelegate {

    // MARK: Callbacks

    var didSelect: ((Task) -> ())? = nil
    var didTapAddTask: (() -> ())? = nil
    var didComplete: ((Task) -> ())? = nil

    // MARK: Properties

    let taskManager: TaskManager

    let dateFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter
    }()

    init(taskManager: TaskManager) {
        self.taskManager = taskManager

        super.init(style: .plain)

        self.tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.identifier)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Tasks"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))

        self.taskManager.register(self)
    }

    deinit {
        self.taskManager.unregister(self)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskManager.tasks.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSelect?(self.taskManager.tasks[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as? TaskTableViewCell else {
            fatalError("Unhandled cell class")
        }
        let task = self.taskManager.tasks[indexPath.row]

        cell.titleLabel.text = task.name ?? "New Task"
        cell.subtitleLabel.text = task.subtitle ?? ""
        cell.subtitleLabel.isHidden = cell.subtitleLabel.text?.isEmpty ?? true
        cell.delegate = self

        if let dueDate = task.dueDate {
            cell.dueDateLabel.text = dateFormatter.string(from: dueDate)
        }

        return cell
    }

    @objc func addTask() {
        self.didTapAddTask?()
    }

    func taskTableViewCell(_ cell: TaskTableViewCell, didTapCompletionButton button: UIButton) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            assertionFailure("Tapped cell not in hierarchy of tableView")
            return
        }

        self.didComplete?(self.taskManager.tasks[indexPath.row])
    }

    func taskManagerDidAddTask(at index: Int) {
        self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    func taskManagerDidUpdateTask(at index: Int) {
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    func taskManagerDidCompleteTask(at index: Int) {
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
}
