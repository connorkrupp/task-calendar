//
//  TaskManager.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/3/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import Foundation

/**
 Protocol for TaskManager notifying observers of changes in available tasks.
 */
protocol TaskManagerChangeObserver: class {
    func taskManagerDidAdd(task: Task)
    func taskManagerDidUpdate(task: Task)
    func taskManagerDidComplete(task: Task)
}

class TaskManager {

    private static let storageFilename = "tasks.json"

    var tasks = [Task]()
    var projects = [Project]()

    init() {
        if Storage.fileExists(TaskManager.storageFilename, in: .documents) {
            self.tasks = Storage.retrieve(TaskManager.storageFilename, from: .documents, as: [Task].self)
        }
    }

    func save() {
        Storage.store(self.tasks, to: .documents, as: TaskManager.storageFilename)
    }

    func save(task: Task) {
        for observer in self.observers {
            observer.taskManagerDidUpdate(task: task)
        }

        self.save()
    }

    func add(task: Task) {
        self.tasks.append(task)

        for observer in self.observers {
            observer.taskManagerDidAdd(task: task)
        }

        self.save()
    }

    func complete(task: Task) {
        guard let index = self.tasks.index(where: { $0.id == task.id }) else {
            assertionFailure("Error: Completing task that does not exist in Task Manager.")
            return
        }

        self.tasks.remove(at: index)

        for observer in self.observers {
            observer.taskManagerDidComplete(task: task)
        }

        self.save()
    }

    // MARK: Observers

    private var observers = [TaskManagerChangeObserver]()

    /*
     Registers the observers.

     - parameter observer: observer to notify of changes.
     */
    func register(_ observer: TaskManagerChangeObserver) {
        self.observers.append(observer)
    }

    /*
     Unregisters the observers.

     - parameter observer: observer to stop notifying of changes.
     */
    func unregister(_ observer: TaskManagerChangeObserver) {
        if let index = observers.index(where: { $0 === observer }) {
            observers.remove(at: index)
        }
    }

}
