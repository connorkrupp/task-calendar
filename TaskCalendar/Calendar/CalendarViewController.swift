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
        return Time.numberOfHoursInDay * Time.numberOfDaysShown
    }

    func startPartialRowForItem(at indexPath: IndexPath) -> Double {
        let task = self.taskManager.tasks[indexPath.row]

        guard let today = Time.today, let offset = task.offsetFrom(date: today) else { return 0.0 }

        return offset.totalHours()
    }

    func endPartialRowForItem(at indexPath: IndexPath) -> Double {
        let task = self.taskManager.tasks[indexPath.row]
        let workTimeHours = Double(task.workTime!.duration) / Double(Time.numberOfMinutesInHour)

        return self.startPartialRowForItem(at: indexPath) + workTimeHours
    }

    func didMoveItem(at indexPath: IndexPath, to partialRow: Double) {
        let task = self.taskManager.tasks[indexPath.row]
        guard let today = Time.today, let offset = task.offsetFrom(date: today), let workTime = task.workTime else { return }

        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: workTime.startDate)

        let totalHours = Int(floor(partialRow))
        let dayOffset = totalHours / 24 - offset.days

        components.day = components.day! + dayOffset
        components.hour = totalHours % 24
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

        self.taskManager.register(self)
    }

    deinit {
        self.taskManager.unregister(self)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.taskManager.tasks.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "asdf", for: indexPath) as! CalendarEventCollectionViewCell
        let task = self.taskManager.tasks[indexPath.row]

        cell.nameLabel.text = task.name
        cell.backgroundColor = task.color.uiColor

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.didSelect?(self.taskManager.tasks[indexPath.row])
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch CalendarDayLayout.SupplementaryViewKind(rawValue: kind)! {
        case .Separator:
            let hourSeparator = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HourSeparator", for: indexPath) as! ScheduleHourSeparator

            let hour = indexPath.row % 12

            hourSeparator.hourLabel.text = "\(hour == 0 ? 12 : hour) \((indexPath.row % 24) < 12 ? "AM" : "PM" )"

            return hourSeparator
        }
    }

    // MARK: TaskManagerChangeObserver

    func taskManagerDidAddTask(at index: Int) {
        self.collectionView?.insertItems(at: [IndexPath(row: index, section: 0)])
    }

    func taskManagerDidUpdateTask(at index: Int) {
        self.collectionView?.reloadItems(at: [IndexPath(row: index, section: 0)])
    }

    func taskManagerDidCompleteTask(at index: Int) {
        self.collectionView?.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
}

