//
//  AppCoordinator.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/3/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import UIKit

class AppCoordinator {

    let taskManager = TaskManager()

    let tabBarController = UITabBarController()

    let taskListNavigationController: UINavigationController
    let taskListViewController: TaskListViewController

    let calendarNavigationController: UINavigationController
    let calendarViewController: CalendarViewController

    var rootViewController: UIViewController {
        return self.tabBarController
    }

    init() {
        self.taskListViewController = TaskListViewController(taskManager: self.taskManager)
        self.calendarViewController = CalendarViewController(taskManager: self.taskManager)

        self.taskListNavigationController = UINavigationController(rootViewController: self.taskListViewController)
        self.taskListNavigationController.navigationBar.prefersLargeTitles = true

        self.calendarNavigationController = UINavigationController(rootViewController: self.calendarViewController)

        self.taskListNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 1)
        self.calendarNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 2)

        self.tabBarController.setViewControllers([self.taskListNavigationController, self.calendarNavigationController], animated: false)

        self.taskListViewController.didSelect = { self.didEdit(task: $0, from: self.taskListNavigationController) }
        self.taskListViewController.didTapAddTask = { () in self.didTapAddTask(from: self.taskListNavigationController) }
        self.taskListViewController.didComplete = { self.didComplete(task: $0) }

        self.calendarViewController.didSelect = { self.didEdit(task: $0, from: self.calendarNavigationController) }
        self.calendarViewController.didTapAddTask = { () in self.didTapAddTask(from: self.calendarNavigationController) }
        self.calendarViewController.didMove = self.didMove
    }

    func didMove(task: Task) {
        self.taskManager.save(task: task)
    }

    func didEdit(task: Task, from navigationController: UINavigationController) {
        let taskViewController = TaskViewController(task: task)

        taskViewController.saveTask = { task in
            self.taskManager.save(task: task)
            navigationController.popViewController(animated: true)
        }

        navigationController.pushViewController(taskViewController, animated: true)
    }

    func didTapAddTask(from navigationController: UINavigationController) {
        let taskViewController = TaskViewController()

        taskViewController.saveTask = { task in
            self.taskManager.add(task: task)
            navigationController.popViewController(animated: true)
        }

        navigationController.pushViewController(taskViewController, animated: true)
    }

    func didComplete(task: Task) {
        self.taskManager.complete(task: task)
    }
}
