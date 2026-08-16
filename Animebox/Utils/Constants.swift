//
//  Constants.swift
//  Animebox
//

import SwiftUI

enum AppColors {
    static let primary = Color(hex: "#6366F1")
    static let secondary = Color(hex: "#8B5CF6")
    static let accent = Color(hex: "#EC4899")
    static let background = Color(hex: "#0F172A")
    static let cardBackground = Color(hex: "#1E293B")
    static let textPrimary = Color(hex: "#F1F5F9")
    static let textSecondary = Color(hex: "#94A3B8")
}

enum AppSpacing {
    static let microSpacing: Double = 4
    static let compactSpacing: Double = 8
    static let itemSpacing: Double = 12
    static let padding: Double = 16
    static let sectionSpacing: Double = 24
    static let cornerRadius: Double = 12
}

nonisolated enum APIConfig {
    static let jikanBaseURL = URL(string: "https://api.jikan.moe/v4")!
    static let requestTimeout: TimeInterval = 30
    static let searchDebounceMilliseconds: UInt64 = 300
}

extension Color {
    init(hex: String) {
        let trimmed = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: trimmed).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
