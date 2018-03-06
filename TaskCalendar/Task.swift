//
//  Task.swift
//  TaskCalendar
//
//  Created by Connor Krupp on 3/3/18.
//  Copyright © 2018 Connor Krupp. All rights reserved.
//

import UIKit

struct FlatColors {
    static let blue = #colorLiteral(red: 0.3098039216, green: 0.3333333333, blue: 0.9137254902, alpha: 1)
    static let purple = #colorLiteral(red: 0.6078431373, green: 0.3882352941, blue: 0.9176470588, alpha: 1)
    static let lightBlue = #colorLiteral(red: 0.3882352941, green: 0.9176470588, blue: 0.9137254902, alpha: 1)
    static let red = #colorLiteral(red: 0.9137254902, green: 0.3098039216, blue: 0.3803921569, alpha: 1)
    static let green = #colorLiteral(red: 0.2117647059, green: 0.7490196078, blue: 0.2784313725, alpha: 1)
    static let orange = #colorLiteral(red: 0.9647058824, green: 0.6588235294, blue: 0.1725490196, alpha: 1)
}

class Task: Codable {
    enum EventColor: String, Codable {
        case red
        case blue
        case lightBlue
        case green
        case orange

        var cgColor: CGColor {
            return uiColor.cgColor
        }

        var uiColor: UIColor {
            switch self {
            case .blue:
                return FlatColors.blue
            case .lightBlue:
                return FlatColors.lightBlue
            case .red:
                return FlatColors.red
            case .green:
                return FlatColors.green
            case .orange:
                return FlatColors.orange
            }
        }
    }


    struct WorkTimeInfo: Codable {
        let startDate: Date
        let duration: Int
    }

    let id = UUID()
    var workTime: WorkTimeInfo? = nil
    var name: String? = nil
    var subtitle: String? = nil
    var dueDate: Date? = nil
    var color: EventColor = EventColor.orange
    var isFromCalendar = false

    func offsetFrom(date other: Date) -> Time.Offset? {
        guard let workTime = self.workTime else { return nil }

        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: workTime.startDate)
        let otherComponents = Calendar.current.dateComponents([.day, .hour, .minute], from: other)

        let dayComponent = components.day
        let hourComponent = components.hour
        let minutesComponent = components.minute

        let otherDayComponent = otherComponents.day
        let otherHourComponent = otherComponents.hour
        let otherMinutesComponent = otherComponents.minute

        guard
            let day = dayComponent, let hour = hourComponent, let minutes = minutesComponent,
            let otherDay = otherDayComponent, let otherHour = otherHourComponent,
            let otherMinutes = otherMinutesComponent else { return nil }

        return Time.Offset(days: day - otherDay, hours: hour - otherHour, minutes: minutes - otherMinutes)
    }
}
