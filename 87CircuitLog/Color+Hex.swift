//
//  Color+Hex.swift
//  87CircuitLog
//

import SwiftUI

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let red = Double((value >> 16) & 0xFF) / 255.0
        let green = Double((value >> 8) & 0xFF) / 255.0
        let blue = Double(value & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }

    static let appBackground = Color(hex: "1A2C38")
    static let appAccent = Color(hex: "1475E1")
    static let appSuccess = Color(hex: "16FF16")
    static let appBackgroundLight = Color(hex: "1E3544")
    static let appBackgroundDark = Color(hex: "0F1A22")
}

// MARK: - Card shadows & volume

extension View {
    /// Объёмная тень для карточек (глубина).
    func cardShadow() -> some View {
        self
            .shadow(color: .black.opacity(0.45), radius: 12, x: 0, y: 6)
            .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
    }

    /// Мягкая тень для приподнятых элементов.
    func softShadow() -> some View {
        self
            .shadow(color: Color.appAccent.opacity(0.15), radius: 8, x: 0, y: 4)
            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
    }

    /// Лёгкое свечение для акцентных карточек.
    func glowShadow(color: Color = .appSuccess) -> some View {
        self.shadow(color: color.opacity(0.35), radius: 10, x: 0, y: 0)
    }
}
