//
//  Time.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/5/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import Foundation

struct Time {

    static let numberOfDaysShown = 7
    static let numberOfHoursInDay = 24
    static let numberOfMinutesInHour = 60

    static var today: Date? {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: Date())

        return Calendar.current.date(from: components)
    }

    struct Offset {
        let days: Int
        let hours: Int
        let minutes: Int

        func totalHours() -> Double {
            let dayHoursOffset = Double(self.days * Time.numberOfHoursInDay)
            let hours = Double(self.hours)
            let partialHour = Double(self.minutes) / Double(Time.numberOfMinutesInHour)

            return dayHoursOffset + hours + partialHour
        }
    }
}
