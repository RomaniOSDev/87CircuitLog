//
//  ContentView.swift
//  87CircuitLog
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = HabitViewModel()
    @StateObject private var affirmationStore = AffirmationStore()
    @State private var showOnboarding = !OnboardingStorage.isCompleted

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showOnboarding = false
                    }
                }
            } else {
                mainTabView
            }
        }
    }

    private var mainTabView: some View {
        TabView {
            HomeView(viewModel: viewModel, affirmationStore: affirmationStore)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            StatsView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Statistics")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .tint(.appAccent)
        .background(Color.appBackground.ignoresSafeArea())
    }
}

#Preview {
    ContentView()
}
