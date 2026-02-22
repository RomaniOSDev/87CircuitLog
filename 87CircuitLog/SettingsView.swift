//
//  SettingsView.swift
//  87CircuitLog
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    private var backgroundGradient: some View {
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
                backgroundGradient
                ScrollView {
                    VStack(spacing: 16) {
                        settingsRow(
                            icon: "star.fill",
                            title: "Rate Us",
                            subtitle: "Enjoying CircuitLog? Leave a review."
                        ) {
                            rateApp()
                        }
                        settingsRow(
                            icon: "lock.shield.fill",
                            title: "Privacy Policy",
                            subtitle: "How we handle your data."
                        ) {
                            openURL("https://www.termsfeed.com/live/7709fb6a-ea31-4877-8feb-7cba28b2c98d")
                        }
                        settingsRow(
                            icon: "doc.text.fill",
                            title: "Terms of Use",
                            subtitle: "Terms and conditions."
                        ) {
                            openURL("https://www.termsfeed.com/live/e5747c39-238a-488d-9680-70f4e732b9e8")
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func settingsRow(
        icon: String,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.appAccent)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.appAccent.opacity(0.12))
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.appAccent)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.appAccent.opacity(0.7))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.appAccent.opacity(0.5))
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
            .softShadow()
        }
        .buttonStyle(.plain)
    }

    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
