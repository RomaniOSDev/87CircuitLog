//
//  Habit.swift
//  87CircuitLog
//
//  Created by Роман Главацкий on 09.02.2026.
//

import Foundation

/// Predefined categories for filtering and grouping habits.
enum HabitCategory: String, CaseIterable, Codable {
    case health = "Health"
    case learning = "Learning"
    case sport = "Sport"
    case sleep = "Sleep"
    case work = "Work"
    case other = "Other"
}

/// Goal type for a habit: streak of N days or N times per week.
enum HabitGoalType: String, CaseIterable, Codable {
    case none = "None"
    case streak = "Streak"
    case timesPerWeek = "Times per week"
}

struct Habit: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var iconName: String
    let creationDate: Date
    var completionDates: [Date]
    var category: HabitCategory
    var notes: String?
    var sortOrder: Int
    var isArchived: Bool
    var goalType: HabitGoalType
    var goalValue: Int

    enum CodingKeys: String, CodingKey {
        case id, name, iconName, creationDate, completionDates, category, notes, sortOrder, isArchived
        case goalType, goalValue
    }

    init(id: UUID, name: String, iconName: String, creationDate: Date, completionDates: [Date],
         category: HabitCategory = .other, notes: String? = nil, sortOrder: Int = 0, isArchived: Bool = false,
         goalType: HabitGoalType = .none, goalValue: Int = 0) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.creationDate = creationDate
        self.completionDates = completionDates
        self.category = category
        self.notes = notes
        self.sortOrder = sortOrder
        self.isArchived = isArchived
        self.goalType = goalType
        self.goalValue = goalValue
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        iconName = try c.decode(String.self, forKey: .iconName)
        creationDate = try c.decode(Date.self, forKey: .creationDate)
        completionDates = try c.decode([Date].self, forKey: .completionDates)
        category = (try? c.decode(HabitCategory.self, forKey: .category)) ?? .other
        notes = try c.decodeIfPresent(String.self, forKey: .notes)
        sortOrder = try c.decodeIfPresent(Int.self, forKey: .sortOrder) ?? 0
        isArchived = try c.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
        goalType = (try? c.decode(HabitGoalType.self, forKey: .goalType)) ?? .none
        goalValue = try c.decodeIfPresent(Int.self, forKey: .goalValue) ?? 0
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        let completedDays = Set(completionDates.map { $0.startOfDay(using: calendar) })
        var streak = 0
        var day = Date().startOfDay(using: calendar)

        while completedDays.contains(day) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: day) else {
                break
            }
            day = previousDay
        }

        return streak
    }

    /// Completions this week (current calendar week).
    func completionCountThisWeek(calendar: Calendar = .current) -> Int {
        let weekStart = Date().startOfWeek(using: calendar)
        return completionDates.filter { date in
            let d = date.startOfDay(using: calendar)
            return d >= weekStart && d < calendar.date(byAdding: .day, value: 7, to: weekStart)!
        }.count
    }

    /// Progress toward goal: (current, target) or nil if no goal.
    var goalProgress: (current: Int, target: Int)? {
        switch goalType {
        case .none:
            return nil
        case .streak:
            guard goalValue > 0 else { return nil }
            return (currentStreak, goalValue)
        case .timesPerWeek:
            guard goalValue > 0 else { return nil }
            return (completionCountThisWeek(), goalValue)
        }
    }

    var isGoalReached: Bool {
        guard let progress = goalProgress else { return false }
        return progress.current >= progress.target
    }

    func isCompleted(on date: Date) -> Bool {
        let calendar = Calendar.current
        let targetDay = date.startOfDay(using: calendar)
        return completionDates.contains { $0.startOfDay(using: calendar) == targetDay }
    }

    mutating func toggleCompletion(on date: Date) {
        let calendar = Calendar.current
        let targetDay = date.startOfDay(using: calendar)

        if let index = completionDates.firstIndex(where: { $0.startOfDay(using: calendar) == targetDay }) {
            completionDates.remove(at: index)
        } else {
            completionDates.append(date)
        }
    }
}
