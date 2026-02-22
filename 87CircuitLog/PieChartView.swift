//
//  PieChartView.swift
//  87CircuitLog
//
//  Created by Роман Главацкий on 09.02.2026.
//

import SwiftUI

struct PieChartView: View {
    let completed: Int
    let total: Int

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let rect = CGRect(x: 0, y: 0, width: size, height: size)

            ZStack {
                if total == 0 {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.appAccent.opacity(0.8), Color.appAccent.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                } else {
                    slice(
                        in: rect,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(-90 + completedAngle)
                    )
                    .fill(
                        LinearGradient(
                            colors: [Color.appSuccess, Color.appSuccess.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.appSuccess.opacity(0.4), radius: 6, x: 0, y: 0)

                    slice(
                        in: rect,
                        startAngle: .degrees(-90 + completedAngle),
                        endAngle: .degrees(270)
                    )
                    .fill(
                        LinearGradient(
                            colors: [Color.appAccent.opacity(0.9), Color.appAccent.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
            }
            .frame(width: size, height: size, alignment: .center)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var completedAngle: Double {
        guard total > 0 else { return 0 }
        return (Double(completed) / Double(total)) * 360
    }

    private func slice(in rect: CGRect, startAngle: Angle, endAngle: Angle) -> Path {
        Path { path in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = rect.width / 2

            path.move(to: center)
            path.addArc(
                center: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
            path.closeSubpath()
        }
    }
}
