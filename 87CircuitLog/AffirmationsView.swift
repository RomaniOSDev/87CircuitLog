//
//  AffirmationsView.swift
//  87CircuitLog
//

import SwiftUI

struct AffirmationsView: View {
    @ObservedObject var store: AffirmationStore
    @Environment(\.dismiss) private var dismiss
    @State private var newText = ""

    private var affirmationsBackground: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appBackgroundDark, Color.appBackground, Color.appBackgroundLight],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [Color.appSuccess.opacity(0.05), Color.clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 350
            )
        }
        .ignoresSafeArea()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                affirmationsBackground
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        TextField("New affirmation", text: $newText)
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
                        Button {
                            store.add(newText)
                            newText = ""
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.appSuccess, Color.appSuccess.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.appSuccess.opacity(0.4), radius: 6, x: 0, y: 0)
                        }
                        .disabled(newText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.horizontal)

                    Text("Tap one to show on dashboard. Add your own below.")
                        .font(.caption)
                        .foregroundColor(.appAccent.opacity(0.8))
                        .padding(.horizontal)

                    List {
                        ForEach(Array(store.items.enumerated()), id: \.offset) { index, text in
                            Text(text)
                                .foregroundColor(.appAccent)
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.appBackgroundLight.opacity(0.5), Color.appBackground.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .listRowSeparatorTint(.appAccent.opacity(0.3))
                        }
                        .onDelete { offsets in
                            for i in offsets.sorted(by: >) {
                                store.remove(at: i)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
                .padding(.top, 8)
            }
            .navigationTitle("Affirmations")
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
