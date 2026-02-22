//
//  AchievementsView.swift
//  87CircuitLog
//

import SwiftUI

struct AchievementsView: View {
    @ObservedObject var achievementStore: AchievementStore
    @Environment(\.dismiss) private var dismiss

    private var achievementsBackground: some View {
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
                achievementsBackground
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Achievement.all) { achievement in
                            let unlocked = achievementStore.isUnlocked(achievement.id)
                            HStack(spacing: 16) {
                                Image(systemName: achievement.iconName)
                                    .font(.title2)
                                    .foregroundColor(unlocked ? .appSuccess : .appAccent.opacity(0.4))
                                    .frame(width: 44, height: 44)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(achievement.title)
                                        .font(.headline)
                                        .foregroundColor(.appAccent)
                                    Text(achievement.description)
                                        .font(.caption)
                                        .foregroundColor(.appAccent.opacity(0.8))
                                }
                                Spacer()
                                if unlocked {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.appSuccess)
                                        .shadow(color: Color.appSuccess.opacity(0.4), radius: 4, x: 0, y: 0)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.appBackgroundLight.opacity(0.9),
                                                Color.appBackground,
                                                Color.appBackgroundDark.opacity(0.7)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(
                                                unlocked
                                                    ? Color.appSuccess.opacity(0.4)
                                                    : Color.appAccent.opacity(0.3),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .softShadow()
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Achievements")
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
