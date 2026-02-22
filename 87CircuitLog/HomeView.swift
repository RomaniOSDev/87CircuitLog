//
//  HomeView.swift
//  87CircuitLog
//

import SwiftUI

struct HomeView: View {
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

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 17 { return "Good afternoon" }
        return "Good evening"
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        progressSection
                        if let quote = affirmationStore.random, !quote.isEmpty {
                            affirmationCard(quote)
                        }
                        habitsSection
                    }
                    .padding(.bottom, 32)
                }
            }
            .searchable(text: $searchText, prompt: "Search habits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("CircuitLog")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.appAccent)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 8) {
                        Menu {
                            Button("All") { selectedCategory = nil }
                            ForEach(HabitCategory.allCases, id: \.self) { cat in
                                Button(cat.rawValue) { selectedCategory = cat }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.body)
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
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.appSuccess)
                        }
                    }
                }
            }
            .alert("Reset today?", isPresented: $showResetDayAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) { viewModel.resetDay() }
            } message: {
                Text("Remove all today's completions. This cannot be undone.")
            }
            .alert("Goal reached!", isPresented: $viewModel.showGoalCelebration) {
                Button("OK") { viewModel.dismissGoalCelebration() }
            } message: {
                if let msg = viewModel.goalReachedMessage {
                    Text("\(msg.habitName): \(msg.goalText)")
                }
            }
            .sheet(isPresented: $isEditorPresented) {
                HabitEditorView(viewModel: viewModel, editingHabit: editingHabit)
            }
            .sheet(isPresented: $isArchivePresented) { ArchiveView(viewModel: viewModel) }
            .sheet(isPresented: $showCalendar) { CalendarView(viewModel: viewModel) }
            .sheet(isPresented: $showAchievements) {
                AchievementsView(achievementStore: viewModel.achievementStore)
            }
            .sheet(isPresented: $showAffirmations) {
                AffirmationsView(store: affirmationStore)
            }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.appBackgroundDark,
                    Color.appBackground,
                    Color.appBackgroundLight,
                    Color.appBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [
                    Color.appAccent.opacity(0.08),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 400
            )
        }
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greeting)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white.opacity(0.98), .white.opacity(0.88)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            Text(Self.dateFormatter.string(from: Date()))
                .font(.subheadline)
                .foregroundColor(.appAccent.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Progress ring

    private var progressSection: some View {
        let total = viewModel.activeHabits.count
        let completed = viewModel.completedTodayCount
        let ratio = total > 0 ? CGFloat(completed) / CGFloat(total) : 0

        return HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.appAccent.opacity(0.2), lineWidth: 6)
                    .frame(width: 72, height: 72)
                Circle()
                    .trim(from: 0, to: ratio)
                    .stroke(
                        completed == total && total > 0
                            ? LinearGradient(
                                colors: [Color.appSuccess, Color.appSuccess.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                colors: [Color.appAccent, Color.appAccent.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 72, height: 72)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: ratio)
                Text(total > 0 ? "\(completed)" : "0")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .shadow(color: (completed == total && total > 0 ? Color.appSuccess : Color.appAccent).opacity(0.3), radius: 8, x: 0, y: 0)
            VStack(alignment: .leading, spacing: 4) {
                Text("Today's progress")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.appAccent.opacity(0.9))
                Text(total > 0 ? "\(completed) of \(total) habits completed" : "Add habits to start")
                    .font(.caption)
                    .foregroundColor(.appAccent.opacity(0.7))
            }
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appAccent.opacity(0.12),
                            Color.appAccent.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
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
        .cardShadow()
        .padding(.horizontal, 20)
    }

    // MARK: - Affirmation card

    private func affirmationCard(_ quote: String) -> some View {
        Button {
            showAffirmations = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "quote.opening")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.appSuccess, Color.appSuccess.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                Text(quote)
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(.appAccent.opacity(0.95))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.appAccent.opacity(0.6))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appSuccess.opacity(0.12),
                                Color.appSuccess.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.appSuccess.opacity(0.4), Color.appSuccess.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .softShadow()
        .glowShadow(color: .appSuccess)
        .padding(.horizontal, 20)
    }

    // MARK: - Habits grid

    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Today's habits")
                    .font(.headline)
                    .foregroundColor(.appAccent)
                Spacer()
                if selectedCategory != nil {
                    Button("Clear filter") {
                        selectedCategory = nil
                    }
                    .font(.caption)
                    .foregroundColor(.appSuccess)
                }
            }
            .padding(.horizontal, 4)

            if displayedHabits.isEmpty {
                emptyHabitsPlaceholder
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 14),
                    GridItem(.flexible(), spacing: 14)
                ], spacing: 14) {
                    ForEach(displayedHabits) { habit in
                        HabitCardView(
                            habit: habit,
                            onEdit: {
                                editingHabit = habit
                                isEditorPresented = true
                            },
                            onArchive: { viewModel.archiveHabit(id: habit.id) },
                            onTapToToggle: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.toggleHabit(for: Date(), habit: habit)
                                }
                            }
                        )
                        .contextMenu {
                            Button("Edit") {
                                editingHabit = habit
                                isEditorPresented = true
                            }
                            Button("Archive") { viewModel.archiveHabit(id: habit.id) }
                            Button("Delete", role: .destructive) { viewModel.deleteHabit(id: habit.id) }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var emptyHabitsPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.circle.dashed")
                .font(.system(size: 44))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.appAccent.opacity(0.6), Color.appAccent.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            Text("No habits yet")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.appAccent.opacity(0.8))
            Text("Tap + to add your first habit")
                .font(.caption)
                .foregroundColor(.appAccent.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appAccent.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.appAccent.opacity(0.3), Color.appAccent.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 1.5, dash: [8])
                        )
                )
        )
        .softShadow()
    }
}

#Preview {
    HomeView(
        viewModel: HabitViewModel(),
        affirmationStore: AffirmationStore()
    )
}
