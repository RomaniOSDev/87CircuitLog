//
//  HabitEditorView.swift
//  87CircuitLog
//
//  Created by Роман Главацкий on 09.02.2026.
//

import SwiftUI

struct HabitEditorView: View {
    @ObservedObject var viewModel: HabitViewModel
    let editingHabit: Habit?

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var iconName: String
    @State private var category: HabitCategory
    @State private var notes: String
    @State private var goalType: HabitGoalType
    @State private var goalValue: Int

    private let availableIcons = [
        "brain.head.profile", "laptopcomputer", "dumbbell", "book", "moon.stars",
        "heart.fill", "figure.run", "cup.and.saucer.fill", "leaf.fill", "paintbrush.fill",
        "music.note", "phone.fill", "envelope.fill", "gamecontroller.fill", "camera.fill",
        "lightbulb.fill", "pencil", "book.closed.fill", "graduationcap.fill", "briefcase.fill",
        "house.fill", "car.fill", "airplane", "tram.fill", "bicycle",
        "drop.fill", "snowflake", "sun.max.fill", "cloud.fill", "bolt.fill",
        "star.fill", "flag.fill", "gift.fill", "bell.fill", "clock.fill"
    ]

    private static let goalValueOptions = [3, 5, 7, 10]

    init(viewModel: HabitViewModel, editingHabit: Habit?) {
        self.viewModel = viewModel
        self.editingHabit = editingHabit
        _name = State(initialValue: editingHabit?.name ?? "")
        _iconName = State(initialValue: editingHabit?.iconName ?? "brain.head.profile")
        _category = State(initialValue: editingHabit?.category ?? .other)
        _notes = State(initialValue: editingHabit?.notes ?? "")
        _goalType = State(initialValue: editingHabit?.goalType ?? .none)
        _goalValue = State(initialValue: (editingHabit?.goalValue ?? 0) > 0 ? (editingHabit?.goalValue ?? 3) : 3)
    }

    private var editorBackground: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appBackgroundDark, Color.appBackground, Color.appBackgroundLight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [Color.appAccent.opacity(0.06), Color.clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 400
            )
        }
        .ignoresSafeArea()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                editorBackground

                VStack(alignment: .leading, spacing: 20) {
                    TextField(
                        "",
                        text: $name,
                        prompt: Text("Habit name").foregroundColor(.gray)
                    )
                    .padding(12)
                    .foregroundColor(.appAccent)
                    .tint(.appAccent)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.appBackgroundDark.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.appAccent.opacity(0.6), Color.appAccent.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .softShadow()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category")
                            .font(.headline)
                            .foregroundColor(.appAccent)
                        Picker("Category", selection: $category) {
                            ForEach(HabitCategory.allCases, id: \.self) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.appAccent)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Icon")
                            .font(.headline)
                            .foregroundColor(.appAccent)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(availableIcons, id: \.self) { icon in
                                    Button {
                                        iconName = icon
                                    } label: {
                                        Image(systemName: icon)
                                            .font(.title2)
                                            .foregroundColor(.appAccent)
                                            .frame(width: 44, height: 44)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [Color.appBackgroundLight.opacity(0.8), Color.appBackground],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .stroke(
                                                        iconName == icon ? Color.appSuccess : Color.appAccent.opacity(0.5),
                                                        lineWidth: iconName == icon ? 2 : 1
                                                    )
                                            )
                                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Goal (optional)")
                            .font(.headline)
                            .foregroundColor(.appAccent)
                        Picker("Goal type", selection: $goalType) {
                            ForEach(HabitGoalType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.appAccent)
                        if goalType != .none {
                            Picker("Target", selection: $goalValue) {
                                ForEach(Self.goalValueOptions, id: \.self) { n in
                                    Text(goalType == .streak ? "\(n) days" : "\(n) per week").tag(n)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.appAccent)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes (optional)")
                            .font(.headline)
                            .foregroundColor(.appAccent)
                        TextField(
                            "",
                            text: $notes,
                            prompt: Text("Add a short note").foregroundColor(.gray),
                            axis: .vertical
                        )
                        .lineLimit(3...6)
                        .padding(12)
                        .foregroundColor(.appAccent)
                        .tint(.appAccent)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.appBackgroundDark.opacity(0.5))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.appAccent.opacity(0.5), Color.appAccent.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .softShadow()
                    }

                    Spacer()

                    HStack(spacing: 12) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundColor(.appAccent)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.appAccent.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.appAccent.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .softShadow()

                        Button("Save") {
                            saveHabit()
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundColor(.appBackground)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appSuccess, Color.appSuccess.opacity(0.85)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: Color.appSuccess.opacity(0.4), radius: 8, x: 0, y: 2)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(20)
            }
            .navigationTitle(editingHabit == nil ? "New Habit" : "Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func saveHabit() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.isEmpty == false else { return }
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let notesValue = trimmedNotes.isEmpty ? nil : trimmedNotes

        let value = goalType == .none ? 0 : goalValue
        if let editingHabit {
            let updated = Habit(
                id: editingHabit.id,
                name: trimmedName,
                iconName: iconName,
                creationDate: editingHabit.creationDate,
                completionDates: editingHabit.completionDates,
                category: category,
                notes: notesValue,
                sortOrder: editingHabit.sortOrder,
                isArchived: editingHabit.isArchived,
                goalType: goalType,
                goalValue: value
            )
            viewModel.addHabit(updated)
        } else {
            let newHabit = Habit(
                id: UUID(),
                name: trimmedName,
                iconName: iconName,
                creationDate: Date(),
                completionDates: [],
                category: category,
                notes: notesValue,
                sortOrder: 0,
                isArchived: false,
                goalType: goalType,
                goalValue: value
            )
            viewModel.addHabit(newHabit)
        }
    }
}
