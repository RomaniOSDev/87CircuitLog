//
//  Date+Helpers.swift
//  87CircuitLog
//
//  Created by Роман Главацкий on 09.02.2026.
//

import Foundation

/// Time of day for analytics (derived from hour).
enum TimeOfDay: String, CaseIterable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"

    static func from(date: Date, calendar: Calendar = .current) -> TimeOfDay {
        let hour = calendar.component(.hour, from: date)
        if hour < 12 { return .morning }
        if hour < 17 { return .afternoon }
        return .evening
    }
}

extension Date {
    func startOfDay(using calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: self)
    }

    func startOfWeek(using calendar: Calendar = .current) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    func timeOfDay(using calendar: Calendar = .current) -> TimeOfDay {
        TimeOfDay.from(date: self, calendar: calendar)
    }
}
