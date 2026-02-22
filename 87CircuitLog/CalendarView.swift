//
//  CalendarView.swift
//  87CircuitLog
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: HabitViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var month = Date()
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    private var monthTitle: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: month)
    }

    private var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let first = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return []
        }
        let firstWeekday = calendar.component(.weekday, from: first) - 1
        var list: [Date?] = Array(repeating: nil, count: firstWeekday)
        for day in range {
            if let d = calendar.date(byAdding: .day, value: day - 1, to: first) {
                list.append(d)
            }
        }
        return list
    }

    private func isCompleted(_ date: Date) -> Bool {
        viewModel.activeHabits.contains { $0.isCompleted(on: date) }
    }

    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    private var calendarBackground: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appBackgroundDark, Color.appBackground, Color.appBackgroundLight],
                startPoint: .top,
                endPoint: .bottom
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

    var body: some View {
        NavigationStack {
            ZStack {
                calendarBackground
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Button {
                            if let newMonth = calendar.date(byAdding: .month, value: -1, to: month) {
                                month = newMonth
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.appAccent)
                        }
                        Spacer()
                        Text(monthTitle)
                            .font(.headline)
                            .foregroundColor(.appAccent)
                        Spacer()
                        Button {
                            if let newMonth = calendar.date(byAdding: .month, value: 1, to: month) {
                                month = newMonth
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.appAccent)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.appAccent.opacity(0.1), Color.appAccent.opacity(0.03)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.appAccent.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    .softShadow()

                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { w in
                            Text(w)
                                .font(.caption)
                                .foregroundColor(.appAccent.opacity(0.8))
                        }
                        ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                            if let date {
                                let completed = isCompleted(date)
                                let today = isToday(date)
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(
                                            completed
                                                ? LinearGradient(
                                                    colors: [Color.appSuccess.opacity(0.4), Color.appSuccess.opacity(0.2)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                                : LinearGradient(colors: [Color.clear], startPoint: .top, endPoint: .bottom)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .stroke(
                                                    today ? Color.appSuccess : Color.appAccent.opacity(0.4),
                                                    lineWidth: today ? 2 : 1
                                                )
                                        )
                                    Text("\(calendar.component(.day, from: date))")
                                        .font(.caption)
                                        .foregroundColor(.appAccent)
                                }
                                .aspectRatio(1, contentMode: .fit)
                                .shadow(color: completed ? Color.appSuccess.opacity(0.2) : .clear, radius: 4, x: 0, y: 1)
                            } else {
                                Color.clear
                                    .aspectRatio(1, contentMode: .fit)
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.appBackgroundLight.opacity(0.8),
                                        Color.appBackground,
                                        Color.appBackgroundDark.opacity(0.6)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.appAccent.opacity(0.4), Color.appAccent.opacity(0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .cardShadow()
                    .padding(.horizontal)

                    HStack(spacing: 16) {
                        HStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.appSuccess.opacity(0.3))
                                .frame(width: 20, height: 20)
                            Text("Completed day")
                                .font(.caption)
                                .foregroundColor(.appAccent)
                        }
                        HStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.appSuccess, lineWidth: 2)
                                .frame(width: 20, height: 20)
                            Text("Today")
                                .font(.caption)
                                .foregroundColor(.appAccent)
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                .padding(.top, 8)
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.appAccent)
                }
            }
        }
    }
}
