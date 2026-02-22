//
//  AffirmationStore.swift
//  87CircuitLog
//

import Foundation
import Combine
final class AffirmationStore: ObservableObject {
    private let key = "affirmations_list"

    @Published var items: [String] = [] {
        didSet {
            UserDefaults.standard.set(items, forKey: key)
        }
    }

    init() {
        if let list = UserDefaults.standard.array(forKey: key) as? [String] {
            items = list
        } else {
            items = [
                "I am capable of building better habits.",
                "Every small step counts.",
                "I choose progress over perfection.",
                "Today I will do my best."
            ]
            UserDefaults.standard.set(items, forKey: key)
        }
    }

    var random: String? {
        items.isEmpty ? nil : items.randomElement()
    }

    func add(_ text: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        items.append(t)
    }

    func remove(at index: Int) {
        guard index >= 0, index < items.count else { return }
        items.remove(at: index)
    }

    func update(at index: Int, text: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard index >= 0, index < items.count else { return }
        if t.isEmpty {
            items.remove(at: index)
        } else {
            items[index] = t
        }
    }
}
