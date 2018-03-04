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
        self.calendarNavigationController = UINavigationController(rootViewController: self.calendarViewController)

        self.taskListNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 1)
        self.calendarNavigationController.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 2)

        self.tabBarController.setViewControllers([self.taskListNavigationController, self.calendarNavigationController], animated: false)
    }
}
