//
//  TaskManager.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/3/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import Foundation

class TaskManager {

    var tasks = [Task]()

    init() {
        let task1 = Task()
        task1.workTimes = [Task.WorkTimeInfo(startDate: self.dateWith(hour: 12), duration: 60)]
        task1.name = "Midterm 2"
        task1.color = Task.EventColor.lightBlue

        let task2 = Task()
        task2.workTimes = [Task.WorkTimeInfo(startDate: self.dateWith(hour: 14), duration: 90)]
        task2.name = "Project 3"
        task2.color = Task.EventColor.red

        let task3 = Task()
        task3.workTimes = [Task.WorkTimeInfo(startDate: self.dateWith(hour: 16), duration: 120)]
        task3.name = "Letter of Engagement"
        task3.color = Task.EventColor.green

        self.tasks.append(contentsOf: [task1, task2, task3])
    }

    private func dateWith(hour: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        components.year = 2018
        components.month = 2
        components.day = 28
        components.hour = hour
        components.minute = 0
        components.second = 0

        return Calendar.current.date(from: components)!
    }
}
