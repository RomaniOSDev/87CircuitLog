//
//  HabitCardView.swift
//  87CircuitLog
//
//  Created by Роман Главацкий on 09.02.2026.
//

import SwiftUI

struct HabitCardView: View {
    let habit: Habit
    var onEdit: (() -> Void)?
    var onArchive: (() -> Void)?
    var onTapToToggle: (() -> Void)?

    var body: some View {
        let isCompletedToday = habit.isCompleted(on: Date())

        VStack(alignment: .leading, spacing: 12) {
            // Header: buttons here must not be covered by toggle tap
            HStack {
                Image(systemName: habit.iconName)
                    .font(.title2)
                    .foregroundColor(.appAccent)
                Spacer()
                if onEdit != nil || onArchive != nil {
                    HStack(spacing: 8) {
                        if let onEdit {
                            Button(action: onEdit) {
                                Image(systemName: "pencil")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.appAccent)
                            }
                            .buttonStyle(.plain)
                        }
                        if let onArchive {
                            Button(action: onArchive) {
                                Image(systemName: "archivebox")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.appAccent)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                Text(habit.category.rawValue)
                    .font(.caption2)
                    .foregroundColor(.appAccent.opacity(0.9))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(Color.appAccent.opacity(0.6), lineWidth: 1)
                    )
                Text("🔥 \(habit.currentStreak)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.appSuccess)
            }

            if let progress = habit.goalProgress {
                HStack(spacing: 4) {
                    Text("\(progress.current)/\(progress.target)")
                        .font(.caption)
                        .foregroundColor(habit.isGoalReached ? Color.appSuccess : .appAccent.opacity(0.9))
                    if habit.isGoalReached {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.appSuccess)
                    }
                }
            }

            // Toggle area: only this part reacts to tap for completion
            VStack(alignment: .leading, spacing: 12) {
                Text(habit.name)
                    .font(.headline)
                    .foregroundColor(.appAccent)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                if let notes = habit.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.appAccent.opacity(0.8))
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Circle()
                    .fill(
                        isCompletedToday
                            ? LinearGradient(
                                colors: [Color.appSuccess, Color.appSuccess.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom)
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                isCompletedToday
                                    ? Color.appSuccess.opacity(0.5)
                                    : Color.appAccent,
                                lineWidth: 2
                            )
                    )
                    .shadow(color: isCompletedToday ? Color.appSuccess.opacity(0.5) : .clear, radius: 6, x: 0, y: 0)
                    .frame(width: 52, height: 52)
                    .scaleEffect(isCompletedToday ? 1.05 : 0.95)
            }
            .frame(maxWidth: .infinity, minHeight: 0, alignment: .topLeading)
            .contentShape(Rectangle())
            .onTapGesture {
                onTapToToggle?()
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appBackgroundLight,
                            Color.appBackground,
                            Color.appBackgroundDark.opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.appAccent.opacity(0.6),
                                    Color.appAccent.opacity(0.25)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)
        .shadow(color: Color.appAccent.opacity(isCompletedToday ? 0.2 : 0.08), radius: isCompletedToday ? 6 : 2, x: 0, y: 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCompletedToday)
    }
}
