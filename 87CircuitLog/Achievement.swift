//
//  Achievement.swift
//  87CircuitLog
//

import Foundation
import Combine

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String

    static let all: [Achievement] = [
        Achievement(id: "first_completion", title: "First Step", description: "Complete a habit for the first time", iconName: "star.fill"),
        Achievement(id: "streak_3", title: "On Fire", description: "3-day streak on any habit", iconName: "flame.fill"),
        Achievement(id: "streak_7", title: "Week Warrior", description: "7-day streak on any habit", iconName: "flame.circle.fill"),
        Achievement(id: "streak_30", title: "Unstoppable", description: "30-day streak on any habit", iconName: "crown.fill"),
        Achievement(id: "all_today", title: "Perfect Day", description: "Complete all habits in one day", iconName: "checkmark.circle.fill"),
        Achievement(id: "week_perfect", title: "Perfect Week", description: "Complete all habits every day for a week", iconName: "calendar.badge.checkmark"),
        Achievement(id: "habit_5", title: "Dedicated", description: "Create 5 habits", iconName: "square.stack.3d.up.fill"),
        Achievement(id: "early_bird", title: "Early Bird", description: "Complete a habit in the morning", iconName: "sunrise.fill"),
        Achievement(id: "night_owl", title: "Night Owl", description: "Complete a habit in the evening", iconName: "moon.stars.fill")
    ]
}

final class AchievementStore: ObservableObject {
    @Published var unlockedIds: Set<String> = [] {
        didSet {
            let array = Array(unlockedIds)
            UserDefaults.standard.set(array, forKey: "achievements_unlocked")
        }
    }

    init() {
        if let array = UserDefaults.standard.array(forKey: "achievements_unlocked") as? [String] {
            unlockedIds = Set(array)
        }
    }

    func unlock(_ id: String) {
        guard !unlockedIds.contains(id) else { return }
        unlockedIds.insert(id)
    }

    func isUnlocked(_ id: String) -> Bool {
        unlockedIds.contains(id)
    }
}
