//
//  OnboardingView.swift
//  87CircuitLog
//

import SwiftUI

private let onboardingCompletedKey = "onboarding_completed"

enum OnboardingStorage {
    static var isCompleted: Bool {
        get { UserDefaults.standard.bool(forKey: onboardingCompletedKey) }
        set { UserDefaults.standard.set(newValue, forKey: onboardingCompletedKey) }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
}

struct OnboardingView: View {
    var onComplete: () -> Void

    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "square.grid.2x2.fill",
            title: "Track Your Habits",
            subtitle: "Create habits and tap to mark them done each day. Build streaks and stay consistent."
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "See Your Progress",
            subtitle: "View statistics, weekly completion, and when you complete habits — morning, afternoon, or evening."
        ),
        OnboardingPage(
            icon: "trophy.fill",
            title: "Earn Achievements",
            subtitle: "Unlock badges for streaks, perfect days, and more. Set goals and get motivated."
        )
    ]

    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appBackgroundDark, Color.appBackground, Color.appBackgroundLight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [Color.appAccent.opacity(0.1), Color.clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 500
            )
        }
        .ignoresSafeArea()
    }

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingPageView(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.25), value: currentPage)

                pageIndicator
                    .padding(.top, 24)

                Button {
                    if currentPage == pages.count - 1 {
                        OnboardingStorage.isCompleted = true
                        onComplete()
                    } else {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            currentPage += 1
                        }
                    }
                } label: {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.appBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appSuccess, Color.appSuccess.opacity(0.85)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color.appSuccess.opacity(0.4), radius: 8, x: 0, y: 2)
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 48)
            }
        }
    }

    private func onboardingPageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: page.icon)
                .font(.system(size: 72))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.appAccent, Color.appAccent.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.appAccent.opacity(0.3), radius: 12, x: 0, y: 4)
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                Text(page.subtitle)
                    .font(.body)
                    .foregroundColor(.appAccent.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
            Spacer()
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Circle()
                    .fill(currentPage == index ? Color.appAccent : Color.appAccent.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(currentPage == index ? 1.2 : 1)
            }
        }
    }
}
