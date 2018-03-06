//
//  CalendarViewController.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/3/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import UIKit

class CalendarViewController: UICollectionViewController, CalendarDayLayoutDataSource, TaskManagerChangeObserver {

    // MARK: Callbacks

    var didSelect: ((Task) -> ())? = nil
    var didTapAddTask: (() -> ())? = nil
    var didMove: ((Task) -> ())? = nil

    // MARK: CalendarDayLayoutDelegate

    func numberOfRowsIn(section: Int) -> Int {
        return Time.numberOfHoursInDay
    }

    func startPartialRowForItem(at indexPath: IndexPath) -> Double {
        let task = self.task(for: indexPath)

        guard let offset = task.offsetFrom(date: Time.today) else { return 0.0 }

        return Double(offset.hours) + Double(offset.minutes) / Double(Time.numberOfMinutesInHour)
    }

    func endPartialRowForItem(at indexPath: IndexPath) -> Double {
        let task = self.task(for: indexPath)
        let workTimeHours = Double(task.workTime!.duration) / Double(Time.numberOfMinutesInHour)

        return self.startPartialRowForItem(at: indexPath) + workTimeHours
    }

    func didMoveItem(at indexPath: IndexPath, to partialRow: Double, in section: Int) {
        let task = self.task(for: indexPath)
        guard let workTime = task.workTime else { return }

        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: workTime.startDate)

        components.day = self.firstDayInView + section
        components.hour = Int(floor(partialRow))
        components.minute = Int((partialRow - floor(partialRow)) * Double(Time.numberOfMinutesInHour))

        task.workTime = Task.WorkTimeInfo(startDate: Calendar.current.date(from: components)!, duration: workTime.duration)

        self.didMove?(task)
    }

    let taskManager: TaskManager

    init(taskManager: TaskManager) {
        self.taskManager = taskManager

        super.init(collectionViewLayout: CalendarDayLayout(withDataSource: self))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Today"
        self.collectionView?.backgroundColor = UIColor.white

        self.collectionView?.register(CalendarEventCollectionViewCell.self, forCellWithReuseIdentifier: "asdf")
        self.collectionView?.register(ScheduleHourSeparator.self, forSupplementaryViewOfKind: CalendarDayLayout.SupplementaryViewKind.Separator.rawValue, withReuseIdentifier: "HourSeparator")
        self.collectionView?.register(ScheduleDaySeparator.self, forSupplementaryViewOfKind: CalendarDayLayout.SupplementaryViewKind.Header.rawValue, withReuseIdentifier: "DaySeparator")

        self.taskManager.register(self)
    }

    deinit {
        self.taskManager.unregister(self)
    }

    func tasksInDay(day: Int) -> [Task] {
        return self.taskManager.tasks.filter({ (task) -> Bool in
            let components = Calendar.current.dateComponents([.day], from: task.workTime!.startDate)

            return components.day! == day
        })
    }

    var firstDayInView: Int {
        let components = Calendar.current.dateComponents([.day], from: Time.today)

        return components.day!
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tasksInDay(day: self.firstDayInView + section).count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "asdf", for: indexPath) as! CalendarEventCollectionViewCell
        let task = self.tasksInDay(day: self.firstDayInView + indexPath.section)[indexPath.row]
        cell.nameLabel.text = task.name
        cell.backgroundColor = task.color.uiColor

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.didSelect?(self.task(for: indexPath))
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch CalendarDayLayout.SupplementaryViewKind(rawValue: kind)! {
        case .Separator:
            let hourSeparator = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HourSeparator", for: indexPath) as! ScheduleHourSeparator

            let hour = indexPath.row % 12

            hourSeparator.hourLabel.text = "\(hour == 0 ? 12 : hour) \((indexPath.row % 24) < 12 ? "AM" : "PM" )"

            return hourSeparator
        case .Header:
            let dayHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DaySeparator", for: indexPath) as! ScheduleDaySeparator

            dayHeader.dayLabel.text = "Monday"
            dayHeader.dateLabel.text = "1/1/15"

            return dayHeader
        }
    }

    // MARK: TaskManagerChangeObserver

    func taskManagerDidAdd(task: Task) {
        self.collectionView?.insertItems(at: [self.indexPath(for: task)])
    }

    func taskManagerDidUpdate(task: Task) {
        self.collectionView?.reloadData()
    }

    func taskManagerDidComplete(task: Task, at index: Int) {
        self.collectionView?.reloadData()
    }

    // MARK: Helpers

    private func task(for indexPath: IndexPath) -> Task {
        return self.tasksInDay(day: self.firstDayInView + indexPath.section)[indexPath.row]
    }

    private func section(for task: Task) -> Int {
        return task.offsetFrom(date: Time.today)!.days
    }

    private func indexPath(for task: Task) -> IndexPath {
        let section = self.section(for: task)
        let row = self.tasksInDay(day: self.firstDayInView + section).index { $0.id == task.id }!

        return IndexPath(row: row, section: section)
    }

}

