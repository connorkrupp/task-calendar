//
//  CalendarViewController.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/3/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import UIKit

class CalendarViewController: UICollectionViewController, CalendarDayLayoutDelegate {
    func numberOfRowsIn(section: Int) -> Int {
        return 24
    }

    func startRowForItem(at indexPath: IndexPath) -> Int {
        let task = self.taskManager.tasks[indexPath.row]

        return Calendar.current.component(.hour, from: task.workTimes[0].startDate)
    }

    func endRowForItem(at indexPath: IndexPath) -> Int {
        let task = self.taskManager.tasks[indexPath.row]

        return Calendar.current.component(.hour, from: task.workTimes[0].startDate) + task.workTimes[0].duration / 60
    }


    let taskManager: TaskManager

    init(taskManager: TaskManager) {
        self.taskManager = taskManager

        super.init(collectionViewLayout: CalendarDayLayout(withDelegate: self))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.register(CalendarEventCollectionViewCell.self, forCellWithReuseIdentifier: "asdf")
        self.collectionView?.register(ScheduleHourSeparator.self, forSupplementaryViewOfKind: CalendarDayLayout.SupplementaryViewKind.Separator.rawValue, withReuseIdentifier: "HourSeparator")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload))
    }

    @objc func reload() {
        self.collectionView?.reloadData()
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

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch CalendarDayLayout.SupplementaryViewKind(rawValue: kind)! {
        case .Separator:
            let hourSeparator = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HourSeparator", for: indexPath) as! ScheduleHourSeparator

            let hour = indexPath.row % 12

            hourSeparator.hourLabel.text = "\(hour == 0 ? 12 : hour) \(indexPath.row < 12 ? "AM" : "PM" )"

            return hourSeparator
        }
    }

}

