//
//  HabitDashboardView.swift
//  87CircuitLog
//
//  Created by Роман Главацкий on 09.02.2026.
//

import SwiftUI

struct HabitDashboardView: View {
    @ObservedObject var viewModel: HabitViewModel
    @ObservedObject var affirmationStore: AffirmationStore
    @State private var isEditorPresented = false
    @State private var editingHabit: Habit?
    @State private var selectedCategory: HabitCategory?
    @State private var isArchivePresented = false
    @State private var searchText = ""
    @State private var showResetDayAlert = false
    @State private var showCalendar = false
    @State private var showAchievements = false
    @State private var showAffirmations = false

    private var displayedHabits: [Habit] {
        var list = viewModel.activeHabits
        if let category = selectedCategory {
            list = list.filter { $0.category == category }
        }
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let q = searchText.lowercased()
            list = list.filter {
                $0.name.lowercased().contains(q) ||
                ($0.notes?.lowercased().contains(q) ?? false)
            }
        }
        return list
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    if let quote = affirmationStore.random, !quote.isEmpty {
                        Button {
                            showAffirmations = true
                        } label: {
                            Text(quote)
                                .font(.subheadline)
                                .foregroundColor(.appAccent.opacity(0.9))
                                .italic()
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                        .background(Color.appAccent.opacity(0.08))
                    }

                List {
                    ForEach(displayedHabits) { habit in
                        HabitCardView(
                            habit: habit,
                            onEdit: {
                                editingHabit = habit
                                isEditorPresented = true
                            },
                            onArchive: {
                                viewModel.archiveHabit(id: habit.id)
                            },
                            onTapToToggle: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.toggleHabit(for: Date(), habit: habit)
                                }
                            }
                        )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .contextMenu {
                                Button("Edit") {
                                    editingHabit = habit
                                    isEditorPresented = true
                                }
                                Button("Archive") {
                                    viewModel.archiveHabit(id: habit.id)
                                }
                                Button("Delete", role: .destructive) {
                                    viewModel.deleteHabit(id: habit.id)
                                }
                            }
                    }
                    .onMove { source, destination in
                                if selectedCategory == nil {
                                    viewModel.moveHabit(from: source, to: destination)
                                }
                            }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                }
            }
            .searchable(text: $searchText, prompt: "Search habits")
            .navigationTitle("Habit Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 12) {
                        Menu {
                            Button("All") { selectedCategory = nil }
                            ForEach(HabitCategory.allCases, id: \.self) { category in
                                Button(category.rawValue) { selectedCategory = category }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .foregroundColor(.appAccent)
                        }
                        Button {
                            showCalendar = true
                        } label: {
                            Image(systemName: "calendar")
                                .foregroundColor(.appAccent)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        if viewModel.hasCompletionsToday {
                            Button {
                                showResetDayAlert = true
                            } label: {
                                Image(systemName: "arrow.uturn.backward.circle")
                                    .foregroundColor(.appAccent)
                            }
                        }
                        Button {
                            showAchievements = true
                        } label: {
                            Image(systemName: "trophy")
                                .foregroundColor(.appAccent)
                        }
                        Button {
                            isArchivePresented = true
                        } label: {
                            Image(systemName: "archivebox")
                                .foregroundColor(.appAccent)
                        }
                        Button {
                            editingHabit = nil
                            isEditorPresented = true
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.appAccent)
                        }
                    }
                }
            }
            .alert("Reset today?", isPresented: $showResetDayAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    viewModel.resetDay()
                }
            } message: {
                Text("Remove all today's completions. This cannot be undone.")
            }
            .alert("Goal reached!", isPresented: $viewModel.showGoalCelebration) {
                Button("OK") {
                    viewModel.dismissGoalCelebration()
                }
            } message: {
                if let msg = viewModel.goalReachedMessage {
                    Text("\(msg.habitName): \(msg.goalText)")
                }
            }
            .sheet(isPresented: $isEditorPresented) {
                HabitEditorView(viewModel: viewModel, editingHabit: editingHabit)
            }
            .sheet(isPresented: $isArchivePresented) {
                ArchiveView(viewModel: viewModel)
            }
            .sheet(isPresented: $showCalendar) {
                CalendarView(viewModel: viewModel)
            }
            .sheet(isPresented: $showAchievements) {
                AchievementsView(achievementStore: viewModel.achievementStore)
            }
            .sheet(isPresented: $showAffirmations) {
                AffirmationsView(store: affirmationStore)
            }
        }
    }
}

// MARK: - Archive

struct ArchiveView: View {
    @ObservedObject var viewModel: HabitViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var editingHabit: Habit?
    @State private var isEditorPresented = false

    private var archiveBackground: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appBackgroundDark, Color.appBackground, Color.appBackgroundLight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [Color.appAccent.opacity(0.05), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 350
            )
        }
        .ignoresSafeArea()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                archiveBackground
                if viewModel.archivedHabits.isEmpty {
                    Text("No archived habits")
                        .foregroundColor(.appAccent)
                } else {
                    List {
                        ForEach(viewModel.archivedHabits) { habit in
                            HStack(spacing: 12) {
                                Image(systemName: habit.iconName)
                                    .foregroundColor(.appAccent)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(habit.name)
                                        .foregroundColor(.appAccent)
                                    Text(habit.category.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                HStack(spacing: 12) {
                                    Button {
                                        editingHabit = habit
                                        isEditorPresented = true
                                    } label: {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.appAccent)
                                    }
                                    Button("Restore") {
                                        viewModel.unarchiveHabit(id: habit.id)
                                    }
                                    .foregroundColor(.appSuccess)
                                }
                            }
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.appBackgroundLight.opacity(0.6), Color.appBackground.opacity(0.9)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .padding(.vertical, 4)
                            )
                            .listRowSeparatorTint(.appAccent.opacity(0.3))
                        }
                        .onDelete { offsets in
                            let ids = offsets.map { viewModel.archivedHabits[$0].id }
                            ids.forEach { viewModel.deleteHabit(id: $0) }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Archive")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.appAccent)
                }
            }
            .sheet(isPresented: $isEditorPresented) {
                HabitEditorView(viewModel: viewModel, editingHabit: editingHabit)
            }
        }
    }
}
