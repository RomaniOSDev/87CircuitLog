//
//  StatsView.swift
//  87CircuitLog
//
//  Created by Роман Главацкий on 09.02.2026.
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: HabitViewModel

    private var statsBackground: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appBackgroundDark, Color.appBackground, Color.appBackgroundLight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [Color.appAccent.opacity(0.06), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 350
            )
        }
        .ignoresSafeArea()
    }

    private func statsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appBackgroundLight.opacity(0.9),
                                Color.appBackground,
                                Color.appBackgroundDark.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.appAccent.opacity(0.5), Color.appAccent.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .cardShadow()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                statsBackground

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        statsCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Today Completion")
                                    .font(.headline)
                                    .foregroundColor(.appAccent)

                                PieChartView(
                                    completed: viewModel.completedTodayCount,
                                    total: viewModel.completedTodayCount + viewModel.remainingTodayCount
                                )
                                .frame(height: 180)

                                HStack {
                                    Label(
                                        "Completed \(viewModel.completedTodayCount)",
                                        systemImage: "checkmark.circle.fill"
                                    )
                                    .foregroundColor(.appSuccess)

                                    Spacer()

                                    Label(
                                        "Remaining \(viewModel.remainingTodayCount)",
                                        systemImage: "circle"
                                    )
                                    .foregroundColor(.appAccent)
                                }
                                .font(.subheadline)
                            }
                        }

                        statsCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("This Week")
                                    .font(.headline)
                                    .foregroundColor(.appAccent)
                                Text("Total completions: \(viewModel.totalWeeklyCompletions)")
                                    .font(.subheadline)
                                    .foregroundColor(.appAccent)
                                if !viewModel.activeHabits.isEmpty {
                                    ForEach(viewModel.activeHabits) { habit in
                                        let count = viewModel.weeklyCompletionCount(for: habit)
                                        let goalText = habit.goalType == .timesPerWeek && habit.goalValue > 0
                                            ? " / \(habit.goalValue) goal"
                                            : ""
                                        HStack(spacing: 12) {
                                            Image(systemName: habit.iconName)
                                                .foregroundColor(.appAccent)
                                            Text(habit.name)
                                                .foregroundColor(.appAccent)
                                                .lineLimit(1)
                                            Spacer()
                                            Text("\(count)\(goalText)")
                                                .foregroundColor(.appSuccess)
                                                .font(.subheadline)
                                        }
                                        .padding(8)
                                    }
                                }
                            }
                        }

                        statsCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Time of Day (this week)")
                                    .font(.headline)
                                    .foregroundColor(.appAccent)
                                HStack(spacing: 16) {
                                    timeOfDayLabel("Morning", viewModel.activeHabits.map { viewModel.weeklyCompletionsByTimeOfDay(for: $0).morning }.reduce(0, +))
                                    timeOfDayLabel("Afternoon", viewModel.activeHabits.map { viewModel.weeklyCompletionsByTimeOfDay(for: $0).afternoon }.reduce(0, +))
                                    timeOfDayLabel("Evening", viewModel.activeHabits.map { viewModel.weeklyCompletionsByTimeOfDay(for: $0).evening }.reduce(0, +))
                                }
                            }
                        }

                        statsCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Top Streaks")
                                    .font(.headline)
                                    .foregroundColor(.appAccent)

                                if viewModel.topStreakHabits.isEmpty {
                                    Text("No streaks yet")
                                        .foregroundColor(.appAccent)
                                        .font(.subheadline)
                                } else {
                                    ForEach(viewModel.topStreakHabits) { habit in
                                        HStack(spacing: 12) {
                                            Image(systemName: habit.iconName)
                                                .foregroundColor(.appAccent)
                                            Text(habit.name)
                                                .foregroundColor(.appAccent)
                                                .lineLimit(1)
                                            Spacer()
                                            Text("🔥 \(habit.currentStreak)")
                                                .foregroundColor(.appSuccess)
                                                .font(.subheadline.weight(.semibold))
                                        }
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.appAccent.opacity(0.08), Color.appAccent.opacity(0.02)],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(Color.appAccent.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Statistics")
        }
    }

    private func timeOfDayLabel(_ title: String, _ count: Int) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2.weight(.semibold))
                .foregroundColor(.appSuccess)
            Text(title)
                .font(.caption)
                .foregroundColor(.appAccent)
        }
        .frame(maxWidth: .infinity)
    }
}
