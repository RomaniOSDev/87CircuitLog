//
//  HabitViewModel.swift
//  87CircuitLog
//
//  Created by Роман Главацкий on 09.02.2026.
//

import Foundation
import Combine
import SwiftUI

/// Основной ViewModel для управления привычками и сохранением данных.
final class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = [] {
        didSet {
            storage.save(habits)
            checkAchievements()
        }
    }

    @Published var goalReachedMessage: (habitName: String, goalText: String)?
    @Published var showGoalCelebration: Bool = false

    private let storage = HabitStorage()
    let achievementStore: AchievementStore

    init(achievementStore: AchievementStore = AchievementStore()) {
        self.achievementStore = achievementStore
        habits = storage.load()
        checkAchievements()
    }

    /// Active (non-archived) habits, sorted by sortOrder.
    var activeHabits: [Habit] {
        habits.filter { !$0.isArchived }.sorted { $0.sortOrder < $1.sortOrder }
    }

    /// Archived habits, sorted by sortOrder.
    var archivedHabits: [Habit] {
        habits.filter { $0.isArchived }.sorted { $0.sortOrder < $1.sortOrder }
    }

    func addHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
        } else {
            var newHabit = habit
            if newHabit.sortOrder == 0 {
                newHabit.sortOrder = (habits.map(\.sortOrder).max() ?? -1) + 1
            }
            habits.append(newHabit)
        }
    }

    func toggleHabit(for date: Date, habitId: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == habitId }) else { return }
        var habit = habits[index]
        let wasCompleted = habit.isCompleted(on: date)
        habit.toggleCompletion(on: date)
        habits[index] = habit
        if !wasCompleted && habit.isGoalReached {
            goalReachedMessage = (habit.name, goalDescription(for: habit))
            showGoalCelebration = true
        }
    }

    func toggleHabit(for date: Date, habit: Habit) {
        toggleHabit(for: date, habitId: habit.id)
    }

    func deleteHabit(at offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
    }

    func deleteHabit(id: UUID) {
        habits.removeAll { $0.id == id }
    }

    func archiveHabit(id: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return }
        habits[index].isArchived = true
    }

    func unarchiveHabit(id: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return }
        habits[index].isArchived = false
    }

    func moveHabit(from source: IndexSet, to destination: Int) {
        var list = activeHabits
        list.move(fromOffsets: source, toOffset: destination)
        for (offset, habit) in list.enumerated() {
            if let idx = habits.firstIndex(where: { $0.id == habit.id }) {
                habits[idx].sortOrder = offset
            }
        }
    }

    var completedTodayCount: Int {
        activeHabits.filter { $0.isCompleted(on: Date()) }.count
    }

    var remainingTodayCount: Int {
        max(activeHabits.count - completedTodayCount, 0)
    }

    var completionRatio: Double {
        guard activeHabits.isEmpty == false else { return 0 }
        return Double(completedTodayCount) / Double(activeHabits.count)
    }

    var topStreakHabits: [Habit] {
        activeHabits.sorted { $0.currentStreak > $1.currentStreak }.prefix(3).map { $0 }
    }

    // MARK: - Reset day

    func resetDay() {
        let calendar = Calendar.current
        let today = Date().startOfDay(using: calendar)
        for index in habits.indices {
            habits[index].completionDates.removeAll { calendar.isDate($0, inSameDayAs: today) }
        }
        checkAchievements()
    }

    var hasCompletionsToday: Bool {
        activeHabits.contains { $0.isCompleted(on: Date()) }
    }

    // MARK: - Weekly stats

    func weeklyCompletionCount(for habit: Habit) -> Int {
        habit.completionCountThisWeek()
    }

    var totalWeeklyCompletions: Int {
        activeHabits.reduce(0) { $0 + $1.completionCountThisWeek() }
    }

    func weeklyCompletionsByTimeOfDay(for habit: Habit) -> (morning: Int, afternoon: Int, evening: Int) {
        let calendar = Calendar.current
        let weekStart = Date().startOfWeek(using: calendar)
        var m = 0, a = 0, e = 0
        for date in habit.completionDates {
            guard date >= weekStart else { continue }
            guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart), date < weekEnd else { continue }
            switch date.timeOfDay(using: calendar) {
            case .morning: m += 1
            case .afternoon: a += 1
            case .evening: e += 1
            }
        }
        return (m, a, e)
    }

    func dismissGoalCelebration() {
        showGoalCelebration = false
        goalReachedMessage = nil
    }

    private func goalDescription(for habit: Habit) -> String {
        switch habit.goalType {
        case .none:
            return ""
        case .streak:
            return "\(habit.goalValue) days in a row!"
        case .timesPerWeek:
            return "\(habit.goalValue) times this week!"
        }
    }

    private func checkAchievements() {
        let active = activeHabits
        if active.contains(where: { $0.isCompleted(on: Date()) }) {
            achievementStore.unlock("first_completion")
        }
        for habit in active {
            if habit.currentStreak >= 3 { achievementStore.unlock("streak_3") }
            if habit.currentStreak >= 7 { achievementStore.unlock("streak_7") }
            if habit.currentStreak >= 30 { achievementStore.unlock("streak_30") }
        }
        if !active.isEmpty && active.allSatisfy({ $0.isCompleted(on: Date()) }) {
            achievementStore.unlock("all_today")
        }
        if habits.count >= 5 {
            achievementStore.unlock("habit_5")
        }
        for habit in active {
            for date in habit.completionDates {
                switch date.timeOfDay() {
                case .morning: achievementStore.unlock("early_bird"); break
                case .evening: achievementStore.unlock("night_owl"); break
                default: break
                }
            }
        }
        if !active.isEmpty {
            let cal = Calendar.current
            var day = Date().startOfDay(using: cal)
            var consecutivePerfect = 0
            for _ in 0..<7 {
                if active.allSatisfy({ $0.isCompleted(on: day) }) {
                    consecutivePerfect += 1
                } else {
                    break
                }
                day = cal.date(byAdding: .day, value: -1, to: day) ?? day
            }
            if consecutivePerfect >= 7 { achievementStore.unlock("week_perfect") }
        }
    }
}

private struct HabitStorage {
    private let key = "habits_storage_key"

    func load() -> [Habit] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([Habit].self, from: data)) ?? []
    }

    func save(_ habits: [Habit]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(habits) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
